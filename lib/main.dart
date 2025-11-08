import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Settings.dart';
import 'package:respire/components/Global/SoundScope.dart';
import 'package:respire/components/Global/Sounds.dart';
import 'package:respire/components/Global/SoundAsset.dart';
import 'package:respire/components/Global/Step.dart';
import 'package:respire/components/Global/StepIncrement.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/pages/HomePage.dart';
import 'package:respire/services/TextToSpeechService.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/services/UserSoundsDataBase.dart';
import 'package:respire/components/Global/PhaseSounds.dart';
import 'theme/Colors.dart';

void main() async{
  
  WidgetsFlutterBinding.ensureInitialized();

  await initialize();
  runApp(const MainApp());
}

Future<void> initialize() async
{
  await Hive.initFlutter();
  // If any changes in loaded data occur, uncomment the following
  // line to delete the data and load it again
  // await Hive.deleteBoxFromDisk('respire'); // disable deleting local storage to retain presets between restarts
  Hive.registerAdapter(BreathingPhaseAdapter());
  Hive.registerAdapter(BreathingPhaseTypeAdapter());
  Hive.registerAdapter(BreathTypeAdapter());
  Hive.registerAdapter(BreathDepthAdapter());
  Hive.registerAdapter(BreathingPhaseIncrementTypeAdapter());
  Hive.registerAdapter(BreathingPhaseIncrementAdapter());
  Hive.registerAdapter(TrainingStageAdapter());
  Hive.registerAdapter(TrainingAdapter());
  Hive.registerAdapter(SoundAssetAdapter());
  Hive.registerAdapter(SoundScopeAdapter());
  Hive.registerAdapter(SoundTypeAdapter());
  Hive.registerAdapter(SoundsAdapter());
  Hive.registerAdapter(SettingsAdapter());
  Hive.registerAdapter(BreathingPhaseSoundsAdapter());
  await Hive.openBox('respire');
  await Hive.openBox('userShortSounds');
  await Hive.openBox('userLongSounds');
  await TextToSpeechService().init();
  UserSoundsDatabase().loadData();
  TranslationProvider();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final translationProvider = TranslationProvider();
    return AnimatedBuilder(
      animation: translationProvider,
      builder: (context, _) => MaterialApp(
        theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: darkerblue,             
          selectionColor: lightblue, 
          selectionHandleColor: darkerblue,    
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkerblue, 
          ).copyWith(
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
        home: HomePage(),
      ),
    );
  }
}
