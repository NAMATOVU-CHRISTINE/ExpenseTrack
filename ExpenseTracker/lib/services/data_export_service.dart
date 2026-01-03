import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DataExportService {
  /// Export expenses to CSV format
  static Future<String> exportToCSV(List<Map<String, dynamic>> expenses) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Date,Title,Amount,Category,Notes');

    // Data rows
    for (final expense in expenses) {
      final date = expense['date'] is DateTime
          ? (expense['date'] as DateTime).toIso8601String().split('T')[0]
          : expense['date'].toString().split('T')[0];
      final title = _escapeCSV(expense['title'] ?? '');
      final amount = expense['amount']?.toString() ?? '0';
      final category = _escapeCSV(expense['category'] ?? '');
      final notes = _escapeCSV(expense['notes'] ?? '');

      buffer.writeln('$date,$title,$amount,$category,$notes');
    }

    return buffer.toString();
  }

  /// Export data to JSON format
  static String exportToJSON(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Save export to file and share
  static Future<void> shareExport(String content, String filename) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Expense Tracker Export');
  }

  /// Export expenses as CSV and share
  static Future<void> shareExpensesCSV(
    List<Map<String, dynamic>> expenses,
  ) async {
    final csv = await exportToCSV(expenses);
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    await shareExport(csv, 'expenses_$timestamp.csv');
  }

  /// Export all data as JSON and share
  static Future<void> shareAllDataJSON(Map<String, dynamic> allData) async {
    final json = exportToJSON(allData);
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    await shareExport(json, 'expense_tracker_backup_$timestamp.json');
  }

  /// Generate monthly report
  static Map<String, dynamic> generateMonthlyReport(
    List<Map<String, dynamic>> expenses,
    List<Map<String, dynamic>> incomes,
    int month,
    int year,
  ) {
    final monthExpenses = expenses.where((e) {
      final date = e['date'] is DateTime
          ? e['date']
          : DateTime.parse(e['date']);
      return date.month == month && date.year == year;
    }).toList();

    final monthIncomes = incomes.where((i) {
      final date = i['date'] is DateTime
          ? i['date']
          : DateTime.parse(i['date']);
      return date.month == month && date.year == year;
    }).toList();

    final totalExpenses = monthExpenses.fold<double>(
      0,
      (sum, e) => sum + (e['amount'] as num).toDouble(),
    );

    final totalIncome = monthIncomes.fold<double>(
      0,
      (sum, i) => sum + (i['amount'] as num).toDouble(),
    );

    // Group expenses by category
    final byCategory = <String, double>{};
    for (final expense in monthExpenses) {
      final category = expense['category'] as String;
      byCategory[category] =
          (byCategory[category] ?? 0) + (expense['amount'] as num).toDouble();
    }

    return {
      'month': month,
      'year': year,
      'totalExpenses': totalExpenses,
      'totalIncome': totalIncome,
      'netSavings': totalIncome - totalExpenses,
      'expenseCount': monthExpenses.length,
      'incomeCount': monthIncomes.length,
      'byCategory': byCategory,
      'topCategory': byCategory.isNotEmpty
          ? byCategory.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null,
    };
  }

  static String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
