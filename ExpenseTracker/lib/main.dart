import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'screens/monthly_report_screen.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';

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
    if (!mounted) return;
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
    if (!mounted) return;
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  void _setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    if (!mounted) return;
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
    final primaryColor = const Color(0xFF2196F3); // Blue like Monefy
    final accentColor = const Color(0xFF42A5F5); // Light blue
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF212121);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: const CircleBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF353535) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        color: cardColor,
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        selectedColor: primaryColor,
        labelStyle: TextStyle(color: textColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        elevation: 0,
        height: 60,
        indicatorColor: primaryColor.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            );
          }
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        error: const Color(0xFFEF5350),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textColor.withOpacity(0.7),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ==================== CATEGORY COLORS ====================

class CategoryHelper {
  static const Map<String, Color> colors = {
    'food': Color(0xFFFF6B6B),           // Vibrant Red
    'transport': Color(0xFF4ECDC4),      // Turquoise
    'shopping': Color(0xFFFFA726),       // Orange
    'bills': Color(0xFF42A5F5),          // Blue
    'entertainment': Color(0xFFAB47BC),  // Purple
    'health': Color(0xFF66BB6A),         // Green
    'education': Color(0xFF5C6BC0),      // Indigo
    'rent': Color(0xFFEF5350),           // Deep Red
    'utilities': Color(0xFF26C6DA),      // Cyan
    'general': Color(0xFF78909C),        // Blue Grey
  };

  static Color getColor(String category) {
    return colors[category.toLowerCase()] ?? colors['general']!;
  }

  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'rent':
        return Icons.home_rounded;
      case 'utilities':
        return Icons.bolt_rounded;
      default:
        return Icons.attach_money_rounded;
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
  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    this.isRecurring = false,
    this.receiptPath,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

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
    receiptPath: json['receiptPath'],
  );
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;
  final bool isRecurring;
  final String? receiptPath;

  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    bool? isRecurring,
    String? receiptPath,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
      receiptPath: receiptPath ?? this.receiptPath,
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
    'receiptPath': receiptPath,
  };
}

class Budget {
  Budget({
    String? id,
    required this.category,
    required this.limit,
    this.spent = 0,
    this.warningThreshold = 0.8,
    this.period = 'monthly',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'],
    category: json['category'],
    limit: json['limit'].toDouble(),
    spent: json['spent']?.toDouble() ?? 0,
    warningThreshold: json['warningThreshold']?.toDouble() ?? 0.8,
    period: json['period'] ?? 'monthly',
  );
  final String id;
  final String category;
  final double limit;
  double spent;
  final double warningThreshold;
  final String period; // 'monthly', '3months', 'food1', 'food3', 'food4plus'

  Budget copyWith({
    String? category,
    double? limit,
    double? spent,
    double? warningThreshold,
    String? period,
  }) {
    return Budget(
      id: id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'limit': limit,
    'spent': spent,
    'warningThreshold': warningThreshold,
    'period': period,
  };

  double get progress => limit > 0 ? (spent / limit).clamp(0, 1.5) : 0;
  double get remaining => limit - spent;
  bool get isOverBudget => spent > limit;
  bool get isNearLimit => progress >= warningThreshold && !isOverBudget;
}

class IncomeSource {
  IncomeSource({
    String? id,
    required this.name,
    required this.amount,
    required this.frequency,
    DateTime? date,
    this.source,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       date = date ?? DateTime.now();

  factory IncomeSource.fromJson(Map<String, dynamic> json) => IncomeSource(
    id: json['id'],
    name: json['name'],
    amount: json['amount'].toDouble(),
    frequency: json['frequency'],
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    source: json['source'],
  );

  final String id;
  final String name;
  final double amount;
  final String frequency; // 'once', 'weekly', 'monthly', 'yearly'
  final DateTime date;
  final String? source; // e.g., 'Gift', 'Salary', 'Freelance', 'Other'

  IncomeSource copyWith({
    String? name,
    double? amount,
    String? frequency,
    DateTime? date,
    String? source,
  }) {
    return IncomeSource(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      date: date ?? this.date,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'frequency': frequency,
    'date': date.toIso8601String(),
    'source': source,
  };

  bool get isOneTime => frequency == 'once';
}

class SavingsGoal {
  SavingsGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
    this.fundAdditions = const [],
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    name: json['name'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount']?.toDouble() ?? 0,
    targetDate: json['targetDate'] is String
        ? DateTime.parse(json['targetDate'])
        : DateTime.now().add(const Duration(days: 365)),
    fundAdditions:
        (json['fundAdditions'] as List?)
            ?.map((e) => FundAddition.fromJson(e))
            .toList() ??
        [],
  );
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final List<FundAddition> fundAdditions;

  SavingsGoal copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    List<FundAddition>? fundAdditions,
  }) {
    return SavingsGoal(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      fundAdditions: fundAdditions ?? this.fundAdditions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'fundAdditions': fundAdditions.map((f) => f.toJson()).toList(),
  };

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;
}

class FundAddition {
  FundAddition({required this.amount, required this.date});

  factory FundAddition.fromJson(Map<String, dynamic> json) => FundAddition(
    amount: json['amount'].toDouble(),
    date: json['date'] is String
        ? DateTime.parse(json['date'])
        : DateTime.now(),
  );

  final double amount;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'date': date.toIso8601String(),
  };
}

class RecurringBill {
  RecurringBill({
    String? id,
    required this.name,
    required this.amount,
    required this.dueDay,
    required this.frequency,
    this.isPaid = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();
  factory RecurringBill.fromJson(Map<String, dynamic> json) => RecurringBill(
    id: json['id'],
    name: json['name'],
    amount: json['amount'].toDouble(),
    dueDay: json['dueDay'] ?? 1,
    frequency: json['frequency'],
    isPaid: json['isPaid'] ?? false,
  );
  final String id;
  final String name;
  final double amount;
  final int dueDay;
  final String frequency;
  bool isPaid;

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
  const AppWrapper({
    super.key,
    required this.currency,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onSetCurrency,
  });
  final String currency;
  final bool isDarkMode;
  final Function(bool) onToggleTheme;
  final Function(String) onSetCurrency;

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
    if (!mounted) return;
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
  const OnboardingPage({super.key, required this.onComplete});
  final VoidCallback onComplete;

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
  const HomePage({
    super.key,
    required this.currency,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onSetCurrency,
  });
  final String currency;
  final bool isDarkMode;
  final Function(bool) onToggleTheme;
  final Function(String) onSetCurrency;

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
    if (!mounted) return;
    setState(() => _isLoading = true);
    expenses = await DataService.getExpenses();
    budgets = await DataService.getBudgets();
    incomeSources = await DataService.getIncomeSources();
    savingsGoals = await DataService.getSavingsGoals();
    recurringBills = await DataService.getRecurringBills();
    profile = await DataService.getProfile();
    
    // Generate recurring transactions
    await _generateRecurringTransactions();
    
    _recalculateBudgetSpent();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _generateRecurringTransactions() async {
    bool hasChanges = false;
    final now = DateTime.now();
    
    // Generate recurring expenses
    final recurringExpenses = expenses.where((e) => e.isRecurring).toList();
    for (var recurringExpense in recurringExpenses) {
      // Check if we need to generate for current month
      final existsThisMonth = expenses.any((e) =>
          e.title == recurringExpense.title &&
          e.category == recurringExpense.category &&
          e.amount == recurringExpense.amount &&
          e.date.month == now.month &&
          e.date.year == now.year);
      
      if (!existsThisMonth) {
        // Generate for current month
        expenses.add(Expense(
          title: recurringExpense.title,
          amount: recurringExpense.amount,
          category: recurringExpense.category,
          date: DateTime(now.year, now.month, recurringExpense.date.day),
          notes: recurringExpense.notes,
          isRecurring: false, // Mark as generated, not the template
        ));
        hasChanges = true;
      }
    }
    
    // Generate recurring income for current month
    for (var income in incomeSources) {
      if (income.frequency != 'once') {
        // Check if income should be generated for this month
        final monthsSinceStart = _getMonthsDifference(income.date, now);
        bool shouldGenerate = false;
        
        switch (income.frequency.toLowerCase()) {
          case 'monthly':
            shouldGenerate = monthsSinceStart >= 0;
            break;
          case 'weekly':
            shouldGenerate = monthsSinceStart >= 0;
            break;
          case 'yearly':
            shouldGenerate = monthsSinceStart >= 0 && 
                           now.month == income.date.month;
            break;
        }
        
        if (shouldGenerate) {
          // Income is automatically counted in calculations
          // No need to generate duplicate entries
        }
      }
    }
    
    if (hasChanges) {
      await DataService.saveExpenses(expenses);
    }
  }

  int _getMonthsDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
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
    if (!mounted) return;
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
      if (index != -1) {
        recurringBills[index].isPaid = !recurringBills[index].isPaid;
      }
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

  void _showQuickAddIncome() {
    showIncomeSheet(
      context: context,
      currency: widget.currency,
      onSave: _addIncomeSource,
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return DashboardPage(
          key: const ValueKey('dashboard'),
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
          onQuickAddIncome: _showQuickAddIncome,
        );
      case 1:
        return ExpensesPage(
          key: const ValueKey('expenses'),
          expenses: expenses,
          budgets: budgets,
          currency: widget.currency,
          onAdd: _addExpense,
          onUpdate: _updateExpense,
          onDelete: _deleteExpense,
        );
      case 2:
        return BudgetsPage(
          key: const ValueKey('budgets'),
          budgets: budgets,
          currency: widget.currency,
          onAdd: _addBudget,
          onUpdate: _updateBudget,
          onDelete: _deleteBudget,
        );
      case 3:
        return FinancePage(
          key: const ValueKey('finance'),
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
        );
      case 4:
        return MonthlyReportScreen(
          key: const ValueKey('reports'),
          expenses: expenses.map((e) => e.toJson()).toList(),
          incomeSources: incomeSources.map((i) => i.toJson()).toList(),
          currency: widget.currency,
        );
      default:
        return const SizedBox();
    }
  }

  Widget? _buildFab() {
    switch (_currentIndex) {
      case 0:
        // Dashboard has its own buttons, no FAB needed
        return null;
      case 1:
        return FloatingActionButton(
          heroTag: 'expenses_fab',
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          onPressed: _showQuickAddExpense,
          child: const Icon(Icons.add, size: 28),
        );
      case 2:
        return FloatingActionButton(
          heroTag: 'budgets_fab',
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          onPressed: () => _showBudgetSheet(),
          child: const Icon(Icons.add, size: 28),
        );
      case 3:
        return FloatingActionButton(
          heroTag: 'finance_fab',
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          onPressed: () => _showFinanceSheet(),
          child: const Icon(Icons.add, size: 28),
        );
      default:
        return null;
    }
  }

  void _showBudgetSheet() {
    final existingCategories = budgets.map((b) => b.category).toSet();
    final availableCategories = CategoryHelper.defaultCategories
        .where((c) => !existingCategories.contains(c))
        .toList();

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All categories have budgets')),
      );
      return;
    }

    String selectedCategory = availableCategories.first;
    String selectedPeriod = 'monthly';
    final limitController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                    const Text(
                      'Add Budget',
                      style: TextStyle(
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
                      const Text(
                        'Budget Period',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Monthly'),
                            selected: selectedPeriod == 'monthly',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = 'monthly'),
                          ),
                          ChoiceChip(
                            label: const Text('3 Months'),
                            selected: selectedPeriod == '3months',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = '3months'),
                          ),
                          ChoiceChip(
                            label: const Text('Food - 1 Month'),
                            selected: selectedPeriod == 'food1',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = 'food1'),
                          ),
                          ChoiceChip(
                            label: const Text('Food - 3 Months'),
                            selected: selectedPeriod == 'food3',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = 'food3'),
                          ),
                          ChoiceChip(
                            label: const Text('Food - 4+ Months'),
                            selected: selectedPeriod == 'food4plus',
                            onSelected: (v) => setModalState(
                              () => selectedPeriod = 'food4plus',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        limitController,
                        'Budget Limit (${widget.currency})',
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
                          _addBudget(
                            Budget(
                              category: selectedCategory,
                              limit: limit,
                              period: selectedPeriod,
                            ),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Budget added successfully!'),
                            ),
                          );
                        },
                        child: const Text(
                          'Add Budget',
                          style: TextStyle(
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

  void _showFinanceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.green),
              title: const Text('Income Source'),
              onTap: () {
                Navigator.pop(ctx);
                _showIncomeSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.blue),
              title: const Text('Savings Goal'),
              onTap: () {
                Navigator.pop(ctx);
                _showGoalSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt, color: Colors.orange),
              title: const Text('Recurring Bill'),
              onTap: () {
                Navigator.pop(ctx);
                _showBillSheet();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomeSheet() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String frequency = 'monthly';
    DateTime selectedDate = DateTime.now();
    bool isRecurring = false;
    int recurringDuration = 12;
    String durationType = 'months';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setModalState) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      const Text(
                        'Add Income',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    children: [
                      const SizedBox(height: 12),
                      _buildTextField(
                        nameController,
                        'Source Name',
                        Icons.work,
                        hint: 'e.g., Salary, Freelance',
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        amountController,
                        'Amount (${widget.currency})',
                        Icons.attach_money,
                        keyboardType: TextInputType.number,
                        hint: '0',
                      ),
                      const SizedBox(height: 12),
                      // One-time vs Recurring Toggle
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isRecurring ? Icons.repeat : Icons.event,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Recurring Income',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isRecurring,
                                onChanged: (v) {
                                  setModalState(() {
                                    isRecurring = v;
                                    if (!v) {
                                      frequency = 'once';
                                    } else {
                                      frequency = 'monthly';
                                    }
                                  });
                                },
                                activeColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRecurring) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Frequency',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: ['weekly', 'monthly', 'yearly']
                              .map(
                                (f) => ChoiceChip(
                                  label: Text(
                                    f[0].toUpperCase() + f.substring(1),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  selected: frequency == f,
                                  selectedColor: Colors.blue.shade100,
                                  onSelected: (v) =>
                                      setModalState(() => frequency = f),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Duration',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: recurringDuration,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    items: [
                                      for (int i = 1; i <= 24; i++)
                                        DropdownMenuItem(
                                          value: i,
                                          child: Text('$i'),
                                        ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => recurringDuration = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: durationType,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'months',
                                        child: Text('Months'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'years',
                                        child: Text('Years'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => durationType = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Repeats for ${recurringDuration} ${durationType}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDate(selectedDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
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
                          _addIncomeSource(
                            IncomeSource(
                              name: nameController.text.trim(),
                              amount: amount,
                              frequency: isRecurring ? frequency : 'once',
                              date: selectedDate,
                            ),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Income added successfully!'),
                            ),
                          );
                        },
                        child: const Text('Add Income'),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGoalSheet() {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 365));

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
                    const Text(
                      'Add Goal',
                      style: TextStyle(
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
                          if (picked != null) {
                            setModalState(() => targetDate = picked);
                          }
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
                          _addSavingsGoal(
                            SavingsGoal(
                              name: nameController.text.trim(),
                              targetAmount: target,
                              targetDate: targetDate,
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Add Goal'),
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

  void _showBillSheet() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    int dueDay = 1;
    String frequency = 'Monthly';

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
                    const Text(
                      'Add Bill',
                      style: TextStyle(
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
                        initialValue: dueDay,
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
                          _addRecurringBill(
                            RecurringBill(
                              name: nameController.text.trim(),
                              amount: amount,
                              dueDay: dueDay,
                              frequency: frequency,
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        child: const Text('Add Bill'),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: _buildCurrentPage(),
      floatingActionButton: _buildFab(),
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
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD PAGE ====================

class DashboardPage extends StatelessWidget {
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
    required this.onQuickAddIncome,
  });
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
  final VoidCallback onQuickAddIncome;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyExpenses = expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();
    final totalExpenses = monthlyExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalIncome = incomeSources.fold(0.0, (sum, i) => sum + i.amount);
    final displayIncome = totalIncome > 0
        ? totalIncome
        : (profile['monthlyIncome'] ?? 0.0);
    final balance = displayIncome - totalExpenses;

    // Calculate spending by category for pie chart
    final categorySpending = <String, double>{};
    for (var expense in monthlyExpenses) {
      categorySpending[expense.category] =
          (categorySpending[expense.category] ?? 0) + expense.amount;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              '${_getMonthName(now.month)} ${now.year}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => _showCurrencyPicker(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content area with chart
          Expanded(
            child: categorySpending.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 100,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No expenses this month',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first expense',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.maxWidth < constraints.maxHeight
                          ? constraints.maxWidth * 0.7
                          : constraints.maxHeight * 0.7;
                      
                      return Center(
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pie Chart
                              CustomPaint(
                                size: Size(size, size),
                                painter: _PieChartPainter(
                                  categorySpending,
                                  Colors.white,
                                ),
                              ),
                              
                              // Center amount
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatCurrency(totalExpenses, currency),
                                    style: TextStyle(
                                      fontSize: size * 0.08,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Category icons around the circle
                              ..._buildCategoryIcons(categorySpending, size),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Bottom balance bar (Monefy style)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatCurrency(balance, currency),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom buttons (- and +)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Minus button (expense)
                InkWell(
                  onTap: onQuickAdd,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.shade300,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: Colors.red.shade300,
                      size: 32,
                    ),
                  ),
                ),
                // Plus button (income)
                InkWell(
                  onTap: onQuickAddIncome,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.green.shade300,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  List<Widget> _buildCategoryIcons(Map<String, double> spending, double chartSize) {
    final categories = spending.keys.toList();
    final total = spending.values.fold(0.0, (a, b) => a + b);
    final radius = chartSize * 0.55; // Position icons outside the chart
    
    return List.generate(
      categories.length > 8 ? 8 : categories.length,
      (index) {
        final category = categories[index];
        final color = CategoryHelper.getColor(category);
        final percentage = (spending[category]! / total * 100).toStringAsFixed(0);
        
        // Calculate position around circle
        final angle = (index * 2 * math.pi / (categories.length > 8 ? 8 : categories.length)) - math.pi / 2;
        final x = radius * math.cos(angle);
        final y = radius * math.sin(angle);
        
        return Positioned(
          left: chartSize / 2 + x - 25,
          top: chartSize / 2 + y - 25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CategoryHelper.getIcon(category),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      },
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

  Future<void> _exportToCSV(BuildContext context) async {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No expenses to export')));
      return;
    }

    try {
      // Create CSV content
      final StringBuffer csv = StringBuffer();
      csv.writeln('Date,Title,Category,Amount ($currency),Notes');

      for (final expense in expenses) {
        final date =
            '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
        final title = expense.title.replaceAll(',', ';');
        final notes = (expense.notes ?? '').replaceAll(',', ';');
        csv.writeln(
          '$date,$title,${expense.category},${expense.amount},$notes',
        );
      }

      // Get temporary directory and save file
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'expenses_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csv.toString());

      // Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], subject: 'Expense Report - ${formatDate(now)}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expenses exported successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
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
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.currency,
  });
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String currency;

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

class _QuickStatCard extends StatefulWidget {
  const _QuickStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  State<_QuickStatCard> createState() => _QuickStatCardState();
}

class _QuickStatCardState extends State<_QuickStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() => _isPressed = true);
                _controller.forward();
              },
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _controller.reverse();
              },
              onTapCancel: () {
                setState(() => _isPressed = false);
                _controller.reverse();
              },
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Card(
                      elevation: _isPressed ? 1 : 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withOpacity(0.05),
                              widget.color.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 600),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.elasticOut,
                                  builder: (context, iconValue, child) {
                                    return Transform.scale(
                                      scale: iconValue,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: widget.color.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          widget.icon,
                                          color: widget.color,
                                          size: 20,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                TweenAnimationBuilder<double>(
                                  duration: const Duration(milliseconds: 800),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOut,
                                  builder: (context, badgeValue, child) {
                                    return Transform.scale(
                                      scale: badgeValue,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          widget.value,
                                          style: TextStyle(
                                            color: widget.color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 500),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, textValue, child) {
                                return Opacity(
                                  opacity: textValue,
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpendingComparisonCard extends StatelessWidget {
  const _SpendingComparisonCard({
    required this.current,
    required this.previous,
    required this.currency,
  });
  final double current;
  final double previous;
  final String currency;

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
  const _SpendingChartCard({
    required this.categorySpending,
    required this.currency,
  });
  final Map<String, double> categorySpending;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final total = categorySpending.values.fold(0.0, (a, b) => a + b);
    final sorted = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.donut_large_rounded,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Spending by Category',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(140, 140),
                          painter: _PieChartPainter(
                            categorySpending,
                            Theme.of(context).cardColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatCurrency(total, currency),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sorted
                          .take(5)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: CategoryHelper.getColor(e.key),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CategoryHelper.getColor(e.key)
                                              .withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: CategoryHelper.getColor(e.key)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(e.value / total * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: CategoryHelper.getColor(e.key),
                                      ),
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
  _PieChartPainter(this.data, this.centerColor);
  final Map<String, double> data;
  final Color centerColor;

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
  const _BudgetAlertCard({required this.budget, required this.currency});
  final Budget budget;
  final String currency;

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
  const _ProgressCard({
    required this.current,
    required this.target,
    required this.color,
    this.showRemaining = false,
    required this.currency,
  });
  final double current, target;
  final Color color;
  final bool showRemaining;
  final String currency;

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
  const _BillTile({required this.bill, required this.currency});
  final RecurringBill bill;
  final String currency;

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
  const _GoalTile({required this.goal, required this.currency});
  final SavingsGoal goal;
  final String currency;

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
  const _TransactionTile({required this.expense, required this.currency});
  final Expense expense;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final color = CategoryHelper.getColor(expense.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Can add navigation to expense details
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                expense.category,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              formatShortDate(expense.date),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${formatCurrency(expense.amount, currency)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red.shade600,
                      ),
                    ),
                    if (expense.isRecurring)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 10,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Recurring',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
  bool isRecurring = expense?.isRecurring ?? false;

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
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
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

                    // Recurring checkbox
                    CheckboxListTile(
                      title: const Text('Recurring Expense'),
                      subtitle: const Text('This expense repeats every month'),
                      value: isRecurring,
                      onChanged: (value) => setModalState(() => isRecurring = value ?? false),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 8),

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
                            isRecurring: isRecurring,
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

// ==================== INCOME SHEET HELPER ====================

void showIncomeSheet({
  required BuildContext context,
  required String currency,
  required Function(IncomeSource) onSave,
  IncomeSource? income,
}) {
  final isEdit = income != null;
  final nameController = TextEditingController(text: income?.name ?? '');
  final amountController = TextEditingController(
    text: income?.amount.toStringAsFixed(0) ?? '',
  );
  String frequency = income?.frequency ?? 'monthly';
  DateTime selectedDate = income?.date ?? DateTime.now();
  bool isRecurring = income?.frequency != 'once';
  int recurringDuration = 12; // Default 12 months
  String durationType = 'months'; // 'months' or 'years'

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
                      'Amount ($currency)',
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                      hint: '0',
                    ),
                    const SizedBox(height: 20),
                    // One-time vs Recurring Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isRecurring ? Icons.repeat : Icons.event,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Recurring Income',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isRecurring,
                            onChanged: (v) {
                              setModalState(() {
                                isRecurring = v;
                                if (!v) {
                                  frequency = 'once';
                                } else {
                                  frequency = 'monthly';
                                }
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    if (isRecurring) ...[
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
                        children: ['weekly', 'monthly', 'yearly']
                            .map(
                              (f) => ChoiceChip(
                                label: Text(f[0].toUpperCase() + f.substring(1)),
                                selected: frequency == f,
                                selectedColor: Colors.blue.shade100,
                                onSelected: (v) =>
                                    setModalState(() => frequency = f),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: recurringDuration,
                                  isExpanded: true,
                                  items: [
                                    for (int i = 1; i <= 24; i++)
                                      DropdownMenuItem(
                                        value: i,
                                        child: Text('$i'),
                                      ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setModalState(() => recurringDuration = v);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: durationType,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'months',
                                      child: Text('Months'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'years',
                                      child: Text('Years'),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setModalState(() => durationType = v);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Income will repeat for ${recurringDuration} ${durationType}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
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
                        if (picked != null) {
                          setModalState(() => selectedDate = picked);
                        }
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
                          ],
                        ),
                      ),
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
                        onSave(
                          IncomeSource(
                            id: income?.id,
                            name: nameController.text.trim(),
                            amount: amount,
                            frequency: frequency,
                            date: selectedDate,
                          ),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Income ${isEdit ? "updated" : "added"} successfully!',
                            ),
                          ),
                        );
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

// ==================== EXPENSES PAGE ====================

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({
    super.key,
    required this.expenses,
    required this.budgets,
    required this.currency,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });
  final List<Expense> expenses;
  final List<Budget> budgets;
  final String currency;
  final Function(Expense) onAdd;
  final Function(Expense) onUpdate;
  final Function(String) onDelete;

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
    final totalExpenses = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () => _showFilterSheet(categories),
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Expenses Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  'TOTAL EXPENSES',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(totalExpenses, widget.currency),
                  style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // Expense List
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredExpenses.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      final color = CategoryHelper.getColor(expense.category);
                      
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(
                            CategoryHelper.getIcon(expense.category),
                            color: color,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          '${expense.category} • ${formatShortDate(expense.date)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          formatCurrency(expense.amount, widget.currency),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red.shade400,
                          ),
                        ),
                        onTap: () => _showExpenseDetails(expense),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 30,
              backgroundColor: CategoryHelper.getColor(expense.category).withOpacity(0.15),
              child: Icon(
                CategoryHelper.getIcon(expense.category),
                color: CategoryHelper.getColor(expense.category),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              expense.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(expense.amount, widget.currency),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${expense.category} • ${formatDate(expense.date)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            if (expense.notes != null && expense.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expense.notes!,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showExpenseSheet(
                        context: context,
                        budgets: widget.budgets,
                        currency: widget.currency,
                        onSave: widget.onUpdate,
                        expense: expense,
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onDelete(expense.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense deleted')),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
                Navigator.pop(ctx);
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _dateRange,
                );
                if (range != null) setState(() => _dateRange = range);
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
  const BudgetsPage({
    super.key,
    required this.budgets,
    required this.currency,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });
  final List<Budget> budgets;
  final String currency;
  final Function(Budget) onAdd;
  final Function(Budget) onUpdate;
  final Function(String) onDelete;

  @override
  Widget build(BuildContext context) {
    final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.limit);
    final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spent);
    final remaining = totalBudget - totalSpent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
      ),
      body: budgets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets set',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Budget Summary Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        'TOTAL BUDGET',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency(totalBudget, currency),
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                formatCurrency(totalSpent, currency),
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SPENT',
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
                                formatCurrency(remaining, currency),
                                style: TextStyle(
                                  color: remaining >= 0 ? Colors.green.shade400 : Colors.red.shade400,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'REMAINING',
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
                
                // Budget List
                Expanded(
                  child: ListView.separated(
                    itemCount: budgets.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final budget = budgets[index];
                      final color = CategoryHelper.getColor(budget.category);
                      final progress = budget.progress.clamp(0.0, 1.0);
                      
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.15),
                          child: Icon(
                            CategoryHelper.getIcon(budget.category),
                            color: color,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          budget.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  budget.isOverBudget ? Colors.red.shade400 : color,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${formatCurrency(budget.spent, currency)} of ${formatCurrency(budget.limit, currency)}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: budget.isOverBudget ? Colors.red.shade400 : color,
                          ),
                        ),
                        onTap: () => _showBudgetDetails(context, budget),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showBudgetDetails(BuildContext context, Budget budget) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 30,
              backgroundColor: CategoryHelper.getColor(budget.category).withOpacity(0.15),
              child: Icon(
                CategoryHelper.getIcon(budget.category),
                color: CategoryHelper.getColor(budget.category),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              budget.category,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Budget: ${formatCurrency(budget.limit, currency)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      formatCurrency(budget.spent, currency),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Spent',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      formatCurrency(budget.remaining, currency),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: budget.remaining >= 0 ? Colors.green.shade400 : Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remaining',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showBudgetSheet(context, budget: budget);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onDelete(budget.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget deleted')),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    String selectedPeriod = budget?.period ?? 'monthly';
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

    if (!isEdit && availableCategories.isNotEmpty) {
      selectedCategory = availableCategories.first;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                      const Text(
                        'Budget Period',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Monthly'),
                            selected: selectedPeriod == 'monthly',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = 'monthly'),
                          ),
                          ChoiceChip(
                            label: const Text('3 Months'),
                            selected: selectedPeriod == '3months',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = '3months'),
                          ),
                          ChoiceChip(
                            label: const Text('Food - 1 Month'),
                            selected: selectedPeriod == 'food1',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = 'food1'),
                          ),
                          ChoiceChip(
                            label: const Text('Food - 3 Months'),
                            selected: selectedPeriod == 'food3',
                            onSelected: (v) =>
                                setModalState(() => selectedPeriod = 'food3'),
                          ),
                          ChoiceChip(
                            label: const Text('Food - 4+ Months'),
                            selected: selectedPeriod == 'food4plus',
                            onSelected: (v) => setModalState(
                              () => selectedPeriod = 'food4plus',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                            onUpdate(
                              budget.copyWith(
                                limit: limit,
                                period: selectedPeriod,
                              ),
                            );
                          } else {
                            onAdd(
                              Budget(
                                category: selectedCategory,
                                limit: limit,
                                period: selectedPeriod,
                              ),
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
    String frequency = income?.frequency ?? 'monthly';
    DateTime selectedDate = income?.date ?? DateTime.now();
    bool isRecurring = income?.frequency != 'once';
    int recurringDuration = 12;
    String durationType = 'months';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setModalState) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        isEdit ? 'Edit Income' : 'Add Income',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                    ),
                    children: [
                      const SizedBox(height: 12),
                      _buildTextField(
                        nameController,
                        'Source Name',
                        Icons.work,
                        hint: 'e.g., Salary, Freelance',
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        amountController,
                        'Amount (${widget.currency})',
                        Icons.attach_money,
                        keyboardType: TextInputType.number,
                        hint: '0',
                      ),
                      const SizedBox(height: 12),
                      // One-time vs Recurring Toggle
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isRecurring ? Icons.repeat : Icons.event,
                              color: Colors.blue,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Recurring Income',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const Spacer(),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isRecurring,
                                onChanged: (v) {
                                  setModalState(() {
                                    isRecurring = v;
                                    if (!v) {
                                      frequency = 'once';
                                    } else {
                                      frequency = 'monthly';
                                    }
                                  });
                                },
                                activeColor: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRecurring) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Frequency',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          children: ['weekly', 'monthly', 'yearly']
                              .map(
                                (f) => ChoiceChip(
                                  label: Text(
                                    f[0].toUpperCase() + f.substring(1),
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  selected: frequency == f,
                                  selectedColor: Colors.blue.shade100,
                                  onSelected: (v) =>
                                      setModalState(() => frequency = f),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Duration',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: recurringDuration,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    items: [
                                      for (int i = 1; i <= 24; i++)
                                        DropdownMenuItem(
                                          value: i,
                                          child: Text('$i'),
                                        ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => recurringDuration = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: durationType,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'months',
                                        child: Text('Months'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'years',
                                        child: Text('Years'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        setModalState(() => durationType = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Repeats for ${recurringDuration} ${durationType}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDate(selectedDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 14),
                        ),
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
                          final incomeSource = IncomeSource(
                            id: income?.id,
                            name: nameController.text.trim(),
                            amount: amount,
                            frequency: isRecurring ? frequency : 'once',
                            date: selectedDate,
                          );
                          if (isEdit) {
                            widget.onUpdateIncome(incomeSource);
                          } else {
                            widget.onAddIncome(incomeSource);
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Income ${isEdit ? "updated" : "added"} successfully!',
                              ),
                            ),
                          );
                        },
                        child: Text(isEdit ? 'Save Changes' : 'Add Income'),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
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
                if (goal.fundAdditions.isNotEmpty) ...[
                  const Text(
                    'Fund History',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: goal.fundAdditions.length,
                      itemBuilder: (context, index) {
                        final fund = goal.fundAdditions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatShortDate(fund.date),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                formatCurrency(fund.amount, widget.currency),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
                          if (picked != null) {
                            setModalState(() => targetDate = picked);
                          }
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
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                amountController,
                'Amount (${widget.currency})',
                Icons.add,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        formatDate(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) return;
                  HapticFeedback.mediumImpact();

                  final updatedFunds = [...goal.fundAdditions];
                  updatedFunds.add(
                    FundAddition(amount: amount, date: selectedDate),
                  );

                  widget.onUpdateGoal(
                    goal.copyWith(
                      currentAmount: goal.currentAmount + amount,
                      fundAdditions: updatedFunds,
                    ),
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
                        initialValue: dueDay,
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
