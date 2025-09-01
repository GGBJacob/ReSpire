import 'package:flutter/material.dart';
import 'package:respire/theme/Colors.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TranslationProvider translationProvider = TranslationProvider();
  bool photoAdded = false;

  Widget _firstBox(double screenWidth) {
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
              ),
              child: Column(children: [
                SizedBox(height: screenWidth * 0.4 / 2),
                Text(
                  translationProvider.getTranslation("ProfilePage.default_name"),
                  style: TextStyle(fontSize: 30, fontFamily: 'Glacial'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline),
                    SizedBox(width: 10),
                    Text(
                      translationProvider.getTranslation("ProfilePage.default_email"),
                      style: TextStyle(fontSize: 20, fontFamily: 'Glacial'),
                    ),
                  ],
                ),
                SizedBox(height: 20)
              ])),
          Positioned(
              top: -screenWidth * 0.4 / 2,
              child: Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                    child: Container(
                  width: screenWidth * 0.35,
                  height: screenWidth * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lightblue,
                  ),
                  child: photoAdded
                      ? SizedBox() //If photo is added
                      : Icon(
                          Icons.person,
                          size: screenWidth * 0.30,
                          color: darkerblue,
                        ),
                )),
              )),
        ]);
  }

  Widget _secondBox(double screenWidth) {
    return Container(
        width: screenWidth * 0.9,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              translationProvider.getTranslation("ProfilePage.badges_title"),
              style: TextStyle(fontSize: 30, fontFamily: 'Glacial'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightblue,
                    ),
                    child: Center(
                      child: Text(
                        "1",
                        style: TextStyle(color: darkerblue, fontSize: 24),
                      ),
                    )),
                SizedBox(width: 10),
                Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightblue,
                    ),
                    child: Center(
                      child: Text(
                        "2",
                        style: TextStyle(color: darkerblue, fontSize: 24),
                      ),
                    )),
                SizedBox(width: 10),
                Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightblue,
                    ),
                    child: Center(
                      child: Text(
                        "3",
                        style: TextStyle(color: darkerblue, fontSize: 24),
                      ),
                    ))
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightblue,
                    ),
                    child: Center(
                      child: Text(
                        "4",
                        style: TextStyle(color: darkerblue, fontSize: 24),
                      ),
                    )),
                SizedBox(width: 10),
                Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightblue,
                    ),
                    child: Center(
                      child: Text(
                        "5",
                        style: TextStyle(color: darkerblue, fontSize: 24),
                      ),
                    )),
                SizedBox(width: 10),
                Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightblue,
                    ),
                    child: Center(
                      child: Text(
                        "6",
                        style: TextStyle(color: darkerblue, fontSize: 24),
                      ),
                    ))
              ],
            ),
            SizedBox(height: 20),
          ],
        ));
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
          title: Text(translationProvider.getTranslation("ProfilePage.page_title"),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'Glacial')),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        backgroundColor: mediumblue,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _firstBox(screenWidth),
            SizedBox(height: 20),
            _secondBox(screenWidth)
          ]),
        ));
  }
}
