import 'dart:async';
import 'dart:collection';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/TrainingParser.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Step.dart' as breathing_phase;
import 'package:respire/services/BinauralBeatGenerator.dart';
import 'package:respire/services/SoundManagers/PlaylistManager.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';
import 'package:respire/services/TextToSpeechService.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class TrainingController {
  Timer? _timer;
  final TrainingParser parser;
  final ValueNotifier<Queue<breathing_phase.BreathingPhase?>>
      breathingPhasesQueue = ValueNotifier(Queue<breathing_phase.BreathingPhase?>());
  final Queue<String?> _trainingStageNameQueue = Queue<String?>();
  final Queue<String?> _trainingStageIdQueue = Queue<String?>(); // Track stage ID for each phase
  final ValueNotifier<int> second = ValueNotifier(3);
  final ValueNotifier<bool> isPaused = ValueNotifier(false);
  final ValueNotifier<int> breathingPhasesCount = ValueNotifier(0);
  final ValueNotifier<String> currentTrainingStageName = ValueNotifier('');
  final ValueNotifier<int> currentStageIndex = ValueNotifier(0);
  final ValueNotifier<int> totalStages = ValueNotifier(0);

  final int _updateInterval = 25; //in milliseconds

  int _remainingTime = 0; //in milliseconds
  int _nextRemainingTime = 0; //in milliseconds
  int _newBreathingPhaseRemainingTime = 0; //in milliseconds

  bool end = false;
  bool _finishedLoadingSteps = false;
  bool _nextPhaseSoundPlayed = false;
  int _stopTimer = 2;

  late Sounds _sounds;
  late Settings _settings;

  String? _currentSound;
  String? _currentTrainingStageId;
  late SoundManager soundManager;
  late PlaylistManager playlistManager;
  late BinauralBeatGenerator binauralGenerator;
  bool _isUsingPlaylist = false;
  bool _preparationPhaseCompleted = false;

  TranslationProvider translationProvider = TranslationProvider();

  final longSoundNames = ['Wdech', 'Wstrzymanie', 'Wydech', 'Zatrzymanie'];

  TrainingController(this.parser) {
    soundManager = SoundManager();
    soundManager.stopAllSounds();
    playlistManager = PlaylistManager();
    binauralGenerator = BinauralBeatGenerator();
    _remainingTime = parser.training.settings.preparationDuration * 1000;
    _sounds = parser.training.sounds;
    _settings = parser.training.settings;

    // Initialize current stage ID to the first stage
    if (parser.training.trainingStages.isNotEmpty) {
      _currentTrainingStageId = parser.training.trainingStages[0].id;
      totalStages.value = parser.training.trainingStages.length;
      currentStageIndex.value = 1;
    }

    // Binaural beats will be started after preparation phase
    dev.log(
        'TrainingController: binauralBeatsEnabled=${_settings.binauralBeatsEnabled}');

    _preloadBreathingPhases();
    _currentSound = _sounds.preparationTrack.type != SoundType.none
        ? _sounds.preparationTrack.name
        : null;

    // Note: Global playlist will be started after preparation phase
    // See _handlePreparationPhaseEnd()

    _start();
  }

  void _preloadBreathingPhases() {
    breathingPhasesQueue.value.add(null);
    _logQueue('ADD', phase: null);
    _trainingStageNameQueue.add(null);
    _trainingStageIdQueue.add(null);
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
      _logQueue('ADD (finish)', phase: null);
      _trainingStageNameQueue.add(null);
      _trainingStageIdQueue.add(null);
      dev.log('TrainingController: No more phases to fetch');
      return;
    }

    breathingPhasesQueue.value.add(instructionData["breathingPhase"]);
    _logQueue('ADD', phase: instructionData["breathingPhase"]);
    _trainingStageNameQueue.add(_resolveTrainingStageName(
        instructionData["trainingStageName"] as String?,
        parser.trainingStageID));

    // Store the stage ID for this phase
    String? stageId;
    if (parser.trainingStageID < parser.training.trainingStages.length) {
      stageId = parser.training.trainingStages[parser.trainingStageID].id;
    }
    _trainingStageIdQueue.add(stageId);

    dev.log(
        'TrainingController: Fetched phase for stage: $stageId (parser.trainingStageID=${parser.trainingStageID})');

    _newBreathingPhaseRemainingTime = instructionData["remainingTime"];
  }

  void _logQueue(String action, {breathing_phase.BreathingPhase? phase}) {
    final List<String> queueNames = breathingPhasesQueue.value.map((p) {
      if (p == null) return 'null';
      return '${p.breathingPhaseType.name} (${p.duration ~/ 1000}s)';
    }).toList();

    final phaseName = phase == null
        ? 'null'
        : '${phase.breathingPhaseType.name} (${phase.duration ~/ 1000}s)';

    dev.log('[QUEUE] $action: $phaseName | Queue: [$queueNames]');
  }

  void pause() {
    isPaused.value = true;
    // to account for some longer counting sounds
    //(that are not stored in the _currentSound)
    soundManager.stopAllSounds();
    if (_isUsingPlaylist) {
      playlistManager.pausePlaylist();
    }
    if (_settings.binauralBeatsEnabled) {
      binauralGenerator.pause();
    }
    _timer?.cancel();
  }

  void resume() {
    isPaused.value = false;
    if (_isUsingPlaylist) {
      playlistManager.resumePlaylist();
    } else if (_currentSound != null) {
      //soundManager.playSound(_currentSound!); //TODO: Delete once the playlist is working properly
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

   Future<void> _playEndingSound(endingBackgroundSound, changeTime) async {
    if (_currentSound != null) {
        await soundManager.pauseSoundFadeOut(_currentSound, changeTime);
      }
      _currentSound = endingBackgroundSound;
      if (endingBackgroundSound != null) {
        soundManager.playSoundFadeIn(endingBackgroundSound, changeTime);
      }
  }

  void _playPreBreathingPhaseSound(
      breathing_phase.BreathingPhase breathingPhase) {
    switch (breathingPhase.sounds.preBreathingPhase.type) {
      case SoundType.voice:
        String breathingPhaseName = translationProvider.getTranslation(
            "BreathingPhaseType.${breathingPhase.breathingPhaseType.name}");
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

  bool triggered = false;

  // Switch to a new stage's playlist
  void _switchToStagePlaylist(String stageId) {
    if (_sounds.backgroundSoundScope != SoundScope.perStage) {
      return; // Only for per-stage mode
    }

    // Stop any currently playing playlist
    if (_isUsingPlaylist) {
      playlistManager.completePlaylist();
      _isUsingPlaylist = false;
    }

    // Get playlist for this stage
    if (_sounds.stagePlaylists.containsKey(stageId) &&
        _sounds.stagePlaylists[stageId]!.isNotEmpty) {
      final playlist = _sounds.stagePlaylists[stageId]!;

      // Start new stage playlist
      _isUsingPlaylist = true;
      playlistManager.playPlaylist(playlist.map((s) => s.name).toList());
      _currentSound = null; // Clear single sound tracking

      dev.log(
          'Switched to stage playlist: $stageId (${playlist.length} sounds)');
    }
  }

  Future<void> _handleBackgroundSoundChange(
      String? nextBackgroundSound, int changeTime) async {
    // For global playlist, it should play continuously - don't restart
    if (_sounds.backgroundSoundScope == SoundScope.global &&
        _sounds.trainingBackgroundPlaylist.isNotEmpty) {
      // Playlist already started after preparation, just return
      return;
    }

    // For per-stage playlist - handled separately in phase start, not here
    if (_sounds.backgroundSoundScope == SoundScope.perStage) {
      return;
    }

    // Otherwise use single sound manager (for perPhase or single sounds)
    if (_currentSound != nextBackgroundSound) {
      // Stop playlist if it was playing
      if (_isUsingPlaylist) {
        playlistManager.completePlaylist();
        _isUsingPlaylist = false;
      }

      if (_currentSound != null) {
        await soundManager.pauseSoundFadeOut(_currentSound, changeTime);
      }
      _currentSound = nextBackgroundSound;
      if (nextBackgroundSound != null) {
        soundManager.playSoundFadeIn(nextBackgroundSound, changeTime);
      }
    }
  }

  void _start() {
    int previousSecond = _remainingTime ~/ 1000;
    DateTime lastTick = DateTime.now();
    soundManager.playSound(_currentSound);

    //TODO: Handle distinguishing when are we playing a playlist and when a single sound. Maybe by checking the return type?

    _timer =
        Timer.periodic(Duration(milliseconds: _updateInterval), (Timer timer) {
      final now = DateTime.now();
      final int elapsed = now.difference(lastTick).inMilliseconds;
      lastTick = now;

      if (previousSecond > _remainingTime ~/ 1000 && !end) {
        previousSecond = _remainingTime ~/ 1000;
        second.value = previousSecond + 1;

        if (breathingPhasesQueue.value.length > 1 &&
            breathingPhasesQueue.value.elementAt(1) != null) {
          final nextPhase = breathingPhasesQueue.value.elementAt(1)!;
          final soundName = nextPhase.sounds.preBreathingPhase.name;
          final type = nextPhase.sounds.preBreathingPhase.type;

          if(second.value==1 && 
          (longSoundNames.contains(soundName) ||
          type == SoundType.voice)) {
            _playPreBreathingPhaseSound(nextPhase);
          } else {
             _playCountingSound(previousSecond);
          }
        } else {
          _playCountingSound(previousSecond);
        }
      }

      if (_remainingTime > elapsed) {
        _remainingTime -= elapsed;

        if (breathingPhasesQueue.value.length > 1 &&
            breathingPhasesQueue.value.elementAt(1) != null) {
          final nextPhase = breathingPhasesQueue.value.elementAt(1)!;
          
          if (_remainingTime <= 100 && 
             !_nextPhaseSoundPlayed &&
            !longSoundNames.contains(nextPhase.sounds.preBreathingPhase.name)) {
            _nextPhaseSoundPlayed = true;
            _playPreBreathingPhaseSound(nextPhase); // short sound
          } 
          else if (_remainingTime <= 300 &&
              _remainingTime > 200) {
            //second.value = 0;
            breathing_phase.BreathingPhase breathingPhase =
                breathingPhasesQueue.value.elementAt(1)!;
            _handleBackgroundSoundChange(
                breathingPhase.sounds.background.name, 500);
          }

        }
      } else if (_remainingTime > 0) {
        _remainingTime = 0;
        second.value = 0;
      }

      if (_remainingTime == 0 && _stopTimer != 0) {
        breathingPhasesCount.value++;

        if (breathingPhasesCount.value == 1 && _settings.binauralBeatsEnabled) {
          final trainingDuration =
              parser.calculateTrainingDurationWithoutPreparation();
          dev.log(
              'Starting binaural beats: Left=${_settings.binauralLeftFrequency}Hz, Right=${_settings.binauralRightFrequency}Hz, Duration=${trainingDuration}s');
          binauralGenerator.start(
            _settings.binauralLeftFrequency,
            _settings.binauralRightFrequency,
            durationSeconds: trainingDuration,
          );
        }

        if (breathingPhasesCount.value == 1 && !_preparationPhaseCompleted) {
          soundManager.stopSound(_currentSound);
          _currentSound = null;
          _preparationPhaseCompleted = true;
          if (_sounds.backgroundSoundScope == SoundScope.global &&
              _sounds.trainingBackgroundPlaylist.isNotEmpty) {
            _isUsingPlaylist = true;
            playlistManager.playPlaylist(
                _sounds.trainingBackgroundPlaylist.map((s) => s.name).toList());
          } else if (_sounds.backgroundSoundScope == SoundScope.perStage &&
              _currentTrainingStageId != null) {
            // Start first stage's playlist
            _switchToStagePlaylist(_currentTrainingStageId!);
          }
        }

        if (breathingPhasesQueue.value.elementAt(1) != null) {
          if (_trainingStageNameQueue.length > 1 &&
              _trainingStageNameQueue.elementAt(1) != null) {
            _updateCurrentTrainingStageLabel(peekNext: true);
          }
        } else {
          currentTrainingStageName.value = '';
        }

        if (_remainingTime == 0) {
          if (_finishedLoadingSteps) {
            final removedPhase = breathingPhasesQueue.value.removeFirst();
            _logQueue('REMOVE', phase: removedPhase);
            breathingPhasesQueue.value.add(null);
            _logQueue('ADD (END)', phase: null);
            breathingPhasesQueue.value =
                Queue<breathing_phase.BreathingPhase?>.from(
                    breathingPhasesQueue.value);
            _logQueue('REBUILD');
            _stopTimer--;

            if (_stopTimer == 0) {
              second.value = 0;
              end = true;

              if (_isUsingPlaylist) {
                playlistManager.completePlaylist();
                _isUsingPlaylist = false;
              }

              _playEndingSound(_sounds.endingTrack.name, 500);

            } else {
              _remainingTime = _nextRemainingTime;
              previousSecond = (_remainingTime + 1) ~/ 1000;
            }
          } else {

            String? newStageId;
            if (_trainingStageIdQueue.length > 1) {
              newStageId = _trainingStageIdQueue.elementAt(1); 
            }

            dev.log(
                'TrainingController: Starting new phase with stageId: $newStageId (current: $_currentTrainingStageId, queue size: ${_trainingStageIdQueue.length})');

            final removedPhase = breathingPhasesQueue.value.removeFirst();
            _logQueue('REMOVE', phase: removedPhase);
            _remainingTime = _nextRemainingTime;
            if (_trainingStageNameQueue.isNotEmpty) {
              _trainingStageNameQueue.removeFirst();
            }
            if (_trainingStageIdQueue.isNotEmpty) {
              _trainingStageIdQueue.removeFirst();
            }

            _nextRemainingTime = _newBreathingPhaseRemainingTime;
            previousSecond = (_remainingTime + 1) ~/ 1000;
            _fetchNextBreathingPhase();
            _nextPhaseSoundPlayed = false;
            breathingPhasesQueue.value =
                Queue<breathing_phase.BreathingPhase?>.from(
                    breathingPhasesQueue.value);
            _logQueue('REBUILD');
            _updateCurrentTrainingStageLabel();

            if (newStageId != null && _currentTrainingStageId != newStageId) {
              dev.log(
                  'TrainingController: Stage changed from $_currentTrainingStageId to $newStageId');
              _currentTrainingStageId = newStageId;
              
              for (int i = 0; i < parser.training.trainingStages.length; i++) {
                if (parser.training.trainingStages[i].id == newStageId) {
                  currentStageIndex.value = i + 1; // 1-indexed for display
                  dev.log('TrainingController: Stage index updated to ${i + 1}');
                  break;
                }
              }
              
              if (_sounds.backgroundSoundScope == SoundScope.perStage) {
                dev.log('TrainingController: SWITCHING PLAYLIST for stage $newStageId');
                _switchToStagePlaylist(_currentTrainingStageId!);
              }
            } else if (newStageId != null) {
              dev.log('TrainingController: Same stage ($newStageId) - keeping playlist');
            }
          }
        }
      }
    });
  }

  void dispose() {
    TextToSpeechService().stopSpeaking();
    soundManager.stopAllSounds();
    playlistManager.completePlaylist();
    binauralGenerator.stop();
    _timer?.cancel();
    currentTrainingStageName.dispose();
    currentStageIndex.dispose();
    totalStages.dispose();
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
    final template =
        translationProvider.getTranslation("BreathingPage.default_stage_name");
    if (template.contains('{number}')) {
      return template.replaceAll('{number}', (index + 1).toString());
    }
    return 'Stage ${index + 1}';
  }
}
