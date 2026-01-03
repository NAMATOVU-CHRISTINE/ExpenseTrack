import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/date_picker_field.dart';

class AddIncomeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? existingIncome;

  const AddIncomeScreen({super.key, required this.onSave, this.existingIncome});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _frequency = 'once';
  String _source = 'Other';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existingIncome != null) {
      _nameController.text = widget.existingIncome!['name'] ?? '';
      _amountController.text =
          widget.existingIncome!['amount']?.toString() ?? '';
      _frequency = widget.existingIncome!['frequency'] ?? 'once';
      _source = widget.existingIncome!['source'] ?? 'Other';
      _date = widget.existingIncome!['date'] ?? DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingIncome != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Income' : 'Add Income')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Income Name',
                hintText: 'e.g., Monthly Salary, Gift from Mom',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Please enter an amount';
                if (double.tryParse(v!) == null)
                  return 'Please enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: AppConstants.incomeFrequencies.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(AppConstants.frequencyLabels[f] ?? f),
                );
              }).toList(),
              onChanged: (v) => setState(() => _frequency = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _source,
              decoration: const InputDecoration(
                labelText: 'Source',
                prefixIcon: Icon(Icons.source),
              ),
              items: AppConstants.incomeSources.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (v) => setState(() => _source = v!),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              selectedDate: _date,
              onDateChanged: (d) => setState(() => _date = d),
              label: _frequency == 'once' ? 'Date Received' : 'Start Date',
            ),
            const SizedBox(height: 24),
            if (_frequency == 'once')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.purple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a one-time income. It will be recorded for the selected date only.',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveIncome,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(isEditing ? 'Update Income' : 'Add Income'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveIncome() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave({
        'id': widget.existingIncome?['id'],
        'name': _nameController.text.trim(),
        'amount': double.parse(_amountController.text),
        'frequency': _frequency,
        'source': _source,
        'date': _date,
      });
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
