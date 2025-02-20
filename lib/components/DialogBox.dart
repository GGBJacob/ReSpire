import 'package:flutter/material.dart';

class DialogBox extends StatefulWidget
{

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final double breathCount;
  final double min;
  final double max;

  const DialogBox({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.breathCount,
    this.min = 10.0,
    this.max=100.0});

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox>
{
  double _currentBreathCount = 0;

  @override
  void initState() {
    super.initState();
    _currentBreathCount = widget.breathCount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 400,
        child: Column(
          children: [

            Text("Title"),
            TextField(
              controller: widget.titleController,
            ),

            Text("Description"),
            TextField(
              controller: widget.titleController,
            ),

            Text("Breaths"),
            Slider(
              value: _currentBreathCount,
              min: widget.min,
              max: widget.max,
              divisions: widget.max.toInt() - widget.min.toInt() + 1,
              onChanged: (double newValue) {
               setState(() {
                 _currentBreathCount = newValue;
               }); 
              },
            )
          ],
        ),
      ),
    );
  }

  
}