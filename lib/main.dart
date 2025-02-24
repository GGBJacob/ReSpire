import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:respire/pages/HomePage.dart';
import 'components/PresetEntry.dart';

void main() async{

  await Hive.initFlutter();
  Hive.registerAdapter(PresetEntryAdapter());
  await Hive.openBox('respire');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage()
    );
  }
}
