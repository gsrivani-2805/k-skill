import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final Map<String, dynamic>? lessonData;

  const PlayScreen({
    Key? key,
    required this.filePath,
    required this.title,
    this.lessonData,
  }) : super(key: key);

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Map<String, dynamic>? currentLesson;
  bool isLoading = true;
  bool isPlaying = false;
  String selectedRole = 'all';
  Set<String> availableRoles = {'all'};

  final Map<String, Color> roleColors = {
    'Gary Lopez': Colors.blue,
    'Joan': Colors.purple,
    'MT2': Colors.red,
    'First Noisemaker': Colors.green,
    'Second Noisemaker': Colors.orange,
    'Boy': Colors.cyan,
    'Girl': Colors.pink,
    'Old Giant': Colors.indigo,
    'The Giant': Colors.teal,
    'Child': Colors.deepOrange,
    'Tall Girl': Colors.purple,
    'Short Boy': Colors.blue,
    'Square Girl': Colors.pink,
    'Graceful Girl': Colors.orange,
    'Round Boy': Colors.green,
    'Snow and Frost': Colors.lightBlue,
    'North Wind': Colors.blueGrey,
    'Autumn': Colors.amber,
  };

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      String jsonString;

      // Check if lessonData is already provided
      if (widget.lessonData != null) {
        setState(() {
          currentLesson = widget.lessonData;
          if (currentLesson != null) {
            extractRoles();
          }
          isLoading = false;
        });
        return;
      }

      if (widget.filePath.isNotEmpty) {
        try {
          final file = File(widget.filePath);
          if (await file.exists()) {
            jsonString = await file.readAsString();
          } else {
            jsonString = await rootBundle.loadString(widget.filePath);
          }
        } catch (_) {
          jsonString = await rootBundle.loadString(widget.filePath);
        }
      } else {
        jsonString = await rootBundle.loadString(widget.filePath);
      }

      final decoded = json.decode(jsonString);

      setState(() {
        if (decoded is List) {
          // JSON is a list of lessons
          currentLesson = (decoded).firstWhere(
            (l) => l is Map && l['lesson_title'] == widget.title,
            orElse: () => decoded.first,
          ) as Map<String, dynamic>?;
        } else if (decoded is Map<String, dynamic>) {
          // JSON is a single lesson
          currentLesson = decoded;
        }

        if (currentLesson != null) {
          extractRoles();
        }

        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading JSON: $e');
      setState(() => isLoading = false);
    }
  }

  void extractRoles() {
    availableRoles = {'all'};
    final content = currentLesson?['content'] ?? [];
    
    for (var item in content) {
      if (item is Map<String, dynamic> && item.containsKey('role_play')) {
        final rolePlayList = item['role_play'];
        if (rolePlayList is List) {
          for (var rp in rolePlayList) {
            if (rp is Map<String, dynamic> && rp['role'] != null) {
              availableRoles.add(rp['role'] as String);
            }
          }
        }
      }
    }
  }

  Color getRoleColor(String role) => roleColors[role] ?? Colors.grey;

  Widget buildTextBlock(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey[800]),
      ),
    );
  }

  Widget buildImageBlock(Map<String, dynamic> image) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image['asset_path'] ?? '',
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Image not available', 
                           style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (image['description'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                image['description'],
                style: TextStyle(
                  fontSize: 12, 
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildRolePlayBlock(List<dynamic> data) {
    final dialogues = selectedRole == 'all'
        ? data
        : data.where((rp) => rp is Map && rp['role'] == selectedRole).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dialogues.map<Widget>((rp) {
          if (rp is! Map<String, dynamic>) return const SizedBox.shrink();
          
          final role = rp['role']?.toString() ?? '';
          final dialogue = rp['dialogue']?.toString() ?? '';
          final roleColor = getRoleColor(role);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: roleColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: roleColor.withOpacity(0.2),
                  child: Text(
                    role.isNotEmpty ? role[0].toUpperCase() : "?",
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dialogue,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildRoleFilter() {
    if (availableRoles.length <= 1) return const SizedBox.shrink();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: availableRoles.map((role) {
            final isSelected = selectedRole == role;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(role == 'all' ? "All Roles" : role),
                selected: isSelected,
                selectedColor: Colors.indigo,
                backgroundColor: Colors.grey[100],
                onSelected: (_) => setState(() => selectedRole = role),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildLessonContent() {
    final content = currentLesson?['content'] ?? [];
    
    if (content.isEmpty) {
      return const Center(
        child: Text(
          'No content available for this lesson',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        
        if (item is String) {
          return buildTextBlock(item);
        }
        
        if (item is Map<String, dynamic>) {
          if (item.containsKey('image')) {
            final imageData = item['image'];
            if (imageData is Map<String, dynamic>) {
              return buildImageBlock(imageData);
            }
          }
          
          if (item.containsKey('role_play')) {
            final rolePlayData = item['role_play'];
            if (rolePlayData is List) {
              return buildRolePlayBlock(rolePlayData);
            }
          }
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          currentLesson?['lesson_title']?.toString() ?? widget.title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.indigo,
              size: 28,
            ),
            onPressed: () => setState(() => isPlaying = !isPlaying),
            tooltip: isPlaying ? 'Pause' : 'Play',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading lesson...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : currentLesson == null
              ? const Center(
                  child: Text(
                    'Lesson not found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    buildRoleFilter(),
                    Expanded(child: buildLessonContent()),
                  ],
                ),
    );
  }
}