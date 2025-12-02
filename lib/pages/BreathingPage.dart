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
import 'package:wakelock_plus/wakelock_plus.dart';

class BreathingPage extends StatefulWidget {
  final Training training;

  const BreathingPage({super.key, required this.training});

  @override
  State<StatefulWidget> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage> with WidgetsBindingObserver {
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
  bool _loadingFinalizing = false;

  late double preparationDuration;
  late double endingDuration;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
    // Ensure sounds are properly propagated to breathing phases
    widget.training.updateSounds();
    parser = TrainingParser(training: widget.training);
    breathingPhases = parser.countBreathingPhases();
    
    _preloadAudio();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null) return;
    if (state == AppLifecycleState.paused) {
      controller!.pause();
    } else if (state == AppLifecycleState.resumed) {
      controller!.resume();
    }
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

    // Finalizing loading
    if (mounted) {
      setState(() {
        _currentlyLoading = null;
        _loadingFinalizing = true;
      });
    }
    
    loadPreparationLength();
    loadEndingLength();

    await Future.delayed(const Duration(milliseconds: 50));
    
    // All sounds loaded, create controller and show training
    if (mounted) {
      controller = TrainingController(parser);
      setState(() {
        _isPreloading = false;
      });
    }
  }

  void loadPreparationLength() async {
    SoundManager soundManager = SoundManager();
    if(widget.training.settings.preparationDuration == 0)
    {
      if(widget.training.sounds.preparationTrack.type != SoundType.none) {
        preparationDuration = (await soundManager.getSoundDuration(widget.training.sounds.preparationTrack.name))?.inSeconds.toDouble() ?? 0.0;
      } else {
        preparationDuration = 0.0;
      }
    } else {
      preparationDuration = widget.training.settings.preparationDuration.toDouble();
    }
  }

  void loadEndingLength() async {
    SoundManager soundManager = SoundManager();
    if(widget.training.settings.endingDuration == 0)
    {
      if(widget.training.sounds.endingTrack.type != SoundType.none) {
        endingDuration = (await soundManager.getSoundDuration(widget.training.sounds.endingTrack.name))?.inSeconds.toDouble() ?? 0.0;
      } else {
        endingDuration = 0.0;
      }
    } else {
      endingDuration = widget.training.settings.endingDuration.toDouble();
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translationProvider.getTranslation("BreathingPage.exit_popup_title")),
          content: Text(
            translationProvider.getTranslation("BreathingPage.exit_popup_message")),
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
              child: Text(translationProvider.getTranslation("PopupButton.yes"), style: TextStyle(color: Colors.red)),
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
        finalizing: _loadingFinalizing
      );
    }
    controller!.setContext(context);
    bool _displayStageInfo = false;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: ValueListenableBuilder<Queue<breathing_phase.BreathingPhase?>>(
          valueListenable: controller!.breathingPhasesQueue,
          builder: (context, queue, _) {
            return IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
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
        title: Text(widget.training.title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Glacial',
            ),
          ),
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
              _displayStageInfo = trimmed.isNotEmpty && !_isPreloading;
              return Visibility(
                visible: _displayStageInfo,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        translationProvider
                            .getTranslation("BreathingPage.current_training_stage_label"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                        trimmed,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: controller!.breathingPhasesCount,
                      builder: (context, phaseCount, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: controller!.currentStageIndex,
                          builder: (context, currentIndex, _) {
                            return ValueListenableBuilder<int>(
                              valueListenable: controller!.totalStages,
                              builder: (context, total, _) {
                                return Visibility(
                                  visible: _displayStageInfo,
                                  maintainSize: true,
                                  maintainAnimation: true,
                                  maintainState: true,
                                  child:Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromRGBO(44, 173, 196, 0.8),
                                        Color.fromRGBO(50, 183, 207, 0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(44, 173, 196, 0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.layers_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$currentIndex ${translationProvider.getTranslation("BreathingPage.Counter.connector")} $total',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              )
              );
            },
          ),

          ValueListenableBuilder<bool>(
            valueListenable: controller!.showLabels,
            builder: (context, phaseCount, _) {
              return controller!.showLabels.value ? 
                ValueListenableBuilder<int>(
                  valueListenable: controller!.breathingPhasesCount,
                  builder: (context, breathingPhasesDone, _) {
                    return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(44, 173, 196, 1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${breathingPhasesDone <= breathingPhases ? breathingPhasesDone : breathingPhases} ${translationProvider.getTranslation("BreathingPage.Counter.connector")} $breathingPhases ${translationProvider.getTranslation("BreathingPage.phases")}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(44, 173, 196, 1),
                          ),
                        ),
                      );
                  },
                ) 
                : SizedBox(height: 0);
            }),

          //instructions
          ValueListenableBuilder<Queue<breathing_phase.BreathingPhase?>>(
            valueListenable: controller!.breathingPhasesQueue,
            builder: (context, breathingPhasesQueue, _) {
              return ValueListenableBuilder<int>(
                valueListenable: controller!.breathingPhasesCount,
                builder: (context, change, _) {
                  return InstructionSlider(
                      preparationTime: preparationDuration,
                      endingTime: endingDuration, 
                      breathingPhasesQueue: breathingPhasesQueue, 
                      change: change);
                },
              );
            },
          ),

          ValueListenableBuilder<bool>(
            valueListenable: controller!.showLabels,
            builder: (context, phaseCount, _) {
              return controller!.showLabels.value ? 
                //cycles counter
                ValueListenableBuilder<int>(
                  valueListenable: controller!.currentCycleIndex,
                  builder: (context, phaseCount, _) {
                    return 
                    ValueListenableBuilder<int>(
                      valueListenable: controller!.totalCycles,
                      builder: (context, phaseCount, _) {
                        return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(44, 173, 196, 1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${controller!.currentCycleIndex.value} ${translationProvider.getTranslation("BreathingPage.Counter.connector")} ${controller!.totalCycles.value} ${translationProvider.getTranslation("BreathingPage.cycles")}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(44, 173, 196, 1),
                          ),
                        ),
                      );
                      }
                    );
                  }
                )
                : SizedBox(height: 0);
            }),

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
                              boxShadow: [ //shadow from https://flutter-boxshadow.vercel.app/
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  blurRadius: 3,
                                  spreadRadius: 0,
                                  offset: Offset(0, 1),
                                ),
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.06),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                  offset: Offset(0, 1),
                                )
                              ]
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
