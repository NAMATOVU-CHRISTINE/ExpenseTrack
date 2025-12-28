# Architecture Overview

This document describes the architecture of the ExpenseTracker Flutter application.

## Overview

ExpenseTracker is a mobile application built with Flutter that helps users track their expenses, manage budgets, and achieve savings goals.

## App Structure

```
lib/
└── main.dart          # Single-file architecture containing all widgets and logic
```

## Core Components

### 1. Data Models

- **Expense** - Represents a single expense entry
- **Budget** - Category-based spending limits
- **IncomeSource** - User income streams
- **SavingsGoal** - Financial targets
- **RecurringBill** - Regular payment tracking

### 2. Data Service

Uses `SharedPreferences` for local data persistence. All data is stored on-device with no cloud sync.

### 3. UI Pages

- **DashboardPage** - Overview of finances
- **ExpensesPage** - List and manage expenses
- **BudgetsPage** - Budget management
- **FinancePage** - Income, goals, and bills

## State Management

The app uses Flutter's built-in `setState` for state management, suitable for this app's complexity level.

## Navigation

Uses conditional rendering instead of `IndexedStack` to prevent widget lifecycle issues.

## Future Improvements

- Separate files for models, services, and widgets
- Add state management (Provider/Riverpod)
- Implement cloud sync
