// lib/screens/pomodoro_screen.dart

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
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
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
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
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
    _glowController.dispose();
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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.settings,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 32),
            _buildTimer(),
            const SizedBox(height: 32),
            _buildControls(),
            const SizedBox(height: 32),
            _buildStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final cardGradient = _isWorkTime
        ? AppThemes.getGradient(StorageService.getTheme())
        : LinearGradient(colors: [Theme.of(context).colorScheme.secondary, Colors.teal]);

    return Card(
      elevation: 8,
      shadowColor: _isWorkTime 
          ? Theme.of(context).primaryColor.withOpacity(0.3)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isWorkTime ? Icons.work_outline : Icons.coffee_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              _isWorkTime ? 'Çalışma Zamanı' : 'Mola Zamanı',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isWorkTime 
                  ? 'Odaklan ve hedefine odaklan! 🎯'
                  : 'Rahatla ve enerjini topla ☕',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final timerColor = _isWorkTime ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary;

    return Card(
      elevation: 12,
      shadowColor: timerColor.withOpacity(0.4),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).cardColor,
              Theme.of(context).cardColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRunning && !_isPaused ? _pulseAnimation.value : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: timerColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircularCountDownTimer(
                      duration: _currentDuration * 60,
                      initialDuration: 0,
                      controller: _controller,
                      width: 280,
                      height: 280,
                      ringColor: Colors.grey[300]!,
                      ringGradient: null,
                      fillColor: timerColor,
                      fillGradient: AppThemes.getGradient(StorageService.getTheme()),
                      backgroundColor: Colors.transparent,
                      strokeWidth: 16.0,
                      strokeCap: StrokeCap.round,
                      textStyle: TextStyle(
                        fontSize: 52,
                        color: Theme.of(context).textTheme.headlineLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                      textFormat: CountdownTextFormat.MM_SS,
                      isReverse: true,
                      isReverseAnimation: true,
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
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: timerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentDuration} dakika',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: timerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Kontroller', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isRunning && !_isPaused ? Icons.pause : Icons.play_arrow,
                  label: _isRunning && !_isPaused ? 'Duraklat' : 'Başlat',
                  color: Theme.of(context).primaryColor,
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
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: _skipTimer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(35),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 8),
                Text('Bugünkü İstatistikler', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tamamlanan Pomodoro',
                    _completedPomodoros.toString(),
                    Icons.timer,
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Çalışma Süresi',
                    '${(_totalWorkMinutes / 60).toStringAsFixed(1)}h',
                    Icons.access_time,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_settings.includeInStudyTime)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Çalışma süreniz günlük istatistiklere dahil ediliyor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
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
      height: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
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
      setState(() => _isPaused = true);
    } else {
      _controller.resume();
      setState(() {
        _isRunning = true;
        _isPaused = false;
      });
    }
  }

  void _stopTimer() {
    _controller.reset();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isWorkTime = true;
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
        
        if (_settings.includeInStudyTime) {
          _saveStudyTime();
        }
      }
      
      _isWorkTime = !_isWorkTime;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_isWorkTime ? Icons.work : Icons.coffee, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isWorkTime 
                    ? 'Mola bitti! Çalışma zamanı 💪'
                    : 'Pomodoro tamamlandı! Mola zamanı ☕',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _isWorkTime ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    _controller.restart(duration: _currentDuration * 60);
    _controller.pause();
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
    final workController = TextEditingController(text: _settings.workDuration.toString());
    final breakController = TextEditingController(text: _settings.breakDuration.toString());
    bool includeInStudyTime = _settings.includeInStudyTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pomodoro Ayarları'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: workController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Çalışma Süresi (dakika)',
                    prefixIcon: Icon(Icons.work, color: Theme.of(context).primaryColor),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: breakController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mola Süresi (dakika)',
                    prefixIcon: Icon(Icons.coffee, color: Theme.of(context).colorScheme.secondary),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CheckboxListTile(
                    title: const Text('Çalışma süresini istatistiklere dahil et'),
                    subtitle: const Text('Pomodoro çalışma süreleri günlük verilerinize eklenir'),
                    value: includeInStudyTime,
                    onChanged: (value) {
                      setDialogState(() {
                        includeInStudyTime = value ?? true;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
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
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ayarlar kaydedildi!'), backgroundColor: Colors.green),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}