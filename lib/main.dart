import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/pages/HomePage.dart';
import 'package:respire/services/TextToSpeechService.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'theme/Colors.dart';

void main() async{
  await initialize();
  runApp(const MainApp());
}

Future<void> initialize() async
{
  await Hive.initFlutter();
  // If any changes in loaded data occur, uncomment the following
  // line to delete the data and load it again
  // await Hive.deleteBoxFromDisk('respire'); // disable deleting local storage to retain presets between restarts
  Hive.registerAdapter(StepTypeAdapter());
  Hive.registerAdapter(BreathTypeAdapter());
  Hive.registerAdapter(BreathDepthAdapter());
  Hive.registerAdapter(IncrementTypeAdapter());
  Hive.registerAdapter(StepIncrementAdapter());
  Hive.registerAdapter(StepAdapter());
  Hive.registerAdapter(PhaseAdapter());
  Hive.registerAdapter(TrainingAdapter());
  Hive.registerAdapter(SoundsAdapter());
  await Hive.openBox('respire');
  await TextToSpeechService().init();
  TranslationProvider();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: darkerblue,             
          selectionColor: lightblue, 
          selectionHandleColor: darkerblue,    
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ),
        dialogBackgroundColor: Colors.white,
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
          ),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          contentTextStyle: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
    ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage()
    );
  }
}
