import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/TrainingParser.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Step.dart' as breathing_phase;
import 'package:respire/services/SoundManagers/SoundManager.dart';
import 'package:respire/services/TextToSpeechService.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class TrainingController {
  Timer? _timer;
  final TrainingParser parser;
  final ValueNotifier<Queue<breathing_phase.BreathingPhase?>> breathingPhasesQueue =
      ValueNotifier(Queue<breathing_phase.BreathingPhase?>());
  final Queue<String?> _breathingPhaseNameQueue = Queue<String?>();
  final ValueNotifier<int> second = ValueNotifier(3);
  final ValueNotifier<bool> isPaused = ValueNotifier(false);
  final ValueNotifier<int> breathingPhasesCount = ValueNotifier(0);
  final ValueNotifier<String> currentBreathingPhaseName = ValueNotifier('');

  final int _updateInterval = 100; //in milliseconds
  final int _breathingPhaseDelayDuration = 600; //in milliseconds

  int _remainingTime = 0; //in milliseconds
  int _nextRemainingTime = 0; //in milliseconds
  int _newBreathingPhaseRemainingTime = 0; //in milliseconds

  int _breathingPhaseDelayRemainingTime = 600; //in milliseconds

  bool end = false;
  bool _finishedLoadingSteps = false;
  bool _breathingPhaseDelay = true;
  int _stopTimer = 2;

  late Sounds _sounds;

  String? _currentSound;
  late SoundManager soundManager;

  TranslationProvider translationProvider = TranslationProvider();

  TrainingController(this.parser) {
    soundManager = SoundManager();
    soundManager.stopAllSounds();
    _remainingTime = parser.training.settings.preparationDuration * 1000;
    _sounds = parser.training.sounds;
    _preloadBreathingPhases();
    _start();
  }

  void _preloadBreathingPhases() {
    breathingPhasesQueue.value.add(null);
    _breathingPhaseNameQueue.add(null);
    _updateCurrentBreathingPhaseLabel();
    _fetchNextBreathingPhase();
    _nextRemainingTime = _newBreathingPhaseRemainingTime;
    _fetchNextBreathingPhase();
  }

  void _fetchNextBreathingPhase() {
    var instructionData = parser.nextInstruction();
    if (instructionData == null) {
      _finishedLoadingSteps = true;
      breathingPhasesQueue.value.add(null);
      _breathingPhaseNameQueue.add(null);
      return;
    }
    breathingPhasesQueue.value.add(instructionData["breathingPhase"]);
    _breathingPhaseNameQueue.add(_resolveBreathingPhaseName(
        instructionData["breathingPhaseName"] as String?, parser.breathingPhaseID));
    _newBreathingPhaseRemainingTime = instructionData["remainingTime"];
  }

  void pause() {
    isPaused.value = true;
    if (_currentSound != null) {
      SoundManager().pauseSound(_currentSound!);
    }
    _timer?.cancel();
  }

  void resume() {
    isPaused.value = false;
    if (_currentSound != null) {
      SoundManager().playSound(_currentSound!);
    }
    _start();
  }


  void _playCountingSound(previousSecond) {
    switch (_sounds.countingSound.type) {
      case SoundType.voice:
        TextToSpeechService().readNumber(previousSecond + 1);
        break;
      case SoundType.none:
        break;
      default:
        soundManager.playSound(_sounds.countingSound.path);
        break;
    }
  }

  void _playPreBreathingPhaseSound(breathing_phase.BreathingPhase breathingPhase) {
    String? sound = breathingPhase.sounds.preBreathingPhase;
    switch (sound) {
      case "Voice":
        String breathingPhaseName =
            translationProvider.getTranslation("BreathingPhaseType.${breathingPhase.breathingPhaseType.name}");
        TextToSpeechService().speak(breathingPhaseName);
        break;
      case "None":
        break;
      default:
        soundManager.playSound(sound);
        Future.delayed(const Duration(seconds: 1), () {
          soundManager.stopSound(sound);
        });
        break;
    }
  }

  Future<void> _handleBackgroundSoundChange(String? nextBackgroundSound, String? currentBackgroundSound, int changeTime) async {
    if (currentBackgroundSound != nextBackgroundSound) {
      await soundManager.pauseSoundFadeOut(currentBackgroundSound,changeTime);
      soundManager.playSoundFadeIn(nextBackgroundSound, changeTime);
    }
  }

  void _start() {
    int previousSecond = _remainingTime ~/ 1000;
    DateTime lastTick = DateTime.now();
    String? currentBackgroundSound = _sounds.preparationTrack.path;
    soundManager.playSound(currentBackgroundSound);
    _timer =
        Timer.periodic(Duration(milliseconds: _updateInterval), (Timer timer) {
      final now = DateTime.now();
      final int elapsed = now.difference(lastTick).inMilliseconds;
      lastTick = now;

      // voice countdown (only when decreasing full second)
      if (previousSecond > _remainingTime ~/ 1000 && !end) {
        previousSecond = _remainingTime ~/ 1000;
        second.value = previousSecond + 1;
        _playCountingSound(previousSecond);
      }

      // time update using real elapsed time to reduce drift
      if (_remainingTime > elapsed) {
        _remainingTime -= elapsed;
      } else if (_remainingTime > 0) {
        _remainingTime = 0;
        second.value=0; // finish this segment
      }

      // breathing phase delay for reading the name (enter delay when main time finished)
      if (_remainingTime == 0 && _breathingPhaseDelay && _stopTimer != 0) {
        breathingPhasesCount.value++;
        if (breathingPhasesQueue.value.elementAt(1) != null) {
          if (_breathingPhaseNameQueue.length > 1 && _breathingPhaseNameQueue.elementAt(1) != null) {
            _updateCurrentBreathingPhaseLabel(peekNext: true);
          }
        } else {
          currentBreathingPhaseName.value = '';
        }
        if (breathingPhasesQueue.value.elementAt(1) != null) {
          //second.value = 0;
          breathing_phase.BreathingPhase breathingPhase = breathingPhasesQueue.value.elementAt(1)!;
          _handleBackgroundSoundChange(
            breathingPhase.sounds.background, 
            currentBackgroundSound, 
            (_breathingPhaseDelayRemainingTime / 2).toInt());
          _playPreBreathingPhaseSound(breathingPhase);
          currentBackgroundSound = breathingPhase.sounds.background;
        }
        _breathingPhaseDelay = false;
      } else if (_remainingTime == 0 && _breathingPhaseDelayRemainingTime > 0)  {
        // decrement delay with elapsed time
        if (_breathingPhaseDelayRemainingTime > elapsed) {
          _breathingPhaseDelayRemainingTime -= elapsed;
        } else {
          _breathingPhaseDelayRemainingTime = 0;
        }
      }

      // end of delay period, decide next action
      if (_remainingTime == 0 && _breathingPhaseDelayRemainingTime == 0) {
        if (_finishedLoadingSteps) {
          if (_stopTimer == 0) {
            second.value = 0;
            end=true;
            _handleBackgroundSoundChange(_sounds.endingTrack.path, currentBackgroundSound, 500);
            currentBackgroundSound = _sounds.endingTrack.path;
            //_timer?.cancel();
          } else {
            breathingPhasesQueue.value.removeFirst();
            breathingPhasesQueue.value.add(null);
            breathingPhasesQueue.value =
                Queue<breathing_phase.BreathingPhase?>.from(breathingPhasesQueue.value);
            _stopTimer--;
            if(_stopTimer!=0) {
            _remainingTime = _nextRemainingTime;
            previousSecond = (_remainingTime+1) ~/ 1000;
            _breathingPhaseDelay = true;
            _breathingPhaseDelayRemainingTime = _breathingPhaseDelayDuration;
            }
          }
        } else if (!_breathingPhaseDelay ) {
          // start new breathing phase
          breathingPhasesQueue.value.removeFirst();
          _remainingTime = _nextRemainingTime;
          if (_breathingPhaseNameQueue.isNotEmpty) {
            _breathingPhaseNameQueue.removeFirst();
          }
          _nextRemainingTime = _newBreathingPhaseRemainingTime;
          previousSecond = (_remainingTime+1) ~/ 1000;
          _fetchNextBreathingPhase();
          breathingPhasesQueue.value =
              Queue<breathing_phase.BreathingPhase?>.from(breathingPhasesQueue.value);
          _updateCurrentBreathingPhaseLabel();
          _breathingPhaseDelay = true;
          _breathingPhaseDelayRemainingTime = _breathingPhaseDelayDuration;
        }
      }
    });

  }

  void dispose() {
    TextToSpeechService().stopSpeaking();
    soundManager.stopAllSounds();
    _timer?.cancel();
    currentBreathingPhaseName.dispose();
  }

  String _resolveBreathingPhaseName(String? rawName, int breathingPhaseIndex) {
    final cleaned = rawName?.trim();
    if (cleaned != null && cleaned.isNotEmpty) {
      return cleaned;
    }
    return _defaultStageName(breathingPhaseIndex);
  }

  void _updateCurrentBreathingPhaseLabel({bool peekNext = false}) {
    String? name;
    if (peekNext) {
      if (_breathingPhaseNameQueue.length > 1) {
        name = _breathingPhaseNameQueue.elementAt(1);
      } else {
        name = null;
      }
    } else {
      if (_breathingPhaseNameQueue.isEmpty) {
        name = null;
      } else {
        name = _breathingPhaseNameQueue.first;
      }
    }

    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      currentBreathingPhaseName.value = '';
    } else {
      currentBreathingPhaseName.value = trimmed;
    }
  }

  String _defaultStageName(int index) {
    final template = translationProvider
        .getTranslation("BreathingPage.default_stage_name");
    if (template.contains('{number}')) {
      return template.replaceAll('{number}', (index + 1).toString());
    }
    return 'Stage ${index + 1}';
  }
  
}
  
