import 'dart:async';

import 'package:respire/services/SoundManagers/SingleSoundManager.dart';

class PlaylistManager {

  SingleSoundManager _delegate = SingleSoundManager();

  ///Playlist only variables
  int _currentIndex = 0;
  bool _paused = false;
  bool _stopped = false;
  var _playlistCompleter = Completer<void>();
  List<String> _playlist = [];
  
  ///Use only to play a new playlist
  Future<void> playPlaylist(List<String> soundNames) async {
    if(soundNames.isEmpty) return;
    
    _currentIndex = 0;
    _paused = false;
    _stopped = false;
    _playlist = soundNames;
    
    for(String soundName in _playlist){
      await _delegate.loadSound(soundName);
    }
    
    await resumePlaylist();
  }

  ///Use to resume the playlist after it's been paused
  Future<void> resumePlaylist() async {
    if (_playlist.isEmpty || _stopped) return;
    
    _playlistCompleter = Completer<void>();
    _paused = false;
    
    Future<void> playNext() async {
      if (_currentIndex >= _playlist.length){
        _currentIndex = 0;
      }

      String soundName = _playlist[_currentIndex];
      final player = _delegate.getPlayer(soundName)!;

      _delegate.playSound(soundName);

      //Sketchy gimmic to be able to pause even on short sounds/ sound switches
      await Future.any([player.onPlayerComplete.first, _playlistCompleter.future]);
      if(_paused) return;

      _currentIndex++;
      await playNext();
    }

    playNext();
  }

  ///Use to pause the playlist
  Future<void> pausePlaylist() async {
    if(_paused) return;

    if (!_playlistCompleter.isCompleted) {
      _playlistCompleter.complete(); 
    }
    _delegate.pauseSound(_delegate.currentlyPlaying.value);
    _paused = true;
  }

  ///Use when the playlist will not be played anymore.
  ///Eg. When we want to stop it completly from playing at the end of a training.
  void completePlaylist() {
    if (_stopped) return;
    _stopped = true;
    _paused = false;
    _playlist = [];
    _currentIndex = 0;

    if (!_playlistCompleter.isCompleted) {
      _playlistCompleter.complete();
    }

    _delegate.stopAllSounds();
  }
}