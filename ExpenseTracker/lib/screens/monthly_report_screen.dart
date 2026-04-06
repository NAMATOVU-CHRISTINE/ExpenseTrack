import 'package:flutter/material.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({
    super.key,
    required this.expenses,
    required this.incomeSources,
    required this.currency,
  });

  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> incomeSources;
  final String currency;

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  List<Map<String, dynamic>> getMonthlyExpenses() {
    return widget.expenses.where((e) {
      final date = e['date'] is DateTime
          ? e['date']
          : DateTime.parse(e['date']);
      return date.year == selectedMonth.year &&
          date.month == selectedMonth.month;
    }).toList();
  }

  List<Map<String, dynamic>> getMonthlyIncome() {
    final monthlyIncome = <Map<String, dynamic>>[];
    
    for (var income in widget.incomeSources) {
      final date = income['date'] is DateTime
          ? income['date']
          : DateTime.parse(income['date']);
      final frequency = income['frequency'] as String? ?? 'once';
      
      // For one-time income, only include if it matches the selected month
      if (frequency == 'once') {
        if (date.year == selectedMonth.year &&
            date.month == selectedMonth.month) {
          monthlyIncome.add(income);
        }
      } else {
        // For recurring income, check if it should appear in this month
        final monthsDiff = (selectedMonth.year - date.year) * 12 +
            (selectedMonth.month - date.month);
        
        if (monthsDiff >= 0) {
          bool shouldInclude = false;
          
          if (frequency == 'weekly') {
            // Weekly income appears every month after start date
            shouldInclude = true;
          } else if (frequency == 'monthly') {
            // Monthly income appears every month after start date
            shouldInclude = true;
          } else if (frequency == 'yearly') {
            // Yearly income appears once per year in the same month
            shouldInclude = selectedMonth.month == date.month;
          }
          
          if (shouldInclude) {
            monthlyIncome.add(income);
          }
        }
      }
    }
    
    return monthlyIncome;
  }

  double getTotalExpenses() {
    return getMonthlyExpenses().fold(
      0.0,
      (sum, e) => sum + (e['amount'] as num).toDouble(),
    );
  }

  double getTotalIncome() {
    return getMonthlyIncome().fold(
      0.0,
      (sum, i) => sum + (i['amount'] as num).toDouble(),
    );
  }

  Map<String, double> getExpensesByCategory() {
    final expenses = getMonthlyExpenses();
    final byCategory = <String, double>{};
    for (var expense in expenses) {
      final category = expense['category'] as String;
      byCategory[category] =
          (byCategory[category] ?? 0) + (expense['amount'] as num).toDouble();
    }
    return byCategory;
  }

  String formatCurrency(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '${widget.currency} $formatted';
  }

  String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = getTotalIncome();
    final totalExpenses = getTotalExpenses();
    final balance = totalIncome - totalExpenses;
    final expensesByCategory = getExpensesByCategory();
    final monthlyExpenses = getMonthlyExpenses();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month Selector Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: const Color(0xFF2196F3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(
                        selectedMonth.year,
                        selectedMonth.month - 1,
                      );
                    });
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  '${getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    if (selectedMonth.month < 12 ||
                        selectedMonth.year < DateTime.now().year) {
                      setState(() {
                        selectedMonth = DateTime(
                          selectedMonth.year,
                          selectedMonth.month + 1,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Balance Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  'BALANCE',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(balance),
                  style: TextStyle(
                    color: balance >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          formatCurrency(totalIncome),
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'INCOME',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Text(
                          formatCurrency(totalExpenses),
                          style: TextStyle(
                            color: Colors.red.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'EXPENSES',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Category List
          Expanded(
            child: expensesByCategory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses this month',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: expensesByCategory.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = expensesByCategory.entries.elementAt(index);
                      final percentage = (entry.value / totalExpenses * 100);
                      final color = _getCategoryColor(entry.key);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(
                            _getCategoryIcon(entry.key),
                            color: color,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '${percentage.toStringAsFixed(1)}% of total',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          formatCurrency(entry.value),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    const colors = {
      'Food': Color(0xFFFF6B6B),
      'Transport': Color(0xFF4ECDC4),
      'Shopping': Color(0xFFFFE66D),
      'Bills': Color(0xFF95E1D3),
      'Entertainment': Color(0xFFDDA0DD),
      'Health': Color(0xFF98D8C8),
      'Education': Color(0xFF6C5CE7),
      'Rent': Color(0xFFFF8C42),
      'Utilities': Color(0xFF17A2B8),
      'General': Color(0xFF6C757D),
    };
    return colors[category] ?? colors['General']!;
  }

  IconData _getCategoryIcon(String category) {
    const icons = {
      'Food': Icons.restaurant,
      'Transport': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Bills': Icons.receipt,
      'Entertainment': Icons.movie,
      'Health': Icons.medical_services,
      'Education': Icons.school,
      'Rent': Icons.home,
      'Utilities': Icons.bolt,
      'General': Icons.attach_money,
    };
    return icons[category] ?? icons['General']!;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.currency,
  });

  final String title;
  final double amount;
  final Color color;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              title == 'Income'
                  ? Icons.trending_up
                  : title == 'Expenses'
                  ? Icons.trending_down
                  : Icons.account_balance,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currency $formatted',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
