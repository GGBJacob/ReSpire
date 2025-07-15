import 'dart:convert';
import 'package:flutter/services.dart';

class TranslationProvider {
  
  TranslationProvider._privateConstructor(){init();}
  // Singleton instance
  static final TranslationProvider _instance = TranslationProvider._privateConstructor();
  factory TranslationProvider() {
    return _instance;
  }

  void init() {
    // Load the default language
    loadLanguage(_defaultLanguage);
  }

  final Map<String, String> _languages = {
    "pl_PL": "pl_PL.json",
    "en_US": "en_US.json",
  };
  final String _defaultLanguage = "pl_PL";
  
  Map<String, String> _translations = {};
  String _currentLanguage = "pl_PL";
  String get currentLanguage => _currentLanguage;

  List<String> get supportedLanguages => _languages.keys.toList();

  void loadLanguage(String language) async{
    String loadingFile = _languages[language] ?? _languages[_defaultLanguage]!;
    _currentLanguage = language;
    String jsonContent = await rootBundle.loadString("assets/translations/$loadingFile");
    _translations = Map<String, String>.from(json.decode(jsonContent));
    print("Loading language: $language");
  }

  String getTranslation(String key) {
    var searchKey = key.toLowerCase();
    String value = _translations.containsKey(searchKey) ? _translations[searchKey]! : key;
    return value;
  }
}