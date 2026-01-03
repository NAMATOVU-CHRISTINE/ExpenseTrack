class AppConstants {
  // Income frequencies
  static const List<String> incomeFrequencies = [
    'once',
    'weekly',
    'bi-weekly',
    'monthly',
    'yearly',
  ];

  static const Map<String, String> frequencyLabels = {
    'once': 'One-time',
    'weekly': 'Weekly',
    'bi-weekly': 'Bi-weekly',
    'monthly': 'Monthly',
    'yearly': 'Yearly',
  };

  // Income sources
  static const List<String> incomeSources = [
    'Salary',
    'Freelance',
    'Gift',
    'Investment',
    'Refund',
    'Bonus',
    'Side Hustle',
    'Other',
  ];

  // Expense categories
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Education',
    'Rent',
    'Utilities',
    'General',
  ];

  // Currencies
  static const List<String> currencies = [
    'UGX',
    'USD',
    'EUR',
    'GBP',
    'KES',
    'TZS',
    'NGN',
    'ZAR',
    'INR',
  ];

  static const Map<String, String> currencySymbols = {
    'UGX': 'UGX',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'KES': 'KES',
    'TZS': 'TZS',
    'NGN': '₦',
    'ZAR': 'R',
    'INR': '₹',
  };

  // Bill reminder days
  static const List<int> reminderDays = [1, 2, 3, 5, 7, 14];
}
