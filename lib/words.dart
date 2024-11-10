import 'package:flutter/material.dart';
import 'package:paltan/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Words extends StatefulWidget {
  const Words({super.key});

  @override
  State<Words> createState() => _WordsState();
}

class _WordsState extends State<Words> {
  SharedPreferences? prefs;
  List<String> words = [];
  List<String> filteredWords = [];
  bool isAddable = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences value) {
      prefs = value;
      words = prefs!.getStringList("paltan.words") ?? [];
      setState(() {
        filteredWords = words;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void applyFilter(String filter) {
    filteredWords = words.where((element) => element.contains(filter)).toList();
  }

  String makeTextPretty(String txt) {
    return txt.toLowerCase().trim();
  }

  void handleTextChange(String rawText) {
    String text = makeTextPretty(rawText);
    setState(() {
      isAddable = !words.contains(text) && text.isNotEmpty;
      applyFilter(text);
    });
  }

  void addWord(String word) {
    if (words.contains(word)) {
      return;
    }
    setState(() {
      words.add(word);
      applyFilter(makeTextPretty(_searchController.text));
    });
    prefs!.setStringList("paltan.words", words);
  }

  void removeWord(String word) {
    setState(() {
      words.remove(word);
      applyFilter(makeTextPretty(_searchController.text));
    });
    prefs!.setStringList("paltan.words", words);
    showSnackBar(context, Text("$word supprimé"), SnackBarAction(
        label: "Annuler",
        onPressed: () {
          addWord(word);
        }
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mots"),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "rechercher ou ajouter un mot",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: !isAddable ? null : () {
                    FocusScope.of(context).unfocus();
                    addWord(makeTextPretty(_searchController.text));
                    _searchController.text = "";
                    setState(() {
                      isAddable = false;
                      applyFilter("");
                    });
                  },
                ),
              ),
              onChanged: handleTextChange,
              controller: _searchController,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredWords.length,
              itemBuilder: (BuildContext _, int index) {
                return ListTile(
                  title: Text(filteredWords[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => removeWord(filteredWords[index]),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
