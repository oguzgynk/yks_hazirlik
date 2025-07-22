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

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedChart = 'Çalışma Saati';
  String _selectedPeriod = 'Haftalık';
  String _selectedExamType = 'TYT'; // Deneme grafikleri için
  List<StudySession> _sessions = [];
  List<ExamResult> _examResults = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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
        startDate = DateTime(2020, 1, 1);
        break;
      default:
        startDate = now.subtract(Duration(days: now.weekday - 1));
    }
    
    return _examResults.where((exam) => 
      exam.examDate.isAfter(startDate) && 
      exam.examType == _selectedExamType
    ).toList();
  }  Widget _buildExamHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deneme Geçmişi 📋',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Row(
              children: ['TYT', 'AYT'].map((examType) {
                final isSelected = _selectedExamType == examType;
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedExamType = examType;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? (examType == 'TYT' ? Colors.blue : Colors.purple)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          examType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              if (_getFilteredExamResults().isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz $_selectedExamType denemesi bulunmuyor',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'İlk $_selectedExamType denemenizi girin ve burada görün',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getFilteredExamResults().length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final filteredExams = _getFilteredExamResults()..sort((a, b) => b.examDate.compareTo(a.examDate));
                    final exam = filteredExams[index];
                    return _buildExamTile(exam);
                  },
                ),
            ],
          ),
        ),
      ],
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
            Text(
              exam.examType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              exam.totalNet.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      title: Text(
        exam.examName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('dd MMMM yyyy', 'tr_TR').format(exam.examDate)),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildMiniStat('D', exam.totalCorrect, Colors.green),
              const SizedBox(width: 8),
              _buildMiniStat('Y', exam.totalWrong, Colors.red),
              const SizedBox(width: 8),
              _buildMiniStat('B', exam.totalEmpty, Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Net: ${exam.totalNet.toStringAsFixed(1)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showExamDetails(ExamResult exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                      child: Text(
                        exam.examType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.examName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy', 'tr_TR').format(exam.examDate),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Özet kartlar
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailStatCard('Toplam Net', exam.totalNet.toStringAsFixed(1), Icons.trending_up, Colors.purple),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDetailStatCard('Toplam Soru', exam.totalQuestions.toString(), Icons.quiz, Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                Text(
                  'Ders Bazlı Sonuçlar',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
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
                              Icon(
                                _getSubjectIcon(subject),
                                color: AppTheme.primaryPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'D:${result.correctAnswers} Y:${result.wrongAnswers} B:${result.emptyAnswers}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: result.netScore >= 0 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  result.netScore.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: result.netScore >= 0 ? Colors.green : Colors.red,
                                  ),
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
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'matematik':
        return Icons.calculate;
      case 'türkçe':
      case 'türk dili ve edebiyatı':
        return Icons.menu_book;
      case 'geometri':
        return Icons.square_foot;
      case 'fizik':
        return Icons.science;
      case 'kimya':
        return Icons.biotech;
      case 'biyoloji':
        return Icons.eco;
      case 'tarih':
      case 'tarih-1':
      case 'tarih-2':
        return Icons.history_edu;
      case 'coğrafya':
      case 'coğrafya-1':
      case 'coğrafya-2':
        return Icons.public;
      case 'felsefe':
        return Icons.psychology;
      case 'din kültürü':
        return Icons.mosque;
      default:
        return Icons.subject;
    }
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
        startDate = DateTime(2020, 1, 1); // Çok eskiden başlat
        break;
      default:
        startDate = now.subtract(Duration(days: now.weekday - 1));
    }
    
    return _sessions.where((session) => session.date.isAfter(startDate)).toList();
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
            Text(
              'Grafik Türü',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: charts.map((chart) {
                final isSelected = _selectedChart == chart;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildSelector(chart, isSelected, () {
                      setState(() {
                        _selectedChart = chart;
                      });
                    }),
                  ),
                );
              }).toList(),
            ),
            
            // Deneme grafikleri için TYT/AYT seçici
            if (_selectedChart == 'Deneme Netlerim') ...[
              const SizedBox(height: 16),
              Text(
                'Sınav Türü',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['TYT', 'AYT'].map((examType) {
                  final isSelected = _selectedExamType == examType;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildSelector(examType, isSelected, () {
                        setState(() {
                          _selectedExamType = examType;
                        });
                      }),
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
      children: periods.map((period) {
        final isSelected = _selectedPeriod == period;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildSelector(period, isSelected, () {
              setState(() {
                _selectedPeriod = period;
              });
            }),
          ),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected ? AppTheme.primaryGradient : null,
            color: isSelected ? null : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
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
              child: _buildLineChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    if (_selectedChart == 'Deneme Netlerim') {
      return _buildExamChart();
    }
    
    final filteredSessions = _getFilteredSessions();
    
    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz veri bulunmuyor',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Çalışma verileri girdikçe grafik burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
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
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedDates.length) {
                  final date = sortedDates[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
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
            gradient: AppTheme.primaryGradient,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.primaryPurple,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.3),
                  AppTheme.primaryBlue.withOpacity(0.1),
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
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz $_selectedExamType denemesi bulunmuyor',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Deneme girdikçe grafik burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Denemeleri tarihe göre sırala
    final sortedExams = filteredExams..sort((a, b) => a.examDate.compareTo(b.examDate));
    
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedExams.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedExams[i].totalNet));
    }

    final maxNet = sortedExams.isEmpty ? 10 : 
        sortedExams.map((e) => e.totalNet).reduce((a, b) => a > b ? a : b);
    final minNet = sortedExams.isEmpty ? 0 : 
        sortedExams.map((e) => e.totalNet).reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 5,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedExams.length) {
                  final exam = sortedExams[index];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${exam.examDate.day}/${exam.examDate.month}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            exam.examName.length > 8 
                                ? '${exam.examName.substring(0, 8)}...'
                                : exam.examName,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 8,
                            ),
                          ),
                        ],
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
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
                strokeColor: Colors.white,
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

  double _getYInterval(Iterable<double> values) {
    if (values.isEmpty) return 1;
    final max = values.reduce((a, b) => a > b ? a : b);
    if (max <= 10) return 1;
    if (max <= 50) return 5;
    if (max <= 100) return 10;
    return (max / 10).ceilToDouble();
  }

  Widget _buildSummaryCards() {
    final filteredSessions = _getFilteredSessions();
    
    final totalStudyTime = filteredSessions.fold(0, (sum, session) => sum + session.duration);
    final totalQuestions = filteredSessions.fold(0, (sum, session) => 
        sum + session.correctAnswers + session.wrongAnswers + session.emptyAnswers);
    final examCount = filteredSessions.where((s) => s.isExam).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dönem Özeti',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Çalışma Süresi',
                '${(totalStudyTime / 60).toStringAsFixed(1)}h',
                Icons.access_time,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Toplam Soru',
                totalQuestions.toString(),
                Icons.quiz,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Toplam Çözülen Soru',
                totalQuestions.toString(),
                Icons.quiz_outlined,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Deneme Sayısı',
                examCount.toString(),
                Icons.assignment,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Container(
        height: 120, // Sabit yükseklik
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
            Icon(icon, color: color, size: 28),
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
      ),
    );
  }
}