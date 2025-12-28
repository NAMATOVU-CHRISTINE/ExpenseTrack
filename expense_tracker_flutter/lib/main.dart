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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
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
    await prefs.setString('expenses', jsonEncode(expenses.map((e) => e.toJson()).toList()));
    await prefs.setString('budgets', jsonEncode(budgets.map((b) => b.toJson()).toList()));
    await prefs.setDouble('monthlyIncome', monthlyIncome);
    await prefs.setDouble('savingsTarget', savingsTarget);
    await prefs.setDouble('currentSavings', currentSavings);
  }

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);
  double get thisMonthExpenses {
    final now = DateTime.now();
    return expenses.where((e) => e.date.month == now.month && e.date.year == now.year)
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
      final spent = expenses.where((e) => e.category == category)
          .fold(0.0, (sum, e) => sum + e.amount);
      final percentage = (spent / budget.limit) * 100;
      if (percentage >= 80) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Warning: You\'ve used ${percentage.toStringAsFixed(0)}% of your $category budget!'),
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
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Expenses'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Budgets'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
