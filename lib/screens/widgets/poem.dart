import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class PoemScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final Map<String, dynamic>? lessonData;

  const PoemScreen({
    Key? key,
    required this.filePath,
    required this.title,
    this.lessonData,
  }) : super(key: key);

  @override
  State<PoemScreen> createState() => _PoemScreenState();
}

class _PoemScreenState extends State<PoemScreen> 
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? poemContent;
  bool isLoading = true;
  String? error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    loadJsonData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString(widget.filePath);
      final dynamic jsonData = json.decode(jsonString);
      
      setState(() {
        poemContent = jsonData;
        isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        error = 'Error loading poem: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Warm off-white
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_quote),
            onPressed: () {
              _showPoemInfo(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : error != null
              ? _buildErrorWidget()
              : _buildPoemContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load poem',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoemContent() {
    if (poemContent == null) {
      return const Center(child: Text('No poem content available'));
    }

    final poemTitle = poemContent!['poem_title'] as String? ?? 'Untitled Poem';
    final poemText = poemContent!['poem_text'] as List<dynamic>? ?? [];
    final author = poemContent!['author'] as String? ?? '';

    // Pre-calculate stanza numbers for correct numbering
    int stanzaCounter = 0;
    final stanzaNumbers = <int, int>{};
    
    for (int i = 0; i < poemText.length; i++) {
      final item = poemText[i];
      if (item is Map<String, dynamic> && item.containsKey('stanza')) {
        stanzaCounter++;
        stanzaNumbers[i] = stanzaCounter;
      }
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Poem Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple[100]!,
                    Colors.purple[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    poemTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (author.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'by $author',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.purple[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Poem Content
            ...poemText.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              
              return Container(
                margin: EdgeInsets.only(
                  bottom: index < poemText.length - 1 ? 20.0 : 0,
                ),
                child: _buildPoemItem(item, index, stanzaNumbers),
              );
            }).toList(),

            const SizedBox(height: 32),

            // Decorative bottom element
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[300]!, Colors.purple[100]!],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPoemItem(dynamic item, int index, Map<int, int> stanzaNumbers) {
    if (item is Map<String, dynamic>) {
      if (item.containsKey('stanza')) {
        final stanzaNumber = stanzaNumbers[index] ?? 1;
        return _buildStanza(item['stanza'] as List<dynamic>, stanzaNumber);
      } else if (item.containsKey('image')) {
        return _buildPoemImage(item['image']);
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildStanza(List<dynamic> stanzaLines, int stanzaNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stanza number indicator
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$stanzaNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Stanza $stanzaNumber',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Poem lines
          ...stanzaLines.asMap().entries.map((lineEntry) {
            final lineIndex = lineEntry.key;
            final line = lineEntry.value.toString();
            
            return Padding(
              padding: EdgeInsets.only(
                bottom: lineIndex < stanzaLines.length - 1 ? 8.0 : 0,
                left: _getLineIndentation(line),
              ),
              child: Text(
                line,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400,
                  fontFamily: 'serif',
                ),
                textAlign: _getTextAlignment(line),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPoemImage(Map<String, dynamic> imageData) {
    final description = imageData['description'] ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Placeholder for image (since no asset_path provided)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.purple[100]!,
                    Colors.purple[200]!,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.purple[700],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Illustration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[700],
                    ),
                  ),
                ],
              ),
            ),
            
            if (description.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to add slight indentation for certain lines
  double _getLineIndentation(String line) {
    // Add slight indentation for lines that seem to be continuations
    if (line.startsWith('into') || 
        line.startsWith('the') ||
        line.startsWith('against') ||
        line.startsWith('who') ||
        line.startsWith('to')) {
      return 16.0;
    }
    return 0.0;
  }

  // Helper method to determine text alignment
  TextAlign _getTextAlignment(String line) {
    // Center align short lines (likely for emphasis)
    if (line.length < 20 && 
        (line.contains('Another woman') || 
         line.contains('We shield') ||
         line.contains('Another torch'))) {
      return TextAlign.center;
    }
    return TextAlign.left;
  }

  void _showPoemInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple[700]),
                  const SizedBox(width: 12),
                  Text(
                    'About This Poem',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildInfoRow('Title', poemContent!['poem_title'] ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildInfoRow('Author', poemContent!['author'] ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildInfoRow('Stanzas', '${_countStanzas()} stanzas'),
              
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This poem explores themes of domestic life, societal expectations, and personal struggles.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  int _countStanzas() {
    if (poemContent == null) return 0;
    final poemText = poemContent!['poem_text'] as List<dynamic>? ?? [];
    return poemText.where((item) => 
      item is Map<String, dynamic> && item.containsKey('stanza')
    ).length;
  }
}