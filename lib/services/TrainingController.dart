import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/TrainingParser.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Step.dart' as breathing_phase;
import 'package:respire/services/BinauralBeatGenerator.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';
import 'package:respire/services/TextToSpeechService.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class TrainingController {
  Timer? _timer;
  final TrainingParser parser;
  final ValueNotifier<Queue<breathing_phase.BreathingPhase?>> breathingPhasesQueue =
      ValueNotifier(Queue<breathing_phase.BreathingPhase?>());
  final Queue<String?> _trainingStageNameQueue = Queue<String?>();
  final ValueNotifier<int> second = ValueNotifier(3);
  final ValueNotifier<bool> isPaused = ValueNotifier(false);
  final ValueNotifier<int> breathingPhasesCount = ValueNotifier(0);
  final ValueNotifier<String> currentTrainingStageName = ValueNotifier('');

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
  late Settings _settings;

  String? _currentSound;
  late SoundManager soundManager;
  late BinauralBeatGenerator binauralGenerator;

  TranslationProvider translationProvider = TranslationProvider();

  TrainingController(this.parser) {
    soundManager = SoundManager();
    soundManager.stopAllSounds();
    binauralGenerator = BinauralBeatGenerator();
    _remainingTime = parser.training.settings.preparationDuration * 1000;
    _sounds = parser.training.sounds;
    _settings = parser.training.settings;
    
    // Binaural beats will be started after preparation phase
    dev.log('TrainingController: binauralBeatsEnabled=${_settings.binauralBeatsEnabled}');
    
    _preloadBreathingPhases();
    _start();
  }

  void _preloadBreathingPhases() {
    breathingPhasesQueue.value.add(null);
    _trainingStageNameQueue.add(null);
    _updateCurrentTrainingStageLabel();
    _fetchNextBreathingPhase();
    _nextRemainingTime = _newBreathingPhaseRemainingTime;
    _fetchNextBreathingPhase();
  }

  void _fetchNextBreathingPhase() {
    var instructionData = parser.nextInstruction();
    if (instructionData == null) {
      _finishedLoadingSteps = true;
      breathingPhasesQueue.value.add(null);
      _trainingStageNameQueue.add(null);
      return;
    }
    breathingPhasesQueue.value.add(instructionData["breathingPhase"]);
    _trainingStageNameQueue.add(_resolveTrainingStageName(
        instructionData["trainingStageName"] as String?, parser.trainingStageID));
    _newBreathingPhaseRemainingTime = instructionData["remainingTime"];
  }

  void pause() {
    isPaused.value = true;
    if (_currentSound != null) {
      soundManager.pauseSound(_currentSound!);
    }
    if (_settings.binauralBeatsEnabled) {
      binauralGenerator.pause();
    }
    _timer?.cancel();
  }

  void resume() {
    isPaused.value = false;
    if (_currentSound != null) {
      soundManager.playSound(_currentSound!);
    }
    if (_settings.binauralBeatsEnabled) {
      binauralGenerator.resume();
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
        soundManager.playSound(_sounds.countingSound.name);
        break;
    }
  }

  void _playPreBreathingPhaseSound(breathing_phase.BreathingPhase breathingPhase) {
    switch (breathingPhase.sounds.preBreathingPhase.type) {
      case SoundType.voice:
        String breathingPhaseName =
            translationProvider.getTranslation("BreathingPhaseType.${breathingPhase.breathingPhaseType.name}");
        TextToSpeechService().speak(breathingPhaseName);
        break;
      case SoundType.none:
        break;
      default:
        soundManager.playSound(breathingPhase.sounds.preBreathingPhase.name);
        Future.delayed(const Duration(seconds: 1), () {
          soundManager.stopSound(breathingPhase.sounds.preBreathingPhase.name);
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
    String? currentBackgroundSound = _sounds.preparationTrack.name;
    _currentSound = currentBackgroundSound;
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
        
        // Start binaural beats when first breathing phase begins (after preparation)
        if (breathingPhasesCount.value == 1 && _settings.binauralBeatsEnabled) {
          final trainingDuration = parser.calculateTrainingDurationWithoutPreparation();
          dev.log('Starting binaural beats: Left=${_settings.binauralLeftFrequency}Hz, Right=${_settings.binauralRightFrequency}Hz, Duration=${trainingDuration}s');
          binauralGenerator.start(
            _settings.binauralLeftFrequency,
            _settings.binauralRightFrequency,
            durationSeconds: trainingDuration,
          );
        }
        
        if (breathingPhasesQueue.value.elementAt(1) != null) {
          if (_trainingStageNameQueue.length > 1 && _trainingStageNameQueue.elementAt(1) != null) {
            _updateCurrentTrainingStageLabel(peekNext: true);
          }
        } else {
          currentTrainingStageName.value = '';
        }
        if (breathingPhasesQueue.value.elementAt(1) != null) {
          //second.value = 0;
          breathing_phase.BreathingPhase breathingPhase = breathingPhasesQueue.value.elementAt(1)!;
          _handleBackgroundSoundChange(
            breathingPhase.sounds.background.name, 
            currentBackgroundSound, 
            (_breathingPhaseDelayRemainingTime / 2).toInt());
          _playPreBreathingPhaseSound(breathingPhase);
          currentBackgroundSound = breathingPhase.sounds.background.name;
          _currentSound = currentBackgroundSound;
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
            _handleBackgroundSoundChange(_sounds.endingTrack.name, currentBackgroundSound, 500);
            currentBackgroundSound = _sounds.endingTrack.name;
            _currentSound = currentBackgroundSound;
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
          if (_trainingStageNameQueue.isNotEmpty) {
            _trainingStageNameQueue.removeFirst();
          }
          _nextRemainingTime = _newBreathingPhaseRemainingTime;
          previousSecond = (_remainingTime+1) ~/ 1000;
          _fetchNextBreathingPhase();
          breathingPhasesQueue.value =
              Queue<breathing_phase.BreathingPhase?>.from(breathingPhasesQueue.value);
          _updateCurrentTrainingStageLabel();
          _breathingPhaseDelay = true;
          _breathingPhaseDelayRemainingTime = _breathingPhaseDelayDuration;
        }
      }
    });

  }

  void dispose() {
    TextToSpeechService().stopSpeaking();
    soundManager.stopAllSounds();
    binauralGenerator.stop();
    _timer?.cancel();
    currentTrainingStageName.dispose();
  }

  String _resolveTrainingStageName(String? rawName, int trainingStageIndex) {
    final cleaned = rawName?.trim();
    if (cleaned != null && cleaned.isNotEmpty) {
      return cleaned;
    }
    return _defaultStageName(trainingStageIndex);
  }

  void _updateCurrentTrainingStageLabel({bool peekNext = false}) {
    String? name;
    if (peekNext) {
      if (_trainingStageNameQueue.length > 1) {
        name = _trainingStageNameQueue.elementAt(1);
      } else {
        name = null;
      }
    } else {
      if (_trainingStageNameQueue.isEmpty) {
        name = null;
      } else {
        name = _trainingStageNameQueue.first;
      }
    }

    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      currentTrainingStageName.value = '';
    } else {
      currentTrainingStageName.value = trimmed;
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
  
