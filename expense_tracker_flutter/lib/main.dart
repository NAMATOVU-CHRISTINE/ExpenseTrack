import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 8,
          indicatorColor: Colors.black.withOpacity(0.1),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              );
            }
            return TextStyle(fontSize: 12, color: Colors.grey.shade600);
          }),
        ),
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black54,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ==================== MODELS ====================

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final String? notes;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date,
    'notes': notes,
  };
  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    date: json['date'],
    notes: json['notes'],
  );
}

class Budget {
  final String id;
  final String category;
  final double limit;
  double spent;

  Budget({
    String? id,
    required this.category,
    required this.limit,
    this.spent = 0,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'limit': limit,
    'spent': spent,
  };
  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    category: json['category'],
    limit: json['limit'].toDouble(),
    spent: json['spent']?.toDouble() ?? 0,
  );

  double get progress => limit > 0 ? (spent / limit).clamp(0, 1.5) : 0;
  double get remaining => limit - spent;
  bool get isOverBudget => spent > limit;
}

class IncomeSource {
  final String id;
  final String name;
  final double amount;
  final String frequency;

  IncomeSource({
    String? id,
    required this.name,
    required this.amount,
    required this.frequency,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'frequency': frequency,
  };
  factory IncomeSource.fromJson(Map<String, dynamic> json) => IncomeSource(
    id: json['id'],
    name: json['name'],
    amount: json['amount'].toDouble(),
    frequency: json['frequency'],
  );
}

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final String targetDate;

  SavingsGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate,
  };
  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    name: json['name'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount']?.toDouble() ?? 0,
    targetDate: json['targetDate'],
  );

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
}

class RecurringBill {
  final String id;
  final String name;
  final double amount;
  final String dueDate;
  final String frequency;
  bool isPaid;

  RecurringBill({
    String? id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.frequency,
    this.isPaid = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'dueDate': dueDate,
    'frequency': frequency,
    'isPaid': isPaid,
  };
  factory RecurringBill.fromJson(Map<String, dynamic> json) => RecurringBill(
    id: json['id'],
    name: json['name'],
    amount: json['amount'].toDouble(),
    dueDate: json['dueDate'],
    frequency: json['frequency'],
    isPaid: json['isPaid'] ?? false,
  );
}

// ==================== DATA SERVICE ====================

class DataService {
  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<List<Expense>> getExpenses() async {
    final prefs = await _prefs;
    final data = prefs.getString('expenses') ?? '[]';
    return (json.decode(data) as List).map((e) => Expense.fromJson(e)).toList();
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await _prefs;
    await prefs.setString(
      'expenses',
      json.encode(expenses.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<Budget>> getBudgets() async {
    final prefs = await _prefs;
    final data = prefs.getString('budgets') ?? '[]';
    return (json.decode(data) as List).map((b) => Budget.fromJson(b)).toList();
  }

  static Future<void> saveBudgets(List<Budget> budgets) async {
    final prefs = await _prefs;
    await prefs.setString(
      'budgets',
      json.encode(budgets.map((b) => b.toJson()).toList()),
    );
  }

  static Future<List<IncomeSource>> getIncomeSources() async {
    final prefs = await _prefs;
    final data = prefs.getString('incomeSources') ?? '[]';
    return (json.decode(data) as List)
        .map((i) => IncomeSource.fromJson(i))
        .toList();
  }

  static Future<void> saveIncomeSources(List<IncomeSource> sources) async {
    final prefs = await _prefs;
    await prefs.setString(
      'incomeSources',
      json.encode(sources.map((i) => i.toJson()).toList()),
    );
  }

  static Future<List<SavingsGoal>> getSavingsGoals() async {
    final prefs = await _prefs;
    final data = prefs.getString('savingsGoals') ?? '[]';
    return (json.decode(data) as List)
        .map((s) => SavingsGoal.fromJson(s))
        .toList();
  }

  static Future<void> saveSavingsGoals(List<SavingsGoal> goals) async {
    final prefs = await _prefs;
    await prefs.setString(
      'savingsGoals',
      json.encode(goals.map((s) => s.toJson()).toList()),
    );
  }

  static Future<List<RecurringBill>> getRecurringBills() async {
    final prefs = await _prefs;
    final data = prefs.getString('recurringBills') ?? '[]';
    return (json.decode(data) as List)
        .map((b) => RecurringBill.fromJson(b))
        .toList();
  }

  static Future<void> saveRecurringBills(List<RecurringBill> bills) async {
    final prefs = await _prefs;
    await prefs.setString(
      'recurringBills',
      json.encode(bills.map((b) => b.toJson()).toList()),
    );
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await _prefs;
    return {
      'monthlyIncome': prefs.getDouble('monthlyIncome') ?? 0,
      'savingsTarget': prefs.getDouble('savingsTarget') ?? 0,
      'currentSavings': prefs.getDouble('currentSavings') ?? 0,
    };
  }

  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await _prefs;
    await prefs.setDouble('monthlyIncome', profile['monthlyIncome'] ?? 0);
    await prefs.setDouble('savingsTarget', profile['savingsTarget'] ?? 0);
    await prefs.setDouble('currentSavings', profile['currentSavings'] ?? 0);
  }
}

// ==================== UTILITIES ====================

String formatNumber(double num) => num.toStringAsFixed(
  0,
).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
String monthName(int month) => [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];

IconData getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Icons.restaurant;
    case 'transport':
      return Icons.directions_car;
    case 'shopping':
      return Icons.shopping_bag;
    case 'bills':
      return Icons.receipt;
    case 'entertainment':
      return Icons.movie;
    case 'health':
      return Icons.medical_services;
    case 'education':
      return Icons.school;
    case 'rent':
      return Icons.home;
    case 'utilities':
      return Icons.bolt;
    default:
      return Icons.attach_money;
  }
}

// ==================== HOME PAGE ====================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Expense> expenses = [];
  List<Budget> budgets = [];
  List<IncomeSource> incomeSources = [];
  List<SavingsGoal> savingsGoals = [];
  List<RecurringBill> recurringBills = [];
  Map<String, dynamic> profile = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    expenses = await DataService.getExpenses();
    budgets = await DataService.getBudgets();
    incomeSources = await DataService.getIncomeSources();
    savingsGoals = await DataService.getSavingsGoals();
    recurringBills = await DataService.getRecurringBills();
    profile = await DataService.getProfile();
    _recalculateBudgetSpent();
    setState(() => _isLoading = false);
  }

  void _recalculateBudgetSpent() {
    for (var budget in budgets) {
      budget.spent = expenses
          .where((e) => e.category == budget.category)
          .fold(0.0, (sum, e) => sum + e.amount);
    }
  }

  void _addExpense(Expense expense) {
    setState(() {
      expenses.insert(0, expense);
      _recalculateBudgetSpent();
    });
    DataService.saveExpenses(expenses);
    DataService.saveBudgets(budgets);
  }

  void _deleteExpense(String id) {
    setState(() {
      expenses.removeWhere((e) => e.id == id);
      _recalculateBudgetSpent();
    });
    DataService.saveExpenses(expenses);
    DataService.saveBudgets(budgets);
  }

  void _addBudget(Budget budget) {
    setState(() => budgets.add(budget));
    DataService.saveBudgets(budgets);
  }

  void _deleteBudget(String id) {
    setState(() => budgets.removeWhere((b) => b.id == id));
    DataService.saveBudgets(budgets);
  }

  void _addIncomeSource(IncomeSource source) {
    setState(() => incomeSources.add(source));
    DataService.saveIncomeSources(incomeSources);
  }

  void _deleteIncomeSource(String id) {
    setState(() => incomeSources.removeWhere((i) => i.id == id));
    DataService.saveIncomeSources(incomeSources);
  }

  void _addSavingsGoal(SavingsGoal goal) {
    setState(() => savingsGoals.add(goal));
    DataService.saveSavingsGoals(savingsGoals);
  }

  void _updateSavingsGoal(String id, double amount) {
    setState(() {
      final index = savingsGoals.indexWhere((g) => g.id == id);
      if (index != -1) savingsGoals[index].currentAmount += amount;
    });
    DataService.saveSavingsGoals(savingsGoals);
  }

  void _deleteSavingsGoal(String id) {
    setState(() => savingsGoals.removeWhere((g) => g.id == id));
    DataService.saveSavingsGoals(savingsGoals);
  }

  void _addRecurringBill(RecurringBill bill) {
    setState(() => recurringBills.add(bill));
    DataService.saveRecurringBills(recurringBills);
  }

  void _toggleBillPaid(String id) {
    setState(() {
      final index = recurringBills.indexWhere((b) => b.id == id);
      if (index != -1)
        recurringBills[index].isPaid = !recurringBills[index].isPaid;
    });
    DataService.saveRecurringBills(recurringBills);
  }

  void _deleteRecurringBill(String id) {
    setState(() => recurringBills.removeWhere((b) => b.id == id));
    DataService.saveRecurringBills(recurringBills);
  }

  void _updateProfile(Map<String, dynamic> newProfile) {
    setState(() => profile = newProfile);
    DataService.saveProfile(profile);
  }

  double get totalExpenses => expenses.fold(0, (sum, e) => sum + e.amount);
  double get totalBudget => budgets.fold(0, (sum, b) => sum + b.limit);
  double get totalSpent => budgets.fold(0, (sum, b) => sum + b.spent);
  double get totalIncome => incomeSources.fold(0, (sum, i) => sum + i.amount);
  double get unpaidBills => recurringBills
      .where((b) => !b.isPaid)
      .fold(0, (sum, b) => sum + b.amount);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(
            expenses: expenses,
            budgets: budgets,
            incomeSources: incomeSources,
            savingsGoals: savingsGoals,
            recurringBills: recurringBills,
            profile: profile,
            totalExpenses: totalExpenses,
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            totalIncome: totalIncome,
            unpaidBills: unpaidBills,
          ),
          ExpensesPage(
            expenses: expenses,
            budgets: budgets,
            onAdd: _addExpense,
            onDelete: _deleteExpense,
          ),
          BudgetsPage(
            budgets: budgets,
            onAdd: _addBudget,
            onDelete: _deleteBudget,
          ),
          FinancePage(
            incomeSources: incomeSources,
            savingsGoals: savingsGoals,
            recurringBills: recurringBills,
            profile: profile,
            onAddIncome: _addIncomeSource,
            onDeleteIncome: _deleteIncomeSource,
            onAddGoal: _addSavingsGoal,
            onUpdateGoal: _updateSavingsGoal,
            onDeleteGoal: _deleteSavingsGoal,
            onAddBill: _addRecurringBill,
            onToggleBill: _toggleBillPaid,
            onDeleteBill: _deleteRecurringBill,
            onUpdateProfile: _updateProfile,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          height: 65,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Budgets',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Finance',
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DASHBOARD PAGE ====================

class DashboardPage extends StatelessWidget {
  final List<Expense> expenses;
  final List<Budget> budgets;
  final List<IncomeSource> incomeSources;
  final List<SavingsGoal> savingsGoals;
  final List<RecurringBill> recurringBills;
  final Map<String, dynamic> profile;
  final double totalExpenses, totalBudget, totalSpent, totalIncome, unpaidBills;

  const DashboardPage({
    super.key,
    required this.expenses,
    required this.budgets,
    required this.incomeSources,
    required this.savingsGoals,
    required this.recurringBills,
    required this.profile,
    required this.totalExpenses,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalIncome,
    required this.unpaidBills,
  });

  @override
  Widget build(BuildContext context) {
    final currentSavings = profile['currentSavings'] ?? 0.0;
    final savingsTarget = profile['savingsTarget'] ?? 0.0;
    final monthlyIncome = profile['monthlyIncome'] ?? 0.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.black,
        onRefresh: () async {},
        child: ListView(
          padding: EdgeInsets.all(isWide ? 24 : 16),
          children: [
            // Welcome Section
            Text(
              'Welcome back! 👋',
              style: TextStyle(
                fontSize: isWide ? 28 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s your financial overview',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isWide ? 16 : 14,
              ),
            ),
            const SizedBox(height: 20),

            // Summary Cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  return Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Income',
                          amount: monthlyIncome,
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Expenses',
                          amount: totalExpenses,
                          icon: Icons.trending_down,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    _SummaryCard(
                      title: 'Income',
                      amount: monthlyIncome,
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(
                      title: 'Expenses',
                      amount: totalExpenses,
                      icon: Icons.trending_down,
                      color: Colors.red,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Savings Progress
            _buildSection('Savings Progress', Icons.savings, [
              _ProgressCard(
                title: 'Current Savings',
                current: currentSavings,
                target: savingsTarget,
                color: Colors.black,
              ),
            ]),

            // Budget Overview
            if (budgets.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Budget Overview', Icons.pie_chart, [
                _ProgressCard(
                  title: 'Total Budget',
                  current: totalSpent,
                  target: totalBudget,
                  color: totalSpent > totalBudget ? Colors.red : Colors.black,
                  showRemaining: true,
                ),
              ]),
            ],

            // Upcoming Bills
            if (recurringBills.where((b) => !b.isPaid).isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Upcoming Bills', Icons.receipt_long, [
                ...recurringBills
                    .where((b) => !b.isPaid)
                    .take(3)
                    .map((bill) => _BillTile(bill: bill)),
              ]),
            ],

            // Savings Goals
            if (savingsGoals.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Savings Goals', Icons.flag, [
                ...savingsGoals.take(3).map((goal) => _GoalTile(goal: goal)),
              ]),
            ],

            // Recent Transactions
            const SizedBox(height: 16),
            _buildSection('Recent Transactions', Icons.history, [
              if (expenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No transactions yet',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...expenses.take(5).map((e) => _TransactionTile(expense: e)),
            ]),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'UGX ${formatNumber(amount)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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

class _ProgressCard extends StatelessWidget {
  final String title;
  final double current;
  final double target;
  final Color color;
  final bool showRemaining;

  const _ProgressCard({
    required this.title,
    required this.current,
    required this.target,
    required this.color,
    this.showRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final remaining = target - current;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UGX ${formatNumber(current)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'of UGX ${formatNumber(target)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(0)}% ${showRemaining ? "used" : "saved"}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (showRemaining)
              Text(
                remaining >= 0
                    ? 'UGX ${formatNumber(remaining)} left'
                    : 'UGX ${formatNumber(-remaining)} over',
                style: TextStyle(
                  color: remaining >= 0 ? Colors.green : Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BillTile extends StatelessWidget {
  final RecurringBill bill;
  const _BillTile({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Due: ${bill.dueDate}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'UGX ${formatNumber(bill.amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final SavingsGoal goal;
  const _GoalTile({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey.shade200,
              color: Colors.black,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Expense expense;
  const _TransactionTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(getCategoryIcon(expense.category), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${expense.category} • ${expense.date}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '-UGX ${formatNumber(expense.amount)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== RESPONSIVE BOTTOM SHEET ====================

class ResponsiveBottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSubmit;
  final String submitText;

  const ResponsiveBottomSheet({
    super.key,
    required this.title,
    required this.children,
    required this.onSubmit,
    this.submitText = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...children,
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onSubmit,
                      child: Text(
                        submitText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CUSTOM TEXT FIELD ====================

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey.shade600)
                : null,
          ),
        ),
      ],
    );
  }
}

// ==================== CUSTOM DROPDOWN ====================

class CustomDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData? icon;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.grey.shade600)
                : null,
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ==================== EXPENSES PAGE ====================

class ExpensesPage extends StatelessWidget {
  final List<Expense> expenses;
  final List<Budget> budgets;
  final Function(Expense) onAdd;
  final Function(String) onDelete;

  const ExpensesPage({
    super.key,
    required this.expenses,
    required this.budgets,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (expenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${expenses.length} items',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: expenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first expense',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Expense'),
                        content: Text('Delete "${expense.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => onDelete(expense.id),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          getCategoryIcon(expense.category),
                          size: 24,
                        ),
                      ),
                      title: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                expense.category,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              expense.date,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        '-UGX ${formatNumber(expense.amount)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = budgets.isNotEmpty
        ? budgets.first.category
        : 'General';
    final categories = budgets.isNotEmpty
        ? budgets.map((b) => b.category).toList()
        : [
            'General',
            'Food',
            'Transport',
            'Shopping',
            'Bills',
            'Entertainment',
            'Health',
            'Education',
            'Rent',
            'Utilities',
          ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => ResponsiveBottomSheet(
          title: 'Add Expense',
          submitText: 'Add Expense',
          onSubmit: () {
            final amount = double.tryParse(amountController.text);
            if (titleController.text.isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Please enter a title')),
              );
              return;
            }
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
              return;
            }
            final now = DateTime.now();
            onAdd(
              Expense(
                title: titleController.text.trim(),
                amount: amount,
                category: selectedCategory,
                date: '${monthName(now.month)} ${now.day}, ${now.year}',
                notes: notesController.text.isNotEmpty
                    ? notesController.text.trim()
                    : null,
              ),
            );
            Navigator.pop(ctx);
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Expense added successfully!')),
            );
          },
          children: [
            CustomTextField(
              controller: titleController,
              label: 'Title',
              icon: Icons.description,
              hint: 'What did you spend on?',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: amountController,
              label: 'Amount (UGX)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              hint: '0',
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Category',
              value: selectedCategory,
              items: categories,
              icon: Icons.category,
              onChanged: (v) =>
                  setModalState(() => selectedCategory = v ?? selectedCategory),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: notesController,
              label: 'Notes (optional)',
              icon: Icons.note,
              maxLines: 2,
              hint: 'Add any additional details',
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== BUDGETS PAGE ====================

class BudgetsPage extends StatelessWidget {
  final List<Budget> budgets;
  final Function(Budget) onAdd;
  final Function(String) onDelete;

  const BudgetsPage({
    super.key,
    required this.budgets,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.limit);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spent);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budgets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets set',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create budgets to track spending',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // Summary Card
                Card(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Budget',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UGX ${formatNumber(totalBudget)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Spent',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'UGX ${formatNumber(totalSpent)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Remaining',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'UGX ${formatNumber(totalBudget - totalSpent)}',
                                    style: TextStyle(
                                      color: totalSpent > totalBudget
                                          ? Colors.red.shade300
                                          : Colors.green.shade300,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalBudget > 0
                                ? (totalSpent / totalBudget).clamp(0, 1)
                                : 0,
                            backgroundColor: Colors.white24,
                            color: totalSpent > totalBudget
                                ? Colors.red.shade300
                                : Colors.white,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Budget List
                ...budgets.map(
                  (budget) => Dismissible(
                    key: Key(budget.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    onDismissed: (_) => onDelete(budget.id),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    getCategoryIcon(budget.category),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        budget.category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Limit: UGX ${formatNumber(budget.limit)}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: budget.isOverBudget
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    budget.isOverBudget ? 'Over' : 'OK',
                                    style: TextStyle(
                                      color: budget.isOverBudget
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'UGX ${formatNumber(budget.spent)} spent',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  budget.remaining >= 0
                                      ? 'UGX ${formatNumber(budget.remaining)} left'
                                      : 'UGX ${formatNumber(-budget.remaining)} over',
                                  style: TextStyle(
                                    color: budget.isOverBudget
                                        ? Colors.red
                                        : Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: budget.progress.clamp(0, 1),
                                backgroundColor: Colors.grey.shade200,
                                color: budget.isOverBudget
                                    ? Colors.red
                                    : Colors.black,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${(budget.progress * 100).toStringAsFixed(0)}% used',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBudgetSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveBottomSheet(
        title: 'Add Budget',
        submitText: 'Create Budget',
        onSubmit: () {
          final limit = double.tryParse(limitController.text);
          if (categoryController.text.isEmpty) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Please enter a category name')),
            );
            return;
          }
          if (limit == null || limit <= 0) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Please enter a valid limit')),
            );
            return;
          }
          onAdd(Budget(category: categoryController.text.trim(), limit: limit));
          Navigator.pop(ctx);
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Budget created successfully!')),
          );
        },
        children: [
          CustomTextField(
            controller: categoryController,
            label: 'Category Name',
            icon: Icons.category,
            hint: 'e.g., Food, Transport',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: limitController,
            label: 'Budget Limit (UGX)',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            hint: '0',
          ),
        ],
      ),
    );
  }
}

// ==================== FINANCE PAGE ====================

class FinancePage extends StatefulWidget {
  final List<IncomeSource> incomeSources;
  final List<SavingsGoal> savingsGoals;
  final List<RecurringBill> recurringBills;
  final Map<String, dynamic> profile;
  final Function(IncomeSource) onAddIncome;
  final Function(String) onDeleteIncome;
  final Function(SavingsGoal) onAddGoal;
  final Function(String, double) onUpdateGoal;
  final Function(String) onDeleteGoal;
  final Function(RecurringBill) onAddBill;
  final Function(String) onToggleBill;
  final Function(String) onDeleteBill;
  final Function(Map<String, dynamic>) onUpdateProfile;

  const FinancePage({
    super.key,
    required this.incomeSources,
    required this.savingsGoals,
    required this.recurringBills,
    required this.profile,
    required this.onAddIncome,
    required this.onDeleteIncome,
    required this.onAddGoal,
    required this.onUpdateGoal,
    required this.onDeleteGoal,
    required this.onAddBill,
    required this.onToggleBill,
    required this.onDeleteBill,
    required this.onUpdateProfile,
  });

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Goals'),
            Tab(text: 'Bills'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomeTab(),
          _buildGoalsTab(),
          _buildBillsTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildIncomeTab() {
    final totalIncome = widget.incomeSources.fold(
      0.0,
      (sum, i) => sum + i.amount,
    );
    return Scaffold(
      body: widget.incomeSources.isEmpty
          ? _buildEmptyState(
              Icons.trending_up,
              'No income sources',
              'Add your income sources',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.green.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Income',
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                            Text(
                              'UGX ${formatNumber(totalIncome)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.incomeSources.map(
                  (source) => _buildIncomeCard(source),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'income',
        onPressed: () => _showAddIncomeSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildGoalsTab() {
    return Scaffold(
      body: widget.savingsGoals.isEmpty
          ? _buildEmptyState(
              Icons.flag,
              'No savings goals',
              'Set goals to save towards',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: widget.savingsGoals
                  .map((goal) => _buildGoalCard(goal))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'goals',
        onPressed: () => _showAddGoalSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildBillsTab() {
    final unpaid = widget.recurringBills.where((b) => !b.isPaid).toList();
    final paid = widget.recurringBills.where((b) => b.isPaid).toList();

    return Scaffold(
      body: widget.recurringBills.isEmpty
          ? _buildEmptyState(
              Icons.receipt_long,
              'No recurring bills',
              'Track your regular payments',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                if (unpaid.isNotEmpty) ...[
                  Text(
                    'Unpaid (${unpaid.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...unpaid.map((bill) => _buildBillCard(bill)),
                  const SizedBox(height: 16),
                ],
                if (paid.isNotEmpty) ...[
                  Text(
                    'Paid (${paid.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...paid.map((bill) => _buildBillCard(bill)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'bills',
        onPressed: () => _showAddBillSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final incomeController = TextEditingController(
      text: (widget.profile['monthlyIncome'] ?? 0.0).toStringAsFixed(0),
    );
    final savingsController = TextEditingController(
      text: (widget.profile['currentSavings'] ?? 0.0).toStringAsFixed(0),
    );
    final targetController = TextEditingController(
      text: (widget.profile['savingsTarget'] ?? 0.0).toStringAsFixed(0),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text(
                        'Financial Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: incomeController,
                    label: 'Monthly Income (UGX)',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: savingsController,
                    label: 'Current Savings (UGX)',
                    icon: Icons.savings,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: targetController,
                    label: 'Savings Target (UGX)',
                    icon: Icons.flag,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onUpdateProfile({
                          'monthlyIncome':
                              double.tryParse(incomeController.text) ?? 0,
                          'currentSavings':
                              double.tryParse(savingsController.text) ?? 0,
                          'savingsTarget':
                              double.tryParse(targetController.text) ?? 0,
                        });
                        FocusScope.of(context).unfocus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings saved successfully!'),
                          ),
                        );
                      },
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(IncomeSource source) {
    return Dismissible(
      key: Key(source.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => widget.onDeleteIncome(source.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.attach_money, color: Colors.green.shade700),
          ),
          title: Text(
            source.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            source.frequency,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          trailing: Text(
            'UGX ${formatNumber(source.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.flag,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => _showAddToGoalDialog(goal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UGX ${formatNumber(goal.currentAmount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'of UGX ${formatNumber(goal.targetAmount)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue.shade700,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(goal.progress * 100).toStringAsFixed(0)}% complete',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Text(
                  'Due: ${goal.targetDate}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(RecurringBill bill) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bill.isPaid ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            bill.isPaid ? Icons.check_circle : Icons.receipt,
            color: bill.isPaid ? Colors.green : Colors.orange,
            size: 24,
          ),
        ),
        title: Text(
          bill.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: bill.isPaid ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          'Due: ${bill.dueDate} • ${bill.frequency}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'UGX ${formatNumber(bill.amount)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Checkbox(
              value: bill.isPaid,
              onChanged: (_) => widget.onToggleBill(bill.id),
              activeColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddIncomeSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String frequency = 'Monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => ResponsiveBottomSheet(
          title: 'Add Income',
          submitText: 'Add Income',
          onSubmit: () {
            final amount = double.tryParse(amountController.text);
            if (nameController.text.isEmpty || amount == null || amount <= 0) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields correctly'),
                ),
              );
              return;
            }
            widget.onAddIncome(
              IncomeSource(
                name: nameController.text.trim(),
                amount: amount,
                frequency: frequency,
              ),
            );
            Navigator.pop(ctx);
          },
          children: [
            CustomTextField(
              controller: nameController,
              label: 'Source Name',
              icon: Icons.work,
              hint: 'e.g., Salary, Freelance',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: amountController,
              label: 'Amount (UGX)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              hint: '0',
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Frequency',
              value: frequency,
              items: const ['Daily', 'Weekly', 'Monthly', 'Yearly'],
              icon: Icons.repeat,
              onChanged: (v) => setModalState(() => frequency = v ?? frequency),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final dateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ResponsiveBottomSheet(
        title: 'Add Savings Goal',
        submitText: 'Create Goal',
        onSubmit: () {
          final target = double.tryParse(targetController.text);
          if (nameController.text.isEmpty ||
              target == null ||
              target <= 0 ||
              dateController.text.isEmpty) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Please fill all fields correctly')),
            );
            return;
          }
          widget.onAddGoal(
            SavingsGoal(
              name: nameController.text.trim(),
              targetAmount: target,
              targetDate: dateController.text.trim(),
            ),
          );
          Navigator.pop(ctx);
        },
        children: [
          CustomTextField(
            controller: nameController,
            label: 'Goal Name',
            icon: Icons.flag,
            hint: 'e.g., Emergency Fund, Vacation',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: targetController,
            label: 'Target Amount (UGX)',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
            hint: '0',
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: dateController,
            label: 'Target Date',
            icon: Icons.calendar_today,
            hint: 'e.g., Dec 2025',
          ),
        ],
      ),
    );
  }

  void _showAddToGoalDialog(SavingsGoal goal) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to ${goal.name}'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Amount (UGX)',
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                widget.onUpdateGoal(goal.id, amount);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added UGX ${formatNumber(amount)} to ${goal.name}',
                    ),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddBillSheet(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController();
    String frequency = 'Monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => ResponsiveBottomSheet(
          title: 'Add Recurring Bill',
          submitText: 'Add Bill',
          onSubmit: () {
            final amount = double.tryParse(amountController.text);
            if (nameController.text.isEmpty ||
                amount == null ||
                amount <= 0 ||
                dateController.text.isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields correctly'),
                ),
              );
              return;
            }
            widget.onAddBill(
              RecurringBill(
                name: nameController.text.trim(),
                amount: amount,
                dueDate: dateController.text.trim(),
                frequency: frequency,
              ),
            );
            Navigator.pop(ctx);
          },
          children: [
            CustomTextField(
              controller: nameController,
              label: 'Bill Name',
              icon: Icons.receipt,
              hint: 'e.g., Rent, Electricity',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: amountController,
              label: 'Amount (UGX)',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              hint: '0',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: dateController,
              label: 'Due Date',
              icon: Icons.calendar_today,
              hint: 'e.g., 15th of every month',
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              label: 'Frequency',
              value: frequency,
              items: const ['Weekly', 'Monthly'],
              icon: Icons.repeat,
              onChanged: (v) => setModalState(() => frequency = v ?? frequency),
            ),
          ],
        ),
      ),
    );
  }
}
