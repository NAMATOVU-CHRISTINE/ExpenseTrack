# Testing Guide

## Running Tests

```bash
cd ExpenseTracker
flutter test
```

## Test Structure

```
test/
├── unit/           # Unit tests for models and services
├── widget/         # Widget tests for UI components
└── integration/    # Integration tests
```

## Writing Tests

### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expense', () {
    test('should create expense with correct values', () {
      final expense = Expense(
        title: 'Lunch',
        amount: 15.00,
        category: 'Food',
        date: DateTime.now(),
      );
      
      expect(expense.title, 'Lunch');
      expect(expense.amount, 15.00);
      expect(expense.category, 'Food');
    });
  });
}
```

### Widget Test Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Dashboard shows welcome message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));
    
    expect(find.text('Welcome back!'), findsOneWidget);
  });
}
```

## Code Coverage

```bash
flutter test --coverage
```

View coverage report in `coverage/lcov.info`.
