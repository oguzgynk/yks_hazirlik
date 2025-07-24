// lib/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../services/storage_service.dart';
import '../models/data_models.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  String _selectedChart = 'Çalışma Saati';
  String _selectedPeriod = 'Haftalık';
  String _selectedExamType = 'TYT'; // Deneme grafikleri için
  List<StudySession> _sessions = [];
  List<ExamResult> _examResults = [];
  late TabController _examHistoryTabController;

  @override
  void initState() {
    super.initState();
    _examHistoryTabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _examHistoryTabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _sessions = StorageService.getStudySessions();
      _examResults = StorageService.getExamResults();
    });
  }

  List<ExamResult> _getFilteredExamResults() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'Haftalık':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Aylık':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Tümü':
      default:
        startDate = DateTime(2020, 1, 1);
    }
    
    return _examResults.where((exam) => 
      exam.examDate.isAfter(startDate) && 
      exam.examType == _selectedExamType
    ).toList();
  }

  List<ExamResult> _getExamResultsByType(String examType) {
    return _examResults.where((exam) => exam.examType == examType).toList()
      ..sort((a, b) => b.examDate.compareTo(a.examDate));
  }
  
  List<StudySession> _getFilteredSessions() {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'Haftalık':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Aylık':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Tümü':
      default:
        startDate = DateTime(2020, 1, 1);
    }
    
    return _sessions.where((session) => session.date.isAfter(startDate)).toList();
  }

  double _getYInterval(Iterable<double> values) {
    if (values.isEmpty) return 1;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 10) return 1;
    if (max <= 50) return 5;
    if (max <= 100) return 10;
    return (max / 10).ceilToDouble();
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik': return Icons.calculate;
      case 'türkçe':
      case 'türk dili ve edebiyatı':
      case 'türk dili ve edebiyatı-sosyal bilimler-1': return Icons.menu_book;
      case 'geometri': return Icons.square_foot;
      case 'fizik': return Icons.science;
      case 'kimya': return Icons.biotech;
      case 'biyoloji': return Icons.eco;
      case 'tarih':
      case 'tarih-1':
      case 'tarih-2': return Icons.history_edu;
      case 'coğrafya':
      case 'coğrafya-1':
      case 'coğrafya-2': return Icons.public;
      case 'felsefe': return Icons.psychology;
      case 'din kültürü': return Icons.mosque;
      case 'sosyal bilimler':
      case 'sosyal bilimler-2': return Icons.public;
      case 'fen bilimleri': return Icons.science;
      default: return Icons.subject;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartSelector(),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildChart(),
            const SizedBox(height: 24),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildExamHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSelector() {
    final charts = ['Deneme Netlerim', 'Çalışma Saati', 'Çözülen Soru'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grafik Türü', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Column(
              children: charts.map((chart) {
                final isSelected = _selectedChart == chart;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildSelector(chart, isSelected, () => setState(() => _selectedChart = chart)),
                );
              }).toList(),
            ),
            if (_selectedChart == 'Deneme Netlerim') ...[
              const SizedBox(height: 16),
              Text('Sınav Türü', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: ['TYT', 'AYT'].map((examType) {
                  final isSelected = _selectedExamType == examType;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildSelector(examType, isSelected, () => setState(() => _selectedExamType = examType)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Haftalık', 'Aylık', 'Tümü'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildSelector(period, isSelected, () => setState(() => _selectedPeriod = period)),
        );
      }).toList(),
    );
  }

  Widget _buildSelector(String text, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isSelected ? AppThemes.getGradient(StorageService.getTheme()) : null,
            color: isSelected ? null : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildChart() {
    final chartTitle = _selectedChart == 'Deneme Netlerim' 
        ? '$_selectedExamType $_selectedChart'
        : _selectedChart;
        
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    chartTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedChart == 'Deneme Netlerim')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedExamType == 'TYT' 
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedExamType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedExamType == 'TYT' ? Colors.blue[700] : Colors.purple[700],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: _selectedChart == 'Deneme Netlerim' 
                ? _buildExamChart() 
                : _buildSessionChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionChart() {
    final filteredSessions = _getFilteredSessions();
    
    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Henüz veri bulunmuyor', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              'Çalışma verileri girdikçe grafik burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    List<FlSpot> spots = [];
    Map<DateTime, double> dailyData = {};

    // Günlük verileri topla
    for (var session in filteredSessions) {
      final date = DateTime(session.date.year, session.date.month, session.date.day);
      
      switch (_selectedChart) {
        case 'Çalışma Saati':
          dailyData[date] = (dailyData[date] ?? 0) + (session.duration / 60.0);
          break;
        case 'Çözülen Soru':
          dailyData[date] = (dailyData[date] ?? 0) + 
              (session.correctAnswers + session.wrongAnswers + session.emptyAnswers).toDouble();
          break;
      }
    }

    if (dailyData.isEmpty) {
      return Center(
        child: Text(
          'Bu dönem için veri bulunamadı',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      );
    }

    // Sıralı tarih listesi oluştur
    final sortedDates = dailyData.keys.toList()..sort();
    
    for (int i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyData[sortedDates[i]]!));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedDates.length) {
                  final date = sortedDates[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${date.day}/${date.month}',
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getYInterval(dailyData.values),
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        minX: 0,
        maxX: sortedDates.length > 1 ? (sortedDates.length - 1).toDouble() : 1,
        minY: 0,
        maxY: dailyData.values.isNotEmpty 
            ? dailyData.values.reduce((a, b) => a > b ? a : b) * 1.1 
            : 10,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).colorScheme.secondary,
              ]
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Theme.of(context).primaryColor,
                strokeWidth: 2,
                strokeColor: Theme.of(context).cardColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildExamChart() {
    final filteredExams = _getFilteredExamResults();
    
    if (filteredExams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz $_selectedExamType denemesi bulunmuyor',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Deneme girdikçe grafik burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sortedExams = filteredExams..sort((a, b) => a.examDate.compareTo(b.examDate));
    
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedExams.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedExams[i].totalNet));
    }

    final maxNet = sortedExams.isEmpty ? 10 : sortedExams.map((e) => e.totalNet).reduce((a, b) => a > b ? a : b);
    final minNet = sortedExams.isEmpty ? 0 : sortedExams.map((e) => e.totalNet).reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedExams.length) {
                  final exam = sortedExams[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${exam.examDate.day}/${exam.examDate.month}',
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold, fontSize: 9),
                            ),
                            Text(
                              exam.examName.length > 6 ? '${exam.examName.substring(0, 6)}...' : exam.examName,
                              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 8),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.bold, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Theme.of(context).dividerColor)),
        minX: 0,
        maxX: sortedExams.length > 1 ? (sortedExams.length - 1).toDouble() : 1,
        minY: (minNet - 5.0).clamp(0.0, double.infinity),
        maxY: maxNet + 10,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: _selectedExamType == 'TYT' 
                ? LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!])
                : LinearGradient(colors: [Colors.purple[400]!, Colors.purple[600]!]),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 5,
                color: _selectedExamType == 'TYT' ? Colors.blue[600]! : Colors.purple[600]!,
                strokeWidth: 2,
                strokeColor: Theme.of(context).cardColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: _selectedExamType == 'TYT' 
                    ? [Colors.blue[400]!.withOpacity(0.3), Colors.blue[600]!.withOpacity(0.1)]
                    : [Colors.purple[400]!.withOpacity(0.3), Colors.purple[600]!.withOpacity(0.1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final filteredSessions = _getFilteredSessions();
    
    final totalStudyTime = filteredSessions.fold(0, (sum, session) => sum + session.duration);
    final totalQuestions = filteredSessions.fold(0, (sum, session) => 
        sum + session.correctAnswers + session.wrongAnswers + session.emptyAnswers);
    final examCount = _examResults.where((exam) => filteredSessions.any((session) => session.date == exam.examDate)).length;
    final totalStudyHours = (totalStudyTime / 60).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dönem Özeti', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Çalışma Süresi', '${totalStudyHours}h', Icons.access_time, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard('Toplam Soru', totalQuestions.toString(), Icons.quiz, Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Çözülen Deneme', examCount.toString(), Icons.assignment, Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildExamHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deneme Geçmişi 📋',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _examHistoryTabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: AppThemes.getGradient(StorageService.getTheme()),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'TYT'),
              Tab(text: 'AYT'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          // Yüksekliği içeriğe göre ayarlanabilir yapmak için ListView'in shrinkWrap'ını kullanacağız.
          // Bu yüzden belirli bir yükseklik vermek yerine, içeriğin sığmasını sağlıyoruz.
          height: 400, // Yüksekliği, taşma olmaması için geçici olarak belirliyoruz.
          child: TabBarView(
            controller: _examHistoryTabController,
            children: [
              _buildExamTypeHistory('TYT'),
              _buildExamTypeHistory('AYT'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExamTypeHistory(String examType) {
    final exams = _getExamResultsByType(examType);
    
    if (exams.isEmpty) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Henüz $examType denemesi bulunmuyor',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlk $examType denemenizi girin ve burada görün',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: exams.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final exam = exams[index];
          return _buildExamTile(exam);
        },
      ),
    );
  }

  Widget _buildExamTile(ExamResult exam) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: exam.examType == 'TYT' 
              ? LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!])
              : LinearGradient(colors: [Colors.purple[400]!, Colors.purple[600]!]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(exam.examType, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
            FittedBox(
              child: Text(
                exam.totalNet.toStringAsFixed(1),
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      title: Text(exam.examName, style: TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(exam.examDate), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildMiniStat('D', exam.totalCorrect, Colors.green),
              _buildMiniStat('Y', exam.totalWrong, Colors.red),
              _buildMiniStat('B', exam.totalEmpty, Colors.orange),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Net: ${exam.totalNet.toStringAsFixed(1)}',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showExamDetails(exam),
    );
  }

  Widget _buildMiniStat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label:$value',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  void _showExamDetails(ExamResult exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: exam.examType == 'TYT' 
                          ? LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!])
                          : LinearGradient(colors: [Colors.purple[400]!, Colors.purple[600]!]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(exam.examType, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.examName, style: Theme.of(context).textTheme.headlineSmall, overflow: TextOverflow.ellipsis),
                          Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(exam.examDate), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildDetailStatCard('Toplam Net', exam.totalNet.toStringAsFixed(1), Icons.trending_up, Colors.purple)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDetailStatCard('Toplam Soru', exam.totalQuestions.toString(), Icons.quiz, Colors.blue)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Ders Bazlı Sonuçlar', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: exam.subjectResults.length,
                    itemBuilder: (context, index) {
                      final entry = exam.subjectResults.entries.toList()[index];
                      final subject = entry.key;
                      final result = entry.value;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(_getSubjectIcon(subject), color: Theme.of(context).primaryColor, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(subject, style: TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                    Text('D:${result.correctAnswers} Y:${result.wrongAnswers} B:${result.emptyAnswers}', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: result.netScore >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  result.netScore.toStringAsFixed(1),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: result.netScore >= 0 ? Colors.green : Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
          ),
          Text(title, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}