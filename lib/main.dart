import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/pages/HomePage.dart';
import 'package:respire/services/TextToSpeechService.dart';


void main() async{
  await initialize();
  runApp(const MainApp());
}

Future<void> initialize() async
{
  await Hive.initFlutter();
  // If any changes in loaded data occur, uncomment the following
  // line to delete the data and load it again
  // await Hive.deleteBoxFromDisk('respire');
  Hive.registerAdapter(StepTypeAdapter());
  Hive.registerAdapter(BreathTypeAdapter());
  Hive.registerAdapter(BreathDepthAdapter());
  Hive.registerAdapter(IncrementTypeAdapter());
  Hive.registerAdapter(StepIncrementAdapter());
  Hive.registerAdapter(StepAdapter());
  Hive.registerAdapter(PhaseAdapter());
  Hive.registerAdapter(TrainingAdapter());
  await Hive.openBox('respire');
  await TextToSpeechService().init();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage());
  }
}
