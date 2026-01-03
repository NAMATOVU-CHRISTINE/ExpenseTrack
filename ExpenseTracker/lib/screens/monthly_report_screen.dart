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
    return widget.incomeSources.where((i) {
      final date = i['date'] is DateTime
          ? i['date']
          : DateTime.parse(i['date']);
      return date.year == selectedMonth.year &&
          date.month == selectedMonth.month;
    }).toList();
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
      appBar: AppBar(
        title: const Text(
          'Monthly Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Month Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    selectedMonth = DateTime(
                      selectedMonth.year,
                      selectedMonth.month - 1,
                    );
                  });
                },
              ),
              Text(
                '${getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
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
          const SizedBox(height: 16),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Income',
                  amount: totalIncome,
                  color: Colors.green,
                  currency: widget.currency,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Expenses',
                  amount: totalExpenses,
                  color: Colors.red,
                  currency: widget.currency,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Balance',
            amount: balance,
            color: balance >= 0 ? Colors.green : Colors.red,
            currency: widget.currency,
          ),
          const SizedBox(height: 24),

          // Expenses by Category
          if (expensesByCategory.isNotEmpty) ...[
            const Text(
              'Expenses by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: expensesByCategory.entries.map((entry) {
                    final percentage = (entry.value / totalExpenses * 100)
                        .toStringAsFixed(1);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: entry.value / totalExpenses,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                _getCategoryColor(entry.key),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(entry.value),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Financial Analysis
          const Text(
            'Financial Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnalysisRow(
                    label: 'Savings Rate',
                    value: totalIncome > 0
                        ? '${((balance / totalIncome) * 100).toStringAsFixed(1)}%'
                        : 'N/A',
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _AnalysisRow(
                    label: 'Expense Ratio',
                    value: totalIncome > 0
                        ? '${((totalExpenses / totalIncome) * 100).toStringAsFixed(1)}%'
                        : 'N/A',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _AnalysisRow(
                    label: 'Average Daily Expense',
                    value: formatCurrency(totalExpenses / 30),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _AnalysisRow(
                    label: 'Largest Expense Category',
                    value: expensesByCategory.isEmpty
                        ? 'N/A'
                        : expensesByCategory.entries
                              .reduce((a, b) => a.value > b.value ? a : b)
                              .key,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Transactions
          if (monthlyExpenses.isNotEmpty) ...[
            const Text(
              'Transactions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...monthlyExpenses.take(5).map((expense) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(expense['category']),
                    child: Icon(
                      _getCategoryIcon(expense['category']),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(expense['title'] ?? 'Expense'),
                  subtitle: Text(expense['category'] ?? 'General'),
                  trailing: Text(
                    formatCurrency(expense['amount']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],

          const SizedBox(height: 100),
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
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      '$currency $formatted',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
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
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
