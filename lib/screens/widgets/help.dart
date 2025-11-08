import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _searchQuery = '';
  String? _expandedSection;

  final List<HelpSection> _sections = [
    HelpSection(
      id: 'getting_started',
      icon: Icons.rocket_launch,
      title: 'Getting Started',
      color: Colors.blue,
      items: [
        HelpItem(
          title: 'Create an Account',
          steps: [
            'Open the K-Skill app',
            'Tap on Sign Up',
            'Enter your email ID (use parent\'s email if you\'re a student)',
            'Click Verify Email',
            'Check your email for the OTP',
            'Enter the OTP and provide your personal details',
            'Your account is successfully created!'
          ],
          tip: 'Students can use their parent\'s email address to sign up.',
        ),
        HelpItem(
          title: 'Login to Your Account',
          steps: [
            'Open the app and go to Login',
            'Enter your registered email and password',
            'Click Login to enter the app'
          ],
        ),
      ],
    ),
    HelpSection(
      id: 'home_page',
      icon: Icons.home,
      title: 'Home Page Features',
      color: Colors.orange,
      items: [
        HelpItem(
          title: 'Dictionary',
          description: 'Find meanings and translations of words easily.',
          steps: [
            'Tap on the search box labeled "Type a word to search..."',
            'Type the word you want to know',
            'Click on the Search button',
            'View meaning, translation, and example sentence',
            'Tap the mic button to hear pronunciation',
            'View translations in Hindi and Telugu'
          ],
          tip: 'Listen to the pronunciation and use the word in sentences to remember it better.',
        ),
        HelpItem(
          title: 'Take Assessment',
          description: 'Evaluate your English proficiency level.',
          subsections: [
            HelpSubsection(
              title: '1. Grammar and Vocabulary',
              steps: [
                'Tap on Grammar & Vocabulary section',
                'Click "Start Quiz" to begin',
                'Answer 25 multiple-choice questions',
                'View your result/score after completion'
              ],
            ),
            HelpSubsection(
              title: '2. Reading Comprehension',
              steps: [
                'Tap on Reading Comprehension',
                'Read Passage 1 of 3',
                'Tap the button to begin reading',
                'Finish all three passages',
                'View your score'
              ],
              tip: 'Speak clearly and at a normal pace for best results.',
            ),
            HelpSubsection(
              title: '3. Listening Skills',
              steps: [
                'Tap on Listening Skills',
                'Play the audio',
                'Type the sentence you hear',
                'Complete all three audio sentences',
                'View your result'
              ],
              tip: 'Listen carefully to each word — it helps improve spelling!',
            ),
          ],
        ),
        HelpItem(
          title: 'Reading Comprehension',
          description: 'Improve vocabulary, grammar, and critical thinking.',
          steps: [
            'Go to Home Page and tap Reading Comprehension',
            'Read the given passage carefully',
            'Answer the question in the text box',
            'Tap Submit to check your answer',
            'View AI feedback and explanation'
          ],
          tip: 'Read the passage carefully before answering — it helps you understand better!',
        ),
        HelpItem(
          title: 'Vocabulary Topics',
          description: '24 theme-based categories with audio and examples.',
          steps: [
            'Tap on Vocabulary Topics',
            'Choose a topic you want to learn',
            'Type the word in the search box',
            'Tap on the word to see meaning and example',
            'Tap audio button to hear pronunciation'
          ],
          tip: 'Try to read and listen to each word daily to build strong vocabulary!',
        ),
      ],
    ),
    HelpSection(
      id: 'learning',
      icon: Icons.school,
      title: 'Learning Page',
      color: Colors.green,
      items: [
        HelpItem(
          title: 'Beginners Level',
          description: '6 modules with phonics, pronunciation, and basics.',
          steps: [
            'Tap Beginners level',
            'Open the first module (Phonics & Pronunciation)',
            'Select and read the first lesson',
            'Complete the quiz',
            'Mark the lesson as complete',
            'Repeat for other lessons'
          ],
        ),
        HelpItem(
          title: 'Intermediate Level',
          description: '6 modules focusing on sentence formation.',
          steps: [
            'Tap Intermediate level',
            'Open the first module (Sentence Formation)',
            'Read through 5 lessons',
            'Take quizzes after each lesson',
            'Mark lessons as complete'
          ],
        ),
        HelpItem(
          title: 'Advanced Level',
          description: '6 lessons for grammar mastery.',
          steps: [
            'Tap Advanced level',
            'Open Grammar Mastery module',
            'Study 4 lessons',
            'Complete quizzes',
            'Watch YouTube video explanations'
          ],
        ),
        HelpItem(
          title: 'Academics Section',
          description: 'Class 8, 9, and 10 curriculum content.',
          steps: [
            'Tap Academics section',
            'Select your class (8, 9, or 10)',
            'Choose a topic to learn',
            'Read lessons (Prose, Poem, Letter)',
            'Check word meanings anytime'
          ],
        ),
        HelpItem(
          title: 'Discourses',
          description: 'Master various writing skills.',
          subsections: [
            HelpSubsection(
              title: 'Available Topics',
              steps: [
                'Letter Writing',
                'Email Writing',
                'Diary Writing',
                'Essay Writing',
                'Speech Writing',
                'CV/Resume'
              ],
            ),
            HelpSubsection(
              title: 'How to Use',
              steps: [
                'Learn: Read rules and tips',
                'Practice: Select random topics and write',
                'Use Template for guidance',
                'Enable Auto-Save',
                'Submit and get instant feedback',
                'Review: Check all completed work'
              ],
              tip: 'Regularly reviewing feedback helps identify patterns and improve faster.',
            ),
          ],
        ),
      ],
    ),
    HelpSection(
      id: 'practice',
      icon: Icons.fitness_center,
      title: 'Practice Page',
      color: Colors.purple,
      items: [
        HelpItem(
          title: 'Speaking',
          description: 'Practice speaking with AI tutor.',
          steps: [
            'Tap the start button',
            'Begin speaking with the AI tutor',
            'Tap pause to stop conversation',
            'Get real-time feedback'
          ],
          tip: 'Speak slowly and clearly — it helps the AI understand better!',
        ),
        HelpItem(
          title: 'Listening',
          description: 'Improve listening and spelling skills.',
          steps: [
            'Tap Listening option (green)',
            'Play the audio',
            'Type what you hear',
            'View your similarity score',
            'Try another audio'
          ],
          tip: 'Listen more than once to catch every word clearly!',
        ),
        HelpItem(
          title: 'Reading',
          description: 'Enhance pronunciation and fluency.',
          steps: [
            'Tap Reading option (blue)',
            'Read the sentence aloud',
            'View your result',
            'Continue with next sentence'
          ],
          tip: 'Read slowly and clearly to improve pronunciation!',
        ),
        HelpItem(
          title: 'AI Chatbot',
          description: 'Chat to learn words and grammar.',
          steps: [
            'Tap AI Chatbot (purple)',
            'Type your question or message',
            'Get instant replies',
            'Learn through conversation'
          ],
          tip: 'Ask about daily life, school, or hobbies — the more you chat, the better!',
        ),
      ],
    ),
    HelpSection(
      id: 'games',
      icon: Icons.games,
      title: 'Games Page',
      color: Colors.pink,
      items: [
        HelpItem(
          title: 'Word Detective',
          description: '15-question word match challenge.',
          steps: [
            'Tap Word Detective',
            'Read word, sentence, or idiom',
            'Select correct meaning',
            'View explanation',
            'Complete all 15 questions'
          ],
        ),
        HelpItem(
          title: 'Sentence Formation',
          description: 'Build correct sentences from scrambled words.',
          steps: [
            'Tap scrambled words in correct order',
            'Check if sentence is correct',
            'Try again if wrong',
            'Complete 15 questions'
          ],
          tip: 'Focus on word order — correct structure is key!',
        ),
        HelpItem(
          title: 'Fill in the Blanks',
          description: 'Complete sentences with correct words.',
          steps: [
            'Tap correct word from Word Bank',
            'Fill each blank',
            'Check your answer',
            'View correct sentence if wrong'
          ],
        ),
        HelpItem(
          title: 'Picture Story',
          description: 'Form sentences based on pictures.',
          steps: [
            'Observe the picture carefully',
            'Form sentence using given words',
            'Tap complete button',
            'Check if answer is correct'
          ],
          tip: 'Look at small details in the picture — they help form better sentences!',
        ),
        HelpItem(
          title: 'Sound Quest',
          description: 'Three difficulty levels: Basic, Medium, Hard.',
          steps: [
            'Select difficulty level',
            'Listen to audio',
            'Form sentence from words',
            'Check your answer'
          ],
        ),
        HelpItem(
          title: 'Story Wizard',
          description: 'Write creative story endings.',
          steps: [
            'Read the incomplete story',
            'Tap Idea button for hints',
            'Write your own ending',
            'Submit and view analysis',
            'See example ending'
          ],
          tip: 'Be creative! Use imagination and grammar skills to write great endings.',
        ),
      ],
    ),
    HelpSection(
      id: 'profile',
      icon: Icons.person,
      title: 'Profile Page',
      color: Colors.teal,
      items: [
        HelpItem(
          title: 'Overview Section',
          description: 'Track your overall progress.',
          steps: [
            'View overall progress percentage',
            'Check assessment scores',
            'See lessons completed',
            'Track daily usage streak'
          ],
        ),
        HelpItem(
          title: 'Assessments Section',
          description: 'View all test results.',
          steps: [
            'Tap Assessments tab',
            'Check scores from all tests',
            'View overall average score',
            'Track progress levels'
          ],
        ),
        HelpItem(
          title: 'Levels Section',
          description: 'Monitor learning progress.',
          steps: [
            'Tap Levels tab',
            'View completion percentage',
            'Check Beginner, Intermediate, Advanced progress'
          ],
        ),
      ],
    ),
  ];

  List<HelpSection> get _filteredSections {
    if (_searchQuery.isEmpty) return _sections;
    
    return _sections.where((section) {
      final matchesSection = section.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final hasMatchingItems = section.items.any((item) =>
        item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (item.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false));
      return matchesSection || hasMatchingItems;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _filteredSections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSections.length,
                    itemBuilder: (context, index) {
                      final section = _filteredSections[index];
                      return _buildSectionCard(section);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(HelpSection section) {
    final isExpanded = _expandedSection == section.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              _expandedSection = isExpanded ? null : section.id;
            }),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [section.color.withOpacity(0.1), section.color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: section.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(section.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      section.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: section.items.map((item) => _buildHelpItem(item, section.color)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(HelpItem item, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (item.description != null) ...[
            const SizedBox(height: 8),
            Text(
              item.description!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
          if (item.steps.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...item.steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (item.subsections.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...item.subsections.map((subsection) => _buildSubsection(subsection, color)),
          ],
          if (item.tip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.tip!,
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubsection(HelpSubsection subsection, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subsection.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...subsection.steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (subsection.tip != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subsection.tip!,
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Data Models
class HelpSection {
  final String id;
  final IconData icon;
  final String title;
  final Color color;
  final List<HelpItem> items;

  HelpSection({
    required this.id,
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });
}

class HelpItem {
  final String title;
  final String? description;
  final List<String> steps;
  final List<HelpSubsection> subsections;
  final String? tip;

  HelpItem({
    required this.title,
    this.description,
    this.steps = const [],
    this.subsections = const [],
    this.tip,
  });
}

class HelpSubsection {
  final String title;
  final List<String> steps;
  final String? tip;

  HelpSubsection({
    required this.title,
    required this.steps,
    this.tip,
  });
}