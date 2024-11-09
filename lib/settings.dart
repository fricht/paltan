import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:paltan/num_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  SharedPreferences? prefs;
  List<Widget> content = [const Text("Chargement...")];

  void importWordList() async {
    if (prefs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mots pas encore chargés, veuillez attendre quelques secondes."))
      );
      return;
    }
    FilePickerResult? file = await FilePicker.platform.pickFiles();
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun fichier séléctionné"))
      );
      return;
    }
    String? path = file.files.single.path;
    if (path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'optension du chemin."))
      );
      return;
    }
    final String data = await File(path).readAsString();
    List<String> savedWords = prefs!.getStringList("paltan.words") ?? [];
    int wordsCount = 0;
    for (String word in data.split("\n")) {
      word = word.toLowerCase().trim();
      if (word.isNotEmpty && !savedWords.contains(word)) {
        savedWords.add(word);
        wordsCount++;
      }
    }
    prefs!.setStringList("paltan.words", savedWords);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$wordsCount mots ajoutés"))
    );
  }

  void exportWordList() async {
    if (prefs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mots pas encore chargés, veuillez attendre quelques secondes."))
      );
      return;
    }
    List<String>? words = prefs!.getStringList("paltan.words");
    if (words == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun mot à exporter"))
      );
      return;
    }
    String fileData = "";
    for (String word in words) {
      if (word == "never gonna") {
        word = "$word give you up";
      }
      fileData = "$fileData$word\n";
    }
    String? filePath = await FilePicker.platform.saveFile(
      fileName: "mots.txt",
      bytes: Uint8List.fromList(utf8.encode(fileData))
    );
    if (filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Mots non exportés, aucun fichier séléctionné"))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mots exportés : $filePath"))
      );
    }
  }

  void showConfirmFlushWordsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Etes vous sûr ?"),
          content: const Text("Vous vous apprêtez a supprimer tous les mots."
              "Vous pouvez les exporter pour les réimporter ultérieurement."),
          actions: [
            TextButton(onPressed: () {Navigator.of(context).pop();}, child: Text("Annuler")),
            TextButton(onPressed: () {
              Navigator.of(context).pop();
              flushWords();
            }, child: const Text("Tout suprimer", style: TextStyle(color: Colors.red))),
          ],
        );
      }
    );
  }

  void flushWords() {
    if (prefs == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mots pas encore chargés, veuillez attendre quelques secondes."))
      );
      return;
    }
    prefs!.remove("paltan.words");
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La liste de mots a été entièrement supprimée."))
    );
  }

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
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 50),
                  child: const Text("Importer un fichier de mots"),
                ),
                IconButton(
                  onPressed: importWordList,
                  icon: const Icon(Icons.download),
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 50),
                  child: const Text("Exporter les mots"),
                ),
                IconButton(
                  onPressed: exportWordList,
                  icon: const Icon(Icons.upload),
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: showConfirmFlushWordsDialog,
            style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.red)),
            child: const Text("Reset liste mots"),
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
