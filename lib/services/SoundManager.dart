import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';

class SoundManager{
  static final SoundManager _instance = SoundManager._internal();
  SoundManager._internal();
  factory SoundManager() {
    return _instance;
  }

  ///A map of available sounds in the assets folder.\
  ///The keys are the sound names, and the values are the paths to the sound files.
  ///
  // MAKE SURE TO ADD YOUR SOUNDS TO THIS MAP!
  static const Map<String,String> _availableSounds = {
    "None":"",
    "Birds":"sounds/birds.mp3",
    "Ainsa":"sounds/Ainsa.mp3",
    "Rain":"sounds/rain.mp3",
    "Ocean":"sounds/ocean-waves.mp3",
    
  };

  final HashMap<String,AudioPlayer> _audioPlayers = HashMap<String,AudioPlayer>();

  ///Loads a sound from a file in the assets folder.\
  ///[soundName] is the name of the sound file returned by **getLoadedSounds()**.
  Future<bool> loadSound(String soundName) async{
    if(soundName == "None") {
      log("No sound to load.");
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
    try{
      await audioPlayer.setSource(AssetSource(_availableSounds[soundName]!));
      _audioPlayers[soundName] = audioPlayer;
      log("Sound $soundName loaded successfully.");
      return true;
    } catch (e) {
      log("Error loading sound $soundName: $e");
      return false;
    }
  }

  ///Lists all sounds that are currently loaded in the service.
  List<String> getLoadedSounds() {
    return _audioPlayers.keys.toList();
  }

  ///Returns all sounds that are available in the assets folder.
  List<String> getAvailableSounds(){
    return _availableSounds.keys.toList();
  }

  ///Plays a sound from a file in the assets folder.
  Future<void> playSound(String soundName) async{
    if(soundName == "None") {
      log("No sound to play.");
      return;
    }
    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound $soundName is not loaded. Loading now...");
      if(await loadSound(soundName)){
        playSound(soundName);
      }
      return;
    }
    log("Playing sound: $soundName");
    await _audioPlayers[soundName]!.resume();
  }

  ///Plays a sound from a file in the assets folder with a fade-in effect.\
  ///[fadeInDuration] is the duration of the effect in milliseconds.
  Future<void> playSoundFadeIn(String soundName, int fadeInDuration) async{
    if(soundName == "None") {
      return;
    }

    await loadSound(soundName);
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
  Future<void> pauseSound(String soundName) async {
    if(soundName == "None") {
      log("No sound to pause.");
      return;
    }
    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound $soundName is not loaded. Cannot pause.");
      return;
    }
    log("Pausing sound: $soundName");
    await _audioPlayers[soundName]!.pause();
  }

  ///Pauses the provided sound with a fade-out effect.\
  ///[fadeOutDuration] is the duration of the effect in milliseconds.
  Future<void> pauseSoundFadeOut(String soundName, int fadeOutDuration) async{
    if(soundName == "None" || !_audioPlayers.containsKey(soundName)) {
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

    await player.setVolume(1.0);
  }

  ///Stops all sounds that are currently playing.
  ///This will not unload the sounds, just stop and reset them.
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
}