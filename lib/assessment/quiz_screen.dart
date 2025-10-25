import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:K_Skill/models/quiz_question_model.dart';
import 'package:K_Skill/screens/widgets/quiz_card_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> allQuestions = [];
  List<QuizQuestion> selectedQuestions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isQuizCompleted = false;
  bool isLoading = true;
  String? errorMessage;
  int questionsToSelect = 10;

  // Track user's answers for each question
  List<String?> userAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuestionsFromJson();
  }

  Future<void> _loadQuestionsFromJson() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final String jsonString = await rootBundle.loadString(
        'data/assessment/quiz_questions.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<dynamic> quizLevels = jsonMap['grammar_quiz'];

      List<QuizQuestion> loadedQuestions = [];

      for (var levelGroup in quizLevels) {
        String level = levelGroup['level'];
        List<dynamic> questions = levelGroup['questions'];

        for (var q in questions) {
          q['level'] = level; // add level info manually
          loadedQuestions.add(QuizQuestion.fromJson(q));
        }
      }

      allQuestions = loadedQuestions;
      _selectRandomQuestions();
      setState(() => isLoading = false);
    } catch (e) {
      print('Error parsing quiz JSON: $e');
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load quiz questions.";
      });
    }
  }

  void _selectRandomQuestions() {
    if (allQuestions.isEmpty) return;

    final Map<String, List<QuizQuestion>> groupedByLevel = {
      'Easy': [],
      'Medium': [],
      'Hard': [],
    };

    for (var q in allQuestions) {
      groupedByLevel[q.level]?.add(q);
    }

    final random = Random();
    List<QuizQuestion> selected = [];

    List<QuizQuestion> pickRandom(List<QuizQuestion> list, int count) {
      list.shuffle(random);
      return list.take(count.clamp(0, list.length)).toList();
    }

    selected.addAll(pickRandom(groupedByLevel['Easy']!, 10));
    selected.addAll(pickRandom(groupedByLevel['Medium']!, 10));
    selected.addAll(pickRandom(groupedByLevel['Hard']!, 5));

    setState(() {
      selectedQuestions = selected;
      // Initialize userAnswers list with null values
      userAnswers = List.filled(selectedQuestions.length, null);
    });
  }

  void handleAnswerSelected(String selectedAnswer) {
    setState(() {
      userAnswers[currentQuestionIndex] = selectedAnswer;
    });
  }

  void _goToPreviousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _goToNextQuestion() {
    if (currentQuestionIndex < selectedQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _completeQuiz() {
    // Calculate score
    score = 0;
    for (int i = 0; i < selectedQuestions.length; i++) {
      if (userAnswers[i] == selectedQuestions[i].correctAnswer) {
        score++;
      }
    }

    setState(() {
      isQuizCompleted = true;
    });
  }

  void _submitScoreAndContinue() {
    Navigator.pop(context, score);
    
    Future.delayed(Duration.zero, () {
      Navigator.pushNamed(context, '/reading');
    });
  }

  Widget _buildResultScreen() {
    final percentage = (score / selectedQuestions.length) * 100;
    String message;
    Color color;

    if (percentage >= 90) {
      message = "Excellent! 🌟";
      color = Colors.green;
    } else if (percentage >= 70) {
      message = "Good job! 👍";
      color = Colors.blue;
    } else if (percentage >= 50) {
      message = "Keep practicing! ✍️";
      color = Colors.orange;
    } else {
      message = "Don't give up! 💪";
      color = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFFFA500), // Orange
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "You scored $score / ${selectedQuestions.length}",
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  "Percentage: ${percentage.toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Next: Reading Practice",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _submitScoreAndContinue,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Continue to Reading"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final bool canGoBack = currentQuestionIndex > 0;
    final bool canGoNext = currentQuestionIndex < selectedQuestions.length - 1;
    final bool isLastQuestion =
        currentQuestionIndex == selectedQuestions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: canGoBack ? _goToPreviousQuestion : null,
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text("Previous"),
            style: ElevatedButton.styleFrom(
              backgroundColor: canGoBack ? Colors.grey[600] : Colors.grey[300],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Next/Complete button
          ElevatedButton.icon(
            onPressed: isLastQuestion
                ? _completeQuiz
                : (canGoNext ? _goToNextQuestion : null),
            icon: Icon(
              isLastQuestion ? Icons.check : Icons.arrow_forward,
              size: 20,
            ),
            label: Text(isLastQuestion ? "Complete" : "Next"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingScreen();
    if (errorMessage != null) return _buildErrorScreen();
    if (isQuizCompleted) return _buildResultScreen();

    final currentQuestion = selectedQuestions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA500),
        title: Text(
          "Grammar Quiz",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${_getAnsweredCount()} / ${selectedQuestions.length} answered",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        (currentQuestionIndex + 1) / selectedQuestions.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFA500),
                    ),
                  ),
                ],
              ),
            ),

            // Question content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: QuizCardWidget(
                  question: currentQuestion.question,
                  options: currentQuestion.options,
                  correctAnswer: currentQuestion.correctAnswer,
                  selectedAnswer:
                      userAnswers[currentQuestionIndex], // Pass selected answer
                  onAnswerSelected: handleAnswerSelected,
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  int _getAnsweredCount() {
    return userAnswers.where((answer) => answer != null).length;
  }

  Widget _buildLoadingScreen() => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: Color(0xFFFFA500))),
  );

  Widget _buildErrorScreen() => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Error loading quiz',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadQuestionsFromJson,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA500),
            ),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}