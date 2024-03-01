import 'package:flutter/material.dart';
import 'package:paltan/num_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SharedPreferences? prefs;
  List<Widget> content = [const Text("Chargement...")];

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences value) {
      prefs = value;
      setState(() {
        content = [
          SelectField(
            text: "Temps affichage mot",
            minVal: 1,
            maxVal: 30,
            value: prefs!.getInt("paltan.wordTime") ?? 10,
            onValueChange: (int value) async {await prefs!.setInt("paltan.wordTime", value);},
          ),
          SelectField(
            text: "Temps dessin",
            minVal: 1,
            maxVal: 30,
            value: prefs!.getInt("paltan.drawTime") ?? 5,
            onValueChange: (int value) async {await prefs!.setInt("paltan.drawTime", value);},
          ),
          SelectField(
            text: "Temps deviner",
            minVal: 1,
            maxVal: 30,
            value: prefs!.getInt("paltan.guessTime") ?? 20,
            onValueChange: (int value) async {await prefs!.setInt("paltan.guessTime", value);},
          ),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: content
        ),
      ),
    );
  }
}


class SelectField extends StatefulWidget {
  final String text;
  final int minVal;
  final int maxVal;
  int value;
  void Function(int)? onValueChange;
  SelectField({super.key, required this.text, required this.minVal, required this.maxVal, required this.value, this.onValueChange});

  @override
  State<SelectField> createState() => _SelectFieldState();
}

class _SelectFieldState extends State<SelectField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 50),
            child: Text(widget.text),
          ),
          NumberPicker(
            minVal: widget.minVal,
            maxVal: widget.maxVal,
            value: widget.value,
            onValueChange: widget.onValueChange,
          )
        ],
      ),
    );
  }
}
