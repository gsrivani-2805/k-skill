import 'dart:convert';
import 'package:K_Skill/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

/// A helper class for fetching word/phrase meanings from the backend API
class TranslationService {
  static const String baseUrl = ApiConfig.baseUrl;
  static Future<Map<String, dynamic>> getMeaning(
    String text,
    String targetLanguage,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/getMeaning"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text, "targetLanguage": targetLanguage}),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Check if we got the new JSON structure
        if (data.containsKey('word') && data.containsKey('definition')) {
          // New JSON structure - format it nicely
          String formattedMeaning = _formatNewStructure(data);
          
          return {
            'success': true,
            'meaning': formattedMeaning,
            'fromCache': data["fromCache"] ?? false,
            'rawData': data, // Keep raw data for future use
          };
        } else {
          // Old structure or fallback
          final String meaning = (data["meaning"]?.toString() ?? "").trim();
          return {
            'success': true,
            'meaning': meaning.isNotEmpty ? meaning : "No meaning found",
            'fromCache': data["fromCache"] ?? false,
          };
        }
      } else {
        return {
          'success': false,
          'error': "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      debugPrint("Translation error: $e");
      return {'success': false, 'error': "Error: $e"};
    }
  }

  /// Formats the new JSON structure into a readable format
  static String _formatNewStructure(Map<String, dynamic> data) {
    StringBuffer buffer = StringBuffer();
    
    // Word/Phrase title
    if (data['word'] != null) {
      buffer.writeln('**${data['word']}**');
      buffer.writeln();
    }
    
    // Phonetic if available
    if (data['phonetic'] != null && data['phonetic'].toString().isNotEmpty) {
      buffer.writeln('*Pronunciation:* ${data['phonetic']}');
      buffer.writeln();
    }
    
    // Type/Part of speech
    if (data['type'] != null && data['type'].toString().isNotEmpty) {
      buffer.writeln('*Type:* ${data['type']}');
      buffer.writeln();
    }
    
    // Definition
    if (data['definition'] != null && data['definition'].toString().isNotEmpty) {
      buffer.writeln('**Definition:**');
      buffer.writeln(data['definition']);
      buffer.writeln();
    }
    
    // Translations
    buffer.writeln('**Translations:**');
    if (data['telugu'] != null && data['telugu'].toString().isNotEmpty) {
      buffer.writeln('• **Telugu:** ${data['telugu']}');
    }
    if (data['hindi'] != null && data['hindi'].toString().isNotEmpty) {
      buffer.writeln('• **Hindi:** ${data['hindi']}');
    }
    buffer.writeln();
    
    // Example usage
    if (data['example'] != null && data['example'].toString().isNotEmpty) {
      buffer.writeln('**Example:**');
      buffer.writeln('*${data['example']}*');
      buffer.writeln();
    }
    
    // Example sentence usage
    if (data['example_sentence_usage'] != null && 
        data['example_sentence_usage'].toString().isNotEmpty) {
      buffer.writeln('**Usage in sentence:**');
      buffer.writeln('*${data['example_sentence_usage']}*');
      buffer.writeln();
    }
    
    // Example sentence translation
    if (data['example_sentence_translation'] != null && 
        data['example_sentence_translation'].toString().isNotEmpty) {
      buffer.writeln('**Translation:**');
      buffer.writeln('*${data['example_sentence_translation']}*');
    }
    
    // Handle error case
    if (data['error'] != null) {
      buffer.writeln('⚠️ ${data['error']}');
    }
    
    return buffer.toString().trim();
  }
}

/// A mixin to add translation overlay functionality to any screen
mixin TranslationMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _overlayEntry;

  void showSelectionPopup(
    BuildContext context,
    String text,
    Offset position, {
    String targetLanguage = "telugu",
  }) async {
    // Show loading first
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Getting meaning...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    final result = await TranslationService.getMeaning(text, targetLanguage);

    if (!mounted) return;

    // Close loading dialog
    Navigator.pop(context);

    // Show result
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        if (result['success'] == true) {
          final String meaning = result['meaning'] ?? "No meaning found";

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Meaning of "$text"',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Render meaning with Markdown
                    MarkdownBody(
                      data: meaning,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16, height: 1.5),
                        strong: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        em: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.deepPurple,
                        ),
                        code: TextStyle(
                          backgroundColor: Colors.grey.shade200,
                          fontFamily: 'monospace',
                        ),
                        listBullet: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: meaning));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Meaning copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text("Copy"),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        } else {
          final String errorText = result['error'] ?? "Unknown error";
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Error",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  /// Remove overlay popup if showing
  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

/// Small help button in AppBar
class TranslationHelpButton extends StatelessWidget {
  const TranslationHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: "Tap and hold text to translate",
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Select text and tap 'Show Meaning' to get translations"),
            duration: Duration(seconds: 3),
          ),
        );
      },
    );
  }
}

/// Optional banner widget to show translation help
class TranslationHelpWidget extends StatelessWidget {
  const TranslationHelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.translate, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Tip: Select any text to see its meaning and translation.",
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

/// A selectable text widget that integrates with TranslationMixin
class SelectableTextWithTranslation extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Function(String) onMeaningRequested;

  const SelectableTextWithTranslation({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    required this.onMeaningRequested,
  });

  @override
  State<SelectableTextWithTranslation> createState() =>
      _SelectableTextWithTranslationState();
}

class _SelectableTextWithTranslationState
    extends State<SelectableTextWithTranslation> {
  String? _selectedText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
          onSelectionChanged: (selection, cause) {
            final fullText = widget.text;
            if (selection.baseOffset != -1 &&
                selection.extentOffset != -1 &&
                selection.baseOffset != selection.extentOffset) {
              final selected = fullText.substring(
                selection.baseOffset,
                selection.extentOffset,
              );
              setState(() {
                _selectedText = selected.trim();
              });
            } else {
              setState(() {
                _selectedText = null;
              });
            }
          },
        ),

        // Show "Show Meaning" button only when text is selected
        if (_selectedText != null && _selectedText!.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onMeaningRequested(_selectedText!);
                  setState(() => _selectedText = null);
                },
                icon: const Icon(Icons.translate, size: 18),
                label: const Text("Show Meaning"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[800],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}