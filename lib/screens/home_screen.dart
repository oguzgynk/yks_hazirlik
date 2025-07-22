import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';
import 'settings_screen.dart';
import 'question_entry_screen.dart';
import 'exam_entry_screen.dart';
import 'study_time_entry_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime? _yksDate;
  MotivationQuote? _todaysQuote;
  DailyGoal? _dailyGoal;
  int _todayStudyMinutes = 0;
  int _todayQuestions = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  void _loadData() {
    setState(() {
      _yksDate = StorageService.getYksDate() ?? AppConstants.yksDate;
      _todaysQuote = _getTodaysQuote();
      _dailyGoal = StorageService.getDailyGoal();
      _todayStudyMinutes = StorageService.getTodayStudyMinutes();
      _todayQuestions = StorageService.getTodayQuestionsSolved();
    });
  }

  MotivationQuote _getTodaysQuote() {
    // Günlük sabit bir söz için tarih tabanlı rastgele sayı
    final today = DateTime.now();
    final seed = today.year * 1000 + today.month * 100 + today.day;
    final random = Random(seed);
    final index = random.nextInt(AppConstants.motivationQuotes.length);
    return AppConstants.motivationQuotes[index];
  }

  int _getDaysUntilYKS() {
    final now = DateTime.now();
    final difference = _yksDate!.difference(now);
    return difference.inDays;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCountdownCard(),
                const SizedBox(height: 24),
                _buildMotivationCard(),
                const SizedBox(height: 24),
                _buildGoalsCard(),
                const SizedBox(height: 24),
                _buildTodayStats(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba! 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Başarıya hazır mısın?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  isDarkMode: widget.isDarkMode,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            ).then((_) => _loadData());
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownCard() {
    final daysLeft = _getDaysUntilYKS();
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, iconValue, child) {
                      return Transform.scale(
                        scale: iconValue,
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 32,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'YKS\'ye Kalan Süre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        '$daysLeft GÜN',
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    isRepeatingAnimation: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    daysLeft > 0 
                      ? 'Zamanın değerini bil! 💪'
                      : daysLeft == 0 
                        ? 'Bugün büyük gün! 🎯'
                        : 'YKS geçti, haydi yeni hedeflere! 🚀',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivationCard() {
    if (_todaysQuote == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: AppTheme.primaryPurple,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            _todaysQuote!.quote,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '- ${_todaysQuote!.author}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bugünkü Hedeflerim 🎯',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: _showGoalDialog,
                  child: const Text('Düzenle'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_dailyGoal != null) ...[
              _buildGoalProgress(
                'Çalışma Süresi',
                '${(_todayStudyMinutes / 60).toStringAsFixed(1)} / ${_dailyGoal!.studyHours} saat',
                _todayStudyMinutes / 60,
                _dailyGoal!.studyHours.toDouble(),
                Icons.access_time,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildGoalProgress(
                'Soru Sayısı',
                '$_todayQuestions / ${_dailyGoal!.questionCount} soru',
                _todayQuestions.toDouble(),
                _dailyGoal!.questionCount.toDouble(),
                Icons.quiz,
                Colors.green,
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Henüz günlük hedef belirlenmemiş',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _showGoalDialog,
                      child: const Text('Hedef Belirle'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(
    String title,
    String subtitle,
    double current,
    double target,
    IconData icon,
    Color color,
  ) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    
    return Row(
      children: [
        CircularPercentIndicator(
          radius: 25,
          lineWidth: 4,
          percent: progress,
          center: Icon(icon, color: color, size: 20),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugün Çözülenler 📊',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Soru Sayısı',
                    _todayQuestions.toString(),
                    Icons.quiz,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Çalışma Süresi',
                    '${(_todayStudyMinutes / 60).toStringAsFixed(1)}h',
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      height: 120, // Sabit yükseklik
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Çalışmaya Başla 🚀',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Çalışma Saati',
                Icons.access_time,
                AppTheme.primaryBlue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudyTimeEntryScreen(),
                  ),
                ).then((_) => _loadData()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Soru Gir',
                Icons.quiz,
                AppTheme.primaryPurple,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionEntryScreen(),
                  ),
                ).then((_) => _loadData()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Deneme Gir',
                Icons.assignment,
                AppTheme.accentBlue,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExamEntryScreen(),
                  ),
                ).then((_) => _loadData()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Hero(
            tag: 'action_$title',
            child: Container(
              height: 120, // Sabit yükseklik
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Icon(icon, color: Colors.white, size: 28),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalDialog() {
    final studyController = TextEditingController(
      text: _dailyGoal?.studyHours.toString() ?? '4',
    );
    final questionController = TextEditingController(
      text: _dailyGoal?.questionCount.toString() ?? '100',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Günlük Hedef Belirle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: studyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Çalışma Süresi (saat)',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: questionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Soru Sayısı',
                prefixIcon: Icon(Icons.quiz),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final studyHours = int.tryParse(studyController.text) ?? 4;
              final questionCount = int.tryParse(questionController.text) ?? 100;
              
              final goal = DailyGoal(
                studyHours: studyHours,
                questionCount: questionCount,
                date: DateTime.now(),
              );
              
              StorageService.saveDailyGoal(goal);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}