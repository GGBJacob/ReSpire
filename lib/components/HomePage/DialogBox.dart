import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class DialogBox extends StatefulWidget
{

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  final int breathCount;
  final int minBreaths;
  final int maxBreaths;

  final int inhaleTime;
  final int minInhaleTime;
  final int maxInhaleTime;


  final int exhaleTime;
  final int minExhaleTime;
  final int maxExhaleTime;
  
  final int retentionTime;
  final int minRetentionTime;
  final int maxRetentionTime;

  final Function onCancel;


  const DialogBox({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.breathCount,
    required this.inhaleTime,
    required this.exhaleTime,
    required this.retentionTime,
    required this.onCancel,

    this.minBreaths = 10,
    this.maxBreaths = 100,
    
    this.minInhaleTime = 3,
    this.maxInhaleTime = 15,

    this.minExhaleTime = 3,
    this.maxExhaleTime = 15,
    
    this.minRetentionTime = 3,
    this.maxRetentionTime = 15
    });

  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox>
{

  final _formKey = GlobalKey<FormState>();

  int _currentBreathCount = 0;
  int _currentInhaleTime = 0;
  int _currentRetentionTime = 0;
  int _currentExhaleTime = 0;

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
              
            Navigator.pop(context, {
              'title': widget.titleController.text,
              'description': widget.descriptionController.text,
              'breathCount': _currentBreathCount,
              'inhaleTime': _currentInhaleTime,
              'exhaleTime': _currentExhaleTime,
              'retentionTime': _currentRetentionTime,
            });
    
            }
        }, child: Text("Save")),
        TextButton(onPressed: () {
          Navigator.pop(context);
          widget.onCancel();
        }, child: Text("Cancel"))
      ],
      content: Container(
        padding: EdgeInsets.all(10),
        height: 630,
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
                controller: widget.descriptionController,
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


              Text("Inhale"),
              SizedBox(height: 10),
              NumberPicker(
                value: _currentInhaleTime,
                minValue: widget.minInhaleTime,
                maxValue: widget.maxInhaleTime,
                axis: Axis.horizontal,
                decoration: BoxDecoration( //Optional selected item decoration
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black, width: 3)
                ),
                itemCount: 5,
                itemWidth: 50,
                onChanged: (int newValue) {
                  setState(() {
                    _currentInhaleTime = newValue;
                  });
                }
              ),

              SizedBox(height: 25),
              
              Text("Exhale time"),
              SizedBox(height: 10),
              NumberPicker(
                value: _currentExhaleTime,
                minValue: widget.minExhaleTime,
                maxValue: widget.maxExhaleTime,
                axis: Axis.horizontal,
                decoration: BoxDecoration( //Optional selected item decoration
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black, width: 3)
                ),
                itemCount: 5,
                itemWidth: 50,
                onChanged: (int newValue) {
                  setState(() {
                    _currentExhaleTime = newValue;
                  });
                }
              ),
              
              SizedBox(height: 25),

              Text("Retention time"),
              SizedBox(height: 10),
              NumberPicker(
                value: _currentRetentionTime,
                minValue: widget.minRetentionTime,
                maxValue: widget.maxRetentionTime,
                axis: Axis.horizontal,
                decoration: BoxDecoration( //Optional selected item decoration
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black, width: 3)
                ),
                itemCount: 5,
                itemWidth: 50,
                onChanged: (int newValue) {
                  setState(() {
                    _currentRetentionTime = newValue;
                  });
                }
              )
            ],
          ),
        )
      ),
    );
  }

  
}