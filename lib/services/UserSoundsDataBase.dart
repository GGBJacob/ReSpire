import 'package:hive/hive.dart';
import 'package:respire/services/SoundManagers/ISoundManager.dart';
import 'package:respire/services/SoundManagers/SoundManager.dart';

class UserSoundsDatabase {
  static final UserSoundsDatabase _instance = UserSoundsDatabase._internal();
  UserSoundsDatabase._internal();

  factory UserSoundsDatabase() {
    return _instance;
  }

  final _shortBox = Hive.box('userShortSounds');
  final _longBox = Hive.box('userLongSounds');

  final Map<String, String> _userShortSounds = {};
  final Map<String, String> _userLongSounds = {};

  Map<String,String> get userShortSounds => Map.unmodifiable(_userShortSounds);
  Map<String,String> get userLongSounds => Map.unmodifiable(_userLongSounds);

  void loadData()
  {
    final storedMap = _shortBox.get('userShortSounds');
    if (storedMap is Map) {
      _userShortSounds.addAll(storedMap.cast<String, String>());
    }

    final storedMapLong = _longBox.get('userLongSounds');
    if (storedMapLong is Map) {
      _userLongSounds.addAll(storedMapLong.cast<String, String>());
    }
  }

  void addShortSound(MapEntry<String, String> sound) {
    if (!_userShortSounds.containsKey(sound.key)) {
      _userShortSounds[sound.key] = sound.value;
      updateDatabase();
    }
  }

  void addLongSound(MapEntry<String, String> sound) {
    if (!_userLongSounds.containsKey(sound.key)) {
      _userLongSounds[sound.key] = sound.value;
      updateDatabase();
    }
  }

  void removeSound(String soundName, SoundListType type) {
    if (type == SoundListType.longSounds) {
      _userLongSounds.remove(soundName);
    } else {
      _userShortSounds.remove(soundName);
    }
    updateDatabase();
    postRemoveSound(soundName, type);
  }

  void postRemoveSound(String soundName, SoundListType type) {
    SoundManager().removeUserSound(soundName, type);
  }

  void updateDatabase() {
    _shortBox.put('userShortSounds', _userShortSounds);
    _longBox.put('userLongSounds', _userLongSounds);
    SoundManager().refreshSoundsList();
  }

}