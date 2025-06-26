import 'package:flutter/material.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/pages/BreathingPage.dart';
import 'package:respire/pages/TrainingEditorPage.dart';
import 'package:respire/services/PresetDataBase.dart';

class TrainingPage extends StatefulWidget {
  final int index;
  final PresetDataBase db = PresetDataBase();

  TrainingPage({
    super.key,
    required this.index,
  });

  @override
  _TrainingPageState createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late Training training;

  @override
  void initState() {
    super.initState();
    training = widget.db.presetList[widget.index];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(training.title,
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
                    onPressed: () async {
                      final updated = await Navigator.push<Training>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainingEditorPage(
                            training: widget.db.presetList[widget.index],
                          ),
                        ),
                      );
                      if (updated != null) {
                        setState(() {
                          widget.db.presetList[widget.index] = updated;
                          widget.db.updateDataBase();
                        });
                      }
                    }
                  ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: IconButton(
                    icon: Icon(Icons.delete_rounded,
                        color: Color.fromARGB(255, 26, 147, 168)),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: removeTraining,
                )
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
                    padding: EdgeInsets.only(top:10),
                    child: Text(
                      "Description",
                      style: TextStyle(
                        color: Color.fromARGB(255, 26, 147, 168),
                        fontSize: 32,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Container(
                        width: screenWidth - 40,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 123, 222, 240),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              training.description ?? "No description provided.",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 26, 147, 168)),
                            ),
                          ),
                        )))
                  ]),
                )),
          Padding(
              padding: EdgeInsets.all(10),
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BreathingPage(training: training),
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

  Future<void> removeTraining() async {

    showDialog(context: context, builder:  (context) {
      return AlertDialog(
        title: Text("Delete Training"),
        content: Text("Are you sure you want to delete this training?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              widget.db.deletePreset(widget.index); 
              Navigator.pop(context);
              setState(() {});
              Navigator.pop(context, true);
            },
            child: Text("Delete"),
          ),
        ],
      );
    });

  }
}
