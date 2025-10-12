import 'package:flutter/foundation.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';

class SingleSoundManager extends SoundManager {
  
  SingleSoundManager() : super();

  ValueNotifier<String?> currentlyPlaying = ValueNotifier<String?>(null);

  @override
  Future<void> playSound(String? soundName) async {
    if (currentlyPlaying.value != null) {
      await stopSound(currentlyPlaying.value!);
    }
    await super.playSound(soundName);
    currentlyPlaying.value = soundName;
  }

  @override
  Future<void> playSoundFadeIn(String? soundName, int fadeInDuration) {
    currentlyPlaying.value = soundName;
    return super.playSoundFadeIn(soundName, fadeInDuration);
  }

  @override
  Future<void> pauseSound(String? soundName) {
    currentlyPlaying.value = null;
    return super.pauseSound(soundName);
  }

  @override
  Future<void> pauseSoundFadeOut(String? soundName, int fadeOutDuration) {
    currentlyPlaying.value = null;
    return super.pauseSoundFadeOut(soundName, fadeOutDuration);
  }

  @override
  void stopAllSounds() {
    super.stopAllSounds();
    currentlyPlaying.value = null;
  }

  @override
  void removeUserSound(String soundName, SoundListType type) {
    if (currentlyPlaying.value == soundName) {
      currentlyPlaying.value = null;
    }
    super.removeUserSound(soundName, type);
  }

  @override
  Future<void> stopSound(String? soundName) async{
    stopAllSounds();
  }

}