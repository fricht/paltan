import 'package:flutter/material.dart';
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
  TextEditingController _searchController = TextEditingController();

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

  void handleTextChange(String rawText) {
    String text = rawText.toLowerCase();
    setState(() {
      isAddable = !words.contains(text) && text.isNotEmpty;
      applyFilter(text);
    });
  }

  void addWord(String word) {
    setState(() {
      words.add(word);
      applyFilter(_searchController.text.toLowerCase());
    });
    prefs!.setStringList("paltan.words", words);
  }

  void removeWord(String word) {
    setState(() {
      words.remove(word);
      applyFilter(_searchController.text.toLowerCase());
    });
    prefs!.setStringList("paltan.words", words);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$word supprimé"),
        action: SnackBarAction(
          label: "Annuler",
          onPressed: () {
            addWord(word);
          }
        ),
      )
    );
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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: !isAddable ? null : () {
                    FocusScope.of(context).unfocus();
                    addWord(_searchController.text.toLowerCase());
                    _searchController.text = "";
                    setState(() {
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
