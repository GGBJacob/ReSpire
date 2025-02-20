import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

class DialogBox extends StatefulWidget
{

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  final int breathCount;
  final int minBreaths;
  final int maxBreaths;

  final double inhaleTime;
  final double minInhaleTime;
  final double maxInhaleTime;


  final double exhaleTime;
  final double minExhaleTime;
  final double maxExhaleTime;
  
  final double retentionTime;
  final double minRetentionTime;
  final double maxRetentionTime;

  final VoidCallback savePreset;

  const DialogBox({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.breathCount,
    required this.inhaleTime,
    required this.exhaleTime,
    required this.retentionTime,
    required this.savePreset,

    this.minBreaths = 10,
    this.maxBreaths = 100,
    
    this.minInhaleTime = 3.0,
    this.maxInhaleTime = 20.0,

    this.minExhaleTime = 3.0,
    this.maxExhaleTime = 20.0,
    
    this.minRetentionTime = 3.0,
    this.maxRetentionTime = 20.0
    });

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox>
{

  final _formKey = GlobalKey<FormState>();

  int _currentBreathCount = 0;
  double _currentInhaleTime = 0;
  double _currentRetentionTime = 0;
  double _currentExhaleTime = 0;

  @override
  void initState() {
    super.initState();
    _currentBreathCount = widget.breathCount;
    _currentInhaleTime = widget.inhaleTime;
    _currentExhaleTime = widget.exhaleTime;
    _currentRetentionTime = widget.retentionTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(onPressed: ()
        {
          if (_formKey.currentState?.validate() ?? false) {
              widget.savePreset();
            }
        }, child: Text("Save")),
        TextButton(onPressed: () => (Navigator.pop(context)), child: Text("Cancel"))
      ],
      content: Container(
        padding: EdgeInsets.all(10),
        height: 550,
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              Text("Title"),
              TextFormField(
                validator: (value) {  // Title validator - prevents title from not being filled
                    if (value == null || value.trim().isEmpty) {
                      return "Title cannot be empty!";
                    }
                    return null;
                  },
                controller: widget.titleController,
              ),

              SizedBox(height: 25),

              Text("Description"),
              TextFormField(
                controller: widget.titleController,
              ),

              SizedBox(height: 25),



              Text("Breaths"),
              SizedBox(height: 10),
              NumberPicker(
                value: _currentBreathCount,
                minValue: widget.minBreaths,
                maxValue: widget.maxBreaths,
                axis: Axis.horizontal,
                decoration: BoxDecoration( //Optional selected item decoration
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black, width: 3)
                ),
                itemCount: 5,
                itemWidth: 50,
                onChanged: (int newValue) {
                setState(() {
                  _currentBreathCount = newValue;
                }); 
                }),

              SizedBox(height: 25),


              // TODO: Delete if you implement the dialog box
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Column(
              //       children: [
              //             Text("Inhale"),
              //             NumberPicker(
              //               value: _currentBreathCount,
              //               minValue: widget.minBreaths,
              //               maxValue: widget.maxBreaths,
              //               axis: Axis.vertical,
              //               decoration: BoxDecoration( //Optional selected item decoration
              //                 borderRadius: BorderRadius.circular(15),
              //                 border: Border.all(color: Colors.black, width: 3)
              //               ),
              //               itemCount: 3,
              //               itemWidth: 50,
              //               onChanged: (int newValue) {
              //                 setState(() {
              //                   _currentBreathCount = newValue;
              //                 });
              //               }
              //             )
              //       ],
              //     ),
              //     Column(
              //       children: [
              //             Text("Inhale"),
              //             NumberPicker(
              //               value: _currentBreathCount,
              //               minValue: widget.minBreaths,
              //               maxValue: widget.maxBreaths,
              //               axis: Axis.vertical,
              //               decoration: BoxDecoration( //Optional selected item decoration
              //                 borderRadius: BorderRadius.circular(15),
              //                 border: Border.all(color: Colors.black, width: 3)
              //               ),
              //               itemCount: 3,
              //               itemWidth: 50,
              //               onChanged: (int newValue) {
              //                 setState(() {
              //                   _currentBreathCount = newValue;
              //                 });
              //               }
              //             )
              //       ],
              //     ),
              //     Column(
              //       children: [
              //             Text("Inhale"),
              //             NumberPicker(
              //               value: _currentBreathCount,
              //               minValue: widget.minBreaths,
              //               maxValue: widget.maxBreaths,
              //               axis: Axis.vertical,
              //               decoration: BoxDecoration( //Optional selected item decoration
              //                 borderRadius: BorderRadius.circular(15),
              //                 border: Border.all(color: Colors.black, width: 3)
              //               ),
              //               itemCount: 3,
              //               itemWidth: 50,
              //               onChanged: (int newValue) {
              //                 setState(() {
              //                   _currentBreathCount = newValue;
              //                 });
              //               }
              //             )
              //       ],
              //     )
              //   ],
              // ),

              //Alternative for NumberPicker

              Text("Inhale time"),
              Slider(

                value: _currentInhaleTime,
                min: widget.minInhaleTime,
                max: widget.maxInhaleTime,
                divisions: widget.maxInhaleTime.toInt() - widget.minInhaleTime.toInt() + 1,
                onChanged: (double newValue) {
                setState(() {
                  _currentInhaleTime = newValue;
                }); 
                },
              ),
              
              // Text("Inhale time"),
              // Slider(

              //   value: _currentInhaleTime,
              //   min: widget.minInhaleTime,
              //   max: widget.maxInhaleTime,
              //   divisions: widget.maxInhaleTime.toInt() - widget.minInhaleTime.toInt() + 1,
              //   onChanged: (double newValue) {
              //   setState(() {
              //     _currentInhaleTime = newValue;
              //   }); 
              //   },
              // ),Text("Inhale time"),
              // Slider(

              //   value: _currentInhaleTime,
              //   min: widget.minInhaleTime,
              //   max: widget.maxInhaleTime,
              //   divisions: widget.maxInhaleTime.toInt() - widget.minInhaleTime.toInt() + 1,
              //   onChanged: (double newValue) {
              //   setState(() {
              //     _currentInhaleTime = newValue;
              //   }); 
              //   },
              // ),
            ],
          ),
        )
      ),
    );
  }

  
}