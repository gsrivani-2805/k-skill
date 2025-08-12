import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScreen extends StatelessWidget {
  GameScreen({super.key});

  final List<Map<String, dynamic>> games = [
    {
      "title": "Word Match",
      "icon": Icons.compare_arrows,
      "color": Colors.orange,
      "route": WordMatchScreen(jsonPath: "games/word_match.json"),
    },
    {
      "title": "Sentence Formation",
      "icon": Icons.grid_view,
      "color": Colors.blueAccent,
      "route": SentenceForm(jsonPath: "games/sentence_formation.json"),
    },
    {
      "title": "Grammar Mistakes",
      "icon": Icons.spellcheck,
      "color": Colors.green,
      "route": GrammarMistakesScreen(jsonPath: "games/grammar_mistakes.json"),
    },
    {
      "title": "Picture Sentence",
      "icon": Icons.image,
      "color": Colors.purple,
      "route": PictureSentenceScreen(jsonPath: "games/picture_sentence.json"),
    },
    {
      "title": "Listening Puzzle",
      "icon": Icons.headphones,
      "color": Colors.redAccent,
      "route": ListeningPuzzleScreen(jsonPath: "games/listening_puzzle.json"),
    },
    {
      "title": "Story Completion",
      "icon": Icons.menu_book,
      "color": Colors.teal,
      "route": StoryCompletionScreen(jsonPath: "games/story_completion.json"),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Game Zone",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => game['route']),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: game['color'],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(game['icon'], size: 50, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      game['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//
// ===== Placeholder Screens for Each Game =====
//

class WordMatchScreen extends StatelessWidget {
  const WordMatchScreen({super.key, required String jsonPath});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(context, "Word Match");
  }
}

class SentenceForm extends StatefulWidget {
  final String jsonPath;
  const SentenceForm({super.key, required this.jsonPath});

  @override
  State<SentenceForm> createState() => _SentenceFormState();
}

class _SentenceFormState extends State<SentenceForm> {
  List<Map<String, dynamic>> puzzles = [];
  int currentPuzzleIndex = 0;
  List<String> selectedWords = [];
  List<bool> wordUsed = []; // Track fainted words
  List<String> shuffledWords = [];
  String correctSentence = '';

  @override
  void initState() {
    super.initState();
    loadPuzzles();
  }

  Future<void> loadPuzzles() async {
    String jsonString = await rootBundle.loadString(widget.jsonPath);
    final data = jsonDecode(jsonString);
    puzzles = List<Map<String, dynamic>>.from(data['sentence_formation']);
    loadPuzzle(0);
  }

  void loadPuzzle(int index) {
    setState(() {
      currentPuzzleIndex = index;
      selectedWords.clear();
      shuffledWords = List<String>.from(puzzles[index]['words'])..shuffle();
      wordUsed = List<bool>.filled(shuffledWords.length, false);
      correctSentence = puzzles[index]['sentence'];
    });
  }

  void onWordTap(int index) {
    if (!wordUsed[index]) {
      setState(() {
        selectedWords.add(shuffledWords[index]);
        wordUsed[index] = true;
      });
    }
  }

  void checkAnswer() {
    String formedSentence = selectedWords.join(" ");
    bool isCorrect = formedSentence.trim() == correctSentence.trim();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "🎉 Correct!" : "❌ Try Again"),
        content: Text(formedSentence),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isCorrect && currentPuzzleIndex < puzzles.length - 1) {
                loadPuzzle(currentPuzzleIndex + 1);
              } else if (isCorrect) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🏆 All puzzles completed!")),
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void resetSelection() {
    setState(() {
      selectedWords.clear();
      wordUsed = List<bool>.filled(shuffledWords.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    int gridSize = puzzles.isNotEmpty
        ? puzzles[currentPuzzleIndex]['gridSize']
        : 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Words → Sentence"),
        backgroundColor: Colors.blueAccent,
      ),
      body: puzzles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Form the correct sentence",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Blank slots equal to correct sentence length
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: List.generate(
                    correctSentence.split(" ").length,
                    (i) => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: i < selectedWords.length
                            ? Colors.greenAccent
                            : Colors.transparent,
                      ),
                      child: Text(
                        i < selectedWords.length ? selectedWords[i] : "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: GridView.count(
                    crossAxisCount: gridSize,
                    padding: const EdgeInsets.all(8),
                    children: List.generate(shuffledWords.length, (index) {
                      return GestureDetector(
                        onTap: () => onWordTap(index),
                        child: Card(
                          color: wordUsed[index]
                              ? Colors.lightBlueAccent.withOpacity(0.3)
                              : Colors.lightBlueAccent,
                          child: Center(
                            child: Text(
                              shuffledWords[index],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Check & Reset buttons
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: checkAnswer,
                        child: const Text("Check"),
                      ),
                      OutlinedButton(
                        onPressed: resetSelection,
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class GrammarMistakesScreen extends StatelessWidget {
  const GrammarMistakesScreen({super.key, required String jsonPath});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(context, "Grammar Mistakes");
  }
}

class PictureSentenceScreen extends StatefulWidget {
  final String jsonPath;

  const PictureSentenceScreen({super.key, required this.jsonPath});

  @override
  State<PictureSentenceScreen> createState() => _PictureSentenceScreenState();
}

class _PictureSentenceScreenState extends State<PictureSentenceScreen> {
  List<Map<String, dynamic>> gameData = [];
  int currentIndex = 0;
  List<String> selectedWords = [];
  List<bool> wordSelected = [];
  String feedback = "";

  @override
  void initState() {
    super.initState();
    loadGameData();
  }

  Future<void> loadGameData() async {
    String jsonString = await rootBundle.loadString(widget.jsonPath);
    Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      gameData = List<Map<String, dynamic>>.from(jsonData['picture_sentence']);
      
      // Shuffle keywords for all games once when loading
      for (var game in gameData) {
        if (game['keywords'] != null) {
          List<String> keywords = List<String>.from(game['keywords']);
          keywords.shuffle();
          game['keywords'] = keywords;
        }
      }
      
      wordSelected = List.generate(
        gameData[currentIndex]['keywords'].length,
        (_) => false,
      );
    });
  }

  void nextQuestion() {
    if (currentIndex < gameData.length - 1) {
      setState(() {
        currentIndex++;
        selectedWords.clear();
        wordSelected = List.generate(
          gameData[currentIndex]['keywords'].length,
          (_) => false,
        );
        feedback = "";
      });
    } else {
      setState(() {
        feedback = "🎉 Game Over!";
      });
    }
  }

  void checkAnswer() {
    String userSentence = selectedWords.join(" ").trim();
    String correctSentence = (gameData[currentIndex]['sentence'] ?? "").trim();

    if (userSentence.toLowerCase() == correctSentence.toLowerCase()) {
      setState(() {
        feedback = "✅ Correct!";
      });
      Future.delayed(const Duration(seconds: 1), () {
        nextQuestion();
      });
    } else {
      setState(() {
        feedback = "❌ Try again!";
      });
    }
  }

  void resetSelection() {
    setState(() {
      selectedWords.clear();
      wordSelected = List.generate(
        gameData[currentIndex]['keywords'].length,
        (_) => false,
      );
      feedback = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gameData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var currentGame = gameData[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Picture → Sentence"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Image.asset(currentGame['image'], height: 200, fit: BoxFit.cover),
            const SizedBox(height: 20),
            Text(
              selectedWords.join(" "),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Dynamic Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: currentGame['keywords'].length <= 4
                    ? currentGame['keywords'].length
                    : 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(currentGame['keywords'].length, (
                  index,
                ) {
                  return GestureDetector(
                    onTap: () {
                      if (!wordSelected[index]) {
                        setState(() {
                          selectedWords.add(currentGame['keywords'][index]);
                          wordSelected[index] = true;
                        });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: wordSelected[index]
                            ? Colors.grey[400]
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentGame['keywords'][index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Text(
              feedback,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: feedback.startsWith("✅") ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: checkAnswer,
                  child: const Text("Check"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: resetSelection,
                  child: const Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class ListeningPuzzleScreen extends StatelessWidget {
  const ListeningPuzzleScreen({super.key, required String jsonPath});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(context, "Listening Puzzle");
  }
}

class StoryCompletionScreen extends StatelessWidget {
  const StoryCompletionScreen({super.key, required String jsonPath});

  @override
  Widget build(BuildContext context) {
    return _buildPlaceholder(context, "Story Completion");
  }
}

//
// ===== Helper Function for Placeholder UI =====
//
Widget _buildPlaceholder(BuildContext context, String gameName) {
  return Scaffold(
    appBar: AppBar(
      title: Text(gameName),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: Center(
      child: Text(
        "$gameName Coming Soon...",
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
