import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/PresetEntry.dart';

class PresetDataBase {

  List<PresetEntry> presetList = [];

  final _box = Hive.box('respire');

  void initialize()
  {
    if (_box.get('presets') == null) // If this is the first time launching the app
    {
      createInitialData();
    }
    else
    {
      loadData();
    }
  }

  void createInitialData()
  {
    presetList = [
      PresetEntry(title: "Deep Serenity", description: "", breathCount: 30, inhaleTime: 5, exhaleTime: 7, retentionTime: 10),
      PresetEntry(title: "Vital Energy", description: "", breathCount: 10, inhaleTime: 3, exhaleTime: 3, retentionTime: 15),
      PresetEntry(title: "Breath Mastery", description: "Wim Hof's breathing technique", breathCount: 40, inhaleTime: 3, exhaleTime: 3, retentionTime: 15)
    ];
  }

  void loadData()
  {
    final storedList = _box.get('presets');
    if (storedList != null) {
      presetList = (storedList as List).cast<PresetEntry>();
    }
  }

  void updateDataBase()
  {
    _box.put('presets', presetList);
  }
}