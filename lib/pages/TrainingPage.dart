import 'package:flutter/material.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/pages/BreathingPage.dart';

class TrainingPage extends StatefulWidget {
  final Training training;

  const TrainingPage({
    super.key,
    required this.training,
  });

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.training.title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        backgroundColor: Color.fromARGB(255, 50, 184, 207),
        body: Column(children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                    icon: Icon(Icons.share_rounded,
                        color: Color.fromARGB(255, 26, 147, 168)),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => {}),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                    icon: Icon(Icons.edit_rounded,
                        color: Color.fromARGB(255, 26, 147, 168)),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => {}),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                    icon: Icon(Icons.delete_rounded,
                        color: Color.fromARGB(255, 26, 147, 168)),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => {}),
              ),
            ],
          ),
          Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                width: screenWidth - 20,
                constraints: BoxConstraints(
                  minHeight: 120,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Description",
                      style: TextStyle(
                        color: Color.fromARGB(255, 26, 147, 168),
                        fontSize: 32,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                      width: screenWidth - 40,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 123, 222, 240),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "discription text something something",
                            style: TextStyle(
                                color: Color.fromARGB(255, 26, 147, 168)),
                          ),
                        ),
                      ))
                ]),
              )),
          Padding(
              padding: EdgeInsets.all(10),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BreathingPage(training: widget.training),
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color.fromARGB(255, 26, 147, 168),
                  minimumSize: Size(screenWidth, 48),
                ),
                child: Text(
                  "Start training",
                  style: TextStyle(
                    color: Color.fromARGB(255, 26, 147, 168),
                    fontSize: 24,
                  ),
                ),
              ))
        ]));
  }
}
