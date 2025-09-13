import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      id: json['id'],
      question: json['question'],
      type: json['type'],
      answer: json['answer'],
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
      id: json['id'],
      title: json['title'],
      passage: json['passage'],
      questions: (json['questions'] as List)
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
      readingComprehension: (json['reading_comprehension'] as List)
          .map((passage) => ReadingPassage.fromJson(passage))
          .toList(),
    );
  }
}

class DataService {
  static Future<ReadingComprehensionData> loadReadingData() async {
    try {
      final String response = await rootBundle.loadString(
        'data/practice/reading_comprehension.json',
      );
      final data = json.decode(response);
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
  bool showResults = false;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final loadedData = await DataService.loadReadingData();

      loadedData.readingComprehension.shuffle();
      
      setState(() {
        data = loadedData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
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
      return userAnswer.toLowerCase().contains(
        question.answer.toLowerCase().split(' ')[0],
      );
    }
  }

  void submitAnswer() {
    final passage = data!.readingComprehension[currentPassage];
    final question = passage.questions[currentQuestion];

    setState(() {
      showFeedback['$currentPassage-${question.id}'] = true;
    });
  }

  void nextQuestion() {
    final passage = data!.readingComprehension[currentPassage];

    if (currentQuestion < passage.questions.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      setState(() {
        showResults = true;
      });
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
    });
  }

  int getScore() {
    int correct = 0;
    final passage = data!.readingComprehension[currentPassage];

    for (var question in passage.questions) {
      if (checkAnswer(question.id)) {
        correct++;
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBF8FF), Color(0xFFE0E7FF)],
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
                        userAnswer:
                            userAnswers['$currentPassage-${passage.questions[currentQuestion].id}'] ??
                            '',
                        showFeedback:
                            showFeedback['$currentPassage-${passage.questions[currentQuestion].id}'] ??
                            false,
                        isCorrect: checkAnswer(
                          passage.questions[currentQuestion].id,
                        ),
                        questionNumber: currentQuestion + 1,
                        onAnswerChanged: (answer) => handleAnswerChange(
                          passage.questions[currentQuestion].id,
                          answer,
                        ),
                        onSubmit: submitAnswer,
                        onNext: nextQuestion,
                        isLastQuestion:
                            currentQuestion == passage.questions.length - 1,
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Question ${currentQuestion + 1} of ${passage.questions.length}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ LOADING ------------------
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBF8FF), Color(0xFFE0E7FF)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
            SizedBox(height: 16),
            Text(
              'Loading reading passages...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ PASSAGE ------------------
class PassageCard extends StatelessWidget {
  final ReadingPassage passage;

  const PassageCard({super.key, required this.passage});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, size: 20, color: Colors.indigo.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Read the passage carefully',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              passage.passage,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ QUESTION ------------------
class QuestionCard extends StatefulWidget {
  final Question question;
  final String userAnswer;
  final bool showFeedback;
  final bool isCorrect;
  final int questionNumber;
  final Function(String) onAnswerChanged;
  final VoidCallback onSubmit;
  final VoidCallback onNext;
  final bool isLastQuestion;

  const QuestionCard({
    super.key,
    required this.question,
    required this.userAnswer,
    required this.showFeedback,
    required this.isCorrect,
    required this.questionNumber,
    required this.onAnswerChanged,
    required this.onSubmit,
    required this.onNext,
    required this.isLastQuestion,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.userAnswer);
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userAnswer != widget.userAnswer) {
      _controller.text = widget.userAnswer;
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${widget.questionNumber}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.question.question,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            if (widget.question.type == 'mcq')
              _buildMCQOptions()
            else
              _buildTextAnswer(),

            if (widget.showFeedback) ...[
              const SizedBox(height: 16),
              _buildFeedback(),
            ],

            const SizedBox(height: 20),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMCQOptions() {
    return Column(
      children: widget.question.options!.map((option) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: widget.showFeedback
                ? null
                : () => widget.onAnswerChanged(option),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.userAnswer == option
                      ? Colors.indigo.shade600
                      : Colors.grey.shade300,
                  width: widget.userAnswer == option ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: widget.userAnswer == option
                    ? Colors.indigo.shade50
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: widget.userAnswer,
                    onChanged: widget.showFeedback
                        ? null
                        : (value) => widget.onAnswerChanged(value!),
                    activeColor: Colors.indigo.shade600,
                  ),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnswer() {
    return TextField(
      controller: _controller,
      onChanged: widget.showFeedback ? null : widget.onAnswerChanged,
      enabled: !widget.showFeedback,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Write your answer here...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
        ),
        filled: widget.showFeedback,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildFeedback() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(
          color: widget.isCorrect ? Colors.green.shade200 : Colors.red.shade200,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            widget.isCorrect ? Icons.check_circle : Icons.cancel,
            color: widget.isCorrect
                ? Colors.green.shade600
                : Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCorrect ? 'Correct!' : 'Not quite right',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isCorrect
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      const TextSpan(
                        text: 'Correct answer: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.question.answer),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (!widget.showFeedback) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.userAnswer.isNotEmpty ? widget.onSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Submit Answer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.isLastQuestion ? 'View Results' : 'Next Question',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.emoji_events, size: 64, color: Colors.amber.shade600),
              const SizedBox(height: 16),
              const Text(
                'Great Job!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You scored $score out of ${passage.questions.length}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: passage.questions.length,
                  itemBuilder: (context, index) {
                    final question = passage.questions[index];
                    final questionKey = '$currentPassage-${question.id}';
                    final userAns = userAnswers[questionKey] ?? 'Not answered';
                    final correct = checkAnswer(question.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            correct ? Icons.check_circle : Icons.cancel,
                            color: correct
                                ? Colors.green.shade500
                                : Colors.red.shade500,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Q${index + 1}: ${question.question}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your answer: $userAns',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Correct answer: ${question.answer}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  if (hasMorePassages)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onNextPassage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Next Story',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (hasMorePassages) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onResetQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Start Over',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
