import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/PresetDataBase.dart';
import 'package:respire/services/UserSoundsDataBase.dart';
import 'package:respire/components/Global/Sounds_lists.g.dart';

class SoundManager implements ISoundManager {
  SoundManager(){}

  static final longSounds = ReSpireSounds().longSounds;
  static final shortSounds = ReSpireSounds().shortSounds;

  ///A map of available sounds in the assets folder.\
  ///The keys are the sound names, and the values are the paths to the sound files.
  static final Map<String,SoundAsset> _availableSounds = {
    ...longSounds,
    ...shortSounds,
    ...UserSoundsDatabase().userLongSounds,
    ...UserSoundsDatabase().userShortSounds,
  };

  final HashMap<String,AudioPlayer> _audioPlayers = HashMap<String,AudioPlayer>();

  @override
  Map<String, SoundAsset> getSounds(SoundListType type) {
    switch (type) {
      case SoundListType.longSounds:
        return longSounds;
      case SoundListType.shortSounds:
        return shortSounds;
    }
  }

  AudioPlayer? getPlayer(String soundName) {
    return _audioPlayers[soundName];
  }

  SoundAsset? getAsset(String soundName){
    return _availableSounds[soundName];
  }

  ///Loads a sound from a file.\
  ///[soundName] is the name of the sound file returned by **getLoadedSounds()**.
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
    
    if (asset.type == SoundType.cue) {
      setupLowLatencyAudioPlayer(audioPlayer);
    } else {
      _commonAudioPlayerSetup(audioPlayer);
    }

    bool isAsset = asset.path.startsWith("sounds/");
    try{
      if(isAsset){
        await audioPlayer.setSource(AssetSource(asset.path));
      }
      else {
        await audioPlayer.setSource(DeviceFileSource(asset.path));
      }

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

  Future<void> ensureSoundLoaded(String? soundName) async{
    if (soundName == null) {
      return;
    }
    final asset = _availableSounds[soundName];
    if (asset == null) {
      return;
    }
    
    //If cue, always remove old entry
    if (asset.type == SoundType.cue && _audioPlayers.containsKey(soundName)) {
      var player = _audioPlayers[soundName];
      if (player != null) {
        player.dispose();
      }
      _audioPlayers.remove(soundName);
    }

    //Load if needed
    if (!_audioPlayers.containsKey(soundName)) {
      await loadSound(soundName);
    }
  }

  ///Plays a sound from a file in the assets folder.
  @override
  Future<void> playSound(String? soundName) async{
    if (soundName == null || _availableSounds[soundName] == null){
      return;
    }
    await ensureSoundLoaded(soundName);
    log("Playing sound: $soundName");

    var player = _audioPlayers[soundName];
    if (player == null) {
      return;
    }
    if (_availableSounds[soundName]!.type == SoundType.cue) {
      await player.play(player.source!);
    } else {
      await player.resume();
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
    _availableSounds.addAll(UserSoundsDatabase().userLongSounds);
    _availableSounds.addAll(UserSoundsDatabase().userShortSounds);
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
    _audioPlayers.clear();
    log("SoundManager disposed and audio focus released.");
  }
}