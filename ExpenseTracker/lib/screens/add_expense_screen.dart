import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/receipt_image_picker.dart';

class AddExpenseScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? existingExpense;
  final List<String>? categories;

  const AddExpenseScreen({
    super.key,
    required this.onSave,
    this.existingExpense,
    this.categories,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'General';
  DateTime _date = DateTime.now();
  bool _isRecurring = false;
  String? _receiptPath;

  List<String> get _categories =>
      widget.categories ?? AppConstants.expenseCategories;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      _titleController.text = widget.existingExpense!['title'] ?? '';
      _amountController.text =
          widget.existingExpense!['amount']?.toString() ?? '';
      _notesController.text = widget.existingExpense!['notes'] ?? '';
      _category = widget.existingExpense!['category'] ?? 'General';
      _date = widget.existingExpense!['date'] ?? DateTime.now();
      _isRecurring = widget.existingExpense!['isRecurring'] ?? false;
      _receiptPath = widget.existingExpense!['receiptPath'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingExpense != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Expense' : 'Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Lunch, Bus fare, Groceries',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Please enter an amount';
                if (double.tryParse(v!) == null)
                  return 'Please enter a valid number';
                if (double.parse(v) <= 0)
                  return 'Amount must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categories.contains(_category)
                  ? _category
                  : _categories.first,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              selectedDate: _date,
              onDateChanged: (d) => setState(() => _date = d),
              label: 'Date',
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any additional details',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Recurring Expense'),
              subtitle: const Text('This expense repeats regularly'),
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ReceiptImagePicker(
              receiptPath: _receiptPath,
              onReceiptChanged: (path) => setState(() => _receiptPath = path),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(isEditing ? 'Update Expense' : 'Add Expense'),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _confirmDelete(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text('Delete Expense'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'id': widget.existingExpense?['id'],
        'title': _titleController.text.trim(),
        'amount': double.parse(_amountController.text),
        'category': _category,
        'date': _date,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'isRecurring': _isRecurring,
        'receiptPath': _receiptPath,
      });
      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onSave({
                'delete': true,
                'id': widget.existingExpense?['id'],
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
