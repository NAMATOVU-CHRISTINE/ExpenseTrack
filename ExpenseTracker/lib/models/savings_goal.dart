/// Represents a savings goal
class SavingsGoalModel {

  SavingsGoalModel({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.targetDate,
    this.description,
    this.iconName,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) =>
      SavingsGoalModel(
        id: json['id'],
        name: json['name'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
        targetDate: DateTime.parse(json['targetDate']),
        description: json['description'],
        iconName: json['iconName'],
      );
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime targetDate;
  final String? description;
  final String? iconName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'description': description,
    'iconName': iconName,
  };

  SavingsGoalModel copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
    String? iconName,
  }) {
    return SavingsGoalModel(
      id: id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
    );
  }

  /// Progress as a value between 0 and 1
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0, 1) : 0;

  /// Remaining amount to reach goal
  double get remaining => targetAmount - currentAmount;

  /// Whether the goal has been reached
  bool get isCompleted => currentAmount >= targetAmount;

  /// Days remaining until target date
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  /// Whether the target date has passed
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  /// Suggested daily savings to reach goal on time
  double get suggestedDailySavings {
    if (isCompleted || daysRemaining <= 0) return 0;
    return remaining / daysRemaining;
  }

  /// Percentage of goal completed
  double get percentageCompleted => progress * 100;
}
