import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/bill_reminder_card.dart';

class BillRemindersScreen extends StatefulWidget {
  final String currency;

  const BillRemindersScreen({super.key, required this.currency});

  @override
  State<BillRemindersScreen> createState() => _BillRemindersScreenState();
}

class _BillRemindersScreenState extends State<BillRemindersScreen> {
  List<BillReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    await NotificationService.initialize();
    setState(() {
      _reminders = NotificationService.billReminders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
          ? _buildEmptyState()
          : _buildRemindersList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Bill Reminders',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add reminders to never miss a payment',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddReminderDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    final upcoming = NotificationService.getUpcomingReminders();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (upcoming.isNotEmpty) ...[
          Text(
            'Upcoming Bills',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          ...upcoming.map(
            (r) => BillReminderCard(
              reminder: r,
              currency: widget.currency,
              onDelete: () => _deleteReminder(r.id),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'All Reminders',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        ..._reminders.map(
          (r) => BillReminderCard(
            reminder: r,
            currency: widget.currency,
            onTap: () => _showEditReminderDialog(r),
            onDelete: () => _deleteReminder(r.id),
          ),
        ),
      ],
    );
  }

  void _showAddReminderDialog() {
    _showReminderDialog();
  }

  void _showEditReminderDialog(BillReminder reminder) {
    _showReminderDialog(reminder: reminder);
  }

  void _showReminderDialog({BillReminder? reminder}) {
    final nameController = TextEditingController(
      text: reminder?.billName ?? '',
    );
    final amountController = TextEditingController(
      text: reminder?.amount.toStringAsFixed(0) ?? '',
    );
    int dueDay = reminder?.dueDay ?? 1;
    int reminderDays = reminder?.reminderDaysBefore ?? 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(reminder == null ? 'Add Reminder' : 'Edit Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Bill Name',
                    prefixIcon: Icon(Icons.receipt),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: dueDay,
                  decoration: const InputDecoration(
                    labelText: 'Due Day of Month',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: List.generate(28, (i) => i + 1)
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => dueDay = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: reminderDays,
                  decoration: const InputDecoration(
                    labelText: 'Remind Before',
                    prefixIcon: Icon(Icons.notifications),
                  ),
                  items: [1, 2, 3, 5, 7]
                      .map(
                        (d) =>
                            DropdownMenuItem(value: d, child: Text('$d days')),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() => reminderDays = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final amount = double.tryParse(amountController.text) ?? 0;

                if (name.isEmpty || amount <= 0) return;

                final newReminder = BillReminder(
                  id: reminder?.id,
                  billName: name,
                  amount: amount,
                  dueDay: dueDay,
                  reminderDaysBefore: reminderDays,
                );

                if (reminder == null) {
                  await NotificationService.addBillReminder(newReminder);
                } else {
                  await NotificationService.updateBillReminder(newReminder);
                }

                Navigator.pop(ctx);
                _loadReminders();
              },
              child: Text(reminder == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReminder(String id) async {
    await NotificationService.removeBillReminder(id);
    _loadReminders();
  }
}
