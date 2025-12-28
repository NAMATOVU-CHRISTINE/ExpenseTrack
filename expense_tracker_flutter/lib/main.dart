import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black87,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Currency formatter for UGX
String formatUGX(double amount) {
  final formatter = NumberFormat('#,###', 'en_US');
  return 'UGX ${formatter.format(amount.round())}';
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final bool isRecurring;
  final List<String> tags;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.isRecurring = false,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'notes': notes,
    'isRecurring': isRecurring,
    'tags': tags,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    description: json['description'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    date: DateTime.parse(json['date']),
    notes: json['notes'],
    isRecurring: json['isRecurring'] ?? false,
    tags: List<String>.from(json['tags'] ?? []),
  );
}

class Budget {
  final String id;
  final String category;
  final double limit;
  final DateTime month;
  final bool notifications;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.month,
    this.notifications = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'limit': limit,
    'month': month.toIso8601String(),
    'notifications': notifications,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    category: json['category'],
    limit: json['limit'].toDouble(),
    month: DateTime.parse(json['month']),
    notifications: json['notifications'] ?? true,
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Expense> expenses = [];
  List<Budget> budgets = [];
  double monthlyIncome = 5000000; // 5M UGX default
  double savingsTarget = 1000000; // 1M UGX default
  double currentSavings = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load expenses
    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> decoded = jsonDecode(expensesJson);
      expenses = decoded.map((e) => Expense.fromJson(e)).toList();
    }

    // Load budgets
    final budgetsJson = prefs.getString('budgets');
    if (budgetsJson != null) {
      final List<dynamic> decoded = jsonDecode(budgetsJson);
      budgets = decoded.map((b) => Budget.fromJson(b)).toList();
    }

    // Load settings
    monthlyIncome = prefs.getDouble('monthlyIncome') ?? 5000000;
    savingsTarget = prefs.getDouble('savingsTarget') ?? 1000000;
    currentSavings = prefs.getDouble('currentSavings') ?? 0;

    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'expenses',
      jsonEncode(expenses.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      'budgets',
      jsonEncode(budgets.map((b) => b.toJson()).toList()),
    );
    await prefs.setDouble('monthlyIncome', monthlyIncome);
    await prefs.setDouble('savingsTarget', savingsTarget);
    await prefs.setDouble('currentSavings', currentSavings);
  }

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);
  double get thisMonthExpenses {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get disposableIncome => monthlyIncome - thisMonthExpenses;

  void _addExpense(Expense expense) {
    setState(() => expenses.insert(0, expense));
    _saveData();
    _checkBudgetAlerts(expense.category);
  }

  void _deleteExpense(String id) {
    setState(() => expenses.removeWhere((e) => e.id == id));
    _saveData();
  }

  void _checkBudgetAlerts(String category) {
    final budget = budgets.where((b) => b.category == category).firstOrNull;
    if (budget != null && budget.notifications) {
      final spent = expenses
          .where((e) => e.category == category)
          .fold(0.0, (sum, e) => sum + e.amount);
      final percentage = (spent / budget.limit) * 100;
      if (percentage >= 80) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Warning: You\'ve used ${percentage.toStringAsFixed(0)}% of your $category budget!',
            ),
            backgroundColor: percentage >= 100 ? Colors.red : Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildExpensesList(),
          _buildBudgets(),
          _buildReports(),
          _buildProfile(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context),
        backgroundColor: const Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black87],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expense Tracker',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Personal Finance Manager',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.white,
                              ),
                              onPressed: () => _showNotifications(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Monthly Income',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        formatUGX(monthlyIncome),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'This Month',
                        formatUGX(thisMonthExpenses),
                        Icons.trending_down,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Disposable',
                        formatUGX(disposableIncome),
                        Icons.account_balance_wallet,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Savings',
                        formatUGX(currentSavings),
                        Icons.savings,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Target',
                        formatUGX(savingsTarget),
                        Icons.flag,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                // Savings Progress
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Savings Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: savingsTarget > 0
                              ? (currentSavings / savingsTarget).clamp(0, 1)
                              : 0,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.black,
                          ),
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${((currentSavings / savingsTarget) * 100).toStringAsFixed(1)}% of target',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Expenses
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (expenses.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No expenses yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Text('Tap + to add your first expense'),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...expenses.take(5).map((e) => _buildExpenseItem(e)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteExpense(expense.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(expense.category).withAlpha(30),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category),
              size: 20,
            ),
          ),
          title: Text(
            expense.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.category),
              Text(
                DateFormat('MMM dd, yyyy').format(expense.date),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              if (expense.isRecurring)
                const Chip(
                  label: Text('Recurring', style: TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          trailing: Text(
            formatUGX(expense.amount),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          isThreeLine: true,
          onTap: () => _showExpenseDetails(expense),
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    final groupedExpenses = <String, List<Expense>>{};
    for (var expense in expenses) {
      final key = DateFormat('MMMM yyyy').format(expense.date);
      groupedExpenses.putIfAbsent(key, () => []).add(expense);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        backgroundColor: const Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: expenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses recorded',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedExpenses.length,
              itemBuilder: (context, index) {
                final month = groupedExpenses.keys.elementAt(index);
                final monthExpenses = groupedExpenses[month]!;
                final monthTotal = monthExpenses.fold(
                  0.0,
                  (sum, e) => sum + e.amount,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatUGX(monthTotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...monthExpenses.map((e) => _buildExpenseItem(e)),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildBudgets() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        backgroundColor: const Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(),
          ),
        ],
      ),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets set',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBudgetDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                final spent = expenses
                    .where((e) => e.category == budget.category)
                    .fold(0.0, (sum, e) => sum + e.amount);
                final percentage = (spent / budget.limit * 100).clamp(0, 100);
                final remaining = budget.limit - spent;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getCategoryColor(
                                budget.category,
                              ).withAlpha(30),
                              child: Icon(
                                _getCategoryIcon(budget.category),
                                color: _getCategoryColor(budget.category),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Limit: ${formatUGX(budget.limit)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() => budgets.removeAt(index));
                                _saveData();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            percentage > 80
                                ? Colors.red
                                : percentage > 50
                                ? Colors.orange
                                : Colors.green,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ${formatUGX(spent)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: percentage > 80
                                    ? Colors.red
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Remaining: ${formatUGX(remaining)}',
                          style: TextStyle(
                            color: remaining < 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildReports() {
    final categoryTotals = <String, double>{};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: const Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Card(
              color: const Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Expenses',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatUGX(totalExpenses),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${expenses.length} transactions',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Spending by Category
            const Text(
              'Spending by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (sortedCategories.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No data to display',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              )
            else
              ...sortedCategories.map((entry) {
                final percentage = totalExpenses > 0
                    ? (entry.value / totalExpenses * 100)
                    : 0.0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getCategoryColor(
                                entry.key,
                              ).withAlpha(30),
                              radius: 20,
                              child: Icon(
                                _getCategoryIcon(entry.key),
                                color: _getCategoryColor(entry.key),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatUGX(entry.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            _getCategoryColor(entry.key),
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: const Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'User',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Managing finances since ${DateFormat('MMM yyyy').format(DateTime.now())}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Financial Settings
          const Text(
            'Financial Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.attach_money,
                    color: Colors.black,
                  ),
                  title: const Text('Monthly Income'),
                  subtitle: Text(formatUGX(monthlyIncome)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditIncomeDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.savings, color: Colors.black),
                  title: const Text('Savings Target'),
                  subtitle: Text(formatUGX(savingsTarget)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditSavingsDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.account_balance,
                    color: Colors.black,
                  ),
                  title: const Text('Current Savings'),
                  subtitle: Text(formatUGX(currentSavings)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _showEditCurrentSavingsDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // App Settings
          const Text(
            'App Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.black),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download your expense data'),
                  onTap: () => _exportReport(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('Delete all expenses and budgets'),
                  onTap: () => _showClearAllDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Methods
  void _showAddExpenseDialog(BuildContext context) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = 'Food & Dining';
    bool isRecurring = false;
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add New Expense',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (UGX)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) setModalState(() => selectedDate = date);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recurring Expense'),
                  subtitle: const Text('This expense repeats monthly'),
                  value: isRecurring,
                  onChanged: (value) =>
                      setModalState(() => isRecurring = value),
                ),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (descController.text.isNotEmpty &&
                          amountController.text.isNotEmpty) {
                        final expense = Expense(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          description: descController.text,
                          amount: double.tryParse(amountController.text) ?? 0,
                          category: selectedCategory,
                          date: selectedDate,
                          notes: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                          isRecurring: isRecurring,
                        );
                        _addExpense(expense);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Save Expense',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddBudgetDialog() {
    String selectedCategory = 'Food & Dining';
    final limitController = TextEditingController();
    bool notifications = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setDialogState(() => selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget Limit (UGX)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Enable Alerts'),
                subtitle: const Text('Notify when 80% spent'),
                value: notifications,
                onChanged: (value) =>
                    setDialogState(() => notifications = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (limitController.text.isNotEmpty) {
                  setState(() {
                    budgets.add(
                      Budget(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        category: selectedCategory,
                        limit: double.tryParse(limitController.text) ?? 0,
                        month: DateTime.now(),
                        notifications: notifications,
                      ),
                    );
                  });
                  _saveData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getCategoryColor(
                    expense.category,
                  ).withAlpha(30),
                  radius: 25,
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: _getCategoryColor(expense.category),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        expense.category,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _detailRow('Amount', formatUGX(expense.amount)),
            _detailRow(
              'Date',
              DateFormat('MMMM dd, yyyy').format(expense.date),
            ),
            if (expense.notes != null) _detailRow('Notes', expense.notes!),
            if (expense.isRecurring) _detailRow('Type', 'Recurring Monthly'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteExpense(expense.id);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );

  void _showEditIncomeDialog() {
    final controller = TextEditingController(
      text: monthlyIncome.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Income'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly Income (UGX)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => monthlyIncome =
                    double.tryParse(controller.text) ?? monthlyIncome,
              );
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditSavingsDialog() {
    final controller = TextEditingController(
      text: savingsTarget.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Savings Target'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Savings Target (UGX)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => savingsTarget =
                    double.tryParse(controller.text) ?? savingsTarget,
              );
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditCurrentSavingsDialog() {
    final controller = TextEditingController(
      text: currentSavings.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Current Savings'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Current Savings (UGX)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => currentSavings =
                    double.tryParse(controller.text) ?? currentSavings,
              );
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all your expenses and budgets. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                expenses.clear();
                budgets.clear();
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Expenses'),
        content: const Text('Filter feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Expenses'),
        content: const Text('Search feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No new notifications')));
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  // Categories list
  final List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Groceries',
    'Personal Care',
    'Other',
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills & Utilities':
        return Icons.receipt;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Travel':
        return Icons.flight;
      case 'Groceries':
        return Icons.shopping_cart;
      case 'Personal Care':
        return Icons.spa;
      default:
        return Icons.attach_money;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return Colors.orange;
      case 'Transportation':
        return Colors.blue;
      case 'Shopping':
        return Colors.pink;
      case 'Entertainment':
        return Colors.purple;
      case 'Bills & Utilities':
        return Colors.teal;
      case 'Healthcare':
        return Colors.red;
      case 'Education':
        return Colors.indigo;
      case 'Travel':
        return Colors.cyan;
      case 'Groceries':
        return Colors.green;
      case 'Personal Care':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
