import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:paltan/game.dart';
import 'package:paltan/settings.dart';
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
  int current_index = 0;
  List<String>? shuffeled_words;
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
      shuffeled_words = words;
      // Done : shuffle
      shuffeled_words!.shuffle();
      current_index = 0;
    }
    // pick a word
    if (shuffeled_words == null) {
      return null;
    }
    if (shuffeled_words!.isEmpty) {
      return null;
    }
    current_index = current_index % shuffeled_words!.length;
    String picked = shuffeled_words![current_index++];
    return picked;
  }

  void launchGame() {
    if (prefs == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error : prefs is null, can't launch game")));
      return;
    }
    String? pickedWord = getWord();
    if (pickedWord == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors du chargement du mot.")));
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
      appBar: AppBar(
        leading: const Icon(Icons.timer),
        title: const Text("Paltan"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Paltan",
              style: TextStyle(
                fontSize: 80,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  child: const Text("Jouer"),
                  onPressed: launchGame,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  child: const Text("Mots"),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Words())
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  child: const Text("Paramètres"),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const Settings())
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  child: const Text("Règles"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text("Règles du jeu"),
                          content: Text("Lorem ipsum dolor sit amet"),
                        );
                      }
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
