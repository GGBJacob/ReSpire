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
    SoundManager().currentlyPlaying.addListener(_onCurrentlyPlayingChanged);
  }


  Future<void> onIconPressed() async {
    final isPlaying = SoundManager().currentlyPlaying.value == widget.value;
    if (isPlaying)
    {
      SoundManager().stopSound(widget.value);
      _icon = _playIcon;
    }
    else
    {
      SoundManager().playSound(widget.value);
      _icon = _stopIcon;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SoundDropdownItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool isNowPlaying = SoundManager().currentlyPlaying.value == widget.value;

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
          children: [
            if (widget.value == "None")
              const Icon(Icons.volume_off, color: Colors.grey)
            else
            GestureDetector(
              onTap: onIconPressed,
              child: _icon,
            ),
            SizedBox(width: 8),
            Text(widget.value),
          ],
        );
    //   },
    // );
  }

  void _onCurrentlyPlayingChanged() {
    setState(() {
      _icon = SoundManager().currentlyPlaying.value == widget.value ? _stopIcon : _playIcon;
    });
  }

  @override
  void dispose() {
    SoundManager().currentlyPlaying.removeListener(_onCurrentlyPlayingChanged);
    super.dispose();
  }
}