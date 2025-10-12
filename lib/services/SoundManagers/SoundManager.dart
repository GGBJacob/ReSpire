import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/PresetDataBase.dart';
import 'package:respire/services/UserSoundsDataBase.dart';

class SoundManager implements ISoundManager {
  SoundManager(){
    log("SoundManager initialized.");
  }

  static final Map<String,String?> _longSounds = {
    "Birds":"sounds/birds.mp3",
    "Ainsa":"sounds/Ainsa.mp3",
    "Rain":"sounds/rain.mp3",
    "Ocean":"sounds/ocean-waves.mp3",
    
  };

  static final Map<String,String?> _shortSounds = {
    "Notification":"sounds/new-notification.mp3",
    "Whistle Up":"sounds/whistle-up.mp3",
    "Whistle Down":"sounds/whistle-down.mp3",
  };


  ///A map of available sounds in the assets folder.\
  ///The keys are the sound names, and the values are the paths to the sound files.
  static final Map<String,String?> _availableSounds = {
    ..._longSounds,
    ..._shortSounds,
    ...UserSoundsDatabase().userLongSounds,
    ...UserSoundsDatabase().userShortSounds,
  };

  final HashMap<String,AudioPlayer> _audioPlayers = HashMap<String,AudioPlayer>();

  @override
  Map<String, String?> getSounds(SoundListType type) {
    switch (type) {
      case SoundListType.longSounds:
        return _longSounds;
      case SoundListType.shortSounds:
        return _shortSounds;
    }
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
    setPlayerSettings(audioPlayer);

    bool isAsset = _availableSounds[soundName]!.startsWith("sounds/");
    try{

      if(isAsset){
        await audioPlayer.setSource(AssetSource(_availableSounds[soundName]!));
      }
      else {
        await audioPlayer.setSource(DeviceFileSource(_availableSounds[soundName]!));
      }

      _audioPlayers[soundName] = audioPlayer;
      log("Sound $soundName loaded successfully.");
      return true;
    } catch (e) {
      log("Error loading sound $soundName: $e");
      return false;
    }
  }

  void setPlayerSettings(AudioPlayer audioPlayer) {
    audioPlayer.setAudioContext(createAudioContext());
    audioPlayer.setReleaseMode(ReleaseMode.stop);
    audioPlayer.onPlayerComplete.listen((event) async {
        await audioPlayer.seek(Duration.zero);
    });
  }

  AudioContext createAudioContext() {
    return AudioContext(
    android: AudioContextAndroid(
      isSpeakerphoneOn: true,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      // This is the most important part.
      // It tells the player not to request focus, so it won't interrupt others.
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: {
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
  );
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

  ///Plays a sound from a file in the assets folder.
  @override
  Future<void> playSound(String? soundName) async{
    if(_availableSounds[soundName] == null) {
      log("Sound: $soundName is not available.");
      return;
    }
    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound: $soundName is not loaded. Loading now...");
      if(await loadSound(soundName!)){
        playSound(soundName);
      }
      return;
    }
    log("Playing sound: $soundName");
    await _audioPlayers[soundName]!.resume();
  }

  ///Plays a sound from a file in the assets folder with a fade-in effect.\
  ///[fadeInDuration] is the duration of the effect in milliseconds.
  @override
  Future<void> playSoundFadeIn(String? soundName, int fadeInDuration) async{
    if(_availableSounds[soundName] == null) {
      return;
    }

    await loadSound(soundName!);
    var player = _audioPlayers[soundName]!;
    final int stepDuration = 50;
    player.setVolume(0.0);

    int steps = (fadeInDuration / stepDuration).ceil();
    double volumeStep = 1.0 / steps;

    await playSound(soundName);

    for (int i=0; i<steps; i++)
    {
      double newVolume = player.volume + volumeStep;
      if (newVolume > 1.0) newVolume = 1.0;
      log("Fade in: Volume step: $newVolume");
      await player.setVolume(newVolume);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
  }


  ///Pauses a sound from a file in the assets folder if playing.
  @override
  Future<void> pauseSound(String? soundName) async {
    if (_availableSounds[soundName] == null || !_audioPlayers.containsKey(soundName)) {
      log("Sound: $soundName is not available.");
      return;
    }
    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound: $soundName is not loaded. Cannot pause.");
      return;
    }
    log("Pausing sound: $soundName");
    await _audioPlayers[soundName]!.pause();
  }

  ///Stops a sound from a file in the assets folder if playing.
  ///This will stop the sound and reset it to the beginning.
  @override
  Future<void> stopSound(String? soundName) async{
    if(_availableSounds[soundName] == null) {
      log("Sound: $soundName is not available.");
      return;
    }

    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound: $soundName is not loaded. Cannot stop.");
      return;
    }

    log("Stopping sound: $soundName");
    await _audioPlayers[soundName]!.stop();
  }

  ///Pauses the provided sound with a fade-out effect.\
  ///[fadeOutDuration] is the duration of the effect in milliseconds.
  @override
  Future<void> pauseSoundFadeOut(String? soundName, int fadeOutDuration) async{
    if(_availableSounds[soundName] == null || !_audioPlayers.containsKey(soundName)) {
      return;
    }
    
    var player = _audioPlayers[soundName]!;
    final int stepDuration = 50;

    int steps = (fadeOutDuration / stepDuration).ceil();
    double volumeStep = 1.0 / steps;

    for(int i=0; i<steps; i++)
    {
      double newVolume = player.volume - volumeStep;
      if (newVolume < 0.0) newVolume = 0.0;
      log("Fade out: Volume step: $newVolume");
      await player.setVolume(newVolume);
      await Future.delayed(Duration(milliseconds: stepDuration));
    }
    await pauseSound(soundName!);
    await player.setVolume(1.0);
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

  @override
  void refreshSoundsList() {
    _availableSounds.clear();
    _availableSounds.addAll(_longSounds);
    _availableSounds.addAll(_shortSounds);
    _availableSounds.addAll(UserSoundsDatabase().userLongSounds);
    _availableSounds.addAll(UserSoundsDatabase().userShortSounds);
  }

  @override
  void removeUserSound(String soundName, SoundListType type) {
    _availableSounds.remove(soundName);
    if (_audioPlayers.containsKey(soundName)) {
      _audioPlayers[soundName]!.dispose();
      _audioPlayers.remove(soundName);
    }
    PresetDataBase().clearUserSound(soundName);
  }
}