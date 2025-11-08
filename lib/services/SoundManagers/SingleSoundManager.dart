import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';

class SingleSoundManager implements ISoundManager {
  
  SoundManager _delegate = SoundManager();

  ValueNotifier<String?> currentlyPlaying = ValueNotifier<String?>(null);

  @override
  Future<void> playSound(String? soundName) async {
    if (soundName == null) return;

    bool success = await _delegate.loadSound(soundName);
    if(!success) return;

    final player = _delegate.getPlayer(soundName)!;
    final asset = _delegate.getAsset(soundName)!;

    _setupSinglePlayAudioPlayer(player, asset);

    if (currentlyPlaying.value != null && currentlyPlaying.value != soundName) {
      await stopSound(currentlyPlaying.value!);
    }
    
    currentlyPlaying.value = soundName;
    log("Currently playing: " + currentlyPlaying.value!);
    await player.resume();
  }

  @override
  Future<void> playSoundFadeIn(String? soundName, int fadeInDuration) {
    currentlyPlaying.value = soundName;
    return _delegate.playSoundFadeIn(soundName, fadeInDuration);
  }


  @override
  Future<void> pauseSound(String? soundName) {
    // currentlyPlaying.value = null;
    return _delegate.pauseSound(soundName);
  }

  @override
  Future<void> pauseSoundFadeOut(String? soundName, int fadeOutDuration) {
    currentlyPlaying.value = null;
    return _delegate.pauseSoundFadeOut(soundName, fadeOutDuration);
  }

  @override
  void stopAllSounds() {
    currentlyPlaying.value = null;
    _delegate.stopAllSounds();
  }

  void _setupSinglePlayAudioPlayer(AudioPlayer audioPlayer, SoundAsset asset) {
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.onPlayerComplete.listen((event) {
      if (currentlyPlaying.value == asset.name) {
        currentlyPlaying.value = null;
      }
    });
  }

  void removeUserSound(String soundName, SoundListType type) {
    if (currentlyPlaying.value == soundName) {
      currentlyPlaying.value = null;
    }
    _delegate.removeUserSound(soundName, type);
  }

  @override
  Future<void> stopSound(String? soundName) async{
    stopAllSounds();
  }

  @override
  List<String> getAvailableSounds() => _delegate.getAvailableSounds();
  
  @override
  List<String> getLoadedSounds() => _delegate.getLoadedSounds();
  
  @override
  Map<String, SoundAsset> getSounds(SoundListType type) => _delegate.getSounds(type);
  
  @override
  Future<bool> loadSound(String soundName) => _delegate.loadSound(soundName);

  AudioPlayer? getPlayer(String soundName) => _delegate.getPlayer(soundName);
}