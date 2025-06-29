import 'package:flutter/material.dart';
import 'package:respire/services/SoundManager.dart';

class SoundDropdownItem extends StatefulWidget {
  final String value;
  //final ValueChanged<String> handleValueChange; 
  //final ValueNotifier<String> currentlyPlayingNotifier;

  const SoundDropdownItem({super.key, required this.value}); //, required this.handleValueChange, required this.currentlyPlayingNotifier});

  @override
  State<SoundDropdownItem> createState() => _SoundDropdownItemState();
}

class _SoundDropdownItemState extends State<SoundDropdownItem> {
  late Icon _icon;
  final Icon _playIcon = const Icon(Icons.play_arrow, color: Colors.green);
  final Icon _stopIcon = const Icon(Icons.stop, color: Colors.red);

  @override
  void initState() {
    super.initState();
    _icon = _playIcon;
  }


  Future<void> onPressed() async {
    final isPlaying = SoundManager().currentSound == widget.value;
    if (isPlaying)
    {
      //widget.handleValueChange("");
      SoundManager().stopSound(widget.value);
      _icon = _playIcon;
    }
    else
    {
      //widget.handleValueChange(widget.value);
      SoundManager().playSound(widget.value);
      _icon = _stopIcon;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SoundDropdownItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool isNowPlaying = SoundManager().currentSound == widget.value;

    if (!isNowPlaying) {
      SoundManager().stopSound(widget.value);
      _icon = _playIcon;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // return ValueListenableBuilder<String>(
    //   valueListenable: widget.currentlyPlayingNotifier,
    //   builder: (context, currentlyPlaying, child) {
        return Row(
          spacing: 6.0,
          children: [
            if (widget.value == "None")
              const Icon(Icons.volume_off, color: Colors.grey)
            else
            GestureDetector(
              onTap: onPressed,
              child: _icon,
            ),
            
            Text(widget.value),
          ],
        );
    //   },
    // );
  }
}