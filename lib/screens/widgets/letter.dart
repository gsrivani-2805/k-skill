import 'package:K_Skill/screens/widgets/dictionary_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class LetterScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final Map<String, dynamic>? letterData;

  const LetterScreen({
    Key? key,
    required this.filePath,
    required this.title,
    this.letterData,
  }) : super(key: key);

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  Map<String, dynamic>? letter;
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
        letter = jsonData is Map<String, dynamic> ? jsonData : null;
        if (letter == null) {
          throw Exception('Invalid letter format');
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading letter: $e';
        isLoading = false;
      });
    }
  }

  void _showDictionaryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DictionaryBottomSheet(),
    );
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
        backgroundColor: Colors.purple[700],
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
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: buildLetterContent(),
              ),
            ),
      // Floating Action Button for Dictionary
      floatingActionButton: FloatingActionButton(
        onPressed: _showDictionaryBottomSheet,
        backgroundColor: Colors.purple[700],
        tooltip: 'Dictionary',
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }

  Widget buildLetterContent() {
    if (letter == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Letter Header with Sender's Address and Date (Right-aligned)
        buildLetterHeader(),
        const SizedBox(height: 32),

        // Salutation (Left-aligned)
        buildSalutation(),
        const SizedBox(height: 24),

        // Letter Body
        buildLetterBody(),
        const SizedBox(height: 32),

        // Complimentary Close and Signature (Left-aligned)
        buildLetterClosing(),
      ],
    );
  }

  Widget buildLetterHeader() {
    final senderAddress = letter!['sender_address'] as String?;
    final date = letter!['date'] as String?;

    if (senderAddress == null && date == null) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (senderAddress != null)
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                senderAddress,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          if (senderAddress != null && date != null) const SizedBox(height: 8),
          if (date != null)
            Text(
              date,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
        ],
      ),
    );
  }

  Widget buildSalutation() {
    final salutation = letter!['salutation'] as String?;
    if (salutation == null || salutation.isEmpty)
      return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        salutation,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
          height: 1.4,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget buildLetterBody() {
    final content = letter!['content'] as List<dynamic>?;
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.map<Widget>((item) {
        if (item is String && item.trim().isNotEmpty) {
          return Column(
            children: [
              SizedBox(width: 4),
              Text(
                item,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          );
        } else if (item is Map<String, dynamic> && item.containsKey('image')) {
          return buildImageContent(item['image']);
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget buildImageContent(Map<String, dynamic> imageData) {
    final assetPath = imageData['asset_path'];
    final description = imageData['description'] ?? '';

    if (assetPath == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
                minHeight: 200,
              ),
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
                        const SizedBox(height: 4),
                        Text(
                          'Path: assets/images/$assetPath',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
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

  Widget buildLetterClosing() {
    final complimentaryClose = letter!['complimentary_close'] as String?;
    final signature = letter!['signature'] as String?;

    if (complimentaryClose == null && signature == null)
      return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (complimentaryClose != null && complimentaryClose.isNotEmpty)
              Text(
                complimentaryClose,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            if (complimentaryClose != null &&
                complimentaryClose.isNotEmpty &&
                signature != null &&
                signature.isNotEmpty)
              const SizedBox(height: 8),
            if (signature != null && signature.isNotEmpty)
              Text(
                signature,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
          ],
        ),
      ),
    );
  }
}
