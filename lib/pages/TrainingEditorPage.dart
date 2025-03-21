import 'package:flutter/material.dart';
import 'package:respire/components/Global/Training.dart';
import 'package:respire/components/Global/Phase.dart';
import 'package:respire/components/TrainingEditorPage/PhaseTile.dart';

class TrainingEditorPage extends StatefulWidget {
  final Training training;

  const TrainingEditorPage({
    Key? key,
    required this.training,
  }) : super(key: key);

  @override
  _TrainingEditorPageState createState() => _TrainingEditorPageState();
}

class _TrainingEditorPageState extends State<TrainingEditorPage> {
  late List<Phase> phases;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Pobieramy fazy z przekazanego treningu
    phases = widget.training.phases;
  }

  void addPhase() {
    setState(() {
      phases.add(Phase(reps: 3, steps: []));
    });
    // Po krótkiej zwłoce (aby lista zaktualizowała się) przewijamy do końca listy.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void removePhase(int index) {
    setState(() {
      phases.removeAt(index);
    });
  }

  void reorderPhase(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final phase = phases.removeAt(oldIndex);
      phases.insert(newIndex, phase);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edytor treningu")),
      body: ReorderableListView(
        scrollController: _scrollController,
        onReorder: reorderPhase,
        padding: EdgeInsets.only(bottom: 80),
        children: [
          for (int index = 0; index < phases.length; index++)
            PhaseTile(
              key: ValueKey('phase_$index'),
              phase: phases[index],
              onDelete: () => removePhase(index),
              onUpdate: () => setState(() {}),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPhase,
        child: Icon(Icons.add),
      ),
    );
  }
}
