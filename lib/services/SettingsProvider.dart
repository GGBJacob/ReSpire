
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();
  factory SettingsProvider() => _instance;

  SettingsProvider._internal();

  String voiceType = "";

  Future<void> init() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    voiceType = sharedPreferences.getString("voiceType") ?? "en-US";
    log("Loaded voice type: $voiceType");
  }

  Future<void> setVoiceType(String newVoiceType) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    voiceType = newVoiceType;
    await sharedPreferences.setString("voiceType", newVoiceType);
    notifyListeners();
  } 

  String getVoiceType() {
    return voiceType;
  }
}