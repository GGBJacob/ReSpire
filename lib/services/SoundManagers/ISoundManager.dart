// We define the enum here so it's coupled with the interface that uses it.
enum SoundListType {
  longSounds,
  shortSounds,
}

abstract class ISoundManager {
  /// Returns a map of sounds for a given type (long or short).
  Map<String, String?> getSounds(SoundListType type);

  /// Pre-loads a sound into memory for faster playback.
  /// Returns true if successful.
  Future<bool> loadSound(String soundName);

  /// Returns a list of all sounds currently loaded and ready to play.
  List<String> getLoadedSounds();

  /// Returns a list of all sounds available to be loaded.
  List<String> getAvailableSounds();

  /// Plays a sound. If not loaded, it will load it first.
  Future<void> playSound(String? soundName);

  /// Plays a sound with a fade-in effect.
  Future<void> playSoundFadeIn(String? soundName, int fadeInDuration);

  /// Pauses a currently playing sound.
  Future<void> pauseSound(String? soundName);

  /// Stops a sound and resets its position to the beginning.
  Future<void> stopSound(String? soundName);

  /// Pauses a sound with a fade-out effect.
  Future<void> pauseSoundFadeOut(String? soundName, int fadeOutDuration);

  /// Stops all currently playing sounds.
  void stopAllSounds();
  
  /// Refreshes the list of available sounds from the database.
  void refreshSoundsList();

  /// Removes a user-added sound from the manager and database.
  void removeUserSound(String soundName, SoundListType type);
}