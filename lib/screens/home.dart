import 'package:K_Skill/screens/widgets/reading_comprehension.dart';
import 'package:K_Skill/services/app_usage_tracker.dart';
import 'package:flutter/material.dart';
import 'package:K_Skill/assessment/assessment_screen.dart';
import 'package:K_Skill/screens/widgets/dictionary_widget.dart';
import 'package:K_Skill/screens/widgets/vocabulary_widget.dart';
import 'package:K_Skill/services/shared_prefs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  int? currentStreak;
  int currentBottomNavIndex = 0;
  final usageTracker = AppUsageTracker();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await SharedPrefsService.getUserName();
    final streak = await SharedPrefsService.getUserStreak();
    setState(() {
      userName = name;
      currentStreak = streak;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(child: _buildHeader()),
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResponsiveMainSection(),
                    const SizedBox(height: 32),

                    const DictionaryWidget(),
                    const SizedBox(height: 24),

                    const Text(
                      'Vocabulary Topics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    VocabularyWidget(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 400;
        double avatarSize = isSmallScreen ? 40 : 45;
        double welcomeTextSize = isSmallScreen ? 20 : 22;
        return Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300, Colors.indigo.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: isSmallScreen ? 20 : 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_getTimeBasedGreeting()}, ${userName ?? "User"}!',
                  style: TextStyle(
                    fontSize: welcomeTextSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange[600],
                      size: isSmallScreen ? 16 : 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${currentStreak ?? 0}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'images/kskill_logo.png',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // const SizedBox(height: 10),
                    // Text(
                    //   userName ?? 'Student',
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     color: Colors.white.withOpacity(0.9),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(
                      icon: Icons.home,
                      title: 'Home',
                      color: Colors.blue,
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/home');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.book,
                      title: 'Learn',
                      color: Colors.green,
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/levels');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.mic,
                      title: 'Practice',
                      color: Colors.purple,
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/practice');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.play_circle_outline,
                      title: 'Games',
                      color: Colors.orange,
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/games');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.person,
                      title: 'Profile',
                      color: Colors.indigo,
                      onTap: () {
                        //Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    // Divider(
                    //   height: 32,
                    //   thickness: 1,
                    //   indent: 16,
                    //   endIndent: 16,
                    // ),
                    // _buildDrawerItem(
                    //   icon: Icons.emoji_events_rounded,
                    //   title: 'Achievements',
                    //   color: Colors.amber,
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/achievements');
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   icon: Icons.leaderboard_rounded,
                    //   title: 'Leaderboard',
                    //   color: Colors.red,
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/leaderboard');
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   icon: Icons.calendar_today_rounded,
                    //   title: 'My Schedule',
                    //   color: Colors.teal,
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/schedule');
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   icon: Icons.school_rounded,
                    //   title: 'My Courses',
                    //   color: Colors.deepPurple,
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/courses');
                    //   },
                    // ),
                    Divider(
                      height: 32,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    // _buildDrawerItem(
                    //   icon: Icons.settings_rounded,
                    //   title: 'Settings',
                    //   color: Colors.grey,
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     Navigator.pushNamed(context, '/settings');
                    //   },
                    // ),
                    _buildDrawerItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help',
                      color: Colors.blueGrey,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/help');
                      },
                    ),
                  ],
                ),
              ),
              // Logout Button
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showLogoutDialog();
                  },
                  icon: Icon(Icons.logout_rounded),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await usageTracker.stopTracking();
                await AppUsageTracker.syncUsageToServer();
                await SharedPrefsService.logout();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/welcome', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Widget _buildResponsiveMainSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    if (isWeb) {
      // Web view: Side by side layout
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner Image
          Expanded(flex: 1, child: _buildMainHeadline()),
          const SizedBox(width: 24),
          // Practice Modules
          Expanded(flex: 1, child: _buildLearningModules()),
        ],
      );
    } else {
      // Mobile view: Stacked layout
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainHeadline(),
          const SizedBox(height: 32),
          _buildLearningModules(),
        ],
      );
    }
  }

  Widget _buildMainHeadline() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Center(
      child: Container(
        width: isWeb ? double.infinity : double.infinity,
        height: isWeb ? 280 : MediaQuery.of(context).size.height * 0.25,
        constraints: const BoxConstraints(minHeight: 200, maxHeight: 350),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: AssetImage('images/board.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildLearningModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Practice Modules',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Assessment Card
        _buildAssessmentCard(),
        const SizedBox(height: 16),

        // Reading Comprehension Card
        _buildReadingComprehensionCard(),
      ],
    );
  }

  Widget _buildAssessmentCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssessmentScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.indigo.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Take Assessment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Test your skills today',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingComprehensionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReadingComprehension()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.pink.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reading Comprehension',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Practice reading skills',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
