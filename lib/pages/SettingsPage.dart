import 'package:flutter/material.dart';
import 'package:respire/components/Settings/VoiceSelectors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
                color: Colors.grey,
              ),
              child: Column(children: [
                SizedBox(height: screenWidth * 0.4 / 2),
                Text(
                  "Profile Name",
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  "Other important things",
                  style: TextStyle(fontSize: 20),
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
                  color: Colors.grey,
                ),
                child: Center(
                    child: Container(
                  width: screenWidth * 0.35,
                  height: screenWidth * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: photoAdded
                      ? SizedBox() //If photo is added
                      : Icon(
                          Icons.person,
                          size: screenWidth * 0.30,
                        ),
                )),
              )),
        ]);
  }

  Widget _secondBox(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey,
      ),
      child: _options(),
    );
  }

  Widget _options() {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20),
          Text(
            "Settings",
            style: TextStyle(fontSize: 30),
          ),
          //SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Dark Mode",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                width: 10,
              ),
              Switch(
                value: false,
                onChanged: (value) => value,
              )
            ],
          ),

          VoiceSelector(),
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
          title: Text("ReSpire", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.grey,
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _firstBox(screenWidth),
            SizedBox(height: 20),
            _secondBox(screenWidth)
          ]),
        ));
  }
}
