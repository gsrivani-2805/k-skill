import 'dart:convert';
import 'package:K_Skill/screens/widgets/play.dart';
import 'package:K_Skill/screens/widgets/poem.dart';
import 'package:K_Skill/screens/widgets/prose.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key});

  @override
  _AcademicsScreenState createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> academicData = {};
  bool isLoading = true;
  late TabController _tabController;

  // Colors for different classes
  final Map<String, Color> classColors = {
    'Class8': const Color(0xFF6366F1), // Indigo
    'Class9': const Color(0xFF10B981), // Emerald
    'Class10': const Color(0xFF8B5CF6), // Purple
  };

  @override
  void initState() {
    super.initState();
    loadAcademicData();
  }

  Future<void> loadAcademicData() async {
    try {
      final String response = await rootBundle.loadString(
        'data/lessons/academic_curriculum.json',
      );
      final data = json.decode(response);

      _tabController = TabController(length: data.keys.length, vsync: this);

      setState(() {
        academicData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _tabController = TabController(
          length: academicData.keys.length,
          vsync: this,
        );
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '📚 Academic English',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: isLoading
            ? null
            : TabBar(
                controller: _tabController,
                tabs: academicData.keys.map((classKey) {
                  return Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        classKey.replaceAll('Class', 'Class '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.2),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
              ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16),
                  Text(
                    'Loading your lessons...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: academicData.entries.map((entry) {
                return _buildClassContent(entry.key, entry.value);
              }).toList(),
            ),
    );
  }

  Widget _buildClassContent(String classKey, Map<String, dynamic> classData) {
    final units = classData['units'] as Map<String, dynamic>;
    final classColor = classColors[classKey] ?? const Color(0xFF6366F1);

    return CustomScrollView(
      slivers: [
        // Welcome Header
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [classColor, classColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: classColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('🎓', style: TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to ${classKey.replaceAll('Class', 'Class ')}!',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ready to explore amazing stories?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${units.length} exciting units to discover! ✨',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Units Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final unitEntry = units.entries.elementAt(index);
              return _buildUnitCard(
                unitEntry.key,
                unitEntry.value,
                classColor,
                classKey,
                index,
              );
            }, childCount: units.length),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildUnitCard(
    String unitKey,
    Map<String, dynamic> unitData,
    Color classColor,
    String classKey,
    int index,
  ) {
    final lessons = unitData['lessons'] as Map<String, dynamic>;
    final unitTitle = unitData['title'] ?? 'Unit Title';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToUnit(classKey, unitKey, unitData, classColor),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, classColor.withOpacity(0.05)],
              ),
              border: Border.all(color: classColor.withOpacity(0.1), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            classColor.withOpacity(0.1),
                            classColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getUnitEmoji(unitTitle),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unitTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Unit ${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: classColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Lesson Progress Indicators
                Row(
                  children: [
                    Icon(Icons.auto_stories, size: 16, color: classColor),
                    const SizedBox(width: 8),
                    Text(
                      '${lessons.length} lessons',
                      style: TextStyle(
                        fontSize: 14,
                        color: classColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: classColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start Learning',
                            style: TextStyle(
                              fontSize: 12,
                              color: classColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.play_arrow, size: 16, color: classColor),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category Preview
                Wrap(
                  spacing: 8,
                  children: _getLessonCategories(lessons)
                      .take(3)
                      .map(
                        (category) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getCategoryEmoji(category),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getCategoryColor(category),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getLessonCategories(Map<String, dynamic> lessons) {
    Set<String> categories = {};
    for (var lesson in lessons.values) {
      if (lesson is Map<String, dynamic>) {
        categories.add(lesson['category'] ?? 'prose');
      }
    }
    return categories.toList();
  }

  String _getUnitEmoji(String unitTitle) {
    final title = unitTitle.toLowerCase();
    if (title.contains('family')) return '👨‍👩‍👧‍👦';
    if (title.contains('social')) return '🤝';
    if (title.contains('science') || title.contains('technology')) return '🔬';
    if (title.contains('environment') || title.contains('bio')) return '🌱';
    if (title.contains('art') || title.contains('culture')) return '🎨';
    if (title.contains('education') || title.contains('career')) return '🎓';
    if (title.contains('women') || title.contains('empowerment')) return '💪';
    if (title.contains('gratitude')) return '🙏';
    if (title.contains('humour') || title.contains('humor')) return '😄';
    if (title.contains('games') || title.contains('sports')) return '⚽';
    if (title.contains('school')) return '🏫';
    if (title.contains('disaster')) return '⚠️';
    if (title.contains('freedom')) return '🗽';
    if (title.contains('theatre') || title.contains('theater')) return '🎭';
    if (title.contains('travel') || title.contains('tourism')) return '✈️';
    if (title.contains('personality')) return '🌟';
    if (title.contains('wit')) return '💡';
    if (title.contains('human') && title.contains('relation')) return '❤️';
    if (title.contains('film')) return '🎬';
    if (title.contains('nation')) return '🌍';
    if (title.contains('rights')) return '⚖️';
    return '📖';
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'poem':
        return '🎵';
      case 'play':
        return '🎭';
      case 'prose':
      default:
        return '📝';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'poem':
        return const Color(0xFF8B5CF6);
      case 'play':
        return const Color(0xFFF59E0B);
      case 'prose':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  void _navigateToUnit(
    String classKey,
    String unitKey,
    Map<String, dynamic> unitData,
    Color classColor,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UnitDetailScreen(
          classKey: classKey,
          unitKey: unitKey,
          unitData: unitData,
          classColor: classColor,
        ),
      ),
    );
  }
}

// Unit Detail Screen
class UnitDetailScreen extends StatelessWidget {
  final String classKey;
  final String unitKey;
  final Map<String, dynamic> unitData;
  final Color classColor;

  const UnitDetailScreen({
    super.key,
    required this.classKey,
    required this.unitKey,
    required this.unitData,
    required this.classColor,
  });

  @override
  Widget build(BuildContext context) {
    final lessons = unitData['lessons'] as Map<String, dynamic>;
    final unitTitle = unitData['title'] ?? 'Unit';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: classColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                unitTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [classColor, classColor.withOpacity(0.8)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: 20,
                      child: Text(
                        _getUnitEmoji(unitTitle),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Unit Info
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: classColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          classKey.replaceAll('Class', 'Class '),
                          style: TextStyle(
                            fontSize: 12,
                            color: classColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📚', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '${lessons.length} Lessons',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lessons List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final lessonEntry = lessons.entries.elementAt(index);
                return _buildLessonCard(
                  context,
                  lessonEntry.key,
                  lessonEntry.value,
                  index,
                );
              }, childCount: lessons.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    String lessonKey,
    Map<String, dynamic> lessonData,
    int index,
  ) {
    final lessonTitle = lessonData['title'] ?? 'Lesson';
    final category = lessonData['category'] ?? 'prose';
    final filePath = lessonData['file_path'] ?? '';

    final categoryColor = _getCategoryColor(category);
    final readingNumber = lessonData['reading_section']; // A, B, or C

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToLesson(
            context,
            category,
            filePath,
            lessonTitle,
            lessonData,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, categoryColor.withOpacity(0.03)],
              ),
              border: Border.all(
                color: categoryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Reading Letter as Main Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [categoryColor, categoryColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      readingNumber,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Lesson Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lessonTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _getCategoryEmoji(category),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Play Button
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: classColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: classColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getUnitEmoji(String unitTitle) {
    final title = unitTitle.toLowerCase();
    if (title.contains('family')) return '👨‍👩‍👧‍👦';
    if (title.contains('social')) return '🤝';
    if (title.contains('science') || title.contains('technology')) return '🔬';
    if (title.contains('environment') || title.contains('bio')) return '🌱';
    if (title.contains('art') || title.contains('culture')) return '🎨';
    if (title.contains('education') || title.contains('career')) return '🎓';
    if (title.contains('women') || title.contains('empowerment')) return '💪';
    if (title.contains('gratitude')) return '🙏';
    if (title.contains('humour') || title.contains('humor')) return '😄';
    if (title.contains('games') || title.contains('sports')) return '⚽';
    if (title.contains('school')) return '🏫';
    if (title.contains('disaster')) return '⚠️';
    if (title.contains('freedom')) return '🗽';
    if (title.contains('theatre') || title.contains('theater')) return '🎭';
    if (title.contains('travel') || title.contains('tourism')) return '✈️';
    if (title.contains('personality')) return '🌟';
    if (title.contains('wit')) return '💡';
    if (title.contains('human') && title.contains('relation')) return '❤️';
    if (title.contains('film')) return '🎬';
    if (title.contains('nation')) return '🌍';
    if (title.contains('rights')) return '⚖️';
    return '📖';
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'poem':
        return '🎵';
      case 'play':
        return '🎭';
      case 'prose':
      default:
        return '📝';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'poem':
        return const Color(0xFF8B5CF6);
      case 'play':
        return const Color(0xFFF59E0B);
      case 'prose':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  void _navigateToLesson(
    BuildContext context,
    String category,
    String filePath,
    String title,
    Map<String, dynamic> lessonData,
  ) {
    switch (category.toLowerCase()) {
      case 'prose':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProseScreen(
              filePath: filePath,
              title: title,
              lessonData: lessonData,
            ),
          ),
        );
        break;
      case 'poem':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PoemScreen(
              filePath: filePath,
              title: title,
              lessonData: lessonData,
            ),
          ),
        );
        break;
      case 'play':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayScreen(
              filePath: filePath,
              title: title,
              lessonData: lessonData,
            ),
          ),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProseScreen(
              filePath: filePath,
              title: title,
              lessonData: lessonData,
            ),
          ),
        );
    }
  }
}
