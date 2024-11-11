import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:paltan/utils.dart';


class GameEntry extends StatefulWidget {
  final String word;
  final List<int> times;
  const GameEntry({super.key, required this.word, required this.times});

  @override
  State<GameEntry> createState() => _GameEntryState();
}

class _GameEntryState extends State<GameEntry> with SingleTickerProviderStateMixin {
  static AudioPlayer player = AudioPlayer();
  static final AssetSource sound = AssetSource("bell1.wav");
  int currentText = 0;
  late AnimationController timeController = AnimationController(vsync: this, duration: Duration(seconds: widget.times[0]));

  @override
  void initState() {
    super.initState();
    timeController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        player.play(sound);
        if (currentText == 3) {
          Navigator.of(context).pop();
          return;
        }
        setState(() {
          currentText++;
          timeController.duration = Duration(seconds: widget.times[currentText]);
          timeController.reset();
          timeController.forward();
        });
      }
    });
    timeController.forward();
  }

  @override
  void dispose() {
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (currentText == 3) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: AnimatedBuilder(animation: timeController, builder: (BuildContext context, Widget? _) {
          return Stack(
            children: [
              Container(
                color: Color.lerp(color1, color2, timeController.value / 2.0),
                height: MediaQuery.of(context).size.height * timeController.value,
              ),
              Center(
                child: Text(
                  style: TextStyle(
                    fontStyle: [FontStyle.normal, FontStyle.italic, FontStyle.normal, FontStyle.normal][currentText],
                    fontWeight: [FontWeight.normal, FontWeight.bold, FontWeight.normal, FontWeight.normal][currentText],
                    fontSize: 50,
                  ),
                  ["Prêts ?", widget.word, "Dessinez", "Devinez"][currentText],
                ),
              ),
            ]
          );
        }),
      ),
    );
  }
}
