import 'dart:convert';
import 'package:K_Skill/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Question {
  final int id;
  final String question;
  final String type;
  final String answer;
  final List<String>? options;

  Question({
    required this.id,
    required this.question,
    required this.type,
    required this.answer,
    this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      type: json['type'] ?? 'short_answer',
      answer: json['answer'] ?? '',
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
    );
  }
}

class ReadingPassage {
  final int id;
  final String title;
  final String passage;
  final List<Question> questions;

  ReadingPassage({
    required this.id,
    required this.title,
    required this.passage,
    required this.questions,
  });

  factory ReadingPassage.fromJson(Map<String, dynamic> json) {
    return ReadingPassage(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      passage: json['passage'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

class ReadingComprehensionData {
  final List<ReadingPassage> readingComprehension;

  ReadingComprehensionData({required this.readingComprehension});

  factory ReadingComprehensionData.fromJson(Map<String, dynamic> json) {
    return ReadingComprehensionData(
      readingComprehension: (json['reading_comprehension'] as List? ?? [])
          .map((p) => ReadingPassage.fromJson(p))
          .toList(),
    );
  }
}

class AIFeedback {
  final String feedback;

  AIFeedback({required this.feedback});

  factory AIFeedback.fromJson(dynamic json) {
    return AIFeedback(feedback: json);
  }
}

class DataService {
  static Future<ReadingComprehensionData> loadReadingData() async {
    try {
      final String response = await rootBundle.loadString(
        'data/practice/reading_comprehension.json',
      );
      final data = json.decode(response);
      if (data['reading_comprehension'] == null) {
        throw Exception('reading_comprehension key not found in JSON');
      }
      return ReadingComprehensionData.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load reading comprehension data: $e');
    }
  }
}

class ReadingComprehension extends StatefulWidget {
  const ReadingComprehension({super.key});

  @override
  State<ReadingComprehension> createState() => _ReadingComprehensionState();
}

class _ReadingComprehensionState extends State<ReadingComprehension> {
  ReadingComprehensionData? data;
  int currentPassage = 0;
  int currentQuestion = 0;
  Map<String, String> userAnswers = {};
  Map<String, bool> showFeedback = {};
  Map<String, AIFeedback> aiFeedback = {};
  bool showResults = false;
  bool isLoading = true;
  bool isLoadingFeedback = false;
  String? error;
  String? userId;
  String? token;

  String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    loadData();
    _loadUserIdAndFetchProfile();
  }

  Future<void> loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedData = await DataService.loadReadingData();
      if (loadedData.readingComprehension.isNotEmpty) {
        loadedData.readingComprehension.shuffle();
        setState(() {
          data = loadedData;
          isLoading = false;
        });
      } else {
        throw Exception('No reading comprehension data found');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserIdAndFetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('token');
  }

  Future<AIFeedback?> fetchAIAnalysis({
    required String passage,
    required String question,
    required String studentAnswer,
    required String correctAnswer,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/api/$userId/check-comprehension");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "passage": passage,
          "question": question,
          "studentAnswer": studentAnswer,
          "correctAnswer": correctAnswer,
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return AIFeedback.fromJson(body['data']); 
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void handleAnswerChange(int questionId, String answer) {
    setState(() {
      userAnswers['$currentPassage-$questionId'] = answer;
    });
  }

  bool checkAnswer(int questionId) {
    final passage = data!.readingComprehension[currentPassage];
    final question = passage.questions.firstWhere((q) => q.id == questionId);
    final userAnswer = userAnswers['$currentPassage-$questionId'];

    if (question.type == 'mcq') {
      return userAnswer == question.answer;
    } else {
      if (userAnswer == null || userAnswer.isEmpty) return false;

      final correctWords = question.answer.toLowerCase().split(' ');
      final userWords = userAnswer.toLowerCase().split(' ');

      int matchCount = 0;
      for (String correctWord in correctWords) {
        if (correctWord.length > 2) {
          for (String userWord in userWords) {
            if (userWord.contains(correctWord) ||
                correctWord.contains(userWord)) {
              matchCount++;
              break;
            }
          }
        }
      }

      final significantWords = correctWords.where((w) => w.length > 2).length;
      return significantWords > 0 && (matchCount / significantWords) >= 0.4;
    }
  }

  void submitAnswer() async {
    final passage = data!.readingComprehension[currentPassage];
    final question = passage.questions[currentQuestion];
    final studentAnswer = userAnswers['$currentPassage-${question.id}'] ?? "";
    final questionKey = '$currentPassage-${question.id}';

    if (studentAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide an answer before submitting.'),
        ),
      );
      return;
    }

    setState(() {
      showFeedback[questionKey] = true;
      // Only show loading feedback for short answer questions
      if (question.type == 'short_answer') {
        isLoadingFeedback = true;
      }
    });

    // Only fetch AI analysis for short answer questions
    if (question.type == 'short_answer') {
      final feedback = await fetchAIAnalysis(
        passage: passage.passage,
        question: question.question,
        studentAnswer: studentAnswer,
        correctAnswer: question.answer,
      );

      setState(() {
        isLoadingFeedback = false;
        if (feedback != null) {
          aiFeedback[questionKey] = feedback;
        }
      });

      if (feedback == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get AI feedback. Please try again.'),
          ),
        );
      }
    }
  }

  void nextQuestion() {
    final passage = data!.readingComprehension[currentPassage];
    if (currentQuestion < passage.questions.length - 1) {
      setState(() => currentQuestion++);
    } else {
      setState(() => showResults = true);
    }
  }

  void nextPassage() {
    if (currentPassage < data!.readingComprehension.length - 1) {
      setState(() {
        currentPassage++;
        currentQuestion = 0;
        showResults = false;
        showFeedback.clear();
      });
    }
  }

  void resetQuiz() {
    setState(() {
      currentPassage = 0;
      currentQuestion = 0;
      userAnswers.clear();
      showResults = false;
      showFeedback.clear();
      aiFeedback.clear();
    });
  }

  int getScore() {
    int correct = 0;
    final passage = data!.readingComprehension[currentPassage];
    for (var question in passage.questions) {
      if (checkAnswer(question.id)) correct++;
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: LoadingWidget());
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Error loading data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(error!, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (data == null || data!.readingComprehension.isEmpty) {
      return const Scaffold(body: Center(child: Text("No data available")));
    }

    final passage = data!.readingComprehension[currentPassage];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Reading Comprehension",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBF8FF), Color(0xFFE0E7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: showResults
              ? ResultsCard(
                  passage: passage,
                  userAnswers: userAnswers,
                  currentPassage: currentPassage,
                  getScore: getScore,
                  checkAnswer: checkAnswer,
                  onNextPassage: nextPassage,
                  onResetQuiz: resetQuiz,
                  hasMorePassages:
                      currentPassage < data!.readingComprehension.length - 1,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildHeader(passage),
                      const SizedBox(height: 16),
                      PassageCard(passage: passage),
                      const SizedBox(height: 16),
                      QuestionCard(
                        question: passage.questions[currentQuestion],
                        currentPassage: currentPassage,
                        selectedAnswer:
                            userAnswers['$currentPassage-${passage.questions[currentQuestion].id}'] ??
                            '',
                        onAnswerSelected: (answer) => handleAnswerChange(
                          passage.questions[currentQuestion].id,
                          answer,
                        ),
                        onSubmit: submitAnswer,
                        showFeedback:
                            showFeedback['$currentPassage-${passage.questions[currentQuestion].id}'] ??
                            false,
                        aiFeedback:
                            aiFeedback['$currentPassage-${passage.questions[currentQuestion].id}'],
                        isLoadingFeedback: isLoadingFeedback,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: nextQuestion,
                        child: Text(
                          currentQuestion == passage.questions.length - 1
                              ? "Finish"
                              : "Next Question",
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(ReadingPassage passage) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Story ${currentPassage + 1} of ${data!.readingComprehension.length}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              passage.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (currentQuestion + 1) / passage.questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(Colors.indigo.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "Question ${currentQuestion + 1} of ${passage.questions.length}",
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class PassageCard extends StatelessWidget {
  final ReadingPassage passage;
  const PassageCard({super.key, required this.passage});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          passage.passage,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
      ),
    );
  }
}

class QuestionCard extends StatefulWidget {
  final Question question;
  final int currentPassage;
  final String selectedAnswer;
  final Function(String) onAnswerSelected;
  final VoidCallback onSubmit;
  final bool showFeedback;
  final AIFeedback? aiFeedback;
  final bool isLoadingFeedback;

  const QuestionCard({
    super.key,
    required this.question,
    required this.currentPassage,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.onSubmit,
    required this.showFeedback,
    this.aiFeedback,
    required this.isLoadingFeedback,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedAnswer);
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAnswer != widget.selectedAnswer &&
        widget.question.type == "short_answer") {
      _controller.text = widget.selectedAnswer;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // MCQ
            if (widget.question.type == "mcq" &&
                widget.question.options != null)
              ...widget.question.options!.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: widget.selectedAnswer,
                  onChanged: (value) {
                    if (value != null) widget.onAnswerSelected(value);
                  },
                );
              }),

            // Short Answer
            if (widget.question.type == "short_answer")
              TextField(
                controller: _controller,
                onChanged: widget.onAnswerSelected,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Type your answer...",
                  border: OutlineInputBorder(),
                ),
              ),

            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: widget.isLoadingFeedback ? null : widget.onSubmit,
                child: widget.isLoadingFeedback
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Submit"),
              ),
            ),

            if (widget.showFeedback) _buildFeedback(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    bool isCorrect;

    if (widget.question.type == 'mcq') {
      isCorrect = widget.selectedAnswer == widget.question.answer;
    } else {
      if (widget.selectedAnswer.isEmpty) {
        isCorrect = false;
      } else {
        final correctWords = widget.question.answer.toLowerCase().split(' ');
        final userWords = widget.selectedAnswer.toLowerCase().split(' ');

        int matchCount = 0;
        for (String correctWord in correctWords) {
          if (correctWord.length > 2) {
            for (String userWord in userWords) {
              if (userWord.contains(correctWord) ||
                  correctWord.contains(userWord)) {
                matchCount++;
                break;
              }
            }
          }
        }

        final significantWords = correctWords.where((w) => w.length > 2).length;
        isCorrect =
            significantWords > 0 && (matchCount / significantWords) >= 0.4;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        if (widget.question.type == "short_answer") ...[
          if (widget.isLoadingFeedback) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Analyzing your answer...",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ] else if (widget.aiFeedback != null) ...[
            _buildAIFeedbackCard(widget.aiFeedback!),
            const SizedBox(height: 12),
          ],
        ],

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCorrect ? Colors.green.shade200 : Colors.orange.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.info_outline,
                    color: isCorrect ? Colors.green : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.question.type == 'mcq'
                        ? (isCorrect ? "Correct!" : "Not quite right")
                        : "Expected Answer",
                    style: TextStyle(
                      color: isCorrect
                          ? Colors.green.shade700
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.question.type == 'mcq'
                    ? "Correct answer: ${widget.question.answer}"
                    : "Sample answer: ${widget.question.answer}",
                style: TextStyle(
                  color: isCorrect
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),

        // Show warning for short answer if AI feedback failed
        if (widget.question.type == "short_answer" &&
            !widget.isLoadingFeedback &&
            widget.aiFeedback == null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Unable to get detailed AI feedback. Your answer will be evaluated based on keyword matching.",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAIFeedbackCard(AIFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.psychology, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 8),
              const Text(
                "AI Analysis",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Single feedback paragraph
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(
              feedback.feedback,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsCard extends StatelessWidget {
  final ReadingPassage passage;
  final Map<String, String> userAnswers;
  final int currentPassage;
  final int Function() getScore;
  final bool Function(int) checkAnswer;
  final VoidCallback onNextPassage;
  final VoidCallback onResetQuiz;
  final bool hasMorePassages;

  const ResultsCard({
    super.key,
    required this.passage,
    required this.userAnswers,
    required this.currentPassage,
    required this.getScore,
    required this.checkAnswer,
    required this.onNextPassage,
    required this.onResetQuiz,
    required this.hasMorePassages,
  });

  @override
  Widget build(BuildContext context) {
    final score = getScore();
    final percentage = ((score / passage.questions.length) * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.emoji_events, size: 64, color: Colors.amber.shade600),
              Text("Great Job!", style: Theme.of(context).textTheme.titleLarge),
              Text(
                "$percentage%",
                style: TextStyle(fontSize: 36, color: Colors.indigo.shade600),
              ),
              Text("You scored $score out of ${passage.questions.length}"),

              const SizedBox(height: 24),
              ...passage.questions.map((q) {
                final qKey = "$currentPassage-${q.id}";
                final userAns = userAnswers[qKey] ?? "Not answered";
                final correct = checkAnswer(q.id);
                return ListTile(
                  leading: Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    color: correct ? Colors.green : Colors.red,
                  ),
                  title: Text(q.question),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Your answer: $userAns"),
                      Text("Correct: ${q.answer}"),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              Row(
                children: [
                  if (hasMorePassages)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onNextPassage,
                        child: const Text("Next Story"),
                      ),
                    ),
                  if (hasMorePassages) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onResetQuiz,
                      child: const Text("Start Over"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
