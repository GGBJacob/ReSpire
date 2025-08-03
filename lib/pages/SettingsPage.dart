import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:respire/services/TranslationProvider/AppLanguage.dart';
import 'package:respire/services/SettingsProvider.dart';

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
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Text(
            translationProvider.getTranslation("SettingsPage.app_section_title"),
            style: TextStyle(fontSize: 30, fontFamily: 'Glacial'),
          ),
          SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translationProvider.getTranslation("SettingsPage.language_label")),
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _firstBox(screenWidth),
          ],
        ),
      ),
    );
  }
}
