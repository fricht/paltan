import 'dart:math';
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

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences value) {
      prefs = value;
    });
  }

  void launchGame() {
    if (prefs == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mots non chargés, re essayez plus tard")));
      return;
    }
    List<String>? words = prefs!.getStringList("paltan.words");
    if (words == null || words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aucun mot")));
      return;
    }
    String pickedWord = words[random.nextInt(words.length)];
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
          ],
        ),
      ),
    );
  }
}
