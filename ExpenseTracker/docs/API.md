# API Reference

## Models

### Expense

| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier |
| title | String | Expense description |
| amount | double | Amount spent |
| category | String | Category name |
| date | DateTime | Date of expense |
| notes | String? | Optional notes |
| isRecurring | bool | Is recurring expense |

### Budget

| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier |
| category | String | Category name |
| limit | double | Budget limit |
| spent | double | Amount spent |
| warningThreshold | double | Warning at percentage |

### IncomeSource

| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier |
| name | String | Source name |
| amount | double | Income amount |
| frequency | String | Monthly/Weekly/Yearly |

### SavingsGoal

| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier |
| name | String | Goal name |
| targetAmount | double | Target to save |
| currentAmount | double | Current savings |
| targetDate | DateTime | Target date |

### RecurringBill

| Property | Type | Description |
|----------|------|-------------|
| id | String | Unique identifier |
| name | String | Bill name |
| amount | double | Bill amount |
| dueDay | int | Day of month due |
| frequency | String | Monthly/Quarterly/Yearly |
| isPaid | bool | Payment status |

## DataService Methods

| Method | Returns | Description |
|--------|---------|-------------|
| getExpenses() | Future<List<Expense>> | Get all expenses |
| saveExpenses(List<Expense>) | Future<void> | Save expenses |
| getBudgets() | Future<List<Budget>> | Get all budgets |
| saveBudgets(List<Budget>) | Future<void> | Save budgets |
| getIncomeSources() | Future<List<IncomeSource>> | Get income sources |
| getSavingsGoals() | Future<List<SavingsGoal>> | Get savings goals |
| getRecurringBills() | Future<List<RecurringBill>> | Get recurring bills |
