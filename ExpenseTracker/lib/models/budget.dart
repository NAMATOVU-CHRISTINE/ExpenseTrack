/// Represents a budget for a specific category
class BudgetModel {

  BudgetModel({
    String? id,
    required this.category,
    required this.limit,
    this.spent = 0,
    this.warningThreshold = 0.8,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
    id: json['id'],
    category: json['category'],
    limit: (json['limit'] as num).toDouble(),
    spent: (json['spent'] as num?)?.toDouble() ?? 0,
    warningThreshold: (json['warningThreshold'] as num?)?.toDouble() ?? 0.8,
  );
  final String id;
  final String category;
  final double limit;
  double spent;
  final double warningThreshold;

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'limit': limit,
    'spent': spent,
    'warningThreshold': warningThreshold,
  };

  BudgetModel copyWith({
    String? category,
    double? limit,
    double? spent,
    double? warningThreshold,
  }) {
    return BudgetModel(
      id: id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      warningThreshold: warningThreshold ?? this.warningThreshold,
    );
  }

  /// Progress as a value between 0 and 1.5 (can exceed 1 if over budget)
  double get progress => limit > 0 ? (spent / limit).clamp(0, 1.5) : 0;

  /// Remaining budget amount
  double get remaining => limit - spent;

  /// Whether spending has exceeded the budget limit
  bool get isOverBudget => spent > limit;

  /// Whether spending is near the warning threshold but not over budget
  bool get isNearLimit => progress >= warningThreshold && !isOverBudget;

  /// Percentage of budget used
  double get percentageUsed => progress * 100;

  /// Amount over budget (0 if not over)
  double get amountOver => isOverBudget ? spent - limit : 0;
}
