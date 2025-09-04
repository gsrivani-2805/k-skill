import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ProseScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final Map<String, dynamic>? lessonData;

  const ProseScreen({
    Key? key,
    required this.filePath,
    required this.title,
    this.lessonData,
  }) : super(key: key);

  @override
  State<ProseScreen> createState() => _ProseScreenState();
}

class _ProseScreenState extends State<ProseScreen> {
  List<dynamic> lessons = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString(widget.filePath);
      final dynamic jsonData = json.decode(jsonString);

      setState(() {
        // Handle both single lesson object and array of lessons
        if (jsonData is List) {
          lessons = jsonData;
        } else if (jsonData is Map<String, dynamic>) {
          lessons = [jsonData]; // Wrap single lesson in a list
        } else {
          throw Exception('Invalid JSON format');
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading content: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400], size: 64),
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      style: TextStyle(color: Colors.red[700], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                return LessonCard(lesson: lessons[index]);
              },
            ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;

  const LessonCard({Key? key, required this.lesson}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson Title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lesson['lesson_title'] ?? 'Untitled Lesson',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Content
            ...buildContentWidgets(lesson['content'] ?? []),

            // Author (if available)
            if (lesson['author'] != null &&
                lesson['author'].toString().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Author: ${lesson['author']}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
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

  List<Widget> buildContentWidgets(List<dynamic> content) {
    List<Widget> widgets = [];

    for (int i = 0; i < content.length; i++) {
      final item = content[i];

      if (item is String) {
        widgets.add(buildTextContent(item, i));
      } else if (item is Map<String, dynamic> && item.containsKey('image')) {
        widgets.add(buildImageContent(item['image']));
      }

      // Add spacing between content items
      if (i < content.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }

  Widget buildTextContent(String text, int index) {
    // Check if it's a question (starts with a number)
    bool isQuestion = RegExp(r'^\d+\.').hasMatch(text.trim());

    // Check if it's a heading or special instruction
    bool isInstruction =
        text.contains(':') &&
        text.toLowerCase().contains('oral discourse');

    // Check if it's a section header (like "About the author")
    bool isSectionHeader =
        text.trim().toLowerCase() == 'about the author' ||
        text.trim().length < 50 &&
            !text.contains('.') &&
            !text.contains(',') &&
            !text.contains('\'') &&
            !text.trim().toLowerCase().contains('by') &&
            !text.trim().toLowerCase().contains('!');

    if (isQuestion) {
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
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (isInstruction) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.green[300]!, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.assignment, color: Colors.green[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
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
    } else if (isSectionHeader) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // Regular paragraph text
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.grey[800],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.justify,
        ),
      );
    }
  }

  Widget buildImageContent(Map<String, dynamic> imageData) {
    final assetPath = imageData['asset_path'];
    final description = imageData['description'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Image.asset(
                'assets/images/$assetPath',
                fit: BoxFit.cover,
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
                        Text(
                          assetPath,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (description.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
