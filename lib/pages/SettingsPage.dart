import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:respire/services/TranslationProvider/AppLanguage.dart';
import 'package:respire/services/SettingsProvider.dart';
import 'package:respire/utils/TextUtils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TranslationProvider translationProvider = TranslationProvider();
  bool photoAdded = false;

  Widget _firstBox(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: Offset(0, 3),)
        ]
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(
            translationProvider.getTranslation("SettingsPage.app_section_title"),
            style: TextStyle(fontSize: 26, fontFamily: 'Glacial', fontWeight: FontWeight.w300, color: Colors.black),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: mediumblue, width: 1),
            ),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translationProvider.getTranslation("SettingsPage.language_label"), style: TextStyle(fontSize: 16)),
                  DropdownButton2<AppLanguage>(
                    underline: SizedBox(),
                    value: SettingsProvider().currentLanguage,
                    onChanged: (value) async {
                      SettingsProvider().setLanguage(value!);
                      await translationProvider.loadLanguage(value);
                      setState(() {});
                    },
                    items: AppLanguage.supportedLanguages
                        .map((lang) => DropdownMenuItem<AppLanguage>(
                              value: lang,
                              child: Text(lang.name),
                            ))
                        .toList(),
                    iconStyleData: IconStyleData(
                      icon: Icon(Icons.arrow_drop_down, color: darkerblue),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondBox(double screenWidth) {
  return Container(
    width: screenWidth * 0.9,
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          translationProvider.getTranslation("SettingsPage.app_second_section_title"),
          style: TextStyle(
            fontSize: 26,
            fontFamily: 'Glacial',
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child:
            Text(
            TextUtils.addNoBreakingSpaces(translationProvider.getTranslation("SettingsPage.app_description")),
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          ),
        SizedBox(height: 20),
        Icon(
          Icons.air,
          size: 70,
          color: darkerblue,
        ),
        SizedBox(height: 20),
        Text(
          "© ${DateTime.now().year} ${translationProvider.getTranslation("SettingsPage.copyright")}",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          translationProvider.getTranslation("SettingsPage.page_title"),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Glacial',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: mediumblue,
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0), 
        child: 
          Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              _firstBox(screenWidth),
              SizedBox(height: 20),
              _secondBox(screenWidth),
            ],
          ),
        ),
      ),
    ),
    );
  }
}