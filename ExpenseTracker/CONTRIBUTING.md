# Contributing to ExpenseTracker

First off, thank you for considering contributing to ExpenseTracker!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)
- [Commit Messages](#commit-messages)

## Code of Conduct

This project follows a simple code of conduct:
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Assume good intentions

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check existing issues. When creating a bug report, include:

- **Clear title** describing the issue
- **Steps to reproduce** the behavior
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Device/OS information**

### Suggesting Features

Feature requests are welcome! Please include:

- **Clear description** of the feature
- **Use case** - why is this feature needed?
- **Possible implementation** (optional)

### Code Contributions

Great for:
- Bug fixes
- New features
- Documentation improvements
- Code refactoring
- Test coverage

## Development Setup

1. **Fork and clone**
   ```bash
   git clone https://github.com/YOUR-USERNAME/ExpenseTrack.git
   cd ExpenseTrack/ExpenseTracker
   ```

2. **Install Flutter** (if not already installed)
   - Follow [Flutter installation guide](https://docs.flutter.dev/get-started/install)

3. **Get dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Run tests**
   ```bash
   flutter test
   ```

6. **Check for issues**
   ```bash
   flutter analyze
   ```

## Pull Request Process

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

2. **Make your changes**
   - Write clean, readable code
   - Add comments for complex logic
   - Update documentation if needed

3. **Test your changes**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Commit your changes** (see [Commit Messages](#commit-messages))

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Use a clear, descriptive title
   - Reference any related issues
   - Describe what changes you made and why

### PR Review Criteria

- [ ] Code follows project style guidelines
- [ ] No new warnings from `flutter analyze`
- [ ] Tests pass (if applicable)
- [ ] Documentation updated (if needed)
- [ ] PR description is clear and complete

## Style Guidelines

### Dart/Flutter Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Keep functions small and focused
- Add documentation comments for public APIs

```dart
// Good
/// Calculates the total expenses for the given month.
double calculateMonthlyTotal(List<Expense> expenses, DateTime month) {
  return expenses
      .where((e) => e.date.month == month.month && e.date.year == month.year)
      .fold(0.0, (sum, e) => sum + e.amount);
}

// Bad
double calc(List<Expense> e, DateTime m) {
  var t = 0.0;
  for (var x in e) {
    if (x.date.month == m.month) t += x.amount;
  }
  return t;
}
```

### File Organization

- Keep related code together
- Use clear section comments for large files
- Extract reusable widgets when appropriate

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples

```bash
# Feature
git commit -m "feat: add CSV export for expenses"

# Bug fix
git commit -m "fix: resolve duplicate GlobalKey error on navigation"

# Documentation
git commit -m "docs: update README with installation instructions"

# Co-authored commit (for collaboration)
git commit -m "feat: add expense analytics chart

Co-authored-by: Partner Name <partner@email.com>"
```

## Issue Labels

| Label | Description |
|-------|-------------|
| `bug` | Something isn't working |
| `enhancement` | New feature request |
| `good first issue` | Good for newcomers |
| `help wanted` | Extra attention needed |
| `documentation` | Documentation improvements |
| `question` | Further information requested |

## Getting Help

- Open an issue for questions
- Check existing issues and PRs
- Read the Flutter documentation

---

Thank you for contributing!
