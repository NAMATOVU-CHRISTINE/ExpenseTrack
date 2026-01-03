import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationService {
  static const String _billRemindersKey = 'bill_reminders';
  static const String _budgetAlertsKey = 'budget_alerts_enabled';

  static bool _budgetAlertsEnabled = true;
  static List<BillReminder> _billReminders = [];

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _budgetAlertsEnabled = prefs.getBool(_budgetAlertsKey) ?? true;
    await _loadBillReminders();
  }

  static Future<void> _loadBillReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_billRemindersKey);
    if (data != null) {
      final list = json.decode(data) as List;
      _billReminders = list.map((e) => BillReminder.fromJson(e)).toList();
    }
  }

  static Future<void> _saveBillReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _billRemindersKey,
      json.encode(_billReminders.map((e) => e.toJson()).toList()),
    );
  }

  static bool get budgetAlertsEnabled => _budgetAlertsEnabled;

  static Future<void> setBudgetAlertsEnabled(bool enabled) async {
    _budgetAlertsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_budgetAlertsKey, enabled);
  }

  static List<BillReminder> get billReminders =>
      List.unmodifiable(_billReminders);

  static Future<void> addBillReminder(BillReminder reminder) async {
    _billReminders.add(reminder);
    await _saveBillReminders();
  }

  static Future<void> removeBillReminder(String id) async {
    _billReminders.removeWhere((r) => r.id == id);
    await _saveBillReminders();
  }

  static Future<void> updateBillReminder(BillReminder reminder) async {
    final index = _billReminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _billReminders[index] = reminder;
      await _saveBillReminders();
    }
  }

  static List<BillReminder> getUpcomingReminders() {
    final now = DateTime.now();
    final upcoming = _billReminders.where((r) {
      final dueDate = _getNextDueDate(r);
      final daysUntilDue = dueDate.difference(now).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= r.reminderDaysBefore;
    }).toList();

    upcoming.sort((a, b) => _getNextDueDate(a).compareTo(_getNextDueDate(b)));
    return upcoming;
  }

  static DateTime _getNextDueDate(BillReminder reminder) {
    final now = DateTime.now();
    var dueDate = DateTime(now.year, now.month, reminder.dueDay);

    if (dueDate.isBefore(now)) {
      dueDate = DateTime(now.year, now.month + 1, reminder.dueDay);
    }

    return dueDate;
  }
}

class BillReminder {
  final String id;
  final String billName;
  final double amount;
  final int dueDay;
  final int reminderDaysBefore;
  final bool isEnabled;

  BillReminder({
    String? id,
    required this.billName,
    required this.amount,
    required this.dueDay,
    this.reminderDaysBefore = 3,
    this.isEnabled = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory BillReminder.fromJson(Map<String, dynamic> json) => BillReminder(
    id: json['id'],
    billName: json['billName'],
    amount: (json['amount'] as num).toDouble(),
    dueDay: json['dueDay'],
    reminderDaysBefore: json['reminderDaysBefore'] ?? 3,
    isEnabled: json['isEnabled'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'billName': billName,
    'amount': amount,
    'dueDay': dueDay,
    'reminderDaysBefore': reminderDaysBefore,
    'isEnabled': isEnabled,
  };

  BillReminder copyWith({
    String? billName,
    double? amount,
    int? dueDay,
    int? reminderDaysBefore,
    bool? isEnabled,
  }) {
    return BillReminder(
      id: id,
      billName: billName ?? this.billName,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
