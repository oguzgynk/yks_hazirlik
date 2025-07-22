import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with TickerProviderStateMixin {
  late CountDownController _controller;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  PomodoroSettings _settings = PomodoroSettings();
  bool _isWorkTime = true;
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedPomodoros = 0;
  int _totalWorkMinutes = 0;

  @override
  void initState() {
    super.initState();
    _controller = CountDownController();
    _loadSettings();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  void _loadSettings() {
    setState(() {
      _settings = StorageService.getPomodoroSettings();
    });
  }

  @override
  void dispose() {
    _controller.pause();
    _pulseController.dispose();
    super.dispose();
  }

  int get _currentDuration {
    return _isWorkTime ? _settings.workDuration : _settings.breakDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _showSettingsDialog,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildTimer(),
            const SizedBox(height: 24),
            _buildControls(),
            const SizedBox(height: 24),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: _isWorkTime 
              ? AppTheme.primaryGradient 
              : AppTheme.secondaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              _isWorkTime ? Icons.work : Icons.coffee,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _isWorkTime ? 'Çalışma Zamanı' : 'Mola Zamanı',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _isWorkTime 
                  ? 'Odaklan ve çalış! 💪'
                  : 'Biraz dinlen ve nefes al ☕',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRunning && !_isPaused ? _pulseAnimation.value : 1.0,
                  child: CircularCountDownTimer(
                    duration: _currentDuration * 60,
                    initialDuration: 0,
                    controller: _controller,
                    width: 250,
                    height: 250,
                    ringColor: Colors.grey[300]!,
                    ringGradient: null,
                    fillColor: _isWorkTime 
                        ? AppTheme.primaryPurple 
                        : AppTheme.accentBlue,
                    fillGradient: _isWorkTime 
                        ? AppTheme.primaryGradient 
                        : AppTheme.secondaryGradient,
                    backgroundColor: Colors.transparent,
                    strokeWidth: 12.0,
                    strokeCap: StrokeCap.round,
                    textStyle: TextStyle(
                      fontSize: 48,
                      color: Theme.of(context).textTheme.headlineLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                    textFormat: CountdownTextFormat.MM_SS,
                    isReverse: true, // Geri sayım
                    isReverseAnimation: true, // Animasyon da geriye
                    isTimerTextShown: true,
                    autoStart: false,
                    onStart: () {
                      setState(() {
                        _isRunning = true;
                        _isPaused = false;
                      });
                    },
                    onComplete: () {
                      _onTimerComplete();
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              '${_currentDuration} dakika',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: _isRunning && !_isPaused ? Icons.pause : Icons.play_arrow,
          label: _isRunning && !_isPaused ? 'Duraklat' : 'Başlat',
          color: AppTheme.primaryPurple,
          onTap: _toggleTimer,
        ),
        _buildControlButton(
          icon: Icons.stop,
          label: 'Durdur',
          color: Colors.red,
          onTap: _stopTimer,
        ),
        _buildControlButton(
          icon: Icons.skip_next,
          label: _isWorkTime ? 'Molaya Geç' : 'Çalışmaya Geç',
          color: AppTheme.accentBlue,
          onTap: _skipTimer,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bugünkü İstatistikler',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tamamlanan Pomodoro',
                    _completedPomodoros.toString(),
                    Icons.timer,
                    AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Çalışma Süresi',
                    '${(_totalWorkMinutes / 60).toStringAsFixed(1)}h',
                    Icons.access_time,
                    AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_settings.includeInStudyTime)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Çalışma süreniz günlük istatistiklere dahil ediliyor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTimer() {
    if (_isRunning && !_isPaused) {
      _controller.pause();
      setState(() {
        _isPaused = true;
      });
    } else {
      _controller.start();
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    }
  }

  void _stopTimer() {
    _controller.pause();
    _controller.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
  }

  void _skipTimer() {
    _onTimerComplete();
  }

  void _onTimerComplete() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      
      if (_isWorkTime) {
        _completedPomodoros++;
        _totalWorkMinutes += _settings.workDuration;
        
        // Çalışma süresini kaydet
        if (_settings.includeInStudyTime) {
          _saveStudyTime();
        }
      }
      
      _isWorkTime = !_isWorkTime;
    });

    // Bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWorkTime 
              ? 'Mola bitti! Çalışma zamanı 💪'
              : 'Pomodoro tamamlandı! Mola zamanı ☕',
        ),
        backgroundColor: _isWorkTime 
            ? AppTheme.primaryPurple 
            : AppTheme.accentBlue,
        duration: const Duration(seconds: 3),
      ),
    );

    // Timer'ı sıfırla
    _controller.reset();
  }

  void _saveStudyTime() {
    final session = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: 'Pomodoro',
      topic: 'Çalışma',
      duration: _settings.workDuration,
      correctAnswers: 0,
      wrongAnswers: 0,
      emptyAnswers: 0,
      date: DateTime.now(),
    );

    StorageService.saveStudySession(session);
  }

  void _showSettingsDialog() {
    final workController = TextEditingController(
      text: _settings.workDuration.toString(),
    );
    final breakController = TextEditingController(
      text: _settings.breakDuration.toString(),
    );
    bool includeInStudyTime = _settings.includeInStudyTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pomodoro Ayarları'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: workController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Çalışma Süresi (dakika)',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: breakController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Mola Süresi (dakika)',
                  prefixIcon: Icon(Icons.coffee),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Çalışma süresini istatistiklere dahil et'),
                value: includeInStudyTime,
                onChanged: (value) {
                  setDialogState(() {
                    includeInStudyTime = value ?? true;
                  });
                },
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
                final workDuration = int.tryParse(workController.text) ?? 25;
                final breakDuration = int.tryParse(breakController.text) ?? 5;
                
                final newSettings = PomodoroSettings(
                  workDuration: workDuration,
                  breakDuration: breakDuration,
                  includeInStudyTime: includeInStudyTime,
                );
                
                StorageService.savePomodoroSettings(newSettings);
                setState(() {
                  _settings = newSettings;
                });
                
                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}