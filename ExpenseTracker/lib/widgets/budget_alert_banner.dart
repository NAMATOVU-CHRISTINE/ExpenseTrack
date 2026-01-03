import 'package:flutter/material.dart';

class BudgetAlertBanner extends StatelessWidget {

  const BudgetAlertBanner({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    required this.currency,
    this.onDismiss,
  });
  final String category;
  final double spent;
  final double limit;
  final String currency;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final isOverBudget = spent > limit;
    final percentage = (spent / limit * 100).clamp(0, 150);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [Colors.red.shade400, Colors.red.shade600]
              : [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? Colors.red : Colors.orange).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isOverBudget ? Icons.warning : Icons.info,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOverBudget
                          ? '$category Budget Exceeded!'
                          : '$category Budget Warning',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOverBudget
                          ? 'Over by $currency ${(spent - limit).toStringAsFixed(0)}'
                          : '${percentage.toStringAsFixed(0)}% used - $currency ${(limit - spent).toStringAsFixed(0)} remaining',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onDismiss,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BudgetAlertList extends StatelessWidget {

  const BudgetAlertList({
    super.key,
    required this.alerts,
    required this.currency,
    this.onDismiss,
  });
  final List<BudgetAlert> alerts;
  final String currency;
  final Function(String)? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      children: alerts.map((alert) {
        return BudgetAlertBanner(
          category: alert.category,
          spent: alert.spent,
          limit: alert.limit,
          currency: currency,
          onDismiss: onDismiss != null
              ? () => onDismiss!(alert.category)
              : null,
        );
      }).toList(),
    );
  }
}

class BudgetAlert {

  BudgetAlert({
    required this.category,
    required this.spent,
    required this.limit,
  });
  final String category;
  final double spent;
  final double limit;

  bool get isOverBudget => spent > limit;
  bool get isNearLimit => spent / limit >= 0.8 && !isOverBudget;
}
