# ExpenseTracker

A beautiful, feature-rich expense tracking app built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)

## Features

- **Expense Tracking** - Log daily expenses with categories and notes
- **Budget Management** - Set budgets per category with overspend alerts
- **Savings Goals** - Track progress toward financial goals
- **Recurring Bills** - Never miss a payment with bill tracking
- **Income Sources** - Track multiple income streams
- **Dark/Light Theme** - Easy on the eyes, day or night
- **Multi-Currency** - Support for UGX, USD, EUR, GBP, KES, and more
- **Offline First** - Works without internet connection

## Screenshots

| Dashboard | Expenses | Budgets | Finance |
|-----------|----------|---------|---------|
| ![Dashboard](screenshots/dashboard.png) | ![Expenses](screenshots/expenses.png) | ![Budgets](screenshots/budgets.png) | ![Finance](screenshots/finance.png) |

## Getting Started

### Prerequisites

- Flutter SDK 3.x or higher
- Dart 3.x or higher
- Android Studio / VS Code with Flutter extension
- Android device or emulator / iOS simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/NAMATOVU-CHRISTINE/ExpenseTrack.git
   cd ExpenseTrack/ExpenseTracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build APK

```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── main.dart          # App entry point and all widgets
├── models/            # Data models (Expense, Budget, etc.)
├── services/          # Data persistence service
└── utils/             # Helper functions and constants
```

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: setState (built-in)
- **Storage**: SharedPreferences (local storage)
- **Architecture**: Single-file monolith (simple app)

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting a PR.

### Quick Start for Contributors

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [x] Export expenses to CSV
- [ ] Charts and analytics
- [ ] Cloud sync with Firebase
- [ ] Expense categories customization
- [ ] Receipt photo attachment
- [ ] Expense reminders/notifications
- [ ] Monthly/weekly expense reports

## Known Issues

See [Issues](https://github.com/NAMATOVU-CHRISTINE/ExpenseTrack/issues) for a list of known issues and feature requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Christine Namatovu**

- GitHub: [@NAMATOVU-CHRISTINE](https://github.com/NAMATOVU-CHRISTINE)

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who help improve this project

---

**Star this repo if you find it helpful!**
