import 'package:flutter/material.dart';
import 'dart:collection';

class CalendarScreen extends StatefulWidget {
  final List<dynamic> expenses;
  final List<dynamic> incomes;
  final String currency;
  final Function(dynamic)? onExpenseTap;

  const CalendarScreen({
    super.key,
    required this.expenses,
    required this.incomes,
    required this.currency,
    this.onExpenseTap,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  Map<DateTime, List<dynamic>> _getEventsForMonth() {
    final events = <DateTime, List<dynamic>>{};

    for (final expense in widget.expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      events.putIfAbsent(date, () => []).add({
        'type': 'expense',
        'data': expense,
      });
    }

    for (final income in widget.incomes) {
      final date = DateTime(
        income.date.year,
        income.date.month,
        income.date.day,
      );
      events.putIfAbsent(date, () => []).add({
        'type': 'income',
        'data': income,
      });
    }

    return events;
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final events = _getEventsForMonth();
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime.now();
                _selectedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          _buildCalendarGrid(),
          const Divider(height: 1),
          Expanded(child: _buildEventsList()),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                  _focusedMonth.year,
                  _focusedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;

    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final events = _getEventsForMonth();

    return Column(
      children: [
        Row(
          children: days
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayNumber = index - startingWeekday + 1;

            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox();
            }

            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              dayNumber,
            );
            final normalizedDate = DateTime(date.year, date.month, date.day);
            final dayEvents = events[normalizedDate] ?? [];
            final isSelected =
                _selectedDate != null &&
                _selectedDate!.year == date.year &&
                _selectedDate!.month == date.month &&
                _selectedDate!.day == date.day;
            final isToday =
                DateTime.now().year == date.year &&
                DateTime.now().month == date.month &&
                DateTime.now().day == date.day;

            final hasExpense = dayEvents.any((e) => e['type'] == 'expense');
            final hasIncome = dayEvents.any((e) => e['type'] == 'income');

            return GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : isToday
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: Theme.of(context).colorScheme.primary)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                        fontWeight: isToday ? FontWeight.bold : null,
                      ),
                    ),
                    if (hasExpense || hasIncome)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (hasExpense)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (hasIncome)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    if (_selectedDate == null) {
      return const Center(child: Text('Select a date'));
    }

    final events = _getEventsForDay(_selectedDate!);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions on this day',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    double totalExpenses = 0;
    double totalIncome = 0;

    for (final event in events) {
      if (event['type'] == 'expense') {
        totalExpenses += event['data'].amount;
      } else {
        totalIncome += event['data'].amount;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Expenses',
                  amount: totalExpenses,
                  currency: widget.currency,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Income',
                  amount: totalIncome,
                  currency: widget.currency,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isExpense = event['type'] == 'expense';
              final data = event['data'];

              return Card(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isExpense ? Colors.red : Colors.green)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  title: Text(isExpense ? data.title : data.name),
                  subtitle: Text(
                    isExpense ? data.category : (data.source ?? 'Income'),
                  ),
                  trailing: Text(
                    '${isExpense ? '-' : '+'}${widget.currency} ${data.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isExpense ? Colors.red : Colors.green,
                    ),
                  ),
                  onTap: isExpense && widget.onExpenseTap != null
                      ? () => widget.onExpenseTap!(data)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '$currency ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
