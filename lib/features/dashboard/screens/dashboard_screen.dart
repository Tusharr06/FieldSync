import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../submissions/controller/submission_controller.dart';
import '../../submissions/models/submission_model.dart';
import '../../forms/controller/form_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionListProvider);
    final formsAsync = ref.watch(formListProvider);
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: submissionsAsync.when(
          data: (submissions) {
            return formsAsync.when(
              data: (forms) {
                // Analytics Logic
                final pendingCount = submissions.where((s) => s.syncStatus == SyncStatus.pending).length;
                final syncedCount = submissions.where((s) => s.syncStatus == SyncStatus.synced).length;
                
                // Sort submissions by date (newest first)
                final recentSubmissions = List<SubmissionModel>.from(submissions)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, d MMM').format(now).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Overview',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  letterSpacing: -1.0,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[200]!, width: 2),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 24,
                              child: Text(
                                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Key Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'Total Submissions',
                              value: submissions.length.toString(),
                              color: Colors.black,
                              textColor: Colors.white,
                              icon: Icons.folder_open,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _SmallStatCard(
                                  label: 'Synced',
                                  value: syncedCount.toString(),
                                  color: const Color(0xFFE3F2FD),
                                  textColor: const Color(0xFF1565C0),
                                  icon: Icons.check_circle_outline,
                                ),
                                const SizedBox(height: 16),
                                _SmallStatCard(
                                  label: 'Pending',
                                  value: pendingCount.toString(),
                                  color: const Color(0xFFFFF3E0),
                                  textColor: const Color(0xFFEF6C00),
                                  icon: Icons.cloud_upload_outlined,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Chart Section
                      const Text(
                        'Weekly Activity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 220,
                        padding: const EdgeInsets.only(top: 24, bottom: 8, left: 8, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _SubmissionBarChart(submissions: submissions),
                      ),

                      const SizedBox(height: 32),

                      // Recent Activity Section
                      if (recentSubmissions.isNotEmpty) ...[
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Items',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentSubmissions.take(3).length,
                          itemBuilder: (context, index) {
                            final submission = recentSubmissions[index];
                            final form = forms.firstWhere((f) => f.id == submission.formId, orElse: () => forms.first);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[100]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.description_outlined, color: Colors.black87),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          form.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM d, h:mm a').format(submission.createdAt),
                                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _StatusBadge(status: submission.syncStatus),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const SizedBox(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: textColor, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor.withValues(alpha: 0.8),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Icon(icon, color: textColor, size: 24),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SyncStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    
    switch (status) {
      case SyncStatus.synced:
        color = Colors.green;
        text = 'Synced';
        break;
      case SyncStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case SyncStatus.draft:
        color = Colors.grey;
        text = 'Draft';
        break;
      case SyncStatus.failed:
        color = Colors.red;
        text = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}

class _SubmissionBarChart extends StatelessWidget {
  final List<SubmissionModel> submissions;

  const _SubmissionBarChart({required this.submissions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final Map<int, int> days = {};

    for (int i = 0; i < 7; i++) {
       days[i] = 0; 
    }

    for (var s in submissions) {
       final date = s.createdAt; 
       final sDate = DateTime(date.year, date.month, date.day);
       final diff = today.difference(sDate).inDays;
       if (diff >= 0 && diff < 7) {
          final index = 6 - diff; 
          days[index] = (days[index] ?? 0) + 1;
       }
    }

    double maxY = 0;
    days.forEach((_, v) { if (v > maxY) maxY = v.toDouble(); });
    if (maxY == 0) maxY = 5; 

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY + 1,
        barTouchData: BarTouchData(
           enabled: true,
           touchTooltipData: BarTouchTooltipData(
             getTooltipColor: (_) => Colors.black,
             tooltipPadding: const EdgeInsets.all(8),
             tooltipMargin: 8,
             getTooltipItem: (group, groupIndex, rod, rodIndex) {
               return BarTooltipItem(
                 rod.toY.round().toString(),
                 const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
               );
             },
           ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final dayDate = today.subtract(Duration(days: 6 - index));
                final label = DateFormat('E').format(dayDate); 
                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    label.substring(0, 1),
                    style: TextStyle(
                      color: index == 6 ? Colors.black : Colors.grey[400], 
                      fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          for (int i = 0; i < 7; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i]?.toDouble() ?? 0,
                  color: i == 6 ? Colors.black : Colors.grey[300], // Highlight today
                  width: 20, // Thicker bars
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                     show: true,
                     toY: maxY + 1,
                     color: Colors.grey[100],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
