# Troubleshooting Guide

## Common Issues

### Build Errors

#### "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### "CocoaPods not installed"

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### Runtime Errors

#### "Duplicate GlobalKey detected"

This error occurs when multiple widgets share the same GlobalKey. Solutions:
- Use unique `heroTag` for FloatingActionButtons
- Avoid using IndexedStack with widgets that have GlobalKeys
- Use conditional rendering instead

#### "Looking up a deactivated widget's ancestor"

Add `mounted` checks before `setState` in async methods:

```dart
Future<void> loadData() async {
  final data = await fetchData();
  if (!mounted) return;  // Add this check
  setState(() => _data = data);
}
```

### Performance Issues

#### App is slow/laggy

- Use `const` constructors where possible
- Avoid rebuilding entire widget trees
- Use `select` to watch specific properties

### Data Issues

#### Data not saving

- Check SharedPreferences initialization
- Ensure data is serialized correctly to JSON
- Check for storage permissions on Android

#### Data disappeared after update

- App data is stored locally
- Reinstalling clears all data
- Consider implementing backup/export feature

## Getting Help

1. Check existing [Issues](https://github.com/NAMATOVU-CHRISTINE/ExpenseTrack/issues)
2. Search [Discussions](https://github.com/NAMATOVU-CHRISTINE/ExpenseTrack/discussions)
3. Create a new issue with detailed steps to reproduce
