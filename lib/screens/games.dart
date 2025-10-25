import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
class GameScreen extends StatelessWidget {
  GameScreen({super.key});

  final List<Map<String, dynamic>> games = [
    {
      "title": "Word Detective",
      "subtitle": "Match words with their secret meanings!",
      "emoji": "🕵🏼",
      "gradient": [Color(0xFFFFE4E6), Color(0xFFFFD1D6)], // Light pink gradient
      "difficulty": "Easy",
      "route": WordMatchScreen(jsonPath: "games/word_match.json"),
    },
    {
      "title": "Fill in the Blanks",
      "subtitle": "Fill in the missing pieces to complete the magical story!",
      "emoji": "✍🏼",
      "gradient": [Color(0xFFFFF4E6), Color(0xFFFFE6CC)], // Light yellow/orange gradient
      "difficulty": "Easy",
      "route": FillInTheBlanks(jsonPath: "games/grammar_mistakes.json"),
    },
    {
      "title": "Sentence Formation",
      "subtitle": "Build sentences piece by piece!",
      "emoji": "🧩",
      "gradient": [Color(0xFFE6F3FF), Color(0xFFCCE7FF)], // Light blue gradient
      "difficulty": "Medium",
      "route": SentenceForm(jsonPath: "games/sentence_formation.json"),
    },
    {
      "title": "Picture Story",
      "subtitle": "Tell stories through amazing pictures!",
      "emoji": "📷",
      "gradient": [Color(0xFFF0E6FF), Color(0xFFE6D9FF)], // Light purple gradient
      "difficulty": "Medium",
      "route": PictureSentenceScreen(jsonPath: "games/picture_sentence.json"),
    },
    {
      "title": "Sound Quest",
      "subtitle": "Listen carefully and solve the puzzle!",
      "emoji": "🗣️",
      "gradient": [Color(0xFFE6FFE6), Color(0xFFCCFFCC)], // Light green gradient
      "difficulty": "Hard",
      "route": ListeningPuzzleScreen(jsonPath: "games/listening_puzzle.json"),
    },
    {
      "title": "Story Wizard",
      "subtitle": "Create epic endings to incredible adventures!",
      "emoji": "📝",
      "gradient": [Color(0xFFE6F9FF), Color(0xFFCCF2FF)], // Light cyan gradient
      "difficulty": "Hard",
      "route": StoryCompletionScreen(jsonPath: "games/story_completion.json"),
    },
  ];

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Color(0xFF81C784); // Light green
      case 'medium':
        return Color(0xFFFFB74D); // Light orange
      case 'hard':
        return Color(0xFFE57373); // Light red
      default:
        return Color(0xFF64B5F6); // Light blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA), // Light gray background
      appBar: AppBar(
        title: const Text(
          "Game Zone",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF7CB342), // Light green to match practice zone
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Your Adventure!",
                      style: TextStyle(
                        color: Color(0xFF424242), // Soft dark gray
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Pick a game and start learning! 🌟",
                      style: TextStyle(
                        color: Color(0xFF757575), // Light gray
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Games grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid
                    int crossAxisCount;
                    double childAspectRatio;

                    if (constraints.maxWidth > 800) {
                      crossAxisCount = 3;
                      childAspectRatio = 0.85;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 2;
                      childAspectRatio = 0.9;
                    } else {
                      crossAxisCount = 1;
                      childAspectRatio = 1.8;
                    }

                    return GridView.builder(
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return _buildGameCard(context, game, isTablet);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    Map<String, dynamic> game,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: () {
        // Add subtle haptic feedback
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => game['route']),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: game['gradient'],
          ),
          boxShadow: [
            BoxShadow(
              color: game['gradient'][0].withOpacity(0.2), // Lighter shadow
              blurRadius: 10, // Reduced blur
              offset: Offset(0, 4), // Smaller offset
            ),
          ],
        ),
        child: Stack(
          children: [
            // Floating action button - student friendly
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Lighter shadow
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: isTablet ? 40 : 32,
                    height: isTablet ? 40 : 32,
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(game['difficulty']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: isTablet ? 24 : 20,
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji
                  Text(
                    game['emoji'],
                    style: TextStyle(fontSize: isTablet ? 48 : 40),
                  ),

                  SizedBox(height: isTablet ? 16 : 12),

                  // Title
                  Text(
                    game['title'],
                    style: TextStyle(
                      color: Color(0xFF424242), // Dark gray for better contrast on light backgrounds
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.8), // Light shadow for subtle effect
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isTablet ? 12 : 8),

                  // Subtitle
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isTablet ? 70 : 60),
                      child: Text(
                        game['subtitle'],
                        style: TextStyle(
                          color: Color(0xFF616161), // Medium gray for subtitle
                          fontSize: isTablet ? 16 : 14,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.6),
                              offset: Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class WordMatchScreen extends StatefulWidget {
  final String jsonPath;
  const WordMatchScreen({super.key, required this.jsonPath});

  @override
  State<WordMatchScreen> createState() => _WordMatchScreenState();
}

class _WordMatchScreenState extends State<WordMatchScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic> gameData = {};
  List<Map<String, dynamic>> gameQuestions = [];
  int currentQuestionIndex = 0;
  List<String> selectedAnswers = [];
  bool showExplanation = false;
  bool isAnswered = false;

  // Score tracking variables
  int correctAnswers = 0;
  List<bool> questionResults = []; // Track each question's result

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scoreAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    loadGameData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  Future<void> loadGameData() async {
    try {
      String jsonString = await rootBundle.loadString(widget.jsonPath);
      setState(() {
        gameData = json.decode(jsonString);
        setupGameQuestions();
      });
      _animationController.forward();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading game data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void setupGameQuestions() {
    gameQuestions.clear();
    questionResults.clear();
    correctAnswers = 0;

    final basicQuestions =
        (gameData['basic'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final mediumQuestions =
        (gameData['medium'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final hardQuestions =
        (gameData['hard'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    basicQuestions.shuffle();
    mediumQuestions.shuffle();
    hardQuestions.shuffle();

    gameQuestions.addAll(basicQuestions.take(5));
    gameQuestions.addAll(mediumQuestions.take(5));
    gameQuestions.addAll(hardQuestions.take(5));

    // Initialize results list
    questionResults = List.filled(gameQuestions.length, false);
  }

  Map<String, dynamic> getCurrentQuestion() {
    if (gameQuestions.isEmpty || currentQuestionIndex >= gameQuestions.length) {
      return {};
    }
    return gameQuestions[currentQuestionIndex];
  }

  void selectAnswer(String optionId) {
    if (isAnswered) return;

    setState(() {
      if (selectedAnswers.contains(optionId)) {
        selectedAnswers.remove(optionId);
      } else {
        selectedAnswers.add(optionId);
      }
    });
  }

  void submitAnswer() {
    final currentQ = getCurrentQuestion();
    if (currentQ.isEmpty) return;

    // Get correct answers
    final correctAnswerIds = (currentQ['options'] as List)
        .where((option) => option['isCorrect'] == true)
        .map((option) => option['id'] as String)
        .toSet();

    final selectedAnswerIds = selectedAnswers.toSet();

    // Check if the answer is completely correct
    bool isCompletelyCorrect =
        correctAnswerIds.length == selectedAnswerIds.length &&
        correctAnswerIds.every((id) => selectedAnswerIds.contains(id));

    setState(() {
      isAnswered = true;
      showExplanation = true;

      // Update score
      if (isCompletelyCorrect) {
        correctAnswers++;
        questionResults[currentQuestionIndex] = true;
      } else {
        questionResults[currentQuestionIndex] = false;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < gameQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswers.clear();
        showExplanation = false;
        isAnswered = false;
      });
    } else {
      showGameComplete();
    }
  }

  double getScorePercentage() {
    return gameQuestions.isEmpty
        ? 0
        : (correctAnswers / gameQuestions.length) * 100;
  }

  String getScoreGrade() {
    double percentage = getScorePercentage();
    if (percentage >= 90) return 'Excellent! 🌟';
    if (percentage >= 80) return 'Great Job! 🎉';
    if (percentage >= 70) return 'Good Work! 👍';
    if (percentage >= 60) return 'Keep Trying! 💪';
    return 'Practice More! 📚';
  }

  Color getScoreColor() {
    double percentage = getScorePercentage();
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  void showGameComplete() {
    _scoreAnimationController.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Score Circle
                  AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scoreAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getScoreColor().withOpacity(0.1),
                            border: Border.all(
                              color: getScoreColor(),
                              width: 4,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${getScorePercentage().round()}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: getScoreColor(),
                                ),
                              ),
                              Text(
                                '$correctAnswers/${gameQuestions.length}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: getScoreColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Title and Grade
                  const Text(
                    '🎉 Game Complete!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    getScoreGrade(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: getScoreColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Score Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Questions:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${gameQuestions.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Correct Answers:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '$correctAnswers',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Wrong Answers:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${gameQuestions.length - correctAnswers}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: resetGame,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Play Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(
                              context,
                            ).pop(); // Go back to games home
                          },
                          icon: const Icon(Icons.home),
                          label: const Text('Back to Games'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void resetGame() {
    Navigator.of(context).pop();
    _scoreAnimationController.reset();
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswers.clear();
      showExplanation = false;
      isAnswered = false;
      correctAnswers = 0;
      setupGameQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (gameData.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading game...', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    final currentQ = getCurrentQuestion();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Word Match Game',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Score: $correctAnswers/${gameQuestions.length}',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: currentQ.isEmpty
              ? const Center(child: Text('No questions available'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress Card
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              isSmallScreen ? 12.0 : 16.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Word Match Challenge',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value:
                                      (currentQuestionIndex + 1) /
                                      gameQuestions.length,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Question ${currentQuestionIndex + 1} of ${gameQuestions.length}',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 11 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 15 : 20),

                        // Word Card
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Colors.blueAccent, Colors.blue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: EdgeInsets.all(
                              isSmallScreen ? 20.0 : 24.0,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.quiz,
                                  size: isSmallScreen ? 35 : 40,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  currentQ['word'] ?? '',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 22 : 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  currentQ['question'] ?? '',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 15 : 20),

                        // Options
                        ...((currentQ['options'] as List?) ?? []).map((option) {
                          final isSelected = selectedAnswers.contains(
                            option['id'],
                          );
                          final isCorrect = option['isCorrect'] == true;

                          Color cardColor = Colors.white;
                          Color borderColor = Colors.grey[300]!;

                          if (isAnswered) {
                            if (isCorrect) {
                              cardColor = Colors.green[50]!;
                              borderColor = Colors.green;
                            } else if (isSelected && !isCorrect) {
                              cardColor = Colors.red[50]!;
                              borderColor = Colors.red;
                            }
                          } else if (isSelected) {
                            cardColor = Colors.blue.withOpacity(0.1);
                            borderColor = Colors.blue;
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: isSmallScreen ? 8.0 : 12.0,
                            ),
                            child: Card(
                              elevation: isSelected ? 4 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(color: borderColor, width: 2),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(
                                    isSmallScreen ? 12 : 16,
                                  ),
                                  leading: Container(
                                    width: isSmallScreen ? 25 : 30,
                                    height: isSmallScreen ? 25 : 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey[300],
                                    ),
                                    child: Center(
                                      child: Text(
                                        option['id'].toUpperCase(),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: isSmallScreen ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    option['text'],
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isAnswered
                                      ? Icon(
                                          isCorrect
                                              ? Icons.check_circle
                                              : (isSelected
                                                    ? Icons.cancel
                                                    : null),
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          size: isSmallScreen ? 20 : 24,
                                        )
                                      : null,
                                  onTap: () => selectAnswer(option['id']),
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        SizedBox(height: isSmallScreen ? 15 : 20),

                        // Submit Button
                        if (!isAnswered && selectedAnswers.isNotEmpty)
                          ElevatedButton(
                            onPressed: submitAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Submit Answer',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Explanation
                        if (showExplanation)
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.blue[50],
                              ),
                              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lightbulb,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Explanation',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    currentQ['explanation'] ?? '',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  if (currentQuestionIndex <
                                      gameQuestions.length - 1)
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: nextQuestion,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 20 : 24,
                                            vertical: isSmallScreen ? 10 : 12,
                                          ),
                                        ),
                                        child: const Text('Next Question'),
                                      ),
                                    )
                                  else
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: showGameComplete,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 20 : 24,
                                            vertical: isSmallScreen ? 10 : 12,
                                          ),
                                        ),
                                        child: const Text('View Results'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
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
  List<int> shuffledPuzzleOrder = [];
  int currentPuzzleOrderIndex = 0;
  List<String> selectedWords = [];
  List<bool> wordUsed = []; // Track used words
  List<String> shuffledWords = [];
  String correctSentence = '';
  int completedPuzzles = 0;

  // Result display variables
  bool showResult = false;
  bool isAnswerCorrect = false;
  bool showCorrectAnswer = false;
  String userAnswer = '';
  String resultMessage = '';
  bool gameCompleted = false; // Add this flag

  @override
  void initState() {
    super.initState();
    loadPuzzles();
  }

  Future<void> loadPuzzles() async {
    String jsonString = await rootBundle.loadString(widget.jsonPath);
    final data = jsonDecode(jsonString);

    // Extract questions by difficulty
    List<Map<String, dynamic>> basicQuestions = [];
    List<Map<String, dynamic>> mediumQuestions = [];
    List<Map<String, dynamic>> hardQuestions = [];

    if (data['basic'] != null) {
      basicQuestions = List<Map<String, dynamic>>.from(data['basic']);
    }
    if (data['medium'] != null) {
      mediumQuestions = List<Map<String, dynamic>>.from(data['medium']);
    }
    if (data['hard'] != null) {
      hardQuestions = List<Map<String, dynamic>>.from(data['hard']);
    }

    // Create sequential ordered puzzles: Basic first, then Medium, then Hard
    List<Map<String, dynamic>> orderedPuzzles = [];

    // Add 5 basic questions first
    if (basicQuestions.isNotEmpty) {
      basicQuestions.shuffle(Random());
      int basicCount = math.min(5, basicQuestions.length);
      for (int i = 0; i < basicCount; i++) {
        var puzzle = Map<String, dynamic>.from(basicQuestions[i]);
        puzzle['difficulty'] = 'Basic';
        orderedPuzzles.add(puzzle);
      }
    }

    // Add 5 medium questions after basic
    if (mediumQuestions.isNotEmpty) {
      mediumQuestions.shuffle(Random());
      int mediumCount = math.min(5, mediumQuestions.length);
      for (int i = 0; i < mediumCount; i++) {
        var puzzle = Map<String, dynamic>.from(mediumQuestions[i]);
        puzzle['difficulty'] = 'Medium';
        orderedPuzzles.add(puzzle);
      }
    }

    // Add 5 hard questions last
    if (hardQuestions.isNotEmpty) {
      hardQuestions.shuffle(Random());
      int hardCount = math.min(5, hardQuestions.length);
      for (int i = 0; i < hardCount; i++) {
        var puzzle = Map<String, dynamic>.from(hardQuestions[i]);
        puzzle['difficulty'] = 'Hard';
        orderedPuzzles.add(puzzle);
      }
    }

    // Keep the sequential order (no shuffling)
    puzzles = orderedPuzzles;

    // Create order indices (sequential)
    shuffledPuzzleOrder = List.generate(puzzles.length, (index) => index);

    if (puzzles.isNotEmpty) {
      loadPuzzle(0);
    }
  }

  void loadPuzzle(int orderIndex) {
    if (orderIndex >= shuffledPuzzleOrder.length) {
      // Game completed
      setState(() {
        gameCompleted = true;
        showResult = false;
      });
      return;
    }

    int actualPuzzleIndex = shuffledPuzzleOrder[orderIndex];

    setState(() {
      currentPuzzleOrderIndex = orderIndex;
      selectedWords.clear();
      shuffledWords = List<String>.from(puzzles[actualPuzzleIndex]['words'])
        ..shuffle();
      wordUsed = List<bool>.filled(shuffledWords.length, false);
      correctSentence = puzzles[actualPuzzleIndex]['sentence'];
      gameCompleted = false;

      // Reset result display
      showResult = false;
      isAnswerCorrect = false;
      showCorrectAnswer = false;
      userAnswer = '';
      resultMessage = '';
    });
  }

  void onWordTap(int index) {
    setState(() {
      if (!wordUsed[index]) {
        // Select word
        selectedWords.add(shuffledWords[index]);
        wordUsed[index] = true;
      }
    });
  }

  void onSelectedWordTap(int selectedIndex) {
    if (selectedIndex >= selectedWords.length) return;

    String wordToRemove = selectedWords[selectedIndex];

    setState(() {
      // Find the word in shuffledWords and mark as unused
      int wordIndex = shuffledWords.indexOf(wordToRemove);
      if (wordIndex != -1) {
        wordUsed[wordIndex] = false;
      }

      // Remove from selected words
      selectedWords.removeAt(selectedIndex);
    });
  }

  void checkAnswer() {
    if (selectedWords.isEmpty) {
      setState(() {
        showResult = true;
        isAnswerCorrect = false;
        resultMessage = "Please select some words first!";
        showCorrectAnswer = false;
      });
      return;
    }

    String formedSentence = selectedWords.join(" ");
    bool isCorrect =
        formedSentence.trim().toLowerCase() ==
        correctSentence.trim().toLowerCase();

    setState(() {
      showResult = true;
      isAnswerCorrect = isCorrect;
      userAnswer = formedSentence;
      showCorrectAnswer = !isCorrect;

      if (isCorrect) {
        completedPuzzles++;
        resultMessage = "🎉 Excellent! Well done!";
      } else {
        resultMessage = "❌ Not quite right. Try again!";
      }
    });

    // Auto navigate to next question after correct answer
    if (isCorrect) {
      Future.delayed(const Duration(seconds: 2), () {
        if (currentPuzzleOrderIndex < shuffledPuzzleOrder.length - 1) {
          _moveToNextQuestion();
        } else {
          _showCompletionDialog();
        }
      });
    }
  }

  void _moveToNextQuestion() {
    setState(() {
      showResult = false;
      isAnswerCorrect = false;
      showCorrectAnswer = false;
      userAnswer = '';
      resultMessage = '';
    });
    loadPuzzle(currentPuzzleOrderIndex + 1);
  }

  void _showCompletionDialog() {
    setState(() {
      showResult = false;
      isAnswerCorrect = false;
      showCorrectAnswer = false;
      userAnswer = '';
      resultMessage = '';
      gameCompleted = true; // Set completion flag
    });
  }

  void _restartGame() {
    setState(() {
      currentPuzzleOrderIndex = 0;
      completedPuzzles = 0;
      gameCompleted = false;
    });
    // Reload puzzles to get a new random selection
    loadPuzzles();
  }

  void resetSelection() {
    setState(() {
      selectedWords.clear();
      wordUsed = List<bool>.filled(shuffledWords.length, false);
      showResult = false;
      isAnswerCorrect = false;
      showCorrectAnswer = false;
      userAnswer = '';
      resultMessage = '';
    });
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'basic':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (puzzles.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Words → Sentence"),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show completion screen
    if (gameCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Words → Sentence"),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy and celebration
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 60,
                ),
              ),

              const SizedBox(height: 24),

              // Congratulations text
              const Text(
                "🎉 Congratulations! 🎉",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "You've completed all sentence formation puzzles!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Score display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                        const SizedBox(width: 8),
                        const Text(
                          "Final Score",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$completedPuzzles / 15",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      completedPuzzles == 15
                          ? "Perfect Score! Amazing!"
                          : completedPuzzles >= 12
                          ? "Excellent Work!"
                          : completedPuzzles >= 8
                          ? "Great Job!"
                          : "Good Effort!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Go back to previous screen
                      },
                      icon: const Icon(Icons.home, size: 20),
                      label: const Text(
                        "Finish",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _restartGame,
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text(
                        "Play Again",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Regular game screen
    int actualPuzzleIndex = shuffledPuzzleOrder[currentPuzzleOrderIndex];
    int gridSize = puzzles[actualPuzzleIndex]['gridSize'];
    String currentDifficulty =
        puzzles[actualPuzzleIndex]['difficulty'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Words → Sentence"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Header Section (Fixed)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress indicator with question number and difficulty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Form the correct sentence:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Score: $completedPuzzles",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question number and difficulty indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Question ${currentPuzzleOrderIndex + 1}/15",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(currentDifficulty),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentDifficulty,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: (currentPuzzleOrderIndex + 1) / 15,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ],
            ),
          ),

          // Scrollable Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Selected words section (scrollable horizontally if needed)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.touch_app,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Tap words below to remove",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Selected words display (non-scrollable, auto-expanding)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(
                            math.max(
                              correctSentence.split(" ").length,
                              selectedWords.length,
                            ),
                            (i) => GestureDetector(
                              onTap: i < selectedWords.length
                                  ? () => onSelectedWordTap(i)
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: i < selectedWords.length
                                        ? Colors.green
                                        : Colors.grey[400]!,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: i < selectedWords.length
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.white,
                                ),
                                child: Text(
                                  i < selectedWords.length
                                      ? selectedWords[i]
                                      : "___",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: i < selectedWords.length
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: i < selectedWords.length
                                        ? Colors.green[700]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Word grid (scrollable if needed)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double itemWidth =
                          (constraints.maxWidth - (gridSize - 1) * 8) /
                          gridSize;
                      double itemHeight = 50;
                      double gridHeight =
                          ((shuffledWords.length / gridSize).ceil() *
                              (itemHeight + 8)) -
                          8;

                      return Container(
                        height: math.min(
                          gridHeight,
                          250,
                        ), // Max height to ensure scrollability
                        child: SingleChildScrollView(
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: gridSize,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: itemWidth / itemHeight,
                            children: List.generate(shuffledWords.length, (
                              index,
                            ) {
                              return GestureDetector(
                                onTap: () => onWordTap(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: wordUsed[index]
                                        ? Colors.grey[300]
                                        : Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: wordUsed[index]
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.blueAccent
                                                  .withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        shuffledWords[index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: wordUsed[index]
                                              ? Colors.grey[600]
                                              : Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Result Display Section (only when shown, compact and scrollable)
                  if (showResult)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isAnswerCorrect
                                ? Colors.green[300]!
                                : Colors.red[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Compact result header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isAnswerCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isAnswerCorrect
                                          ? Icons.check_circle
                                          : Icons.info_outline,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isAnswerCorrect
                                          ? "Correct! 🎉"
                                          : "Try Again 💪",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isAnswerCorrect
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // Answer sections (auto-expanding)
                              if (userAnswer.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Your answer:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userAnswer,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              if (showCorrectAnswer) ...[
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: Colors.green[300]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Correct answer:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        correctSentence,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 10),

                              // Action buttons
                              if (!isAnswerCorrect) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: resetSelection,
                                        icon: const Icon(
                                          Icons.refresh,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "Try Again",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.blue,
                                          side: const BorderSide(
                                            color: Colors.blue,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _moveToNextQuestion,
                                        icon: const Icon(
                                          Icons.skip_next,
                                          size: 16,
                                        ),
                                        label: const Text(
                                          "Skip",
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.green[600]!,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        currentPuzzleOrderIndex <
                                                shuffledPuzzleOrder.length - 1
                                            ? "Moving to next..."
                                            : "Finishing up...",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Add bottom padding to prevent overlap with bottom buttons
                  SizedBox(height: !showResult ? 100 : 16),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons (Fixed with safe area padding)
          if (!showResult)
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: resetSelection,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text(
                        "Reset",
                        style: TextStyle(fontSize: 14),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: selectedWords.isNotEmpty ? checkAnswer : null,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        "Check Answer",
                        style: TextStyle(fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FillInTheBlanks extends StatefulWidget {
  final String jsonPath;
  const FillInTheBlanks({super.key, required this.jsonPath});
  @override
  _FillInTheBlanksState createState() => _FillInTheBlanksState();
}

class _FillInTheBlanksState extends State<FillInTheBlanks> {
  List<Map<String, dynamic>> allQuestions = [];
  List<Map<String, dynamic>> gameQuestions = [];
  int currentQuestionIndex = 0;
  List<String> currentAnswers = [];
  List<String> currentAvailableWords = [];
  int score = 0;
  bool showResults = false;
  bool isLoading = true;
  bool gameCompleted = false;
  int totalCorrectAnswers = 0;

  @override
  void initState() {
    super.initState();
    loadQuestionsFromJson();
  }

  Future<void> loadQuestionsFromJson() async {
    try {
      // Load the JSON file from assets
      String jsonString = await rootBundle.loadString(widget.jsonPath);
      dynamic jsonData = json.decode(jsonString);

      List<Map<String, dynamic>> loadedQuestions = [];

      // Handle the new JSON structure with basic, medium, hard categories
      if (jsonData is Map<String, dynamic>) {
        // Process basic questions
        if (jsonData['basic'] != null) {
          List<dynamic> basicQuestions = jsonData['basic'];
          for (var question in basicQuestions) {
            Map<String, dynamic> questionMap = Map<String, dynamic>.from(
              question,
            );
            questionMap['categoryId'] = 'basic';
            questionMap['difficulty'] = 'Basic';
            loadedQuestions.add(questionMap);
          }
        }

        // Process medium questions
        if (jsonData['medium'] != null) {
          List<dynamic> mediumQuestions = jsonData['medium'];
          for (var question in mediumQuestions) {
            Map<String, dynamic> questionMap = Map<String, dynamic>.from(
              question,
            );
            questionMap['categoryId'] = 'medium';
            questionMap['difficulty'] = 'Medium';
            loadedQuestions.add(questionMap);
          }
        }

        // Process hard questions
        if (jsonData['hard'] != null) {
          List<dynamic> hardQuestions = jsonData['hard'];
          for (var question in hardQuestions) {
            Map<String, dynamic> questionMap = Map<String, dynamic>.from(
              question,
            );
            questionMap['categoryId'] = 'hard';
            questionMap['difficulty'] = 'Hard';
            loadedQuestions.add(questionMap);
          }
        }
      }
      // Fallback for old JSON structure
      else if (jsonData is Map<String, dynamic> &&
          jsonData['questions'] != null) {
        loadedQuestions = List<Map<String, dynamic>>.from(
          jsonData['questions'],
        );
      } else if (jsonData is List) {
        loadedQuestions = List<Map<String, dynamic>>.from(jsonData);
      }

      setState(() {
        allQuestions = loadedQuestions;
        isLoading = false;
      });

      generateGameQuestions();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      generateGameQuestions();
    }
  }

  void generateGameQuestions() {
    // Separate questions by category
    List<Map<String, dynamic>> basicQuestions = allQuestions
        .where((q) => q['categoryId'] == 'basic')
        .toList();
    List<Map<String, dynamic>> mediumQuestions = allQuestions
        .where((q) => q['categoryId'] == 'medium')
        .toList();
    List<Map<String, dynamic>> hardQuestions = allQuestions
        .where((q) => q['categoryId'] == 'hard')
        .toList();

    // Shuffle each category
    basicQuestions.shuffle(Random());
    mediumQuestions.shuffle(Random());
    hardQuestions.shuffle(Random());

    // Select 5 from each category in order: Basic → Medium → Hard
    List<Map<String, dynamic>> selectedQuestions = [];
    selectedQuestions.addAll(basicQuestions.take(5));
    selectedQuestions.addAll(mediumQuestions.take(5));
    selectedQuestions.addAll(hardQuestions.take(5));

    // DO NOT shuffle the final selection to maintain order

    setState(() {
      gameQuestions = selectedQuestions;
      currentQuestionIndex = 0;
      gameCompleted = false;
      score = 0;
      totalCorrectAnswers = 0;
      initializeCurrentQuestion();
    });
  }

  void initializeCurrentQuestion() {
    if (currentQuestionIndex < gameQuestions.length) {
      Map<String, dynamic> currentQuestion =
          gameQuestions[currentQuestionIndex];
      setState(() {
        currentAnswers = List.filled(currentQuestion['blanks'], '');
        currentAvailableWords = List.from(currentQuestion['availableWords']);
        currentAvailableWords.shuffle(Random());
        showResults = false;
      });
    }
  }

  void resetCurrentQuestion() {
    setState(() {
      Map<String, dynamic> currentQuestion =
          gameQuestions[currentQuestionIndex];
      currentAnswers = List.filled(currentQuestion['blanks'], '');
      currentAvailableWords = List.from(currentQuestion['availableWords']);
      currentAvailableWords.shuffle(Random());
      showResults = false;
    });
  }

  void resetGame() {
    setState(() {
      generateGameQuestions();
    });
  }

  void checkCurrentQuestion() {
    Map<String, dynamic> currentQuestion = gameQuestions[currentQuestionIndex];
    List<String> correctAnswers = List.from(currentQuestion['correctAnswers']);

    bool allCorrect = true;

    for (int i = 0; i < currentAnswers.length; i++) {
      if (currentAnswers[i].trim() != correctAnswers[i].trim()) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      if (allCorrect) {
        score += 1; // ✅ +1 if the whole question is correct
      }
      showResults = true;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < gameQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        initializeCurrentQuestion();
      });
    } else {
      setState(() {
        gameCompleted = true;
      });
      showFinalResults();
    }
  }

  void placeWordInBlank(String word, int blankIndex) {
    setState(() {
      // If blank already has a word, return it to available words
      if (currentAnswers[blankIndex].isNotEmpty) {
        currentAvailableWords.add(currentAnswers[blankIndex]);
      }

      // Place new word in blank and remove from available words
      currentAnswers[blankIndex] = word;
      currentAvailableWords.remove(word);
    });
  }

  void removeWordFromBlank(int blankIndex) {
    setState(() {
      if (currentAnswers[blankIndex].isNotEmpty) {
        currentAvailableWords.add(currentAnswers[blankIndex]);
        currentAnswers[blankIndex] = '';
      }
    });
  }

  bool _areAllBlanksFilled() {
    return currentAnswers.every((answer) => answer.trim().isNotEmpty);
  }

  bool _hasAnyWrongAnswers() {
    Map<String, dynamic> currentQuestion = gameQuestions[currentQuestionIndex];
    List<String> correctAnswers = List.from(currentQuestion['correctAnswers']);

    for (int i = 0; i < currentAnswers.length; i++) {
      if (currentAnswers[i].isNotEmpty &&
          currentAnswers[i] != correctAnswers[i]) {
        return true;
      }
    }
    return false;
  }

  Widget _buildCorrectAnswersSection() {
    if (!showResults || !_hasAnyWrongAnswers()) return const SizedBox.shrink();

    Map<String, dynamic> currentQuestion = gameQuestions[currentQuestionIndex];
    String paragraph = currentQuestion['paragraph'];
    List<String> correctAnswers = List.from(currentQuestion['correctAnswers']);

    // Rebuild full sentence with correct words
    List<String> parts = paragraph.split('____');
    String fullSentence = '';
    for (int i = 0; i < parts.length; i++) {
      fullSentence += parts[i];
      if (i < correctAnswers.length) {
        fullSentence += correctAnswers[i];
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Correct Sentence:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fullSentence,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced blank widget that works better for long sentences
  Widget _buildBlankWidget(int index) {
    Map<String, dynamic> currentQuestion = gameQuestions[currentQuestionIndex];
    bool isCorrect =
        showResults &&
        currentAnswers[index] == currentQuestion['correctAnswers'][index];
    bool isIncorrect =
        showResults &&
        currentAnswers[index].isNotEmpty &&
        currentAnswers[index] != currentQuestion['correctAnswers'][index];

    return GestureDetector(
      onTap: () => removeWordFromBlank(index),
      child: DragTarget<String>(
        onAccept: (word) => placeWordInBlank(word, index),
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              minWidth: 80,
              maxWidth:
                  MediaQuery.of(context).size.width * 0.4, // Limit max width
            ),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.shade100
                  : isIncorrect
                  ? Colors.red.shade100
                  : candidateData.isNotEmpty
                  ? Colors.blue.shade50
                  : currentAnswers[index].isEmpty
                  ? Colors.grey.shade100
                  : Colors.blue.shade100,
              border: Border.all(
                color: isCorrect
                    ? Colors.green
                    : isIncorrect
                    ? Colors.red
                    : candidateData.isNotEmpty
                    ? Colors.blue.shade300
                    : currentAnswers[index].isEmpty
                    ? Colors.grey.shade400
                    : Colors.blue,
                width: candidateData.isNotEmpty ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: candidateData.isNotEmpty
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    currentAnswers[index].isEmpty
                        ? '______'
                        : currentAnswers[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: currentAnswers[index].isEmpty
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: currentAnswers[index].isEmpty
                          ? Colors.grey.shade500
                          : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showResults && currentAnswers[index].isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 18,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<InlineSpan> _buildRichTextSpans() {
    Map<String, dynamic> currentQuestion = gameQuestions[currentQuestionIndex];
    String paragraph = currentQuestion['paragraph'];
    List<String> parts = paragraph.split('____');
    List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      // Add text part
      if (parts[i].trim().isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }

      // Add blank if not the last part
      if (i < parts.length - 1) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _buildBlankWidget(i),
          ),
        );
      }
    }

    return spans;
  }

  void showFinalResults() {
    int totalQuestions = gameQuestions.length;
    int percentage = totalQuestions > 0 ? ((score * 100) ~/ totalQuestions) : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Game Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your Final Score: $score / $totalQuestions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentage% Accuracy',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Back to main menu
              },
              child: const Text('Finish'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fill in the Blanks'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading questions...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    if (gameQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fill in the Blanks'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'No questions available!',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => loadQuestionsFromJson(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill in the Blanks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Header Section (Fixed)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress and Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Complete the sentence:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Score: $score',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Question number and difficulty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Question ${currentQuestionIndex + 1}/15',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: (currentQuestionIndex + 1) / gameQuestions.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Paragraph Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width > 600
                                ? 18
                                : 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                          children: _buildRichTextSpans(),
                        ),
                      ),
                    ),

                    // Correct Answers Section
                    _buildCorrectAnswersSection(),

                    const SizedBox(height: 20),

                    // Word Bank Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.yellow.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Word Bank (Tap words to use them)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (currentAvailableWords.isEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'All words placed!',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Enhanced word bank with clickable words and better visual feedback
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: currentAvailableWords.map((word) {
                                return GestureDetector(
                                  onTap: () {
                                    // Find the first empty blank and place the word there
                                    int emptyBlankIndex = currentAnswers
                                        .indexWhere((answer) => answer.isEmpty);
                                    if (emptyBlankIndex != -1) {
                                      placeWordInBlank(word, emptyBlankIndex);
                                    } else {
                                      // If no empty blanks, show a snackbar
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'All blanks are filled. Tap on a blank to replace it.',
                                          ),
                                          duration: const Duration(seconds: 2),
                                          backgroundColor:
                                              Colors.orange.shade600,
                                        ),
                                      );
                                    }
                                  },
                                  child: Draggable<String>(
                                    data: word,
                                    dragAnchorStrategy:
                                        pointerDragAnchorStrategy,
                                    feedback: WordChip(
                                      word: word,
                                      isDragging: true,
                                    ),
                                    childWhenDragging: WordChip(
                                      word: word,
                                      isDragging: false,
                                      opacity: 0.3,
                                    ),
                                    child: WordChip(
                                      word: word,
                                      isDragging: false,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Add extra padding at bottom to prevent navigation bar overlap
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 100,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons (Fixed with SafeArea)
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (!showResults) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: resetCurrentQuestion,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text(
                              'Reset',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[600]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _areAllBlanksFilled()
                                ? checkCurrentQuestion
                                : null,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text(
                              'Check Answers',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    if (_hasAnyWrongAnswers()) ...[
                      // Show both Retry and Next buttons when there are wrong answers
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: resetCurrentQuestion,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text(
                                'Try Again',
                                style: TextStyle(fontSize: 14),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.orange.shade600),
                                foregroundColor: Colors.orange.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: nextQuestion,
                              icon: Icon(
                                currentQuestionIndex < gameQuestions.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.emoji_events,
                                size: 18,
                              ),
                              label: Text(
                                currentQuestionIndex < gameQuestions.length - 1
                                    ? 'Next Question'
                                    : 'Finish Game',
                                style: const TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Show only Next button when all answers are correct
                      ElevatedButton.icon(
                        onPressed: nextQuestion,
                        icon: Icon(
                          currentQuestionIndex < gameQuestions.length - 1
                              ? Icons.arrow_forward
                              : Icons.emoji_events,
                          size: 18,
                        ),
                        label: Text(
                          currentQuestionIndex < gameQuestions.length - 1
                              ? 'Next Question'
                              : 'Finish Game',
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WordChip extends StatelessWidget {
  final String word;
  final bool isDragging;
  final double opacity;

  const WordChip({
    Key? key,
    required this.word,
    required this.isDragging,
    this.opacity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDragging ? Colors.blue.shade100 : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDragging ? Colors.blue.shade300 : Colors.orange.shade300,
            width: 2,
          ),
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDragging ? Colors.blue.shade800 : Colors.orange.shade800,
          ),
        ),
      ),
    );
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
  int correctAnswers = 0;
  bool gameCompleted = false;

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
      // Game completed, show results
      setState(() {
        gameCompleted = true;
        feedback = "";
      });
    }
  }

  void checkAnswer() {
    String userSentence = selectedWords.join(" ").trim();
    String correctSentence = (gameData[currentIndex]['sentence'] ?? "").trim();

    if (userSentence.toLowerCase() == correctSentence.toLowerCase()) {
      setState(() {
        feedback = "✅ Correct!";
        correctAnswers++;
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

  void restartGame() {
    setState(() {
      currentIndex = 0;
      selectedWords.clear();
      correctAnswers = 0;
      gameCompleted = false;
      feedback = "";

      // Re-shuffle keywords for all games
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

  void goBackHome() {
    Navigator.of(context).pop();
  }

  int _calculateCrossAxisCount(int wordCount) {
    if (wordCount <= 4) return 2;
    if (wordCount <= 6) return 2;
    if (wordCount <= 9) return 3;
    if (wordCount <= 12) return 3;
    return 4;
  }

  double _calculateChildAspectRatio(int wordCount) {
    if (wordCount <= 4) return 2.5;
    if (wordCount <= 6) return 2.0;
    if (wordCount <= 9) return 1.8;
    if (wordCount <= 12) return 1.5;
    return 1.2;
  }

  Widget buildResultsScreen() {
    double percentage = (correctAnswers / gameData.length) * 100;
    String resultMessage;
    Color resultColor;
    String emoji;

    if (percentage >= 80) {
      resultMessage = "Excellent!";
      resultColor = Colors.green;
      emoji = "🏆";
    } else if (percentage >= 60) {
      resultMessage = "Good Job!";
      resultColor = Colors.blue;
      emoji = "👏";
    } else if (percentage >= 40) {
      resultMessage = "Keep Practicing!";
      resultColor = Colors.orange;
      emoji = "💪";
    } else {
      resultMessage = "Try Again!";
      resultColor = Colors.red;
      emoji = "📚";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/games',
              (route) => false,
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result emoji and message
            Text(emoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              resultMessage,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: resultColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Score display
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Text(
                    "Your Score",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$correctAnswers/${gameData.length}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${percentage.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: resultColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "🔄 Play Again",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: goBackHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "🏠 Back Home",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (gameData.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Show results screen if game is completed
    if (gameCompleted) {
      return buildResultsScreen();
    }

    var currentGame = gameData[currentIndex];
    final keywordCount = currentGame['keywords'].length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Picture → Sentence (${currentIndex + 1}/${gameData.length})",
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Image section
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(currentGame['image']),
              ),
            ),

            // Selected sentence display
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                selectedWords.isEmpty
                    ? "Tap words to form a sentence..."
                    : selectedWords.join(" "),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selectedWords.isEmpty
                      ? Colors.grey[600]
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 12),

            // Feedback message
            Container(
              height: 30,
              child: Text(
                feedback,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: feedback.startsWith("✅")
                      ? Colors.green
                      : feedback.startsWith("❌")
                      ? Colors.red
                      : Colors.transparent,
                ),
              ),
            ),

            // Keywords grid - Flexible to take available space
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateCrossAxisCount(keywordCount),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: _calculateChildAspectRatio(keywordCount),
                  ),
                  itemCount: keywordCount,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (!wordSelected[index]) {
                          setState(() {
                            selectedWords.add(currentGame['keywords'][index]);
                            wordSelected[index] = true;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: wordSelected[index]
                              ? Colors.grey[400]
                              : Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: wordSelected[index]
                                ? Colors.grey[600]!
                                : Colors.blue[300]!,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Text(
                            currentGame['keywords'][index],
                            style: TextStyle(
                              fontSize: keywordCount > 12 ? 12 : 14,
                              fontWeight: FontWeight.w500,
                              color: wordSelected[index]
                                  ? Colors.grey[700]
                                  : Colors.blue[800],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bottom button section - Fixed at bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedWords.isNotEmpty
                          ? resetSelection
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedWords.isNotEmpty ? checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Check",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final int id;
  final String sentence;
  final List<String> words;

  Question({required this.id, required this.sentence, required this.words});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      sentence: json['sentence'],
      words: List<String>.from(json['words']),
    );
  }
}

class ListeningPuzzleScreen extends StatefulWidget {
  final String jsonPath;

  const ListeningPuzzleScreen({super.key, required this.jsonPath});
  @override
  _ListeningPuzzleScreenState createState() => _ListeningPuzzleScreenState();
}

class _ListeningPuzzleScreenState extends State<ListeningPuzzleScreen>
    with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  Map<String, List<Question>> gameData = {};
  List<Question> selectedQuestions = [];
  int currentQuestionIndex = 0;
  List<String> arrangedWords = [];
  List<String> availableWords = [];
  Question? currentQuestion;
  bool isLoading = true;
  bool isPlaying = false;
  int score = 0;
  bool showResult = false;
  bool isCorrect = false;
  bool gameCompleted = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final int basicQuestions = 4;
  final int mediumQuestions = 4;
  final int hardQuestions = 2;
  int get totalQuestions => basicQuestions + mediumQuestions + hardQuestions;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTts();
    _loadGameData();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  void _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _loadGameData() async {
    try {
      // Load JSON data from assets file
      final String jsonString = await rootBundle.loadString(widget.jsonPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      gameData = {
        'basic': (jsonData['basic'] as List)
            .map((item) => Question.fromJson(item))
            .toList(),
        'medium': (jsonData['medium'] as List)
            .map((item) => Question.fromJson(item))
            .toList(),
        'hard': (jsonData['hard'] as List)
            .map((item) => Question.fromJson(item))
            .toList(),
      };

      _selectRandomQuestions();
      _loadQuestion();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading game data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectRandomQuestions() {
    selectedQuestions.clear();

    List<Question> basicList = List.from(gameData['basic']!);
    List<Question> mediumList = List.from(gameData['medium']!);
    List<Question> hardList = List.from(gameData['hard']!);

    basicList.shuffle();
    mediumList.shuffle();
    hardList.shuffle();

    selectedQuestions.addAll(basicList.take(basicQuestions));
    selectedQuestions.addAll(mediumList.take(mediumQuestions));
    selectedQuestions.addAll(hardList.take(hardQuestions));

    currentQuestionIndex = 0;
  }

  void _loadQuestion() {
    if (selectedQuestions.isNotEmpty &&
        currentQuestionIndex < selectedQuestions.length) {
      currentQuestion = selectedQuestions[currentQuestionIndex];
      availableWords = List.from(currentQuestion!.words);
      arrangedWords.clear();
      showResult = false;
      gameCompleted = false;
    }
  }

  String _getCurrentDifficulty() {
    if (currentQuestionIndex < basicQuestions) {
      return 'basic';
    } else if (currentQuestionIndex < basicQuestions + mediumQuestions) {
      return 'medium';
    } else {
      return 'hard';
    }
  }

  void _playAudio() async {
    if (currentQuestion != null && !isPlaying) {
      setState(() {
        isPlaying = true;
      });
      await flutterTts.speak(currentQuestion!.sentence);
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        isPlaying = false;
      });
    }
  }

  void _addWord(String word) {
    setState(() {
      arrangedWords.add(word);
      availableWords.remove(word);
    });
  }

  void _removeWord(String word) {
    setState(() {
      arrangedWords.remove(word);
      availableWords.add(word);
    });
  }

  void _checkAnswer() {
    String userSentence = arrangedWords.join(' ');
    isCorrect =
        userSentence.toLowerCase() == currentQuestion!.sentence.toLowerCase();

    String currentDifficulty = _getCurrentDifficulty();
    if (isCorrect) {
      score += currentDifficulty == 'basic'
          ? 10
          : currentDifficulty == 'medium'
          ? 20
          : 30;
    }

    setState(() {
      showResult = true;
    });

    // Auto advance to next question after 2 seconds
    Future.delayed(Duration(seconds: 3), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      showResult = false;
      currentQuestionIndex++;

      if (currentQuestionIndex >= selectedQuestions.length) {
        gameCompleted = true;
      } else {
        _loadQuestion();
      }
    });
  }

  void _resetGame() {
    setState(() {
      score = 0;
      currentQuestionIndex = 0;
      showResult = false;
      gameCompleted = false;
      _selectRandomQuestions();
      _loadQuestion();
    });
  }

  Widget _buildProgressBar() {
    double progress = (currentQuestionIndex) / totalQuestions;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '${currentQuestionIndex}/${totalQuestions}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                // Background segments
                Row(
                  children: [
                    Expanded(
                      flex: basicQuestions,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: mediumQuestions,
                      child: Container(color: Colors.orange.shade200),
                    ),
                    Expanded(
                      flex: hardQuestions,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade200,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Progress indicator
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              _buildLegendItem(Colors.green, 'Basic (${basicQuestions})'),
              SizedBox(width: 16),
              _buildLegendItem(Colors.orange, 'Medium (${mediumQuestions})'),
              SizedBox(width: 16),
              _buildLegendItem(Colors.red, 'Hard (${hardQuestions})'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildAudioButton() {
    return GestureDetector(
      onTap: _playAudio,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isPlaying ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: isPlaying ? Colors.orange : Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade300,
                    blurRadius: 15,
                    spreadRadius: isPlaying ? 5 : 2,
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.volume_up : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordChip(String word, bool isInArranged) {
    return GestureDetector(
      onTap: () {
        if (isInArranged) {
          _removeWord(word);
        } else {
          _addWord(word);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isInArranged ? Colors.green.shade100 : Colors.grey.shade100,
          border: Border.all(
            color: isInArranged ? Colors.green : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          word,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isInArranged ? Colors.green.shade800 : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildArrangedSentence() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: arrangedWords.isEmpty
          ? Text(
              'Drag words here to form the sentence...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            )
          : Wrap(
              children: arrangedWords
                  .map((word) => _buildWordChip(word, true))
                  .toList(),
            ),
    );
  }

  Widget _buildAvailableWords() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Words:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            children: availableWords
                .map((word) => _buildWordChip(word, false))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    if (gameCompleted) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, size: 80, color: Colors.amber),
                SizedBox(height: 20),
                Text(
                  'Game Completed!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Final Score: $score',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _resetGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Back Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      color: showResult ? Colors.black.withOpacity(0.7) : Colors.transparent,
      child: showResult
          ? Center(
              child: Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 80,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    SizedBox(height: 20),
                    Text(
                      isCorrect ? 'Excellent!' : 'Try Again!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Correct Answer:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      currentQuestion?.sentence ?? '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listening Puzzle',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProgressBar(),
                  SizedBox(height: 20),
                  Text(
                    'Listen to the audio and arrange the words',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  _buildAudioButton(),
                  SizedBox(height: 30),
                  _buildArrangedSentence(),
                  SizedBox(height: 20),
                  _buildAvailableWords(),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: arrangedWords.isNotEmpty && !gameCompleted
                              ? _checkAnswer
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Check Answer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _buildResultOverlay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    flutterTts.stop();
    super.dispose();
  }
}

class StoryCompletionScreen extends StatefulWidget {
  final String jsonPath;

  const StoryCompletionScreen({super.key, required this.jsonPath});
  @override
  _StoryCompletionScreenState createState() => _StoryCompletionScreenState();
}

class _StoryCompletionScreenState extends State<StoryCompletionScreen> {
  List<dynamic> allStories = [];
  List<dynamic> selectedStories = [];
  int currentStoryIndex = 0;
  TextEditingController storyController = TextEditingController();
  bool isLoading = true;
  bool showSuggestion = false;
  bool showAffirmation = false;
  bool showAlternatives = false;
  bool gameCompleted = false;
  String selectedAffirmation = '';
  Map<String, dynamic> storyAnalysis = {};
  final int storiesPerGame = 3;

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  Future<void> loadStories() async {
    try {
      // Load from assets/games/ directory
      final String response = await rootBundle.loadString(widget.jsonPath);
      final data = json.decode(response);
      setState(() {
        allStories = data['story_completion_challenges'];
        selectRandomStories();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading stories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void selectRandomStories() {
    if (allStories.length >= storiesPerGame) {
      // Create a copy of allStories and shuffle it
      List<dynamic> shuffledStories = List.from(allStories);
      shuffledStories.shuffle(Random());
      // Select first 3 stories from shuffled list
      selectedStories = shuffledStories.take(storiesPerGame).toList();
    } else {
      // If we have fewer than 3 stories, use all of them
      selectedStories = List.from(allStories);
    }
  }

  void restartGame() {
    setState(() {
      currentStoryIndex = 0;
      storyController.clear();
      showSuggestion = false;
      showAffirmation = false;
      showAlternatives = false;
      gameCompleted = false;
      storyAnalysis = {};
      selectRandomStories(); // Select new random stories
    });
  }

  void nextStory() {
    if (currentStoryIndex < selectedStories.length - 1) {
      setState(() {
        currentStoryIndex++;
        storyController.clear();
        showSuggestion = false;
        showAffirmation = false;
        showAlternatives = false;
        storyAnalysis = {};
      });
    } else {
      // Game completed
      setState(() {
        gameCompleted = true;
      });
    }
  }

  void previousStory() {
    if (currentStoryIndex > 0) {
      setState(() {
        currentStoryIndex--;
        storyController.clear();
        showSuggestion = false;
        showAffirmation = false;
        showAlternatives = false;
        storyAnalysis = {};
        gameCompleted = false; // Reset game completion if going back
      });
    }
  }

  void showHint() {
    // This function is no longer needed since hint shows automatically
  }

  Map<String, dynamic> analyzeStory(String userStory) {
    final story = userStory.toLowerCase().trim();
    final currentStoryData = selectedStories[currentStoryIndex];
    final originalStory = currentStoryData['incomplete_story_text']
        .toLowerCase();

    int score = 0;
    List<String> strengths = [];
    List<String> suggestions = [];

    // Check minimum length
    if (story.length < 20) {
      suggestions.add(
        "Your story would be even more amazing with more details and descriptions!",
      );
      return {
        'score': 1,
        'strengths': [
          'You took the brave step to start writing - that\'s wonderful!',
        ],
        'suggestions': suggestions,
        'feedback':
            'What a great start! I can see your creativity beginning to shine. Try adding more details to paint an even more vivid picture for your readers!',
      };
    }

    // Check for story elements
    List<String> storyElements = [
      'and',
      'then',
      'suddenly',
      'but',
      'so',
      'because',
      'when',
      'while',
      'after',
      'before',
      'finally',
      'meanwhile',
      'however',
      'although',
    ];

    List<String> descriptiveWords = [
      'beautiful',
      'mysterious',
      'bright',
      'dark',
      'magical',
      'amazing',
      'wonderful',
      'scary',
      'exciting',
      'peaceful',
      'loud',
      'quiet',
      'huge',
      'tiny',
      'colorful',
      'shimmering',
      'glowing',
      'sparkling',
    ];

    List<String> actionWords = [
      'ran',
      'walked',
      'jumped',
      'climbed',
      'discovered',
      'found',
      'opened',
      'closed',
      'looked',
      'listened',
      'whispered',
      'shouted',
      'grabbed',
      'touched',
      'moved',
      'appeared',
      'disappeared',
      'transformed',
    ];

    // Check for narrative flow
    int narrativeElements = 0;
    for (String element in storyElements) {
      if (story.contains(element)) narrativeElements++;
    }

    // Check for descriptive language
    int descriptiveCount = 0;
    for (String word in descriptiveWords) {
      if (story.contains(word)) descriptiveCount++;
    }

    // Check for action words
    int actionCount = 0;
    for (String word in actionWords) {
      if (story.contains(word)) actionCount++;
    }

    // Check for dialogue
    bool hasDialogue =
        story.contains('"') ||
        story.contains("'") ||
        story.contains('said') ||
        story.contains('asked') ||
        story.contains('whispered') ||
        story.contains('shouted');

    // Check for character development
    String mainCharacter = getMainCharacter(originalStory);
    bool continuesCharacter = story.contains(mainCharacter.toLowerCase());

    // Calculate score and feedback with positive language
    if (narrativeElements >= 3) {
      score += 2;
      strengths.add(
        "You're a natural storyteller! Your story flows beautifully with connecting words",
      );
    } else if (narrativeElements >= 2) {
      score += 2;
      strengths.add(
        "Excellent use of connecting words - your story flows really well!",
      );
    } else if (narrativeElements >= 1) {
      score += 1;
      strengths.add("Good job using connecting words to link your ideas!");
      suggestions.add(
        "You're doing great! Try adding words like 'suddenly' or 'then' to make your story flow even smoother",
      );
    } else {
      suggestions.add(
        "Your imagination is wonderful! Try connecting your ideas with words like 'then', 'suddenly', or 'but' to help readers follow along",
      );
    }

    if (descriptiveCount >= 3) {
      score += 2;
      strengths.add(
        "Wow! Your descriptive language is absolutely fantastic - I can picture everything clearly!",
      );
    } else if (descriptiveCount >= 2) {
      score += 2;
      strengths.add(
        "Beautiful descriptive language! You really know how to paint a picture with words",
      );
    } else if (descriptiveCount >= 1) {
      score += 1;
      strengths.add("Nice use of descriptive words - keep it up!");
      suggestions.add(
        "You're on the right track! Adding more colorful adjectives will make your story even more captivating",
      );
    } else {
      suggestions.add(
        "Your story has great potential! Try adding descriptive words like 'mysterious', 'sparkling', or 'ancient' to help readers visualize your amazing world",
      );
    }

    if (actionCount >= 3) {
      score += 2;
      strengths.add(
        "Your story is packed with exciting action - it kept me on the edge of my seat!",
      );
    } else if (actionCount >= 2) {
      score += 2;
      strengths.add(
        "Fantastic action and movement! Your story is really engaging",
      );
    } else if (actionCount >= 1) {
      score += 1;
      strengths.add("Good job including action in your story!");
      suggestions.add(
        "You're doing wonderfully! Adding more action verbs will make your adventure even more thrilling",
      );
    } else {
      suggestions.add(
        "Your creativity shines through! Try adding action words like 'discovered', 'whispered', or 'transformed' to bring more excitement to your tale",
      );
    }

    if (hasDialogue) {
      score += 1;
      strengths.add(
        "I love how you brought your characters to life with dialogue - that's advanced storytelling!",
      );
    } else {
      suggestions.add(
        "You're such a talented writer! Consider adding what characters say or think to make them even more real to your readers",
      );
    }

    if (continuesCharacter) {
      score += 1;
      strengths.add(
        "Perfect! You kept the main character as the hero of your story",
      );
    } else {
      suggestions.add(
        "You have such great ideas! Remember to include ${getMainCharacter(originalStory)} in your ending - they're the star of this adventure!",
      );
    }

    // Check for creativity elements
    List<String> creativeElements = [
      'magic',
      'mystery',
      'surprise',
      'adventure',
      'discovery',
      'secret',
      'hidden',
      'ancient',
      'mysterious',
      'enchanted',
    ];

    int creativityScore = 0;
    for (String element in creativeElements) {
      if (story.contains(element)) creativityScore++;
    }

    if (creativityScore >= 3) {
      score += 2;
      strengths.add(
        "Your imagination is absolutely incredible! This story is full of wonder and magic",
      );
    } else if (creativityScore >= 2) {
      score += 2;
      strengths.add(
        "What wonderful creative imagination! Your story is truly magical",
      );
    } else if (creativityScore >= 1) {
      score += 1;
      strengths.add("Great creative thinking - I love your imaginative ideas!");
    }

    // Generate overall feedback with positive, encouraging tone
    String feedback;
    if (score >= 8) {
      feedback =
          "🌟 WOW! You're an amazing storyteller! Your writing is creative, engaging, and beautifully crafted. You should be incredibly proud of this masterpiece!";
    } else if (score >= 6) {
      feedback =
          "✨ Fantastic work! You have real talent as a writer. Your story shows wonderful creativity and skill. Keep writing - you're doing brilliantly!";
    } else if (score >= 4) {
      feedback =
          "🎉 Great job! Your story has so many wonderful elements. You're developing into a skilled writer. I can't wait to see what you write next!";
    } else if (score >= 2) {
      feedback =
          "👏 What a lovely effort! Your creativity is shining through. With each story you write, you're becoming a better storyteller. Keep up the wonderful work!";
    } else {
      feedback =
          "🌈 Thank you for sharing your story! Every great writer started just like you. Your imagination is wonderful, and with practice, your stories will become even more amazing!";
    }

    return {
      'score': score,
      'strengths': strengths,
      'suggestions': suggestions,
      'feedback': feedback,
    };
  }

  String getMainCharacter(String story) {
    // Extract main character name from the original story
    List<String> commonNames = ['Leo', 'Maya', 'Alex', 'Sarah', 'Lily'];
    for (String name in commonNames) {
      if (story.contains(name)) return name;
    }
    return 'the character';
  }

  List<String> generateWritingAlternatives() {
    final currentStoryData = selectedStories[currentStoryIndex];

    // Get alternatives from JSON, with fallback if not present
    if (currentStoryData.containsKey('alternatives') &&
        currentStoryData['alternatives'] is List) {
      return List<String>.from(currentStoryData['alternatives']);
    }

    // Fallback alternatives if not in JSON
    return [
      'Try adding more sensory details (what characters see, hear, feel)',
      'Consider the emotions your characters are experiencing',
      'Think about the cause and effect of events in your story',
      'Add dialogue to show character personalities',
      'Describe the setting in more vivid detail',
    ];
  }

  void submitStory() {
    if (storyController.text.trim().isNotEmpty) {
      final analysis = analyzeStory(storyController.text);
      final affirmations =
          selectedStories[currentStoryIndex]['positive_affirmations'];

      setState(() {
        storyAnalysis = analysis;
        selectedAffirmation =
            (affirmations as List)[(analysis['score'] / 2)
                .clamp(0, affirmations.length - 1)
                .round()];
        showAffirmation = true;
        showSuggestion = true; // Automatically show the hint after submission
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
              SizedBox(height: 16),
              Text('Loading Stories...', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    if (allStories.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Failed to load stories', style: TextStyle(fontSize: 18)),
              Text('Please check if the JSON file is in games/paste.txt'),
            ],
          ),
        ),
      );
    }

    if (selectedStories.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Failed to load stories', style: TextStyle(fontSize: 18)),
              Text('Please check if the JSON file is in games/paste.txt'),
            ],
          ),
        ),
      );
    }

    // Replace the existing game completion screen section with this code:

    if (gameCompleted) {
      return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // Back arrow
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: restartGame,
                      icon: Icon(Icons.arrow_back),
                      color: Colors.grey.shade600,
                    ),
                  ),

                  // Spacer to center content
                  SizedBox(height: 20),

                  // Trophy Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Colors.orange.shade600,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Congratulations Text with Emojis
                  Text(
                    '🎉 Congratulations! 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 12),

                  // Completion Message
                  Text(
                    'You\'ve completed all story formation\npuzzles!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 30),

                  // Achievement Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Star Icon
                        Icon(
                          Icons.star,
                          size: 28,
                          color: Colors.orange.shade500,
                        ),

                        SizedBox(height: 8),

                        // Final Achievement
                        Text(
                          'Story Master',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),

                        SizedBox(height: 4),

                        // Stories completed count
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade600,
                            ),
                            children: [
                              TextSpan(text: '$storiesPerGame'),
                              TextSpan(
                                text: ' / $storiesPerGame',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Stories Completed!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Action Buttons
                  Column(
                    children: [
                      // Home/Finish Button
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.home, size: 18),
                          label: Text(
                            'Finish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      // Play Again Button
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        child: ElevatedButton.icon(
                          onPressed: restartGame,
                          icon: Icon(Icons.refresh, size: 18),
                          label: Text(
                            'Play Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade500,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final currentStory = selectedStories[currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text('Story Completion Game'),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    'Story ${currentStoryIndex + 1} of $storiesPerGame',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (currentStoryIndex + 1) / storiesPerGame,
                    backgroundColor: Colors.purple.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purple.shade400,
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Story title
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade200, Colors.pink.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                currentStory['title'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            // Story text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories, color: Colors.purple.shade400),
                      SizedBox(width: 8),
                      Text(
                        'Your Story Begins...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    currentStory['incomplete_story_text'],
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Writing area
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.green.shade400),
                        SizedBox(width: 8),
                        Text(
                          'Complete the Story!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: storyController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Write your exciting ending here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.green.shade400,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.green.shade50,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: submitStory,
                            icon: Icon(Icons.send),
                            label: Text('Submit Story'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade400,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              showAlternatives = !showAlternatives;
                            });
                          },
                          icon: Icon(Icons.lightbulb),
                          label: Text('Ideas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade400,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Suggested ending (automatically shown after submission)
            if (showSuggestion && showAffirmation) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.orange.shade600),
                        SizedBox(width: 8),
                        Text(
                          'Here\'s How We Imagined It Could End',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Compare this with your creative ending! Remember, there are many wonderful ways a story can end.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      currentStory['suggested_completion_text'],
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Writing alternatives container
            if (showAlternatives) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: Colors.blue.shade600,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Instead, You Could Also Write...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    ...generateWritingAlternatives()
                        .map(
                          (alternative) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: EdgeInsets.only(top: 8, right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    alternative,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ],

            // Story Analysis and Feedback (if shown)
            if (showAffirmation && storyAnalysis.isNotEmpty) ...[
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade200, Colors.purple.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < (storyAnalysis['score'] / 2).round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Story Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      storyAnalysis['feedback'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    if (storyAnalysis['strengths'].isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.celebration,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'What Made Your Story Shine:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ...storyAnalysis['strengths']
                                .map<Widget>(
                                  (strength) => Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          '✨ ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            strength,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                    if (storyAnalysis['suggestions'].isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_fix_high,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Ways to Make It Even More Amazing:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ...storyAnalysis['suggestions']
                                .map<Widget>(
                                  (suggestion) => Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          '💡 ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            suggestion,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            SizedBox(height: 30),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: currentStoryIndex > 0 ? previousStory : null,
                  icon: Icon(Icons.arrow_back),
                  label: Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: currentStoryIndex < storiesPerGame - 1
                      ? nextStory
                      : (showAffirmation ? nextStory : null),
                  icon: Icon(
                    currentStoryIndex < storiesPerGame - 1
                        ? Icons.arrow_forward
                        : Icons.flag,
                  ),
                  label: Text(
                    currentStoryIndex < storiesPerGame - 1
                        ? 'Next Story'
                        : 'Finish Game',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentStoryIndex < storiesPerGame - 1
                        ? Colors.purple.shade400
                        : Colors.green.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }
}
