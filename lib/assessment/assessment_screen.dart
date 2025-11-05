import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:K_Skill/config/api_config.dart';
import 'package:K_Skill/services/shared_prefs.dart';
import 'package:http/http.dart' as http;

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});
  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  bool quizDone = false;
  bool readingDone = false;
  bool listeningDone = false;
  int quizScore = 0;
  int readingScore = 0;
  int listeningScore = 0;
  bool isSubmitted = false; // Add flag to track submission
  late String userId;

  static const String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    userId = (await SharedPrefsService.getUserId())!;
  }

  void _navigateAndSet(String route, Function(bool, int) setter) async {
    try {
      final result = await Navigator.pushNamed(context, route);
      debugPrint('Route $route returned: $result');
      if (mounted && result != null && result is int) {
        setState(() {
          setter(true, result);
          isSubmitted = false; // Reset submission flag when taking new assessment
        });
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  double _calculateOverallProgress() {
    double normalizedQuiz = quizScore * 2.0;
    double normalizedReading = readingScore / 4;
    double normalizedListening = listeningScore / 4;
    return normalizedQuiz + normalizedReading + normalizedListening;
  }

  Future<void> submitAssessment() async {
    final overallScore = _calculateOverallProgress();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/$userId/submit-assessment"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'quizScore': quizScore * 4,
          'readingScore': readingScore,
          'listeningScore': listeningScore,
          'overallScore': overallScore,
          'replaceExisting': true, // Add flag to replace existing scores
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isSubmitted = true; // Mark as submitted
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit assessment: ${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Allow back navigation if submitted or no progress
    if (isSubmitted || (!quizDone && !readingDone && !listeningDone)) {
      return true;
    }

    bool allDone = quizDone && readingDone && listeningDone;

    // Build the completed assessments list with scores
    List<Map<String, dynamic>> completedAssessments = [];
    if (quizDone)
      completedAssessments.add({
        'name': 'Grammar & Vocabulary',
        'score': quizScore * 4,
        'maxScore': 100,
      });
    if (readingDone)
      completedAssessments.add({
        'name': 'Reading Skills',
        'score': readingScore,
        'maxScore': 100,
      });
    if (listeningDone)
      completedAssessments.add({
        'name': 'Listening Skills',
        'score': listeningScore,
        'maxScore': 100,
      });

    // Show alert dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              allDone
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_rounded,
              color: allDone ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(allDone ? 'Assessment Complete' : 'Progress'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              allDone
                  ? 'You have completed all assessments. Here are your scores:'
                  : 'You have completed the following assessments:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...completedAssessments.map(
              (assessment) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            assessment['name'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    if (allDone)
                      Padding(
                        padding: const EdgeInsets.only(left: 28, top: 2),
                        child: Text(
                          'Score: ${assessment['score']}/${assessment['maxScore']}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (allDone) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Score:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '${_calculateOverallProgress().toStringAsFixed(2)}/100',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            Text(
              allDone
                  ? 'Would you like to submit your scores now?'
                  : 'If you go back now without submitting, your progress will be lost. Are you sure you want to leave?',
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: allDone
                ? () async {
                    Navigator.of(context).pop(false);
                    await submitAssessment();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                : () => Navigator.of(context).pop(false),
            style: ElevatedButton.styleFrom(
              backgroundColor: allDone ? Colors.green : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(allDone ? 'Submit Scores' : 'Continue Assessment'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    bool allDone = quizDone && readingDone && listeningDone;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 768;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF5FF),
        appBar: AppBar(
          title: Text(
            "K-Skill English Proficiency Assessment",
            style: TextStyle(fontSize: isDesktop ? 20 : 16),
          ),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(isDesktop ? 32 : 20),
                child: Column(
                  children: [
                    // Header Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'images/login_side_image.png',
                        height: isDesktop ? 150 : 120,
                        width: isDesktop ? 150 : 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 20 : 16),
                    Text(
                      "English Proficiency Assessment",
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 12 : 8),
                    Text(
                      "Complete all three components to determine your English proficiency level and unlock your personalized learning path.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 40 : 24),

                    // Assessment Cards Section
                    if (isDesktop)
                      // Desktop Layout - Single Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildAssessmentTile(
                              title: "Grammar & Vocabulary",
                              description:
                                  "Test your knowledge of English grammar and vocabulary",
                              icon: Icons.quiz_rounded,
                              duration: "25 minutes",
                              questions: 25,
                              color: Colors.orange,
                              done: quizDone,
                              onTap: () => _navigateAndSet('/quiz', (v, score) {
                                quizDone = v;
                                quizScore = score;
                              }),
                              isDesktop: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAssessmentTile(
                              title: "Reading Skills",
                              description:
                                  "Test your reading skills with passages",
                              icon: Icons.description_rounded,
                              duration: "15 minutes",
                              questions: 3,
                              color: Colors.blue,
                              done: readingDone,
                              onTap: () =>
                                  _navigateAndSet('/reading', (v, score) {
                                    readingDone = v;
                                    readingScore = score;
                                  }),
                              isDesktop: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAssessmentTile(
                              title: "Listening Skills",
                              description:
                                  "Listen to audio clips carefully and type what you hear",
                              icon: Icons.headphones,
                              duration: "15 minutes",
                              questions: 3,
                              color: Colors.green,
                              done: listeningDone,
                              onTap: () =>
                                  _navigateAndSet('/listening', (v, score) {
                                    listeningDone = v;
                                    listeningScore = score;
                                  }),
                              isDesktop: true,
                            ),
                          ),
                        ],
                      )
                    else
                      // Mobile/Tablet Layout - Single Column
                      Column(
                        children: [
                          _buildAssessmentTile(
                            title: "Grammar & Vocabulary",
                            description:
                                "Test your knowledge of English grammar and vocabulary",
                            icon: Icons.quiz_rounded,
                            duration: "25 minutes",
                            questions: 25,
                            color: Colors.orange,
                            done: quizDone,
                            onTap: () => _navigateAndSet('/quiz', (v, score) {
                              quizDone = v;
                              quizScore = score;
                            }),
                            isDesktop: false,
                          ),
                          const SizedBox(height: 16),
                          _buildAssessmentTile(
                            title: "Reading Skills",
                            description:
                                "Test your reading skills with passages and questions",
                            icon: Icons.description_rounded,
                            duration: "15 minutes",
                            questions: 3,
                            color: Colors.blue,
                            done: readingDone,
                            onTap: () =>
                                _navigateAndSet('/reading', (v, score) {
                                  readingDone = v;
                                  readingScore = score;
                                }),
                            isDesktop: false,
                          ),
                          const SizedBox(height: 16),
                          _buildAssessmentTile(
                            title: "Listening Skills",
                            description:
                                "Listen to audio clips and answer questions",
                            icon: Icons.headphones,
                            duration: "15 minutes",
                            questions: 3,
                            color: Colors.green,
                            done: listeningDone,
                            onTap: () =>
                                _navigateAndSet('/listening', (v, score) {
                                  listeningDone = v;
                                  listeningScore = score;
                                }),
                            isDesktop: false,
                          ),
                        ],
                      ),

                    SizedBox(height: isDesktop ? 32 : 24),

                    // Completion Section
                    if (allDone && !isSubmitted)
                      Column(
                        children: [
                          Text(
                            "🎉 Assessment Completed!",
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          SizedBox(height: isDesktop ? 16 : 12),
                          ElevatedButton.icon(
                            onPressed: submitAssessment,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Submit Assessment"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 32 : 24,
                                vertical: isDesktop ? 16 : 12,
                              ),
                              textStyle: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 16 : 12),
                          Text(
                            "🧠 Overall Progress: ${_calculateOverallProgress().toStringAsFixed(2)}/100",
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    
                    // Show success message after submission
                    if (isSubmitted)
                      Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: isDesktop ? 80 : 60,
                            color: Colors.green[600],
                          ),
                          SizedBox(height: isDesktop ? 16 : 12),
                          Text(
                            "✅ Assessment Submitted Successfully!",
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isDesktop ? 12 : 8),
                          Text(
                            "Your scores have been saved. You can now go back.",
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentTile({
    required String title,
    required String description,
    required IconData icon,
    required String duration,
    required int questions,
    required Color color,
    required bool done,
    required VoidCallback onTap,
    required bool isDesktop,
  }) {
    return GestureDetector(
      onTap: done ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: done ? 0.6 : 1,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(isDesktop ? 20 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isDesktop ? 48 : 40, color: color),
              SizedBox(height: isDesktop ? 12 : 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 8 : 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: isDesktop ? 14 : 13,
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: isDesktop ? 16 : 14),
                      SizedBox(width: isDesktop ? 4 : 2),
                      Text(
                        duration,
                        style: TextStyle(fontSize: isDesktop ? 14 : 12),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_books, size: isDesktop ? 16 : 14),
                      SizedBox(width: isDesktop ? 4 : 2),
                      Text(
                        '$questions questions',
                        style: TextStyle(fontSize: isDesktop ? 14 : 12),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              if (done)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Completed ✅",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                      fontSize: isDesktop ? 14 : 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}