import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:paltan/game.dart';
import 'package:paltan/settings.dart';
import 'package:paltan/utils.dart';
import 'package:paltan/words.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  SharedPreferences? prefs;
  Random random = Random();
  int currentIndex = 0;
  List<String>? shuffledWords;
  String hash = "";

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences value) {
      prefs = value;
    });
  }

  String getWordsHash(List<String> words) {
    String full = words.join();
    return md5.convert(utf8.encode(full)).toString();
  }

  String? getWord() {
    if (prefs == null) {
      return null;
    }
    List<String>? words = prefs!.getStringList("paltan.words");
    if (words == null) {
      return null;
    }
    // check if the words changed
    String hash = getWordsHash(words);
    if (hash != this.hash) {
      this.hash = hash;
      shuffledWords = words;
      // Done : shuffle
      shuffledWords!.shuffle();
      currentIndex = 0;
    }
    // pick a word
    if (shuffledWords == null) {
      return null;
    }
    if (shuffledWords!.isEmpty) {
      return null;
    }
    currentIndex = currentIndex % shuffledWords!.length;
    String picked = shuffledWords![currentIndex++];
    return picked;
  }

  void launchGame() {
    if (prefs == null) {
      showSnackBar(context, const Text("Error : prefs is null, can't launch game"), null);
      return;
    }
    String? pickedWord = getWord();
    if (pickedWord == null) {
      showSnackBar(context, const Text("Erreur lors du chargement du mot."), null);
      return;
    }
    final List<int> times = [3, prefs!.getInt("paltan.wordTime") ?? 10, prefs!.getInt("paltan.drawTime") ?? 5, prefs!.getInt("paltan.guessTime") ?? 20];
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameEntry(word: pickedWord, times: times))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Paltan",
              style: TextStyle(
                fontSize: 80,
                color: color3,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: MainButton(onPress: launchGame, btnText: "Jouer"),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: MainButton(onPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Words())
                );
              }, btnText: "Mots"),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: MainButton(onPress: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Settings())
                );
              }, btnText: "Paramètres"),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: MainButton(onPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      title: Text("Règles du jeu"),
                      content: Text("Lorem ipsum dolor sit amet"),
                    );
                  }
                );
              }, btnText: "Règles"),
            ),
          ],
        ),
      ),
    );
  }
}
