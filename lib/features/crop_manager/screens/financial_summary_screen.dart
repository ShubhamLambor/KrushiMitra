// lib/features/crop_manager/screens/financial_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/crop_service.dart';

class FinancialSummaryScreen extends StatefulWidget {
  const FinancialSummaryScreen({super.key});

  @override
  State<FinancialSummaryScreen> createState() => _FinancialSummaryScreenState();
}

class _FinancialSummaryScreenState extends State<FinancialSummaryScreen> {
  late Future<Map<String, dynamic>?> _summaryFuture;
  int touchedIndex = -1;

  final List<Color> _chartColors = [
    Colors.green.shade600,
    Colors.blue.shade600,
    Colors.orange.shade600,
    Colors.purple.shade600,
    Colors.teal.shade600,
    Colors.red.shade600,
  ];

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  void _loadSummary() {
    setState(() {
      _summaryFuture = CropService.getExpenseSummary();
    });
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('labour') || lower.contains('labor')) return Icons.people_outline;
    if (lower.contains('fertilizer')) return Icons.science_outlined;
    if (lower.contains('seed')) return Icons.grass_outlined;
    if (lower.contains('pesticide') || lower.contains('chemical')) return Icons.bug_report_outlined;
    if (lower.contains('transport') || lower.contains('shipping')) return Icons.local_shipping_outlined;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Farm Financial Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.green.shade700),
            onPressed: _loadSummary,
            tooltip: 'Refresh Analytics',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Failed to load financial analytics.', style: TextStyle(color: Colors.grey)));
          }

          final data = snapshot.data!;
          final double totalExpense = double.tryParse(data['grand_total'].toString()) ?? 0.0;
          final breakdown = data['breakdown'] as List<dynamic>;
          final double totalRevenue = double.tryParse(data['total_revenue']?.toString() ?? '0.0') ?? 0.0;
          final double profit = totalRevenue - totalExpense;

          return RefreshIndicator(
            color: Colors.green,
            onRefresh: () async => _loadSummary(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Modern Net Balance Card with Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: profit >= 0
                            ? [Colors.green.shade700, Colors.green.shade900]
                            : [Colors.red.shade700, Colors.red.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (profit >= 0 ? Colors.green : Colors.red).withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Total Net Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹ ${profit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profit >= 0 ? 'Profitable Harvest Period' : 'Expenses outweigh earnings',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Revenue & Expense Modern Summary Boxes
                  Row(
                    children: [
                      Expanded(child: _buildSummaryBox('Total Revenue', totalRevenue, Colors.blue.shade700, Icons.trending_up)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryBox('Total Expense', totalExpense, Colors.orange.shade800, Icons.trending_down)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // 3. Visual Breakdown Section Header
                  const Text('Visual Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  _buildChartCard(totalExpense, breakdown),
                  const SizedBox(height: 28),

                  // 4. Expense Breakdown List Header
                  const Text('Expense Breakdown by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  if (breakdown.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(child: Text('No expenses recorded yet.', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: breakdown.length,
                      itemBuilder: (context, index) {
                        final item = breakdown[index];
                        final categoryName = item['category'] ?? 'Other';
                        final amount = double.tryParse(item['total_amount'].toString()) ?? 0.0;

                        return _buildExpenseRow(
                          categoryName,
                          amount,
                          _getCategoryIcon(categoryName),
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Widget Builders & Helpers ---

  Widget _buildChartCard(double totalExpense, List<dynamic> breakdown) {
    if (totalExpense == 0 || breakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(child: Text("No expenses logged for charting yet.", style: TextStyle(color: Colors.grey))),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 45,
                  sections: _getDynamicSections(breakdown, totalExpense),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: List.generate(breakdown.length, (index) {
                final item = breakdown[index];
                final categoryName = item['category'] ?? 'Other';
                return _buildLegend(_chartColors[index % _chartColors.length], categoryName);
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getDynamicSections(List<dynamic> breakdown, double totalExpense) {
    return List.generate(breakdown.length, (i) {
      final isTouched = i == touchedIndex;
      final item = breakdown[i];
      final amount = double.tryParse(item['total_amount'].toString()) ?? 0.0;
      final percentage = (amount / totalExpense) * 100;

      return PieChartSectionData(
        color: _chartColors[i % _chartColors.length],
        value: amount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: isTouched ? 55.0 : 45.0,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16.0 : 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSummaryBox(String title, double amount, Color accentColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseRow(String category, double amount, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.green.shade700, size: 20),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: Text(
          '₹ ${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}