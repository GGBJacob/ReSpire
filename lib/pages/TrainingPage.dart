import 'package:flutter/material.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/pages/BreathingPage.dart';
import 'package:respire/pages/TrainingEditorPage.dart';
import 'package:respire/services/PresetDataBase.dart';
import 'package:respire/services/TranslationProvider/TranslationProvider.dart';
import 'package:respire/theme/Colors.dart';
import 'package:respire/components/TrainingEditorPage/PhaseTile.dart';

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
  late List<Phase> phases;
  bool _expanded = false;
  TranslationProvider translationProvider = TranslationProvider();

  @override
  void initState() {
    super.initState();
    training = widget.db.presetList[widget.index];
    phases = training.phases;
  }

  Widget shareButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: IconButton(
          icon: Icon(Icons.share_rounded, color: darkgrey),
          style: IconButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 207, 206, 206)),
          onPressed: () => {}),
    );
  }

  Widget editButton() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: IconButton(
            icon: Icon(Icons.edit_rounded, color: darkerblue),
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
            }));
  }

  Widget deleteButton() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: IconButton(
          icon: Icon(Icons.delete_rounded, color: darkerblue),
          style: IconButton.styleFrom(backgroundColor: Colors.white),
          onPressed: removeTraining,
        ));
  }

  Widget descriptionBox(double screenWidth) {
    return Container(
        width: screenWidth - 20,
        constraints: BoxConstraints(
          minHeight: 80,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
            padding: EdgeInsets.all(15),
            child: Container(
                width: screenWidth - 40,
                decoration: BoxDecoration(
                  color: lightblue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      training.description == ''
                          ? translationProvider.getTranslation("TrainingPage.description_placeholder")
                          : training.description,
                      style: TextStyle(color: greenblue),
                    ),
                  ),
                ))));
  }

  Widget startTrainingButton() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: TextButton(
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BreathingPage(training: training),
                  ),
                ),
            style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(35),
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(70),
                ))),
            child: Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scaleX: -1,
                      child: Icon(
                        Icons.air,
                        color: darkerblue,
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(translationProvider.getTranslation("TrainingPage.start_button_label"),
                        style: TextStyle(
                          color: darkerblue,
                          fontFamily: 'Glacial',
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.air,
                      color: darkerblue,
                      size: 22.0,
                    ),
                  ],
                ))));
  }

  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget trainingOverviewHeader() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              translationProvider.getTranslation("TrainingPage.TrainingOverview.title"),
              style: TextStyle(
                  fontSize: 18, color: darkerblue, fontWeight: FontWeight.w500),
            ),
            Spacer(),
            AnimatedRotation(
              turns: _expanded ? 0.5 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: darkerblue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget trainingOverviewInsides() {
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: ClipRect(
        child: _expanded
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: phases.map((phase) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        color: lightblue,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${translationProvider.getTranslation("TrainingPage.TrainingOverview.reps")}: ${phase.reps} ${translationProvider.getTranslation("TrainingPage.TrainingOverview.increment")}: ${phase.increment} [s]',
                                style: TextStyle(
                                    color: darkerblue,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Column(
                                children: phase.steps.map((step) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Row(
                                          children: [
                                            Text(
                                              translationProvider.getTranslation("StepType.${step.stepType.name}"),
                                              style: TextStyle(
                                                  color: darkerblue,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Spacer(),
                                            Text(
                                              '${step.duration} s',
                                              style: TextStyle(
                                                  color: darkerblue,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }

  Widget trainingOverview(double screenWidth) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [trainingOverviewHeader(), trainingOverviewInsides()],
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text(training.title,
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800)),
              // style: TextStyle(
              //     color: darkerblue,
              //     fontFamily: 'Glacial',
              //     fontSize: 20,
              //     fontWeight: FontWeight.w800)),
          backgroundColor: Colors.white,
          leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: darkerblue,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        backgroundColor: mediumblue,
        body: SingleChildScrollView(
            child: Column(children: [
          Row(
            children: [shareButton(), Spacer(), editButton(), deleteButton()],
          ),
          descriptionBox(screenWidth),
          trainingOverview(screenWidth),
          startTrainingButton()
        ])));
  }

  Future<void> removeTraining() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(translationProvider.getTranslation("TrainingPage.delete_training_dialog_title")),
            backgroundColor: Colors.white,
            content: Text(translationProvider.getTranslation("TrainingPage.delete_training_dialog_content")),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translationProvider.getTranslation("PopupButton.cancel"), style: TextStyle(color: darkerblue)),
              ),
              TextButton(
                onPressed: () {
                  widget.db.deletePreset(widget.index);
                  Navigator.pop(context);
                  setState(() {});
                  Navigator.pop(context, true);
                },
                child: Text(translationProvider.getTranslation("PopupButton.delete"), style: TextStyle(color: darkerblue)),
              ),
            ],
          );
        });
  }
}
