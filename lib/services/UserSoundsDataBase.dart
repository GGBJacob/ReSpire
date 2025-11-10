import 'package:hive/hive.dart';
import 'package:respire/components/Global/SoundAsset.dart';
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
  final _countingBox = Hive.box('userCountingSounds');

  final Map<String, SoundAsset> _userShortSounds = {};
  final Map<String, SoundAsset> _userLongSounds = {};
  final Map<String, SoundAsset> _userCountingSounds = {};

  Map<String,SoundAsset> get userShortSounds => Map.unmodifiable(_userShortSounds);
  Map<String,SoundAsset> get userLongSounds => Map.unmodifiable(_userLongSounds);
  Map<String,SoundAsset> get userCountingSounds => Map.unmodifiable(_userCountingSounds);

  void loadData()
  {
    final storedMap = _shortBox.get('userShortSounds');
    if (storedMap is Map) {
      _userShortSounds.addAll(storedMap.cast<String, SoundAsset>());
    }

    final storedMapLong = _longBox.get('userLongSounds');
    if (storedMapLong is Map) {
      _userLongSounds.addAll(storedMapLong.cast<String, SoundAsset>());
    }

    final storedMapCounting = _countingBox.get('userCountingSounds');
    if (storedMapCounting is Map) {
      _userCountingSounds.addAll(storedMapCounting.cast<String, SoundAsset>());
    }
  }

  void addShortSound(SoundAsset sound) {
    if (!_userShortSounds.containsKey(sound.name)) {
      _userShortSounds[sound.name] = sound;
      updateDatabase();
    }
  }

  void addLongSound(SoundAsset sound) {
    if (!_userLongSounds.containsKey(sound.name)) {
      _userLongSounds[sound.name] = sound;
      updateDatabase();
    }
  }

  void addCountingSound(SoundAsset sound) {
    if (!_userCountingSounds.containsKey(sound.name)) {
      _userCountingSounds[sound.name] = sound;
      updateDatabase();
    }
  }
  void removeSound(String soundName, SoundListType type) {
    if (type == SoundListType.longSounds) {
      _userLongSounds.remove(soundName);
    } else if (type == SoundListType.shortSounds) {
      _userShortSounds.remove(soundName);
    } else {
      _userCountingSounds.remove(soundName);
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
    _countingBox.put('userCountingSounds', _userCountingSounds);
    SoundManager().refreshSoundsList();
  }

}