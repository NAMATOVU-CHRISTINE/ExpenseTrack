/// Represents a financial transaction (expense or income)
class Transaction {

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.notes,
    this.receiptPath,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    title: json['title'],
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date']),
    category: json['category'],
    type: json['type'] == 'income'
        ? TransactionType.income
        : TransactionType.expense,
    notes: json['notes'],
    receiptPath: json['receiptPath'],
  );
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final TransactionType type;
  final String? notes;
  final String? receiptPath;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'type': type == TransactionType.income ? 'income' : 'expense',
    'notes': notes,
    'receiptPath': receiptPath,
  };

  Transaction copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    TransactionType? type,
    String? notes,
    String? receiptPath,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
}

enum TransactionType { expense, income }
