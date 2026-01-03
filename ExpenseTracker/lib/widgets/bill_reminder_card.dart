import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class BillReminderCard extends StatelessWidget {
  final BillReminder reminder;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BillReminderCard({
    super.key,
    required this.reminder,
    required this.currency,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilDue = _getDaysUntilDue();
    final isUrgent = daysUntilDue <= 3;
    final isDueToday = daysUntilDue == 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.red.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: isUrgent ? Colors.red : Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.billName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currency ${reminder.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDueToday
                          ? Colors.red
                          : isUrgent
                          ? Colors.orange
                          : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDueToday ? 'Due Today' : '$daysUntilDue days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${reminder.dueDay}th',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _getDaysUntilDue() {
    final now = DateTime.now();
    var dueDate = DateTime(now.year, now.month, reminder.dueDay);

    if (dueDate.isBefore(now)) {
      dueDate = DateTime(now.year, now.month + 1, reminder.dueDay);
    }

    return dueDate.difference(now).inDays;
  }
}
