import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final Map<String, dynamic>? lessonData;

  const PlayScreen({
    super.key,
    required this.filePath,
    required this.title,
    this.lessonData,
  });

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Map<String, dynamic>? lessonData;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final jsonString = await rootBundle.loadString(widget.filePath);
      final decoded = json.decode(jsonString);
      setState(() {
        lessonData = decoded;
      });
    } catch (e) {
      debugPrint("Error loading lesson: $e");
    }
  }

  Widget _buildSection(Map<String, dynamic> section) {
    switch (section['type']) {
      case 'image':
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Image.asset(
                section['image_path'],
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Image not found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      case 'paragraph':
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            section['content'],
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
              fontWeight: FontWeight.w400,
            ),
          ),
        );

      case 'dialogue':
        return Padding(
          padding: const EdgeInsets.all(8),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${section['character']}: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(
                  text: section['line'],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'questions':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    (section['content'] as List).length,
                    (index) => Text(
                      "${index + 1}. ${section['content'][index]}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'oral_discourse':
        return Container(
          padding: const EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            border: Border.all(color: Colors.green[300]!, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.assignment, color: Colors.green[700], size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Oral Discourse: ${section['content']}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lessonData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lessonData?['lesson_title'] ?? widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title block at top like in screenshot
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    lessonData?['lesson_title'] ?? widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Render lesson sections dynamically
              ...List.generate(
                (lessonData?['sections'] as List).length,
                (index) => _buildSection(lessonData?['sections'][index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
