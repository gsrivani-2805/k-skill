import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReadingComprehension extends StatefulWidget {
  const ReadingComprehension({super.key});
  
  @override
  State<ReadingComprehension> createState() => _ReadingComprehensionState();
}

class _ReadingComprehensionState extends State<ReadingComprehension> {
  List<Map<String, dynamic>> allPassages = []; // Store all passages
  List<Map<String, dynamic>> selectedPassages = []; // Store 3 random passages
  int currentIndex = 0;
  List<int?> userAnswers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      String data = await rootBundle.loadString('data/practice/reading_comprehension.json');
      final jsonResult = json.decode(data);
      setState(() {
        // Handle both old and new JSON format
        if (jsonResult.containsKey('reading_comprehensions')) {
          // New format with multiple passages
          allPassages = List<Map<String, dynamic>>.from(jsonResult['reading_comprehensions']);
        } else {
          // Old format with single passage - convert to new format
          allPassages = [jsonResult];
        }
        
        // Select 3 random passages
        _selectRandomPassages();
        
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e'); // Debug print
      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectRandomPassages() {
    if (allPassages.isNotEmpty) {
      final random = Random(DateTime.now().millisecondsSinceEpoch);
      
      // Create a copy of all passages to shuffle
      List<Map<String, dynamic>> shuffledPassages = List<Map<String, dynamic>>.from(allPassages);
      
      print('Total available passages: ${shuffledPassages.length}'); // Debug
      
      // Shuffle passages multiple times for better randomization
      for (int i = 0; i < 3; i++) {
        shuffledPassages.shuffle(random);
      }
      
      // Select up to 3 passages (or all if less than 3 available)
      int passagesToSelect = shuffledPassages.length >= 3 ? 3 : shuffledPassages.length;
      selectedPassages = shuffledPassages.take(passagesToSelect).toList();
      
      print('Selected passages: ${selectedPassages.map((p) => p["title"] ?? "Untitled").toList()}'); // Debug
      
      // Reset current index and initialize answers for first passage
      currentIndex = 0;
      _initializeAnswersForCurrentPassage();
    }
  }

  void _initializeAnswersForCurrentPassage() {
    if (selectedPassages.isNotEmpty && 
        currentIndex < selectedPassages.length &&
        selectedPassages[currentIndex]["questions"] != null) {
      userAnswers = List.filled(selectedPassages[currentIndex]["questions"].length, null);
    }
  }

  void nextPassage() {
    if (currentIndex < allPassages.length - 1) {
      setState(() {
        currentIndex++;
        _selectRandomPassages();
      });
    }
  }

  void previousPassage() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _selectRandomPassages();
      });
    }
  }


  void submitAnswers() {
    int score = 0;
    List<Map<String, dynamic>> results = [];
    
    for (int i = 0; i < selectedPassages[currentIndex]["questions"].length; i++) {
      bool isCorrect = userAnswers[i] == selectedPassages[currentIndex]["questions"][i]["answer"];
      if (isCorrect) score++;
      
      results.add({
        'questionIndex': i,
        'isCorrect': isCorrect,
        'userAnswer': userAnswers[i],
        'correctAnswer': selectedPassages[currentIndex]["questions"][i]["answer"],
      });
    }

    _showResultDialog(score, results);
  }

  void _showResultDialog(int score, List<Map<String, dynamic>> results) {
    double percentage = (score / selectedPassages[currentIndex]["questions"].length) * 100;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              percentage >= 70 ? Icons.celebration : Icons.info_outline,
              color: percentage >= 70 ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text("Great Job!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: percentage >= 70 ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "$score out of ${selectedPassages[currentIndex]["questions"].length}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 70 ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                  Text(
                    "${percentage.toInt()}% Score",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              percentage >= 70 
                ? "Excellent work! Keep it up! 🌟"
                : percentage >= 50
                ? "Good effort! Try again to improve! 💪"
                : "Keep practicing! You'll get better! 📚",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
            },
            child: const Text("Back to Home", style: TextStyle(fontSize: 16)),
          ),
          if (currentIndex < selectedPassages.length - 1)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                nextPassage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Next Passage", style: TextStyle(fontSize: 16)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _selectRandomPassages();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("New Passages", style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset for retry with same passage
              setState(() {
                _initializeAnswersForCurrentPassage();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Try Again", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.indigo),
              SizedBox(height: 16),
              Text("Loading reading passages...", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (selectedPassages.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          title: const Text("Reading Comprehension"),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("Could not load reading passages", style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    Map<String, dynamic> currentPassage = selectedPassages[currentIndex];
    
    // Safety check for questions
    if (currentPassage["questions"] == null || currentPassage["questions"].isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          title: const Text("Reading Comprehension"),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text("No questions found for this passage", style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    int answeredQuestions = userAnswers.where((answer) => answer != null).length;
    double progress = answeredQuestions / currentPassage["questions"].length;
    int totalQuestions = currentPassage["questions"].length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text(currentPassage["title"] ?? "Reading Comprehension"),
        elevation: 0,
        actions: [
          // Random passages indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shuffle, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${selectedPassages.length} Random",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Passage selector
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${currentIndex + 1}/${selectedPassages.length}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Container(
            width: double.infinity,
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.indigo.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress and navigation indicators
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Progress: $answeredQuestions/$totalQuestions",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "PASSAGE ${currentIndex + 1}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${(progress * 100).toInt()}% Complete",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(currentPassage["difficulty"]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentPassage["difficulty"]?.toUpperCase() ?? "EASY",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Get new passages button
                        IconButton(
                          onPressed: () {
                            print('New passages button pressed'); // Debug
                            setState(() {
                              _selectRandomPassages();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("New random passages loaded! (${selectedPassages.length} passages)"),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh, color: Colors.orange),
                          tooltip: "Get new random passages",
                        ),
                        IconButton(
                          onPressed: currentIndex > 0 ? previousPassage : null,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: currentIndex > 0 ? Colors.indigo : Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: currentIndex < selectedPassages.length - 1 ? nextPassage : null,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: currentIndex < selectedPassages.length - 1 ? Colors.indigo : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reading passage card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getCategoryIcon(currentPassage["category"]), color: Colors.indigo, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "Reading Passage ${currentIndex + 1} of ${selectedPassages.length}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentPassage["paragraph"],
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Questions section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.quiz, color: Colors.indigo, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "Questions for Passage ${currentIndex + 1}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Questions
                        ...List.generate(currentPassage["questions"].length, (index) {
                          var question = currentPassage["questions"][index];
                          bool isAnswered = userAnswers[index] != null;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isAnswered ? Colors.indigo.shade50 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAnswered ? Colors.indigo.shade200 : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAnswered ? Colors.indigo : Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Q${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        question["question"],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Options
                                ...List.generate(question["options"].length, (optIndex) {
                                  bool isSelected = userAnswers[index] == optIndex;
                                  
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        userAnswers[index] = optIndex;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.indigo : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSelected ? Colors.indigo : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected ? Colors.white : Colors.grey.shade200,
                                              border: Border.all(
                                                color: isSelected ? Colors.white : Colors.grey.shade400,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Center(
                                                    child: Icon(Icons.check, size: 12, color: Colors.indigo),
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              question["options"][optIndex],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isSelected ? Colors.white : Colors.black87,
                                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Submit button (fixed at bottom)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: userAnswers.contains(null) ? null : submitAnswers,
              style: ElevatedButton.styleFrom(
                backgroundColor: userAnswers.contains(null) ? Colors.grey.shade300 : Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: userAnswers.contains(null) ? 0 : 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    userAnswers.contains(null) ? Icons.assignment : Icons.send,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userAnswers.contains(null) 
                        ? "Answer all questions to submit" 
                        : "Submit Answers",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'science':
        return Icons.science;
      case 'nature':
        return Icons.nature;
      case 'animals':
        return Icons.pets;
      case 'school':
        return Icons.school;
      default:
        return Icons.book;
    }
  }
}