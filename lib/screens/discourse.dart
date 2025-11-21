import 'package:K_Skill/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Main Discourse Practice Screen
class Discourse extends StatefulWidget {
  const Discourse({Key? key}) : super(key: key);

  @override
  State<Discourse> createState() => _DiscourseState();
}

class _DiscourseState extends State<Discourse> {
  List<DiscourseType> discourseTypes = [];
  Map<String, dynamic> writingTips = {};
  Map<String, dynamic> grammarRules = {};
  bool isLoading = true;
  String searchQuery = '';

  String? _userId;
  String? token;
  bool _isUserIdLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    loadDiscourseData();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      token = prefs.getString('token');
      _isUserIdLoading = false;
    });
  }

  Future<void> loadDiscourseData() async {
    try {
      final String response = await rootBundle.loadString(
        'data/practice/discourse.json',
      );
      final data = json.decode(response);

      setState(() {
        discourseTypes = (data['discourseTypes'] as List)
            .map((item) => DiscourseType.fromJson(item))
            .toList();
        writingTips = data['writingTips'] ?? {};
        grammarRules = data['grammarRules'] ?? {};
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
    }
  }

  List<DiscourseType> get filteredDiscourseTypes {
    if (searchQuery.isEmpty) return discourseTypes;
    return discourseTypes
        .where(
          (type) =>
              type.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              type.subtitle.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Discourse Practice',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb, color: Colors.white),
            onPressed: () => _showWritingTipsDialog(context),
          ),
        ],
      ),
      body: (isLoading || _isUserIdLoading)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (searchQuery.isNotEmpty) _buildSearchHeader(),
                Expanded(child: _buildDiscourseGrid()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickStartDialog(context),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Quick Start', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[600],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text(
            'Searching for "$searchQuery"',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                searchQuery = '';
              });
            },
            child: Icon(Icons.close, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscourseGrid() {
    if (_userId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'User not logged in or ID not found.',
              style: TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    final items = filteredDiscourseTypes;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No discourse types available'
                  : 'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                  });
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: constraints.maxWidth > 600 ? 2.0 : 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),

            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildDiscourseCard(items[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildDiscourseCard(DiscourseType type) {
    return GestureDetector(
      onTap: () {
        if (_userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to access practice areas.'),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiscourseDetailScreen(
              discourseType: type,
              writingTips: writingTips,
              grammarRules: grammarRules,
              userId: _userId!,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ✅ prevents stretching
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(type.iconData, color: type.color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                type.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                type.subtitle,
                style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = searchQuery;
        return AlertDialog(
          title: const Text('Search Practice'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Search for practice types...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              tempQuery = value;
            },
            controller: TextEditingController(text: searchQuery),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = tempQuery;
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showWritingTipsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Writing Tips'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'General Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...((writingTips['general'] as List?) ?? []).map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('• $tip', style: const TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Formal Writing:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...((writingTips['formal'] as List?) ?? []).map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text('• $tip', style: const TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickStartDialog(BuildContext context) {
    if (discourseTypes.isEmpty) return;
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to access practice areas.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Start'),
        content: const Text('Selecting a random topic to start practicing..'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Random practice
              final randomType = (discourseTypes..shuffle()).first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiscourseDetailScreen(
                    discourseType: randomType,
                    writingTips: writingTips,
                    grammarRules: grammarRules,
                    userId: _userId!, // Pass the loaded userId
                  ),
                ),
              );
            },
            child: const Text('Random'),
          ),
        ],
      ),
    );
  }
}

// Discourse Detail Screen
class DiscourseDetailScreen extends StatefulWidget {
  final DiscourseType discourseType;
  final Map<String, dynamic> writingTips;
  final Map<String, dynamic> grammarRules;
  final String userId; // Add userId here

  const DiscourseDetailScreen({
    Key? key,
    required this.discourseType,
    required this.writingTips,
    required this.grammarRules,
    required this.userId, // Make userId required
  }) : super(key: key);

  @override
  State<DiscourseDetailScreen> createState() => _DiscourseDetailScreenState();
}

class _DiscourseDetailScreenState extends State<DiscourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Add a refresh key to force FutureBuilder rebuild
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to refresh the review tab data
  void _refreshReviewData() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.discourseType.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: widget.discourseType.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Learn'),
            Tab(icon: Icon(Icons.edit), text: 'Practice'),
            Tab(icon: Icon(Icons.check), text: 'Review'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLearnTab(), _buildPracticeTab(), _buildReviewTab()],
      ),
    );
  }

  Widget _buildPracticeTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.discourseType.practiceItems.length,
      itemBuilder: (context, index) {
        return _buildPracticeItemCard(
          widget.discourseType.practiceItems[index],
        );
      },
    );
  }

  Widget _buildPracticeItemCard(PracticeItem item) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            // Navigate and wait for result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WritingEditorScreen(
                  practiceItem: item,
                  discourseType: widget.discourseType,
                  grammarRules: widget.grammarRules,
                  userId: widget.userId,
                ),
              ),
            );

            // If submission was successful, refresh review data
            if (result == true) {
              _refreshReviewData();
              // Switch to review tab to show the new submission
              _tabController.animateTo(2);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : widget.discourseType.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.isCompleted ? Icons.check_circle : Icons.edit,
                        color: item.isCompleted
                            ? Colors.green
                            : widget.discourseType.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.prompt,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildChip(
                      item.difficulty,
                      _getDifficultyColor(item.difficulty),
                    ),
                    const SizedBox(width: 8),
                    _buildChip(item.estimatedTime, Colors.grey),
                    const SizedBox(width: 8),
                    _buildChip(
                      item.type.toUpperCase(),
                      widget.discourseType.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Completed Exercises:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshReviewData,
                tooltip: 'Refresh submissions',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              key: ValueKey(_refreshKey),
              future: _fetchWritingSubmissions(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading your submissions...'),
                      ],
                    ),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading submissions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _refreshReviewData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final submissions = snapshot.data ?? [];

                // Empty state
                if (submissions.isEmpty) {
                  return _buildEmptyStateWithDebugInfo([]);
                }

                // Sort (backend already sorted, but just in case)
                submissions.sort((a, b) {
                  final aDate = a['submissionDate']?.toString() ?? '';
                  final bDate = b['submissionDate']?.toString() ?? '';
                  return bDate.compareTo(aDate);
                });

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshReviewData();
                    await Future.delayed(const Duration(milliseconds: 300));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: submissions.length,
                    itemBuilder: (context, index) {
                      final submission = submissions[index];

                      final submissionNumber = submissions.length - index;

                      return _buildSubmissionCard(submission, submissionNumber);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> _fetchWritingSubmissions() async {
    try {
      final rawType = widget.discourseType.id;
      final discourseType = (rawType).toString().toLowerCase().trim();

      final url =
          Uri.parse(
            '${ApiConfig.baseUrl}/api/${widget.userId}/submissions',
          ).replace(
            queryParameters: discourseType.isNotEmpty
                ? {'discourseType': discourseType}
                : null,
          );

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['success'] == true) {
          final data = decoded['data'];
          if (data is List) return data;
        }

        return [];
      }

      if (response.statusCode == 404) {
        return [];
      }

      throw Exception(
        "Failed to load submissions: ${response.statusCode}, Body: ${response.body}",
      );
    } catch (e) {
      throw Exception("Failed to load writing submissions: $e");
    }
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'About ${widget.discourseType.title}',
            widget.discourseType.description,
            Icons.description,
            widget.discourseType.color,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Key Components',
            widget.discourseType.keyComponents
                .map((component) => '• $component')
                .join('\n'),
            Icons.menu,
            widget.discourseType.color,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Important Rules',
            widget.discourseType.rules.map((rule) => '• $rule').join('\n'),
            Icons.check_circle,
            widget.discourseType.color,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            'Writing Tips',
            _getRelevantTips(),
            Icons.edit,
            widget.discourseType.color,
          ),
          const SizedBox(height: 16),
          _buildGrammarSection(),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWithDebugInfo(List<dynamic> allSubmissions) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Submissions Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          if (allSubmissions.isEmpty)
            Text(
              'No submissions found in the backend.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(1);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Practicing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.discourseType.color,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Map<String, dynamic> submission, int index) {
    int overallScore = 0;
    String feedbackSummary = '';
    String discourseAnalysis = '';
    List<dynamic> errors = [];

    if (submission['feedback'] != null && submission['feedback'] is Map) {
      final feedback = submission['feedback'] as Map<String, dynamic>;
      overallScore = feedback['overallScore'] as int? ?? 0;
      feedbackSummary = feedback['feedbackSummary']?.toString() ?? '';
      discourseAnalysis =
          feedback['discourseSpecificAnalysis']?.toString() ?? '';
      errors = feedback['errors'] as List<dynamic>? ?? [];
    }

    final question = submission['question']?.toString() ?? 'No Question';
    final submittedText = submission['submittedText']?.toString() ?? '';
    final submittedAt =
        submission['submissionDate']?.toString() ??
        submission['submittedAt']?.toString() ??
        submission['submissionDate']?.toString();
    final exerciseTitle =
        submission['exerciseTitle']?.toString() ?? 'Exercise $index';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: widget.discourseType.color,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          exerciseTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            if (submittedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                    Text(
                      'Submitted: ${_formatDate(submittedAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getScoreColor(overallScore),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$overallScore%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your Answer Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Your Answer:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        submittedText.isNotEmpty
                            ? submittedText
                            : 'No answer submitted',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Feedback Summary Section
                if (feedbackSummary.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.feedback,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Feedback Summary:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          feedbackSummary,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],

                // Discourse Analysis Section
                if (discourseAnalysis.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              size: 16,
                              color: Colors.purple[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Detailed Analysis:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          discourseAnalysis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],

                // Errors Section
                if (errors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              size: 16,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Areas for Improvement:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...errors.map(
                          (error) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ${error['type'] ?? 'Error'}: ${error['description'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (error['suggestion'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12,
                                      top: 2,
                                    ),
                                    child: Text(
                                      'Suggestion: ${error['suggestion']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showSubmissionDetails(submission);
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Full Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final utcDate = DateTime.parse(dateString);
      final istDate = utcDate.add(const Duration(hours: 5, minutes: 30));

      final now = DateTime.now();
      final istNow = now.toUtc().add(const Duration(hours: 5, minutes: 30));

      final difference = istNow.difference(istDate);

      if (difference.inDays == 0) {
        return 'Today ${istDate.hour.toString().padLeft(2, '0')}:${istDate.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday ${istDate.hour.toString().padLeft(2, '0')}:${istDate.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays < 7) {
        final weekdays = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];
        final dayName = weekdays[istDate.weekday - 1];
        return '$dayName ${istDate.hour.toString().padLeft(2, '0')}:${istDate.minute.toString().padLeft(2, '0')}';
      } else {
        return '${istDate.day.toString().padLeft(2, '0')}/${istDate.month.toString().padLeft(2, '0')}/${istDate.year} ${istDate.hour.toString().padLeft(2, '0')}:${istDate.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return dateString;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showSubmissionDetails(Map<String, dynamic> submission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submission Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Question:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(submission['question'] ?? 'No question'),
              const SizedBox(height: 16),
              Text(
                'Your Answer:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(submission['submittedText'] ?? 'No text'),
              const SizedBox(height: 16),
              if (submission['feedback'] != null) ...[
                Text(
                  'Feedback:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFeedbackSummary(submission['feedback']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper method to build feedback summary
  Widget _buildFeedbackSummary(Map<String, dynamic> feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Score: ${feedback['overallScore'] ?? 0}/100'),
        if (feedback['feedbackSummary'] != null)
          Text('Summary: ${feedback['feedbackSummary']}'),
        if (feedback['finalSuggestion'] != null)
          Text('Suggestion: ${feedback['finalSuggestion']}'),
      ],
    );
  }

  Widget _buildGrammarSection() {
    if (widget.grammarRules.isEmpty) return const SizedBox.shrink();

    return ExpansionTile(
      title: const Text(
        'Grammar Rules',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      leading: Icon(Icons.spellcheck, color: widget.discourseType.color),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.grammarRules['punctuation'] != null) ...[
                const Text(
                  'Punctuation:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...((widget.grammarRules['punctuation'] as List).map(
                  (rule) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      '• $rule',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )),
                const SizedBox(height: 12),
              ],
              if (widget.grammarRules['common_mistakes'] != null) ...[
                const Text(
                  'Common Mistakes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...((widget.grammarRules['common_mistakes'] as List).map(
                  (mistake) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      '• $mistake',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getRelevantTips() {
    List<String> tips = [];

    if (widget.discourseType.id == 'letter' ||
        widget.discourseType.id == 'email' ||
        widget.discourseType.id == 'cv') {
      tips.addAll(
        (widget.writingTips['formal'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    } else if (widget.discourseType.id == 'diary') {
      tips.addAll(
        (widget.writingTips['creative'] as List<dynamic>?)?.cast<String>() ??
            [],
      );
    }

    tips.addAll(
      (widget.writingTips['general'] as List<dynamic>?)?.cast<String>() ?? [],
    );

    return tips.take(5).map((tip) => '• $tip').join('\n');
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Writing Editor Screen
class WritingEditorScreen extends StatefulWidget {
  final PracticeItem practiceItem;
  final DiscourseType discourseType;
  final Map<String, dynamic> grammarRules;
  final String userId; // Add userId here

  const WritingEditorScreen({
    Key? key,
    required this.practiceItem,
    required this.discourseType,
    required this.grammarRules,
    required this.userId, // Make userId required
  }) : super(key: key);

  @override
  State<WritingEditorScreen> createState() => _WritingEditorScreenState();
}

class _WritingEditorScreenState extends State<WritingEditorScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _wordCount = 0;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateCounts);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCounts() {
    setState(() {
      _characterCount = _textController.text.length;
      _wordCount = _textController.text.trim().isEmpty
          ? 0
          : _textController.text.trim().split(RegExp(r'\s+')).length;
    });
  }

  void _submitForReview() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write some content before submitting'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    var baseUrl = ApiConfig.baseUrl;
    final feedbackUrl = Uri.parse(
      '$baseUrl/api/${widget.userId}/check-writing',
    );
    final saveSubmissionUrl = Uri.parse(
      '$baseUrl/api/${widget.userId}/submit-writing',
    );

    final headers = {'Content-Type': 'application/json'};

    final submissionDataForFeedback = {
      'text': _textController.text.trim(),
      'discourseType': widget.discourseType.id.toLowerCase(),
      'question': widget.practiceItem.prompt,
    };

    try {
      final feedbackResponse = await http.post(
        feedbackUrl,
        headers: headers,
        body: jsonEncode(submissionDataForFeedback),
      );

      if (feedbackResponse.statusCode == 200) {
        final jsonFeedbackResponse = jsonDecode(feedbackResponse.body);

        /// UPDATED MODEL HERE
        final feedback = WritingFeedback.fromJson(jsonFeedbackResponse);

        final dataToSave = {
          'type': widget.discourseType.id.toLowerCase(),
          'content': _textController.text.trim(),
          'question': widget.practiceItem.prompt,
          'exerciseTitle': widget.practiceItem.title,
          'feedback': jsonFeedbackResponse,
        };

        final saveResponse = await http.post(
          saveSubmissionUrl,
          headers: headers,
          body: jsonEncode(dataToSave),
        );

        Navigator.of(context).pop(); // close loader

        if (saveResponse.statusCode == 201 || saveResponse.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Submission saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          await _showFeedbackDialog(feedback);
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Feedback received, but failed to save submission. Status: ${saveResponse.statusCode}',
              ),
              backgroundColor: Colors.orange,
            ),
          );

          await _showFeedbackDialog(feedback);
          Navigator.of(context).pop(false);
        }
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error getting feedback: ${feedbackResponse.statusCode}.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showFeedbackDialog(WritingFeedback feedback) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Writing Feedback'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Overall Score: ${feedback.data.overallScore}/100',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.discourseType.color,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Summary: ${feedback.data.feedbackSummary}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),

              const Text(
                'Detailed Analysis:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Text(
                feedback.data.discourseSpecificAnalysis,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),

              const Text(
                'Detected Errors:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (feedback.data.errors.isEmpty)
                const Text('No major errors found. Great job!')
              else
                ...feedback.data.errors.map((error) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type: ${error.type}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Description: ${error.description}'),
                        Text(
                          'Suggestion: ${error.suggestion}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 16),
              const Divider(),

              Text(
                'Final Tip: ${feedback.data.finalSuggestion}',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Rest of your existing build methods remain the same...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.practiceItem.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: widget.discourseType.color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'template',
                child: Text('Use Template'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFaqsSection(),
          _buildStatsBar(),
          Expanded(child: _buildEditor()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'template':
        _showTemplateDialog();
        break;
    }
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Use Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will replace your current text with a template. Continue?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.practiceItem.template,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _textController.text = widget.practiceItem.template;
              });
            },
            child: const Text('Use Template'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqsSection() {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(
            Icons.question_answer,
            color: widget.discourseType.color,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'Exercise',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.discourseType.color,
            ),
          ),
        ],
      ),
      backgroundColor: widget.discourseType.color.withOpacity(0.05),
      collapsedBackgroundColor: widget.discourseType.color.withOpacity(0.05),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      initiallyExpanded: false,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.discourseType.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.practiceItem.prompt,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Guidelines:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.practiceItem.guidelines.map(
                (guideline) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 8, right: 8),
                        decoration: BoxDecoration(
                          color: widget.discourseType.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          guideline,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Words: $_wordCount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Characters: $_characterCount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        style: const TextStyle(fontSize: 16, height: 1.6),
        decoration: const InputDecoration(
          hintText:
              'Start writing your content here...\n\nTip: Follow the guidelines above for better results.',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _submitForReview,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.discourseType.color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiscourseType {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final int completedCount;
  final int totalCount;
  final String description;
  final List<String> keyComponents;
  final List<String> rules;
  final List<PracticeItem> practiceItems;

  DiscourseType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.completedCount,
    required this.totalCount,
    required this.description,
    required this.keyComponents,
    required this.rules,
    required this.practiceItems,
  });

  IconData get iconData {
    switch (icon.toLowerCase()) {
      case 'mail':
        return Icons.mail;
      case 'email':
        return Icons.email;
      case 'book':
        return Icons.book;
      case 'article':
        return Icons.article;
      case 'mic':
        return Icons.mic;
      case 'person':
        return Icons.person;
      default:
        switch (id) {
          case 'letter':
            return Icons.edit;
          case 'email':
            return Icons.email;
          case 'diary':
            return Icons.book;
          case 'essay':
            return Icons.mic;
          case 'cv':
            return Icons.person;
          case 'speech':
            return Icons.record_voice_over_rounded;
          default:
            return Icons.edit;
        }
    }
  }

  factory DiscourseType.fromJson(Map<String, dynamic> json) {
    return DiscourseType(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: json['icon'] ?? 'edit',
      color: Color(int.parse(json['color'] ?? '0xFF2196F3')),
      completedCount: json['completedCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      description: json['description'] ?? '',
      keyComponents: List<String>.from(json['keyComponents'] ?? []),
      rules: List<String>.from(json['rules'] ?? []),
      practiceItems:
          (json['practiceItems'] as List<dynamic>?)
              ?.map((item) => PracticeItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PracticeItem {
  final String id;
  final String title;
  final String difficulty;
  final String estimatedTime;
  final bool isCompleted;
  final String type;
  final String prompt;
  final List<String> guidelines;
  final String template;

  PracticeItem({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.estimatedTime,
    required this.isCompleted,
    required this.type,
    required this.prompt,
    required this.guidelines,
    required this.template,
  });

  factory PracticeItem.fromJson(Map<String, dynamic> json) {
    return PracticeItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      estimatedTime: json['estimatedTime'] ?? '15 mins',
      isCompleted: json['isCompleted'] ?? false,
      type: json['type'] ?? 'general',
      prompt: json['prompt'] ?? '',
      guidelines: List<String>.from(json['guidelines'] ?? []),
      template: json['template'] ?? '',
    );
  }
}

class WritingFeedback {
  final bool success;
  final int statusCode;
  final String message;
  final WritingData data;
  final String timestamp;

  WritingFeedback({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory WritingFeedback.fromJson(Map<String, dynamic> json) {
    return WritingFeedback(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'],
      data: WritingData.fromJson(json['data']),
      timestamp: json['timestamp'],
    );
  }
}

class WritingData {
  final int overallScore;
  final String feedbackSummary;
  final List<WritingError> errors;
  final String discourseSpecificAnalysis;
  final String finalSuggestion;

  WritingData({
    required this.overallScore,
    required this.feedbackSummary,
    required this.errors,
    required this.discourseSpecificAnalysis,
    required this.finalSuggestion,
  });

  factory WritingData.fromJson(Map<String, dynamic> json) {
    return WritingData(
      overallScore: json['overall_score'],
      feedbackSummary: json['feedback_summary'],
      errors: (json['errors'] as List)
          .map((e) => WritingError.fromJson(e))
          .toList(),
      discourseSpecificAnalysis: json['discourse_specific_analysis'],
      finalSuggestion: json['final_suggestion'],
    );
  }
}

class WritingError {
  final String type;
  final String description;
  final String suggestion;

  WritingError({
    required this.type,
    required this.description,
    required this.suggestion,
  });

  factory WritingError.fromJson(Map<String, dynamic> json) {
    return WritingError(
      type: json['type'],
      description: json['description'],
      suggestion: json['suggestion'],
    );
  }
}

// Helper Extensions for Mobile Responsiveness
extension ScreenSize on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= 600 &&
      MediaQuery.of(this).size.width < 1200;
  bool get isDesktop => MediaQuery.of(this).size.width >= 1200;

  EdgeInsets get responsivePadding {
    if (isMobile) return const EdgeInsets.all(16);
    if (isTablet) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }
}
