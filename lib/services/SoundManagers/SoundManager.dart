import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/PresetDataBase.dart';
import 'package:respire/services/UserSoundsDataBase.dart';
import 'package:respire/components/Global/Sounds_lists.g.dart';
import 'package:respire/services/SoundManagers/AudioPlayerPool.dart';

class SoundManager implements ISoundManager {
  
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  static final longSounds = ReSpireSounds().longSounds;
  static final shortSounds = ReSpireSounds().shortSounds;
  static final countingSounds = ReSpireSounds().countingSounds;

  ///A map of available sounds in the assets folder.\
  ///The keys are the sound names, and the values are the paths to the sound files.
  static final Map<String,SoundAsset> _availableSounds = {
    ...longSounds,
    ...shortSounds,
    ...countingSounds,
    ...UserSoundsDatabase().userLongSounds,
    ...UserSoundsDatabase().userShortSounds,
    ...UserSoundsDatabase().userCountingSounds,
  };

  final HashMap<String,AudioPlayer> _audioPlayers = HashMap<String,AudioPlayer>();
  final Map<String, AudioPlayerPool> _pools = {};
  final int _maxPoolSizePerSound = 5;

  @override
  Map<String, SoundAsset> getSounds(SoundListType type) {
    switch (type) {
      case SoundListType.longSounds:
        return longSounds;
      case SoundListType.shortSounds:
        return shortSounds;
      case SoundListType.countingSounds:
        return countingSounds;
    }
  }

  AudioPlayer? getPlayer(String soundName) {
    return _audioPlayers[soundName];
  }

  SoundAsset? getAsset(String soundName){
    return _availableSounds[soundName];
  }

  bool isUserMusic(String soundName) {
    return UserSoundsDatabase().userShortSounds.containsKey(soundName) ||
        UserSoundsDatabase().userLongSounds.containsKey(soundName) ||
        UserSoundsDatabase().userCountingSounds.containsKey(soundName);
  }

  ///Loads a sound from a file.\
  /// [forceCommonSetup] if true, will setup the audio player with common settings regardless of type.\
  /// [soundName] is the name of the sound file returned by **getLoadedSounds()**.
  @override
  Future<bool> loadSound(String soundName) async{
    if(_availableSounds[soundName] == null) {
      log("Could not load sound: $soundName is not available.");
      return false;
    }
    if (_audioPlayers.containsKey(soundName)) {
      return true;
    }
    else if (!_availableSounds.containsKey(soundName)) {
      log("Sound $soundName is not available in the assets folder.");
      return false;
    }
    AudioPlayer audioPlayer = AudioPlayer();
    
    SoundAsset asset = _availableSounds[soundName]!;
    
    _commonAudioPlayerSetup(audioPlayer);
    
    try{
      await audioPlayer.setSource(_getSourceForAsset(asset));
      _audioPlayers[soundName] = audioPlayer;
      log("Sound $soundName loaded successfully.");
      return true;
    } catch (e) {
      log("Error loading sound $soundName: $e");
      return false;
    }
  }

  void _commonAudioPlayerSetup(AudioPlayer audioPlayer) {
  // Shared audio context to allow multiple sounds simultaneously
  audioPlayer.setAudioContext(
    AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
    ),
  );

  audioPlayer.setReleaseMode(ReleaseMode.stop);
}

  void setupLowLatencyAudioPlayer(AudioPlayer audioPlayer) {
    _commonAudioPlayerSetup(audioPlayer);
    audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  ///Lists all sounds that are currently loaded in the service.
  @override
  List<String> getLoadedSounds() {
    return _audioPlayers.keys.toList();
  }

  ///Returns all sounds that are available in the assets folder.
  @override
  List<String> getAvailableSounds(){
    return _availableSounds.keys.toList();
  }

  @override
  Future<void> playSound(String? soundName) async {
    if (soundName == null || _availableSounds[soundName] == null) return;
    final asset = _availableSounds[soundName]!;
    if (asset.type == SoundType.cue || asset.type == SoundType.counting) {
      await _playShortSound(soundName, asset);
      return;
    }

    await loadSound(soundName);
    final player = _audioPlayers[soundName];
    if (player != null) await player.resume();
  }

  Future<void> _playShortSound(String soundName, SoundAsset asset) async {
    final pool = _pools.putIfAbsent(soundName, () => AudioPlayerPool(size: _maxPoolSizePerSound));

    AudioPlayer? slot = pool.next;

    setupLowLatencyAudioPlayer(slot);
    
    await slot.play(_getSourceForAsset(asset));
  }

  Source _getSourceForAsset(SoundAsset asset) {
    if (asset.path.startsWith("sounds/")) {
      return AssetSource(asset.path);
    } else {
      return DeviceFileSource(asset.path);
    }
  }

  ///Plays a sound from a file in the assets folder with a fade-in effect.\
  ///[fadeInDuration] is the duration of the effect in milliseconds.
  @override
  Future<void> playSoundFadeIn(String? soundName, int fadeInDuration) async{
    if(soundName == null || _availableSounds[soundName] == null) {
      return;
    }

    await loadSound(soundName);
    var player = _audioPlayers[soundName];
    if (player == null) {
      return;
    }
    final int breathingPhaseDuration = 50;
    player.setVolume(0.0);

    int breathingPhases = (fadeInDuration / breathingPhaseDuration).ceil();
    double volumeBreathingPhase = 1.0 / breathingPhases;

    await playSound(soundName);

    for (int i=0; i<breathingPhases; i++)
    {
      double newVolume = player.volume + volumeBreathingPhase;
      if (newVolume > 1.0) newVolume = 1.0;
      log("Fade in: Volume breathing phase: $newVolume");
      await player.setVolume(newVolume);
      await Future.delayed(Duration(milliseconds: breathingPhaseDuration));
    }
  }


  ///Pauses a sound from a file in the assets folder if playing.
  @override
  Future<void> pauseSound(String? soundName) async {
    if (soundName == null || _availableSounds[soundName] == null || !_audioPlayers.containsKey(soundName)) {
      log("Sound: $soundName is not available.");
      return;
    }
    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound: $soundName is not loaded. Cannot pause.");
      return;
    }
    log("Pausing sound: $soundName");
    var player = _audioPlayers[soundName];
    if (player != null) {
      await player.pause();
    }
  }

  ///Stops a sound from a file in the assets folder if playing.
  ///This will stop the sound and reset it to the beginning.
  @override
  Future<void> stopSound(String? soundName) async{
    if(soundName == null || _availableSounds[soundName] == null) {
      log("Sound: $soundName is not available.");
      return;
    }

    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound: $soundName is not loaded. Cannot stop.");
      return;
    }

    log("Stopping sound: $soundName");
    var player = _audioPlayers[soundName];
    if (player != null) {
      await player.stop();
    }
  }

  Future<void> fadeOut(String? soundName, int fadeOutDuration) async {
    if(soundName == null || _availableSounds[soundName] == null) {
      return;
    }
    var player = _audioPlayers[soundName];
    if (player == null) {
      return;
    }
    final int breathingPhaseDuration = 50;

    int breathingPhases = (fadeOutDuration / breathingPhaseDuration).ceil();
    double volumeBreathingPhase = 1.0 / breathingPhases;

    for(int i=0; i<breathingPhases; i++)
    {
      double newVolume = player.volume - volumeBreathingPhase;
      if (newVolume < 0.0) newVolume = 0.0;
      log("Fade out: Volume breathing phase: $newVolume");
      await player.setVolume(newVolume);
      await Future.delayed(Duration(milliseconds: breathingPhaseDuration));
    }
    await player.setVolume(1.0);
  }

  ///Pauses the provided sound with a fade-out effect.\
  ///[fadeOutDuration] is the duration of the effect in milliseconds.
  @override
  Future<void> pauseSoundFadeOut(String? soundName, int fadeOutDuration) async{
    if (soundName == null) {
      return;
    }
    await fadeOut(soundName, fadeOutDuration);
    await pauseSound(soundName);
  }

  ///Stops all sounds that are currently playing.
  ///This will not unload the sounds, just stop and reset them.
  @override
  void stopAllSounds() {
    log("Stopping all sounds.");
    for (var player in _audioPlayers.values) {
      Source? currentSource = player.source;
      player.stop();
      if (currentSource != null) {
        player.setSource(currentSource);
      }
    }
  }

  void refreshSoundsList() {
    _availableSounds.clear();
    _availableSounds.addAll(longSounds);
    _availableSounds.addAll(shortSounds);
    _availableSounds.addAll(countingSounds);
    _availableSounds.addAll(UserSoundsDatabase().userLongSounds);
    _availableSounds.addAll(UserSoundsDatabase().userShortSounds);
    _availableSounds.addAll(UserSoundsDatabase().userCountingSounds);
  }

  void removeUserSound(String soundName, SoundListType type) {
    _availableSounds.remove(soundName);
    if (_audioPlayers.containsKey(soundName)) {
      var player = _audioPlayers[soundName];
      if (player != null) {
        player.dispose();
      }
      _audioPlayers.remove(soundName);
    }
    PresetDataBase().clearUserSound(soundName);
  }

  Future<Duration?> getSoundDuration(String soundName) async {
    if (!_audioPlayers.containsKey(soundName)) {
      bool loaded = await loadSound(soundName);
      if (!loaded) return null;
    }
    
    final player = _audioPlayers[soundName];
    if (player == null) return null;
    
    // Get duration from player
    return await player.getDuration();
  }

  void dispose() {
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    for (var pool in _pools.values) {
      pool.dispose();
    }
    _audioPlayers.clear();
    log("SoundManager disposed and audio focus released.");
  }
}