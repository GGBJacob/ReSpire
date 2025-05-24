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
    "birds":"sounds/birds.mp3",
    "Ainsa":"sounds/Ainsa.mp3"
  };

  final HashMap<String,AudioPlayer> _audioPlayers = HashMap<String,AudioPlayer>();

  ///Loads a sound from a file in the assets folder.\
  ///[soundName] is the name of the sound file returned by **getLoadedSounds()**.
  Future<bool> loadSound(String soundName) async{
    if (_audioPlayers.containsKey(soundName)) {
      return true;
    }
    else if (!_availableSounds.containsKey(soundName)){
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
  void playSoundFadeIn(String soundName, int fadeInDuration) async{
    await loadSound(soundName);
    var player = _audioPlayers[soundName]!;
    final int stepDuration = 50;
    player.setVolume(0.0);
    await playSound(soundName);
    Timer.periodic(Duration(milliseconds: stepDuration), (timer){
      if (player.volume < 1.0){
        double newVolume = player.volume + (stepDuration / fadeInDuration);
        if (newVolume > 1.0) newVolume = 1.0;
        player.setVolume(newVolume);
      } else {
        timer.cancel();
      }
    });
  }


  ///Pauses a sound from a file in the assets folder if playing.
  Future<void> pauseSound(String soundName) async {
    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound $soundName is not loaded. Cannot pause.");
      return;
    }
    log("Pausing sound: $soundName");
    await _audioPlayers[soundName]!.pause();
  }

  ///Pauses the provided sound with a fade-out effect.\
  ///[fadeOutDuration] is the duration of the effect in milliseconds.
  void pauseSoundFadeOut(String soundName, int fadeOutDuration) async{
    if (!_audioPlayers.containsKey(soundName)) {
      log("Sound $soundName is not loaded. Cannot pause.");
      return;
    }
    var player = _audioPlayers[soundName]!;
    final int stepDuration = 50;
    await playSound(soundName);
    Timer.periodic(Duration(milliseconds: stepDuration), (timer) async{
      if (player.volume > 0.0){
        double newVolume = player.volume - (stepDuration / fadeOutDuration);
        if (newVolume < 0.0) newVolume = 0.0;
        player.setVolume(newVolume);
      } else {
        await pauseSound(soundName);
        timer.cancel();
      }
    });
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