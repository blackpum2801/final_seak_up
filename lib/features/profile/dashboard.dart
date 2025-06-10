import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/provider/dashboard.dart';

enum TimeRange {
  week7(7, '7 ngày'),
  days30(30, '30 ngày'),
  months3(90, '3 tháng'),
  months6(180, '6 tháng'),
  custom(0, 'Tùy chỉnh');

  const TimeRange(this.days, this.label);
  final int days;
  final String label;
}

enum ChartType {
  bar('Cột'),
  line('Đường');

  const ChartType(this.label);
  final String label;
}

class DashboardScreen extends StatefulWidget {
  final String userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Constants
  static const double _chartHeight = 250.0;
  static const double _defaultMaxY = 5.0;
  static const int _chartPadding = 2;

  // Text constants
  static const String _dashboardTitle = 'Thống kê học tập';
  static const String _completedLessonsLabel = 'Bài hoàn thành';
  static const String _totalScoreLabel = 'Tổng điểm';
  static const String _progressTitle = 'Tiến độ học tập';
  static const String _insightsTitle = 'Thống kê chi tiết';
  static const String _averageLabel = 'Trung bình/ngày';
  static const String _bestDayLabel = 'Ngày tích cực nhất';
  static const String _lessonUnit = 'bài';
  static const String _lessonsTooltip = 'bài học';

  // Weekday constants
  static const List<String> _weekdays = [
    'CN',
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7'
  ];

  // State variables
  TimeRange _selectedTimeRange = TimeRange.week7;
  ChartType _selectedChartType = ChartType.bar;
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildLoadingScreen();
        }

        final chartData = _processChartData(provider);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: _buildBody(provider, chartData),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        _dashboardTitle,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildBody(DashboardProvider provider, ChartData chartData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(provider),
          const SizedBox(height: 24),
          _buildTimeRangeSelector(),
          const SizedBox(height: 16),
          _buildChartTypeSelector(),
          const SizedBox(height: 16),
          _buildChart(chartData),
          const SizedBox(height: 20),
          if (chartData.counts.isNotEmpty) _buildInsights(chartData.counts),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khoảng thời gian',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TimeRange.values.map((range) {
              final isSelected = _selectedTimeRange == range;
              return GestureDetector(
                onTap: () => _onTimeRangeSelected(range),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[600] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    range.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedTimeRange == TimeRange.custom) ...[
            const SizedBox(height: 12),
            _buildCustomDatePicker(),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomDatePicker() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range),
            label: Text(
              _customDateRange != null
                  ? '${_formatDate2(_customDateRange!.start)} - ${_formatDate2(_customDateRange!.end)}'
                  : 'Chọn khoảng thời gian',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loại biểu đồ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ChartType.values.map((type) {
              final isSelected = _selectedChartType == type;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedChartType = type),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == ChartType.bar
                              ? Icons.bar_chart
                              : Icons.show_chart,
                          color: isSelected ? Colors.white : Colors.black87,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.label,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(DashboardProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: _completedLessonsLabel,
            value: '${provider.completedLessons}',
            icon: Icons.check_circle,
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shadowColor: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: _totalScoreLabel,
            value: '${provider.totalScore}',
            icon: Icons.star,
            gradient: LinearGradient(
              colors: [Colors.orange[400]!, Colors.orange[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shadowColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildChart(ChartData chartData) {
    if (chartData.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(),
          const SizedBox(height: 20),
          SizedBox(
            height: _chartHeight,
            child: _selectedChartType == ChartType.bar
                ? _buildBarChart(chartData)
                : _buildLineChart(chartData),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(ChartData chartData) {
    return LineChart(
      LineChartData(
        gridData: _buildGridData(),
        titlesData: _buildTitlesData(chartData),
        borderData: _buildBorderData(),
        minX: 0,
        maxX: (chartData.counts.length - 1).toDouble(),
        minY: 0,
        maxY: _calculateMaxY(chartData.counts),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              chartData.counts.length,
              (i) => FlSpot(i.toDouble(), chartData.counts[i].toDouble()),
            ),
            isCurved: true,
            curveSmoothness: 0.3,
            color: Colors.blue[600],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue[600]!,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue[600]!.withOpacity(0.2),
                  Colors.blue[600]!.withOpacity(0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.black87,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                return LineTooltipItem(
                  '${chartData.counts[index]} $_lessonsTooltip\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: _formatDate(chartData.days[index]),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildChartHeader(),
          const SizedBox(height: 40),
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu học tập',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChartHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$_progressTitle (${_getTimeRangeText()})',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(ChartData chartData) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: _calculateMaxY(chartData.counts),
        barTouchData: _buildTouchData(chartData),
        titlesData: _buildTitlesData(chartData),
        gridData: _buildGridData(),
        borderData: _buildBorderData(),
        barGroups: _buildBarGroups(chartData),
      ),
    );
  }

  BarTouchData _buildTouchData(ChartData chartData) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.black87,
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            '${chartData.counts[group.x]} $_lessonsTooltip\n',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            children: [
              TextSpan(
                text: _formatDate(chartData.days[group.x]),
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(ChartData chartData) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: _getBottomTitleInterval(chartData.days.length),
          getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx >= 0 && idx < chartData.days.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _getFormattedLabel(chartData.days[idx]),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 1,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey[200]!,
          strokeWidth: 1,
        );
      },
    );
  }

  FlBorderData _buildBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        left: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(ChartData chartData) {
    return List.generate(chartData.counts.length, (i) {
      final isToday = _isToday(chartData.days[i]);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: chartData.counts[i].toDouble(),
            width: _getBarWidth(chartData.counts.length),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            gradient: _getBarGradient(isToday),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
    required Color shadowColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(List<int> counts) {
    final insights = _calculateInsights(counts);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightsHeader(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  _averageLabel,
                  '${insights.average} $_lessonUnit',
                  Icons.trending_up,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildInsightItem(
                  _bestDayLabel,
                  insights.bestDay,
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsHeader() {
    return Row(
      children: [
        Icon(Icons.insights, color: Colors.purple[600]),
        const SizedBox(width: 8),
        Text(
          _insightsTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
      String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Event handlers
  void _onTimeRangeSelected(TimeRange range) {
    setState(() {
      _selectedTimeRange = range;
      if (range != TimeRange.custom) {
        _customDateRange = null;
      }
    });
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
    }
  }

  // Helper methods
  ChartData _processChartData(DashboardProvider provider) {
    final sortedDays = provider.lessonsPerDay.keys.toList()..sort();

    List<String> filteredDays;
    if (_selectedTimeRange == TimeRange.custom && _customDateRange != null) {
      filteredDays = _getCustomRangeDays(sortedDays);
    } else {
      filteredDays = _getLastNDays(sortedDays, _selectedTimeRange.days);
    }

    final counts =
        filteredDays.map((d) => provider.lessonsPerDay[d] ?? 0).toList();
    return ChartData(days: filteredDays, counts: counts);
  }

  List<String> _getCustomRangeDays(List<String> sortedDays) {
    if (_customDateRange == null) return [];

    return sortedDays.where((dayStr) {
      try {
        final day = DateTime.parse(dayStr);
        return day.isAfter(
                _customDateRange!.start.subtract(const Duration(days: 1))) &&
            day.isBefore(_customDateRange!.end.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<String> _getLastNDays(List<String> sortedDays, int n) {
    if (sortedDays.length <= n) return sortedDays;
    return sortedDays.sublist(sortedDays.length - n);
  }

  double _calculateMaxY(List<int> counts) {
    if (counts.isEmpty) return _defaultMaxY;
    final maxValue = counts.reduce((a, b) => a > b ? a : b);
    return (maxValue + _chartPadding).toDouble();
  }

  bool _isToday(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
      return false;
    }
  }

  double _getBarWidth(int dataLength) {
    if (dataLength > 30) return 8;
    if (dataLength > 14) return 16;
    return 24;
  }

  double _getBottomTitleInterval(int dataLength) {
    if (dataLength > 60) return 10;
    if (dataLength > 30) return 5;
    if (dataLength > 14) return 2;
    return 1;
  }

  String _getFormattedLabel(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      if (_selectedTimeRange.days <= 7) {
        return _weekdays[date.weekday % 7];
      } else if (_selectedTimeRange.days <= 30) {
        return '${date.day}/${date.month}';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return dateStr.length >= 5 ? dateStr.substring(5) : dateStr;
    }
  }

  String _getTimeRangeText() {
    if (_selectedTimeRange == TimeRange.custom && _customDateRange != null) {
      return '${_formatDate2(_customDateRange!.start)} - ${_formatDate2(_customDateRange!.end)}';
    }
    return _selectedTimeRange.label;
  }

  LinearGradient _getBarGradient(bool isToday) {
    return LinearGradient(
      colors: isToday
          ? [Colors.blue[400]!, Colors.blue[600]!]
          : [Colors.green[300]!, Colors.green[500]!],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  InsightsData _calculateInsights(List<int> counts) {
    final total = counts.fold(0, (sum, count) => sum + count);
    final average = (total / counts.length).toStringAsFixed(1);
    final maxDay = counts.indexOf(counts.reduce((a, b) => a > b ? a : b));
    final bestDay =
        _getWeekdayShort('2024-${(maxDay + 1).toString().padLeft(2, '0')}-01');

    return InsightsData(average: average, bestDay: bestDay);
  }

  String _getWeekdayShort(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return _weekdays[date.weekday % 7];
    } catch (e) {
      return dateStr.length >= 5 ? dateStr.substring(5) : dateStr;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}';
    } catch (e) {
      return dateStr.length >= 5 ? dateStr.substring(5) : dateStr;
    }
  }

  String _formatDate2(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Data classes
class ChartData {
  final List<String> days;
  final List<int> counts;

  ChartData({required this.days, required this.counts});

  bool get isEmpty => counts.isEmpty;
}

class InsightsData {
  final String average;
  final String bestDay;

  InsightsData({required this.average, required this.bestDay});
}
