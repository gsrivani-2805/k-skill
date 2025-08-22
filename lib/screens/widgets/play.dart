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
  List<dynamic> lessons = [];
  Map<String, dynamic>? currentLesson;
  bool isLoading = true;
  bool isPlaying = false;
  String selectedRole = 'all';
  Set<String> availableRoles = {'all'};
  int currentContentIndex = 0;

  final Map<String, Color> roleColors = {
    'Mrs. Slater': Colors.purple,
    'Victoria': Colors.pink,
    'Henry': Colors.blue,
    'Ben': Colors.green,
    'Mrs. Jordan': Colors.orange,
    'Abel Merryweather': Colors.red,
    'Mrs. Elizabeth Jordan': Colors.teal,
    'Henry Slater': Colors.indigo,
    'Ben Jordan': Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      String jsonString;
      
      // Try to read from file path first
      if (widget.filePath.isNotEmpty) {
        try {
          final file = File(widget.filePath);
          if (await file.exists()) {
            jsonString = await file.readAsString();
          } else {
            // Fallback to assets if file doesn't exist
            jsonString = await rootBundle.loadString(widget.filePath);
          }
        } catch (e) {
          // If file operations fail, try assets
          jsonString = await rootBundle.loadString(widget.filePath);
        }
      } else {
        // If no file path, try to load from assets
        jsonString = await rootBundle.loadString(widget.filePath);
      }

      final decodedData = json.decode(jsonString);
      
      setState(() {
        if (decodedData is List) {
          lessons = decodedData;
          // Find the lesson that matches the title or use the first one
          currentLesson = lessons.firstWhere(
            (lesson) => lesson['lesson_title'] == widget.title,
            orElse: () => lessons.isNotEmpty ? lessons.first : null,
          );
        } else if (decodedData is Map) {
          // Single lesson object
          currentLesson = decodedData as Map<String, dynamic>;
          lessons = [currentLesson!];
        }
        
        if (currentLesson != null) {
          extractAvailableRoles();
        }
        
        isLoading = false;
      });
    } catch (e) {
      print('Error loading JSON: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading lesson data: $e')),
      );
    }
  }

  void extractAvailableRoles() {
    availableRoles = {'all'};
    
    if (currentLesson?['content'] != null) {
      for (var item in currentLesson!['content']) {
        if (item is Map<String, dynamic> && item.containsKey('role_play')) {
          final rolePlayList = item['role_play'];
          if (rolePlayList is List) {
            for (var rolePlay in rolePlayList) {
              if (rolePlay is Map<String, dynamic> && rolePlay['role'] != null) {
                availableRoles.add(rolePlay['role'].toString());
              }
            }
          }
        }
      }
    }
    print('Available roles: $availableRoles'); // Debug print
  }

  Color getRoleColor(String role) {
    return roleColors[role] ?? Colors.grey;
  }

  String getRoleInitials(String role) {
    return role
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join('')
        .substring(0, role.split(' ').length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  Widget buildTextContent(String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget buildImageContent(Map<String, dynamic> imageData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Image',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageData['asset_path'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, 
                           size: 64, color: Colors.grey[500]),
                      const SizedBox(height: 8),
                      Text(
                        'Image placeholder',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            imageData['description'] ?? '',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRolePlayContent(List<dynamic> rolePlayData) {
    if (rolePlayData.isEmpty) return const SizedBox.shrink();

    List<dynamic> filteredDialogues = selectedRole == 'all'
        ? rolePlayData
        : rolePlayData.where((rp) {
            if (rp is Map<String, dynamic> && rp['role'] != null) {
              return rp['role'].toString() == selectedRole;
            }
            return false;
          }).toList();

    if (filteredDialogues.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 20, color: Colors.indigo[600]),
              const SizedBox(width: 8),
              Text(
                'Role Play Scene',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filteredDialogues.map((rolePlay) {
            if (rolePlay is Map<String, dynamic>) {
              return buildDialogueCard(rolePlay);
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget buildDialogueCard(Map<String, dynamic> rolePlay) {
    final role = rolePlay['role'] ?? '';
    final dialogue = rolePlay['dialogue'] ?? '';
    final roleColor = getRoleColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: roleColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: roleColor.withOpacity(0.2),
              child: Text(
                getRoleInitials(role),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: roleColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement text-to-speech
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playing audio for: $role'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.volume_up,
                          size: 16,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  dialogue,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: roleColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    if (currentLesson == null || currentLesson!['content'] == null) {
      return const Center(
        child: Text(
          'No content available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final content = currentLesson!['content'] as List<dynamic>;
    print('Content items: ${content.length}'); // Debug print
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        print('Item $index type: ${item.runtimeType}, content: $item'); // Debug print

        if (item is String) {
          return buildTextContent(item);
        } else if (item is Map<String, dynamic>) {
          if (item.containsKey('image')) {
            return buildImageContent(item['image']);
          } else if (item.containsKey('role_play')) {
            final rolePlayData = item['role_play'];
            if (rolePlayData is List) {
              return buildRolePlayContent(rolePlayData);
            }
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Unhandled content type: ${item.runtimeType}',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        );
      },
    );
  }

  Widget buildRoleFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Filter by Character:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableRoles.map((role) {
              final isSelected = selectedRole == role;
              return GestureDetector(
                onTap: () => setState(() => selectedRole = role),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.indigo[600] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.indigo[600]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    role == 'all' ? 'All Characters' : role,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentLesson?['lesson_title'] ?? widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (currentLesson?['author'] != null)
              Text(
                currentLesson!['author'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: isPlaying ? Colors.indigo[600] : Colors.grey[600],
            ),
            onPressed: () {
              setState(() => isPlaying = !isPlaying);
              // TODO: Implement play/pause functionality
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildRoleFilter(),
                Expanded(child: buildContent()),
              ],
            ),
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book, size: 16, color: Colors.indigo[600]),
            const SizedBox(width: 8),
            Text(
              'Progress: ${currentLesson != null ? ((currentContentIndex / (currentLesson!['content']?.length ?? 1)) * 100).round() : 0}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}