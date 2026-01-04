
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityStatsChart extends StatefulWidget {
  final int articlesRead;
  final int verificationsCount;
  final int challengesCompleted;
  final int totalXP;

  const ActivityStatsChart({
    super.key,
    required this.articlesRead,
    required this.verificationsCount,
    required this.challengesCompleted,
    required this.totalXP,
  });

  @override
  State<ActivityStatsChart> createState() => _ActivityStatsChartState();
}

class _ActivityStatsChartState extends State<ActivityStatsChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _hasData =>
      widget.articlesRead > 0 ||
      widget.verificationsCount > 0 ||
      widget.challengesCompleted > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D2D44).withOpacity(0.8),
            const Color(0xFF1A1A2E).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Aktivitas Kamu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.totalXP} XP',
                  style: const TextStyle(
                    color: Color(0xFF4ECDC4),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Chart or Empty State
          _hasData ? _buildChart() : _buildEmptyState(),

          const SizedBox(height: 20),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return ListenableBuilder(
      listenable: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 180,
          child: Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: _buildSections(),
                  ),
                ),
              ),
              
              // Stats Detail
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItem(
                      'Total Aktivitas',
                      '${widget.articlesRead + widget.verificationsCount + widget.challengesCompleted}',
                      const Color(0xFF4ECDC4),
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      'Paling Aktif',
                      _getMostActiveType(),
                      _getMostActiveColor(),
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

  List<PieChartSectionData> _buildSections() {
    final total = widget.articlesRead +
        widget.verificationsCount +
        widget.challengesCompleted;
    
    if (total == 0) return [];

    return [
      // Articles Read
      PieChartSectionData(
        color: const Color(0xFF5B9BD5),
        value: widget.articlesRead.toDouble(),
        title: _touchedIndex == 0 ? '${widget.articlesRead}' : '',
        radius: _touchedIndex == 0 ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _touchedIndex == 0
            ? _buildBadge(Icons.article, const Color(0xFF5B9BD5))
            : null,
        badgePositionPercentageOffset: 1.2,
      ),
      // Verifications
      PieChartSectionData(
        color: const Color(0xFF4ECDC4),
        value: widget.verificationsCount.toDouble(),
        title: _touchedIndex == 1 ? '${widget.verificationsCount}' : '',
        radius: _touchedIndex == 1 ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _touchedIndex == 1
            ? _buildBadge(Icons.verified, const Color(0xFF4ECDC4))
            : null,
        badgePositionPercentageOffset: 1.2,
      ),
      // Challenges
      PieChartSectionData(
        color: const Color(0xFFFFD93D),
        value: widget.challengesCompleted.toDouble(),
        title: _touchedIndex == 2 ? '${widget.challengesCompleted}' : '',
        radius: _touchedIndex == 2 ? 60 : 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        badgeWidget: _touchedIndex == 2
            ? _buildBadge(Icons.emoji_events, const Color(0xFFFFD93D))
            : null,
        badgePositionPercentageOffset: 1.2,
      ),
    ];
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800]!.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: Colors.grey[600],
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada aktivitas',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai baca artikel, verifikasi, atau challenge!',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          'Artikel',
          const Color(0xFF5B9BD5),
          widget.articlesRead,
        ),
        _buildLegendItem(
          'Verifikasi',
          const Color(0xFF4ECDC4),
          widget.verificationsCount,
        ),
        _buildLegendItem(
          'Challenge',
          const Color(0xFFFFD93D),
          widget.challengesCompleted,
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($value)',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getMostActiveType() {
    final max = [
      widget.articlesRead,
      widget.verificationsCount,
      widget.challengesCompleted
    ].reduce((a, b) => a > b ? a : b);

    if (max == 0) return '-';
    if (max == widget.articlesRead) return 'Membaca';
    if (max == widget.verificationsCount) return 'Verifikasi';
    return 'Challenge';
  }

  Color _getMostActiveColor() {
    final max = [
      widget.articlesRead,
      widget.verificationsCount,
      widget.challengesCompleted
    ].reduce((a, b) => a > b ? a : b);

    if (max == 0) return Colors.grey;
    if (max == widget.articlesRead) return const Color(0xFF5B9BD5);
    if (max == widget.verificationsCount) return const Color(0xFF4ECDC4);
    return const Color(0xFFFFD93D);
  }
}
