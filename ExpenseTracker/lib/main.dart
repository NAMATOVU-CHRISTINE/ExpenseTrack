import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  ThemeMode _themeMode = ThemeMode.light;
  String _currency = 'UGX';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = prefs.getBool('darkMode') ?? false
          ? ThemeMode.dark
          : ThemeMode.light;
      _currency = prefs.getString('currency') ?? 'UGX';
    });
  }

  void _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void _setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    setState(() => _currency = currency);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: AppWrapper(
        currency: _currency,
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
        onSetCurrency: _setCurrency,
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? Colors.white : Colors.black,
        foregroundColor: isDark ? Colors.black : Colors.white,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cardColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 8,
        indicatorColor: primaryColor.withOpacity(0.1),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        secondary: primaryColor.withOpacity(0.7),
        surface: cardColor,
        error: Colors.red,
        onPrimary: isDark ? Colors.black : Colors.white,
        onSecondary: isDark ? Colors.black : Colors.white,
        onSurface: primaryColor,
        onError: Colors.white,
      ),
    );
  }
}

// ==================== CATEGORY COLORS ====================

class CategoryHelper {
  static const Map<String, Color> colors = {
    'food': Color(0xFFFF6B6B),
    'transport': Color(0xFF4ECDC4),
    'shopping': Color(0xFFFFE66D),
    'bills': Color(0xFF95E1D3),
    'entertainment': Color(0xFFDDA0DD),
    'health': Color(0xFF98D8C8),
    'education': Color(0xFF6C5CE7),
    'rent': Color(0xFFFF8C42),
    'utilities': Color(0xFF17A2B8),
    'general': Color(0xFF6C757D),
  };

  static Color getColor(String category) {
    return colors[category.toLowerCase()] ?? colors['general']!;
  }

  static IconData getIcon(String category) {
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

  static List<String> defaultCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Rent',
    'Utilities',
    'General',
  ];
}

// ==================== MODELS ====================

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final bool isRecurring;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.isRecurring = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    bool? isRecurring,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'notes': notes,
    'isRecurring': isRecurring,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    title: json['title'],
    amount: json['amount'].toDouble(),
    category: json['category'],
    date: json['date'] is String
        ? DateTime.parse(json['date'])
        : DateTime.now(),
    notes: json['notes'],
    isRecurring: json['isRecurring'] ?? false,
  );
}

class Budget {
  final String id;
  final String category;
  final double limit;
  double spent;
  final double warningThreshold;

  Budget({
    String? id,
    required this.category,
    required this.limit,
    this.spent = 0,
    this.warningThreshold = 0.8,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Budget copyWith({
    String? category,
    double? limit,
    double? spent,
    double? warningThreshold,
  }) {
    return Budget(
      id: id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      warningThreshold: warningThreshold ?? this.warningThreshold,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'limit': limit,
    'spent': spent,
    'warningThreshold': warningThreshold,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    category: json['category'],
    limit: json['limit'].toDouble(),
    spent: json['spent']?.toDouble() ?? 0,
    warningThreshold: json['warningThreshold']?.toDouble() ?? 0.8,
  );

  double get progress => limit > 0 ? (spent / limit).clamp(0, 1.5) : 0;
  double get remaining => limit - spent;
  bool get isOverBudget => spent > limit;
  bool get isNearLimit => progress >= warningThreshold && !isOverBudget;
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

  IncomeSource copyWith({String? name, double? amount, String? frequency}) {
    return IncomeSource(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
    );
  }

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
  final DateTime targetDate;

  SavingsGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  SavingsGoal copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
  }) {
    return SavingsGoal(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
  };
  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    name: json['name'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount']?.toDouble() ?? 0,
    targetDate: json['targetDate'] is String
        ? DateTime.parse(json['targetDate'])
        : DateTime.now().add(const Duration(days: 365)),
  );

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
}

class RecurringBill {
  final String id;
  final String name;
  final double amount;
  final int dueDay;
  final String frequency;
  bool isPaid;

  RecurringBill({
    String? id,
    required this.name,
    required this.amount,
    required this.dueDay,
    required this.frequency,
    this.isPaid = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  RecurringBill copyWith({
    String? name,
    double? amount,
    int? dueDay,
    String? frequency,
    bool? isPaid,
  }) {
    return RecurringBill(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      frequency: frequency ?? this.frequency,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'dueDay': dueDay,
    'frequency': frequency,
    'isPaid': isPaid,
  };
  factory RecurringBill.fromJson(Map<String, dynamic> json) => RecurringBill(
    id: json['id'],
    name: json['name'],
    amount: json['amount'].toDouble(),
    dueDay: json['dueDay'] ?? 1,
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

  static Future<bool> isOnboarded() async {
    final prefs = await _prefs;
    return prefs.getBool('onboarded') ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await _prefs;
    await prefs.setBool('onboarded', true);
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

String formatCurrency(double num, String currency) {
  final formatted = num.toStringAsFixed(
    0,
  ).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '$currency $formatted';
}

String formatDate(DateTime date) {
  const months = [
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
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatShortDate(DateTime date) {
  const months = [
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
  ];
  return '${months[date.month - 1]} ${date.day}';
}

// ==================== APP WRAPPER ====================

class AppWrapper extends StatefulWidget {
  final String currency;
  final bool isDarkMode;
  final Function(bool) onToggleTheme;
  final Function(String) onSetCurrency;

  const AppWrapper({
    super.key,
    required this.currency,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onSetCurrency,
  });

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final onboarded = await DataService.isOnboarded();
    setState(() {
      _showOnboarding = !onboarded;
      _isLoading = false;
    });
  }

  void _completeOnboarding() {
    DataService.setOnboarded();
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_showOnboarding) {
      return OnboardingPage(onComplete: _completeOnboarding);
    }
    return HomePage(
      currency: widget.currency,
      isDarkMode: widget.isDarkMode,
      onToggleTheme: widget.onToggleTheme,
      onSetCurrency: widget.onSetCurrency,
    );
  }
}

// ==================== ONBOARDING PAGE ====================

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingPage({super.key, required this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _incomeController = TextEditingController();
  final _savingsTargetController = TextEditingController();
  final Set<String> _selectedCategories = {
    'Food',
    'Transport',
    'Bills',
    'Shopping',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildWelcomePage(),
                  _buildIncomePage(),
                  _buildCategoriesPage(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 100,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to\nExpense Tracker',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Take control of your finances with smart tracking and insights',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.trending_up, size: 80, color: Colors.green),
          const SizedBox(height: 32),
          const Text(
            'Set Your Income',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us give you better insights',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Income',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _savingsTargetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Savings Target',
              prefixIcon: Icon(Icons.savings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.category, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Choose Categories',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the categories you want to track',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CategoryHelper.defaultCategories.map((cat) {
                final selected = _selectedCategories.contains(cat);
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (v) => setState(
                    () => v
                        ? _selectedCategories.add(cat)
                        : _selectedCategories.remove(cat),
                  ),
                  avatar: Icon(
                    CategoryHelper.getIcon(cat),
                    size: 18,
                    color: selected
                        ? Colors.white
                        : CategoryHelper.getColor(cat),
                  ),
                  backgroundColor: CategoryHelper.getColor(
                    cat,
                  ).withOpacity(0.1),
                  selectedColor: CategoryHelper.getColor(cat),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Row(
            children: List.generate(
              3,
              (i) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _currentPage
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          const Spacer(),
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Text('Back'),
            ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              if (_currentPage < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // Save initial data
                final income = double.tryParse(_incomeController.text) ?? 0;
                final target =
                    double.tryParse(_savingsTargetController.text) ?? 0;
                await DataService.saveProfile({
                  'monthlyIncome': income,
                  'savingsTarget': target,
                  'currentSavings': 0.0,
                });

                // Create budgets for selected categories
                final budgets = _selectedCategories
                    .map((cat) => Budget(category: cat, limit: income * 0.1))
                    .toList();
                await DataService.saveBudgets(budgets);

                widget.onComplete();
              }
            },
            child: Text(_currentPage == 2 ? 'Get Started' : 'Next'),
          ),
        ],
      ),
    );
  }
}

// ==================== HOME PAGE ====================

class HomePage extends StatefulWidget {
  final String currency;
  final bool isDarkMode;
  final Function(bool) onToggleTheme;
  final Function(String) onSetCurrency;

  const HomePage({
    super.key,
    required this.currency,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onSetCurrency,
  });

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
    final now = DateTime.now();
    for (var budget in budgets) {
      budget.spent = expenses
          .where(
            (e) =>
                e.category == budget.category &&
                e.date.month == now.month &&
                e.date.year == now.year,
          )
          .fold(0.0, (sum, e) => sum + e.amount);
    }
  }

  // Expense CRUD
  void _addExpense(Expense expense) {
    setState(() {
      expenses.insert(0, expense);
      _recalculateBudgetSpent();
    });
    DataService.saveExpenses(expenses);
    DataService.saveBudgets(budgets);
    _checkBudgetWarnings(expense.category);
  }

  void _updateExpense(Expense expense) {
    setState(() {
      final index = expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) expenses[index] = expense;
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

  void _checkBudgetWarnings(String category) {
    final budget = budgets.where((b) => b.category == category).firstOrNull;
    if (budget != null) {
      if (budget.isOverBudget) {
        _showBudgetAlert(
          'Budget Exceeded!',
          'You\'ve exceeded your ${budget.category} budget by ${formatCurrency(budget.spent - budget.limit, widget.currency)}',
        );
      } else if (budget.isNearLimit) {
        _showBudgetAlert(
          'Budget Warning',
          'You\'ve used ${(budget.progress * 100).toInt()}% of your ${budget.category} budget',
        );
      }
    }
  }

  void _showBudgetAlert(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              title.contains('Exceeded') ? Icons.warning : Icons.info,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: title.contains('Exceeded')
            ? Colors.red
            : Colors.orange,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Budget CRUD
  void _addBudget(Budget budget) {
    setState(() => budgets.add(budget));
    DataService.saveBudgets(budgets);
  }

  void _updateBudget(Budget budget) {
    setState(() {
      final index = budgets.indexWhere((b) => b.id == budget.id);
      if (index != -1) budgets[index] = budget;
    });
    DataService.saveBudgets(budgets);
  }

  void _deleteBudget(String id) {
    setState(() => budgets.removeWhere((b) => b.id == id));
    DataService.saveBudgets(budgets);
  }

  // Income CRUD
  void _addIncomeSource(IncomeSource source) {
    setState(() => incomeSources.add(source));
    DataService.saveIncomeSources(incomeSources);
  }

  void _updateIncomeSource(IncomeSource source) {
    setState(() {
      final index = incomeSources.indexWhere((i) => i.id == source.id);
      if (index != -1) incomeSources[index] = source;
    });
    DataService.saveIncomeSources(incomeSources);
  }

  void _deleteIncomeSource(String id) {
    setState(() => incomeSources.removeWhere((i) => i.id == id));
    DataService.saveIncomeSources(incomeSources);
  }

  // Savings Goal CRUD
  void _addSavingsGoal(SavingsGoal goal) {
    setState(() => savingsGoals.add(goal));
    DataService.saveSavingsGoals(savingsGoals);
  }

  void _updateSavingsGoal(SavingsGoal goal) {
    setState(() {
      final index = savingsGoals.indexWhere((g) => g.id == goal.id);
      if (index != -1) savingsGoals[index] = goal;
    });
    DataService.saveSavingsGoals(savingsGoals);
  }

  void _deleteSavingsGoal(String id) {
    setState(() => savingsGoals.removeWhere((g) => g.id == id));
    DataService.saveSavingsGoals(savingsGoals);
  }

  // Recurring Bill CRUD
  void _addRecurringBill(RecurringBill bill) {
    setState(() => recurringBills.add(bill));
    DataService.saveRecurringBills(recurringBills);
  }

  void _updateRecurringBill(RecurringBill bill) {
    setState(() {
      final index = recurringBills.indexWhere((b) => b.id == bill.id);
      if (index != -1) recurringBills[index] = bill;
    });
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
  double get monthlyExpenses {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalBudget => budgets.fold(0, (sum, b) => sum + b.limit);
  double get totalSpent => budgets.fold(0, (sum, b) => sum + b.spent);
  double get totalIncome => incomeSources.fold(0, (sum, i) => sum + i.amount);
  double get unpaidBills => recurringBills
      .where((b) => !b.isPaid)
      .fold(0, (sum, b) => sum + b.amount);

  void _showQuickAddExpense() {
    showExpenseSheet(
      context: context,
      budgets: budgets,
      currency: widget.currency,
      onSave: _addExpense,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            currency: widget.currency,
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
            onSetCurrency: widget.onSetCurrency,
            onQuickAdd: _showQuickAddExpense,
          ),
          ExpensesPage(
            expenses: expenses,
            budgets: budgets,
            currency: widget.currency,
            onAdd: _addExpense,
            onUpdate: _updateExpense,
            onDelete: _deleteExpense,
          ),
          BudgetsPage(
            budgets: budgets,
            currency: widget.currency,
            onAdd: _addBudget,
            onUpdate: _updateBudget,
            onDelete: _deleteBudget,
          ),
          FinancePage(
            incomeSources: incomeSources,
            savingsGoals: savingsGoals,
            recurringBills: recurringBills,
            profile: profile,
            currency: widget.currency,
            onAddIncome: _addIncomeSource,
            onUpdateIncome: _updateIncomeSource,
            onDeleteIncome: _deleteIncomeSource,
            onAddGoal: _addSavingsGoal,
            onUpdateGoal: _updateSavingsGoal,
            onDeleteGoal: _deleteSavingsGoal,
            onAddBill: _addRecurringBill,
            onUpdateBill: _updateRecurringBill,
            onToggleBill: _toggleBillPaid,
            onDeleteBill: _deleteRecurringBill,
            onUpdateProfile: _updateProfile,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showQuickAddExpense,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        height: 65,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
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
  final String currency;
  final bool isDarkMode;
  final Function(bool) onToggleTheme;
  final Function(String) onSetCurrency;
  final VoidCallback onQuickAdd;

  const DashboardPage({
    super.key,
    required this.expenses,
    required this.budgets,
    required this.incomeSources,
    required this.savingsGoals,
    required this.recurringBills,
    required this.profile,
    required this.currency,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onSetCurrency,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyExpenses = expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
    final lastMonthExpenses = expenses
        .where((e) => e.date.month == (now.month == 1 ? 12 : now.month - 1))
        .fold(0.0, (sum, e) => sum + e.amount);
    final totalIncome = incomeSources.fold(0.0, (sum, i) => sum + i.amount);
    final displayIncome = totalIncome > 0
        ? totalIncome
        : (profile['monthlyIncome'] ?? 0.0);
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.limit);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spent);
    final unpaidBills = recurringBills
        .where((b) => !b.isPaid)
        .fold(0.0, (sum, b) => sum + b.amount);

    // Calculate spending by category for pie chart
    final categorySpending = <String, double>{};
    for (var expense in expenses.where(
      (e) => e.date.month == now.month && e.date.year == now.year,
    )) {
      categorySpending[expense.category] =
          (categorySpending[expense.category] ?? 0) + expense.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => onToggleTheme(!isDarkMode),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'currency') _showCurrencyPicker(context);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'currency',
                child: Row(
                  children: [
                    const Icon(Icons.attach_money, size: 20),
                    const SizedBox(width: 8),
                    Text('Currency: $currency'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome
            Text(
              'Welcome back!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Here\'s your financial overview',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Income',
                    amount: displayIncome,
                    icon: Icons.trending_up,
                    color: Colors.green,
                    currency: currency,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Expenses',
                    amount: monthlyExpenses,
                    icon: Icons.trending_down,
                    color: Colors.red,
                    currency: currency,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Spending Comparison
            if (lastMonthExpenses > 0) ...[
              _SpendingComparisonCard(
                current: monthlyExpenses,
                previous: lastMonthExpenses,
                currency: currency,
              ),
              const SizedBox(height: 16),
            ],

            // Spending Chart
            if (categorySpending.isNotEmpty) ...[
              _SpendingChartCard(
                categorySpending: categorySpending,
                currency: currency,
              ),
              const SizedBox(height: 16),
            ],

            // Budget Alerts
            ...budgets
                .where((b) => b.isOverBudget || b.isNearLimit)
                .map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BudgetAlertCard(budget: b, currency: currency),
                  ),
                ),

            // Budget Overview
            if (budgets.isNotEmpty) ...[
              _buildSection(context, 'Budget Overview', Icons.pie_chart, [
                _ProgressCard(
                  current: totalSpent,
                  target: totalBudget,
                  color: totalSpent > totalBudget
                      ? Colors.red
                      : Theme.of(context).primaryColor,
                  showRemaining: true,
                  currency: currency,
                ),
              ]),
              const SizedBox(height: 16),
            ],

            // Upcoming Bills
            if (recurringBills.where((b) => !b.isPaid).isNotEmpty) ...[
              _buildSection(context, 'Upcoming Bills', Icons.receipt_long, [
                ...recurringBills
                    .where((b) => !b.isPaid)
                    .take(3)
                    .map((bill) => _BillTile(bill: bill, currency: currency)),
                if (unpaidBills > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Total due: ${formatCurrency(unpaidBills, currency)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ]),
              const SizedBox(height: 16),
            ],

            // Savings Goals
            if (savingsGoals.isNotEmpty) ...[
              _buildSection(context, 'Savings Goals', Icons.flag, [
                ...savingsGoals
                    .take(3)
                    .map((goal) => _GoalTile(goal: goal, currency: currency)),
              ]),
              const SizedBox(height: 16),
            ],

            // Recent Transactions
            _buildSection(context, 'Recent Transactions', Icons.history, [
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
                ...expenses
                    .take(5)
                    .map(
                      (e) => _TransactionTile(expense: e, currency: currency),
                    ),
            ]),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Currency',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...['UGX', 'USD', 'EUR', 'GBP', 'KES', 'TZS', 'RWF', 'NGN'].map(
              (c) => ListTile(
                title: Text(c),
                trailing: currency == c
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  onSetCurrency(c);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
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
  final String currency;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.currency,
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
                      formatCurrency(amount, currency),
                      style: const TextStyle(
                        fontSize: 18,
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

class _SpendingComparisonCard extends StatelessWidget {
  final double current;
  final double previous;
  final String currency;

  const _SpendingComparisonCard({
    required this.current,
    required this.previous,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final diff = current - previous;
    final percent = previous > 0 ? ((diff / previous) * 100).abs() : 0.0;
    final isMore = diff > 0;

    return Card(
      color: isMore ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isMore ? Icons.trending_up : Icons.trending_down,
              color: isMore ? Colors.red : Colors.green,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMore ? 'Spending Up' : 'Spending Down',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMore
                          ? Colors.red.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(0)}% ${isMore ? "more" : "less"} than last month',
                    style: TextStyle(
                      fontSize: 13,
                      color: isMore
                          ? Colors.red.shade600
                          : Colors.green.shade600,
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

class _SpendingChartCard extends StatelessWidget {
  final Map<String, double> categorySpending;
  final String currency;

  const _SpendingChartCard({
    required this.categorySpending,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final total = categorySpending.values.fold(0.0, (a, b) => a + b);
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.donut_large, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Spending by Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        categorySpending,
                        Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sorted
                          .take(4)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: CategoryHelper.getColor(e.key),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    '${(e.value / total * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
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

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final Color centerColor;
  _PieChartPainter(this.data, this.centerColor);

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    var startAngle = -math.pi / 2;

    for (var entry in data.entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = CategoryHelper.getColor(entry.key)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Inner circle for donut effect
    canvas.drawCircle(center, radius * 0.5, Paint()..color = centerColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BudgetAlertCard extends StatelessWidget {
  final Budget budget;
  final String currency;

  const _BudgetAlertCard({required this.budget, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isOver = budget.isOverBudget;
    return Card(
      color: isOver ? Colors.red.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isOver ? Icons.warning : Icons.info,
              color: isOver ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOver
                        ? '${budget.category} Over Budget!'
                        : '${budget.category} Near Limit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOver
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                  Text(
                    '${(budget.progress * 100).toInt()}% used - ${formatCurrency(budget.remaining.abs(), currency)} ${isOver ? "over" : "left"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOver
                          ? Colors.red.shade600
                          : Colors.orange.shade600,
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
  final double current, target;
  final Color color;
  final bool showRemaining;
  final String currency;

  const _ProgressCard({
    required this.current,
    required this.target,
    required this.color,
    this.showRemaining = false,
    required this.currency,
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
              formatCurrency(current, currency),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'of ${formatCurrency(target, currency)}',
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
                    ? '${formatCurrency(remaining, currency)} left'
                    : '${formatCurrency(-remaining, currency)} over',
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
  final String currency;
  const _BillTile({required this.bill, required this.currency});

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
                  'Due: Day ${bill.dueDay}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(bill.amount, currency),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final SavingsGoal goal;
  final String currency;
  const _GoalTile({required this.goal, required this.currency});

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
              color: Theme.of(context).primaryColor,
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
  final String currency;
  const _TransactionTile({required this.expense, required this.currency});

  @override
  Widget build(BuildContext context) {
    final color = CategoryHelper.getColor(expense.category);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CategoryHelper.getIcon(expense.category),
              size: 20,
              color: color,
            ),
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
                  '${expense.category} • ${formatShortDate(expense.date)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '-${formatCurrency(expense.amount, currency)}',
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

// ==================== EXPENSE SHEET HELPER ====================

void showExpenseSheet({
  required BuildContext context,
  required List<Budget> budgets,
  required String currency,
  required Function(Expense) onSave,
  Expense? expense,
}) {
  final isEdit = expense != null;
  final titleController = TextEditingController(text: expense?.title ?? '');
  final amountController = TextEditingController(
    text: expense?.amount.toStringAsFixed(0) ?? '',
  );
  final notesController = TextEditingController(text: expense?.notes ?? '');
  String selectedCategory =
      expense?.category ??
      (budgets.isNotEmpty ? budgets.first.category : 'General');
  DateTime selectedDate = expense?.date ?? DateTime.now();

  final categories = budgets.isNotEmpty
      ? budgets.map((b) => b.category).toList()
      : CategoryHelper.defaultCategories;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    isEdit ? 'Edit Expense' : 'Add Expense',
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
                    _buildTextField(
                      titleController,
                      'Title',
                      Icons.description,
                      hint: 'What did you spend on?',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      amountController,
                      'Amount ($currency)',
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                      hint: '0',
                    ),
                    const SizedBox(height: 16),

                    // Category Selector
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final selected = selectedCategory == cat;
                        final color = CategoryHelper.getColor(cat);
                        return ChoiceChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (v) =>
                              setModalState(() => selectedCategory = cat),
                          avatar: Icon(
                            CategoryHelper.getIcon(cat),
                            size: 16,
                            color: selected ? Colors.white : color,
                          ),
                          backgroundColor: color.withOpacity(0.1),
                          selectedColor: color,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : null,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null)
                          setModalState(() => selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Text(formatDate(selectedDate)),
                            const Spacer(),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      notesController,
                      'Notes (optional)',
                      Icons.note,
                      maxLines: 2,
                      hint: 'Add any additional details',
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text);
                        if (titleController.text.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a title'),
                            ),
                          );
                          return;
                        }
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                            ),
                          );
                          return;
                        }
                        HapticFeedback.mediumImpact();
                        onSave(
                          Expense(
                            id: expense?.id,
                            title: titleController.text.trim(),
                            amount: amount,
                            category: selectedCategory,
                            date: selectedDate,
                            notes: notesController.text.isNotEmpty
                                ? notesController.text.trim()
                                : null,
                          ),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Expense ${isEdit ? "updated" : "added"} successfully!',
                            ),
                          ),
                        );
                      },
                      child: Text(
                        isEdit ? 'Save Changes' : 'Add Expense',
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
    ),
  );
}

Widget _buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  TextInputType? keyboardType,
  int maxLines = 1,
  String? hint,
}) {
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
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
        ),
      ),
    ],
  );
}

// ==================== EXPENSES PAGE ====================

class ExpensesPage extends StatefulWidget {
  final List<Expense> expenses;
  final List<Budget> budgets;
  final String currency;
  final Function(Expense) onAdd;
  final Function(Expense) onUpdate;
  final Function(String) onDelete;

  const ExpensesPage({
    super.key,
    required this.expenses,
    required this.budgets,
    required this.currency,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String _searchQuery = '';
  String? _filterCategory;
  DateTimeRange? _dateRange;

  List<Expense> get filteredExpenses {
    var result = widget.expenses;

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (e) =>
                e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                e.category.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_filterCategory != null) {
      result = result.where((e) => e.category == _filterCategory).toList();
    }

    if (_dateRange != null) {
      result = result
          .where(
            (e) =>
                e.date.isAfter(
                  _dateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                e.date.isBefore(_dateRange!.end.add(const Duration(days: 1))),
          )
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.budgets.map((b) => b.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (widget.expenses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterSheet(categories),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (widget.expenses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
              ),
            ),

          // Active Filters
          if (_filterCategory != null || _dateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (_filterCategory != null)
                    Chip(
                      label: Text(_filterCategory!),
                      onDeleted: () => setState(() => _filterCategory = null),
                      deleteIconColor: Colors.grey,
                    ),
                  if (_dateRange != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        '${formatShortDate(_dateRange!.start)} - ${formatShortDate(_dateRange!.end)}',
                      ),
                      onDeleted: () => setState(() => _dateRange = null),
                      deleteIconColor: Colors.grey,
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      _filterCategory = null;
                      _dateRange = null;
                    }),
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),

          // Expense List
          Expanded(
            child: filteredExpenses.isEmpty
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
                          widget.expenses.isEmpty
                              ? 'No expenses yet'
                              : 'No matching expenses',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.expenses.isEmpty
                              ? 'Tap + to add your first expense'
                              : 'Try adjusting your filters',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      final color = CategoryHelper.getColor(expense.category);
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
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.pop(ctx, true);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) => widget.onDelete(expense.id),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: InkWell(
                            onTap: () => showExpenseSheet(
                              context: context,
                              budgets: widget.budgets,
                              currency: widget.currency,
                              expense: expense,
                              onSave: widget.onUpdate,
                            ),
                            borderRadius: BorderRadius.circular(16),
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
                                    child: Icon(
                                      CategoryHelper.getIcon(expense.category),
                                      size: 24,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                expense.category,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: color,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              formatShortDate(expense.date),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '-${formatCurrency(expense.amount, widget.currency)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.grey.shade400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showExpenseSheet(
          context: context,
          budgets: widget.budgets,
          currency: widget.currency,
          onSave: widget.onAdd,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  void _showFilterSheet(List<String> categories) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Expenses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _filterCategory == null,
                  onSelected: (v) {
                    setState(() => _filterCategory = null);
                    Navigator.pop(ctx);
                  },
                ),
                ...categories.map(
                  (cat) => ChoiceChip(
                    label: Text(cat),
                    selected: _filterCategory == cat,
                    onSelected: (v) {
                      setState(() => _filterCategory = cat);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Date Range',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (range != null) setState(() => _dateRange = range);
                if (mounted) Navigator.pop(ctx);
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                _dateRange != null
                    ? '${formatShortDate(_dateRange!.start)} - ${formatShortDate(_dateRange!.end)}'
                    : 'Select date range',
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== BUDGETS PAGE ====================

class BudgetsPage extends StatelessWidget {
  final List<Budget> budgets;
  final String currency;
  final Function(Budget) onAdd;
  final Function(Budget) onUpdate;
  final Function(String) onDelete;

  const BudgetsPage({
    super.key,
    required this.budgets,
    required this.currency,
    required this.onAdd,
    required this.onUpdate,
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
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Budget',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency(totalBudget, currency),
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
                                  Text(
                                    'Spent',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(totalSpent, currency),
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
                                  Text(
                                    'Remaining',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(
                                      totalBudget - totalSpent,
                                      currency,
                                    ),
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
                ...budgets.map((budget) {
                  final color = CategoryHelper.getColor(budget.category);
                  return Dismissible(
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
                      child: InkWell(
                        onTap: () => _showBudgetSheet(context, budget: budget),
                        borderRadius: BorderRadius.circular(16),
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
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      CategoryHelper.getIcon(budget.category),
                                      size: 20,
                                      color: color,
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
                                          'Limit: ${formatCurrency(budget.limit, currency)}',
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
                                          : budget.isNearLimit
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      budget.isOverBudget
                                          ? 'Over'
                                          : budget.isNearLimit
                                          ? 'Warning'
                                          : 'OK',
                                      style: TextStyle(
                                        color: budget.isOverBudget
                                            ? Colors.red
                                            : budget.isNearLimit
                                            ? Colors.orange
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${formatCurrency(budget.spent, currency)} spent',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    budget.remaining >= 0
                                        ? '${formatCurrency(budget.remaining, currency)} left'
                                        : '${formatCurrency(-budget.remaining, currency)} over',
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
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: budget.progress.clamp(0, 1),
                                  backgroundColor: Colors.grey.shade200,
                                  color: budget.isOverBudget
                                      ? Colors.red
                                      : budget.isNearLimit
                                      ? Colors.orange
                                      : color,
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBudgetSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  void _showBudgetSheet(BuildContext context, {Budget? budget}) {
    final isEdit = budget != null;
    final limitController = TextEditingController(
      text: budget?.limit.toStringAsFixed(0) ?? '',
    );
    String selectedCategory =
        budget?.category ?? CategoryHelper.defaultCategories.first;
    final existingCategories = budgets.map((b) => b.category).toSet();
    final availableCategories = isEdit
        ? CategoryHelper.defaultCategories
        : CategoryHelper.defaultCategories
              .where((c) => !existingCategories.contains(c))
              .toList();

    if (availableCategories.isEmpty && !isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All categories have budgets')),
      );
      return;
    }

    if (!isEdit && availableCategories.isNotEmpty)
      selectedCategory = availableCategories.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      isEdit ? 'Edit Budget' : 'Add Budget',
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
                      if (!isEdit) ...[
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: availableCategories.map((cat) {
                            final selected = selectedCategory == cat;
                            final color = CategoryHelper.getColor(cat);
                            return ChoiceChip(
                              label: Text(cat),
                              selected: selected,
                              onSelected: (v) =>
                                  setModalState(() => selectedCategory = cat),
                              avatar: Icon(
                                CategoryHelper.getIcon(cat),
                                size: 16,
                                color: selected ? Colors.white : color,
                              ),
                              backgroundColor: color.withOpacity(0.1),
                              selectedColor: color,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : null,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        limitController,
                        'Budget Limit ($currency)',
                        Icons.attach_money,
                        keyboardType: TextInputType.number,
                        hint: '0',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final limit = double.tryParse(limitController.text);
                          if (limit == null || limit <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid limit'),
                              ),
                            );
                            return;
                          }
                          HapticFeedback.mediumImpact();
                          if (isEdit) {
                            onUpdate(budget.copyWith(limit: limit));
                          } else {
                            onAdd(
                              Budget(category: selectedCategory, limit: limit),
                            );
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Budget ${isEdit ? "updated" : "added"} successfully!',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          isEdit ? 'Save Changes' : 'Add Budget',
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
  final String currency;
  final Function(IncomeSource) onAddIncome;
  final Function(IncomeSource) onUpdateIncome;
  final Function(String) onDeleteIncome;
  final Function(SavingsGoal) onAddGoal;
  final Function(SavingsGoal) onUpdateGoal;
  final Function(String) onDeleteGoal;
  final Function(RecurringBill) onAddBill;
  final Function(RecurringBill) onUpdateBill;
  final Function(String) onToggleBill;
  final Function(String) onDeleteBill;
  final Function(Map<String, dynamic>) onUpdateProfile;

  const FinancePage({
    super.key,
    required this.incomeSources,
    required this.savingsGoals,
    required this.recurringBills,
    required this.profile,
    required this.currency,
    required this.onAddIncome,
    required this.onUpdateIncome,
    required this.onDeleteIncome,
    required this.onAddGoal,
    required this.onUpdateGoal,
    required this.onDeleteGoal,
    required this.onAddBill,
    required this.onUpdateBill,
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
    _tabController = TabController(length: 3, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildIncomeTab(), _buildGoalsTab(), _buildBillsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'finance_fab',
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              _showIncomeSheet(context);
              break;
            case 1:
              _showGoalSheet(context);
              break;
            case 2:
              _showBillSheet(context);
              break;
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildIncomeTab() {
    final totalIncome = widget.incomeSources.fold(
      0.0,
      (sum, i) => sum + i.amount,
    );
    return widget.incomeSources.isEmpty
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
                            formatCurrency(totalIncome, widget.currency),
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
              ...widget.incomeSources.map((source) => _buildIncomeCard(source)),
            ],
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
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => widget.onDeleteIncome(source.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () => _showIncomeSheet(context, income: source),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.attach_money, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        source.frequency,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(source.amount, widget.currency),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIncomeSheet(BuildContext context, {IncomeSource? income}) {
    final isEdit = income != null;
    final nameController = TextEditingController(text: income?.name ?? '');
    final amountController = TextEditingController(
      text: income?.amount.toStringAsFixed(0) ?? '',
    );
    String frequency = income?.frequency ?? 'Monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      isEdit ? 'Edit Income' : 'Add Income',
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
                      _buildTextField(
                        nameController,
                        'Source Name',
                        Icons.work,
                        hint: 'e.g., Salary, Freelance',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        amountController,
                        'Amount (${widget.currency})',
                        Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Frequency',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Monthly', 'Weekly', 'Bi-weekly', 'Yearly']
                            .map(
                              (f) => ChoiceChip(
                                label: Text(f),
                                selected: frequency == f,
                                onSelected: (v) =>
                                    setModalState(() => frequency = f),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (nameController.text.isEmpty ||
                              amount == null ||
                              amount <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                            return;
                          }
                          HapticFeedback.mediumImpact();
                          if (isEdit) {
                            widget.onUpdateIncome(
                              income.copyWith(
                                name: nameController.text.trim(),
                                amount: amount,
                                frequency: frequency,
                              ),
                            );
                          } else {
                            widget.onAddIncome(
                              IncomeSource(
                                name: nameController.text.trim(),
                                amount: amount,
                                frequency: frequency,
                              ),
                            );
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(isEdit ? 'Save Changes' : 'Add Income'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsTab() {
    return widget.savingsGoals.isEmpty
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
          );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => widget.onDeleteGoal(goal.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () => _showGoalSheet(context, goal: goal),
          borderRadius: BorderRadius.circular(16),
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.flag, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Target: ${formatDate(goal.targetDate)}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency(goal.currentAmount, widget.currency),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'of ${formatCurrency(goal.targetAmount, widget.currency)}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.blue,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showAddToGoalSheet(context, goal),
                        child: const Text('Add Funds'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalSheet(BuildContext context, {SavingsGoal? goal}) {
    final isEdit = goal != null;
    final nameController = TextEditingController(text: goal?.name ?? '');
    final targetController = TextEditingController(
      text: goal?.targetAmount.toStringAsFixed(0) ?? '',
    );
    final currentController = TextEditingController(
      text: goal?.currentAmount.toStringAsFixed(0) ?? '0',
    );
    DateTime targetDate =
        goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      isEdit ? 'Edit Goal' : 'Add Goal',
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
                      _buildTextField(
                        nameController,
                        'Goal Name',
                        Icons.flag,
                        hint: 'e.g., Emergency Fund',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        targetController,
                        'Target Amount (${widget.currency})',
                        Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      if (isEdit) ...[
                        _buildTextField(
                          currentController,
                          'Current Amount (${widget.currency})',
                          Icons.savings,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Target Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: targetDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null)
                            setModalState(() => targetDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(formatDate(targetDate)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final target = double.tryParse(targetController.text);
                          final current =
                              double.tryParse(currentController.text) ?? 0;
                          if (nameController.text.isEmpty ||
                              target == null ||
                              target <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                            return;
                          }
                          HapticFeedback.mediumImpact();
                          if (isEdit) {
                            widget.onUpdateGoal(
                              goal.copyWith(
                                name: nameController.text.trim(),
                                targetAmount: target,
                                currentAmount: current,
                                targetDate: targetDate,
                              ),
                            );
                          } else {
                            widget.onAddGoal(
                              SavingsGoal(
                                name: nameController.text.trim(),
                                targetAmount: target,
                                targetDate: targetDate,
                              ),
                            );
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(isEdit ? 'Save Changes' : 'Add Goal'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddToGoalSheet(BuildContext context, SavingsGoal goal) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add to ${goal.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              amountController,
              'Amount (${widget.currency})',
              Icons.add,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount == null || amount <= 0) return;
                HapticFeedback.mediumImpact();
                widget.onUpdateGoal(
                  goal.copyWith(currentAmount: goal.currentAmount + amount),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added ${formatCurrency(amount, widget.currency)} to ${goal.name}',
                    ),
                  ),
                );
              },
              child: const Text('Add Funds'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsTab() {
    final unpaid = widget.recurringBills.where((b) => !b.isPaid).toList();
    final paid = widget.recurringBills.where((b) => b.isPaid).toList();

    return widget.recurringBills.isEmpty
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
          );
  }

  Widget _buildBillCard(RecurringBill bill) {
    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => widget.onDeleteBill(bill.id),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () => _showBillSheet(context, bill: bill),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bill.isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt,
                    color: bill.isPaid ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Due: Day ${bill.dueDay} • ${bill.frequency}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(bill.amount, widget.currency),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.onToggleBill(bill.id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: bill.isPaid
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bill.isPaid ? 'Paid ✓' : 'Mark Paid',
                          style: TextStyle(
                            fontSize: 11,
                            color: bill.isPaid ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBillSheet(BuildContext context, {RecurringBill? bill}) {
    final isEdit = bill != null;
    final nameController = TextEditingController(text: bill?.name ?? '');
    final amountController = TextEditingController(
      text: bill?.amount.toStringAsFixed(0) ?? '',
    );
    int dueDay = bill?.dueDay ?? 1;
    String frequency = bill?.frequency ?? 'Monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      isEdit ? 'Edit Bill' : 'Add Bill',
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
                      _buildTextField(
                        nameController,
                        'Bill Name',
                        Icons.receipt,
                        hint: 'e.g., Rent, Netflix',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        amountController,
                        'Amount (${widget.currency})',
                        Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Due Day of Month',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: dueDay,
                        items: List.generate(
                          28,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('Day ${i + 1}'),
                          ),
                        ),
                        onChanged: (v) => setModalState(() => dueDay = v ?? 1),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Frequency',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Monthly', 'Quarterly', 'Yearly']
                            .map(
                              (f) => ChoiceChip(
                                label: Text(f),
                                selected: frequency == f,
                                onSelected: (v) =>
                                    setModalState(() => frequency = f),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(amountController.text);
                          if (nameController.text.isEmpty ||
                              amount == null ||
                              amount <= 0) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                            return;
                          }
                          HapticFeedback.mediumImpact();
                          if (isEdit) {
                            widget.onUpdateBill(
                              bill.copyWith(
                                name: nameController.text.trim(),
                                amount: amount,
                                dueDay: dueDay,
                                frequency: frequency,
                              ),
                            );
                          } else {
                            widget.onAddBill(
                              RecurringBill(
                                name: nameController.text.trim(),
                                amount: amount,
                                dueDay: dueDay,
                                frequency: frequency,
                              ),
                            );
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(isEdit ? 'Save Changes' : 'Add Bill'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
}
