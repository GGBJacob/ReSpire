import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:respire/components/BreathingPage/AnimatedCircle.dart';
import 'package:respire/components/BreathingPage/InstructionSlider.dart';
import 'package:respire/components/BreathingPage/PreloadingScreen.dart';
import 'package:respire/components/BreathingPage/TrainingParser.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Step.dart' as breathing_phase;
import 'package:respire/services/SoundManagers/SoundManager.dart';
import 'package:respire/services/TrainingController.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class BreathingPage extends StatefulWidget {
  final Training training;

  const BreathingPage({super.key, required this.training});

  @override
  State<StatefulWidget> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> {
  late TrainingParser parser;
  TrainingController? controller;
  int second = 0;
  int breathingPhases = 0;
  TranslationProvider translationProvider = TranslationProvider();
  
  // Preloading state
  bool _isPreloading = true;
  double _preloadProgress = 0.0;
  int _loadedCount = 0;
  int _totalCount = 0;
  String? _currentlyLoading;

  @override
  void initState() {
    super.initState();
    // Ensure sounds are properly propagated to breathing phases
    widget.training.updateSounds();
    parser = TrainingParser(training: widget.training);
    breathingPhases = parser.countBreathingPhases();
    
    _preloadAudio();
  }
  
  Future<void> _preloadAudio() async {
    final soundManager = SoundManager();
    final soundsToPreload = <String>{};
    
    // Collect all sounds that need to be loaded
    // 1. Preparation track
    if (widget.training.sounds.preparationTrack.type != SoundType.none &&
        widget.training.sounds.preparationTrack.type != SoundType.voice) {
      soundsToPreload.add(widget.training.sounds.preparationTrack.name);
    }
    
    // 2. Ending track
    if (widget.training.sounds.endingTrack.type != SoundType.none &&
        widget.training.sounds.endingTrack.type != SoundType.voice) {
      soundsToPreload.add(widget.training.sounds.endingTrack.name);
    }
    
    // 3. Global playlist
    if (widget.training.sounds.trainingBackgroundPlaylist.isNotEmpty) {
      for (var sound in widget.training.sounds.trainingBackgroundPlaylist) {
        if (sound.type != SoundType.none && sound.type != SoundType.voice) {
          soundsToPreload.add(sound.name);
        }
      }
    }
    
    // 4. Stage playlists
    for (var playlist in widget.training.sounds.stagePlaylists.values) {
      for (var sound in playlist) {
        if (sound.type != SoundType.none && sound.type != SoundType.voice) {
          soundsToPreload.add(sound.name);
        }
      }
    }
    
    // 5. Phase-specific sounds (per-phase background sounds)
    for (var stage in widget.training.trainingStages) {
      for (var phase in stage.breathingPhases) {
        if (phase.sounds.background.type != SoundType.none &&
            phase.sounds.background.type != SoundType.voice) {
          soundsToPreload.add(phase.sounds.background.name);
        }
        if (phase.sounds.preBreathingPhase.type != SoundType.none &&
            phase.sounds.preBreathingPhase.type != SoundType.voice) {
          soundsToPreload.add(phase.sounds.preBreathingPhase.name);
        }
      }
    }
    
    final soundsList = soundsToPreload.toList();
    setState(() {
      _totalCount = soundsList.length;
    });
    
    // Load each sound with progress updates
    for (int i = 0; i < soundsList.length; i++) {
      final soundName = soundsList[i];
      
      if (mounted) {
        setState(() {
          _currentlyLoading = soundName;
        });
      }
      
      await soundManager.loadSound(soundName);
      
      if (mounted) {
        setState(() {
          _loadedCount = i + 1;
          _preloadProgress = (_loadedCount / _totalCount);
        });
      }
      
      // Small delay to show progress (optional, for UX)
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    // All sounds loaded, create controller and show training
    if (mounted) {
      controller = TrainingController(parser);
      setState(() {
        _isPreloading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("BreathingPage.exit_popup_title")),
          content: Text(
            translationProvider.getTranslation("BreathingPage.exit_popup_message")),
              //textAlign: TextAlign.center),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller!.resume();
              },
              child: Text(translationProvider.getTranslation("PopupButton.no")),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(translationProvider.getTranslation("PopupButton.yes")),
            ),
          ],
        );
      },
    );
  }

  Widget textInCircle() {
    return ValueListenableBuilder<int>(
      valueListenable: controller!.second,
      builder: (context, value, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isPreloading || controller == null) {
      return PreloadingScreen(
        progress: _preloadProgress,
        loadedCount: _loadedCount,
        totalCount: _totalCount,
        currentlyLoading: _currentlyLoading,
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: ValueListenableBuilder<Queue<breathing_phase.BreathingPhase?>>(
          valueListenable: controller!.breathingPhasesQueue,
          builder: (context, queue, _) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (queue.isNotEmpty && queue.first != null) {
                  controller!.pause();
                  _showConfirmationDialog();
                } else {
                  Navigator.pop(context);
                }
              },
            );
          },
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: controller!.isPaused,
            builder: (context, isPaused, _) {
              return IconButton(
                icon: isPaused ? Icon(Icons.play_arrow, color: Colors.black,) : Icon(Icons.pause, color: Colors.black,),
                onPressed: () {
                  isPaused ? controller!.resume() : controller!.pause();
                },
              );
            },
          )
        ],
        title: Text(widget.training.title),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(50, 183, 207, 1),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),

          ValueListenableBuilder<String>(
            valueListenable: controller!.currentTrainingStageName,
            builder: (context, stageName, _) {
              final trimmed = stageName.trim();
              final hasLabel = trimmed.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: hasLabel,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Text(
                        translationProvider
                            .getTranslation("BreathingPage.current_training_stage_label"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Visibility(
                      visible: hasLabel,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Text(
                        trimmed,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),

          //instructions
          ValueListenableBuilder<Queue<breathing_phase.BreathingPhase?>>(
            valueListenable: controller!.breathingPhasesQueue,
            builder: (context, breathingPhasesQueue, _) {
              return ValueListenableBuilder<int>(
                valueListenable: controller!.breathingPhasesCount,
                builder: (context, change, _) {
                  return InstructionSlider(
                      preparationTime: widget.training.settings.preparationDuration.toDouble(), 
                      breathingPhasesQueue: breathingPhasesQueue, 
                      change: change);
                },
              );
            },
          ),

          //breathing phase counter
          ValueListenableBuilder<int>(
            valueListenable: controller!.breathingPhasesCount,
            builder: (context, breathingPhasesDone, _) {
              return Text(
                '${breathingPhasesDone <= breathingPhases ? breathingPhasesDone : breathingPhases} / $breathingPhases',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              );
            },
          ),

          //circles
          ValueListenableBuilder<bool>(
              valueListenable: controller!.isPaused,
              builder: (context, isPaused, _) {
                return Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: isPaused ? controller!.resume : controller!.pause,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          //background circle, max value
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(183, 244, 255, 1),
                            ),
                          ),

                          //animated circle
                          ValueListenableBuilder<Queue<breathing_phase.BreathingPhase?>>(
                              valueListenable: controller!.breathingPhasesQueue,
                              builder: (context, breathingPhases, _) {
                                return ValueListenableBuilder<bool>(
                                    valueListenable: controller!.isPaused,
                                    builder: (context, isPaused, _) {
                                      return AnimatedCircle(
                                          breathingPhase: breathingPhases.first,
                                          isPaused: isPaused);
                                    });
                              }),

                          //foreground circle, min value
                          Container(
                            width: 125,
                            height: 125,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(44, 173, 196, 1),
                            ),
                          ),

                          isPaused
                              ? Text(
                                  translationProvider.getTranslation("BreathingPage.circle_paused_text"),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : textInCircle()
                        ],
                      ),
                    ),
                  ),
                );
              })
        ],
      ),
    );
  }
}
