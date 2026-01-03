import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencyConverterWidget extends StatefulWidget {
  final String baseCurrency;

  const CurrencyConverterWidget({super.key, required this.baseCurrency});

  @override
  State<CurrencyConverterWidget> createState() =>
      _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  final _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'UGX';
  double _result = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fromCurrency = widget.baseCurrency;
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoading = true);
    await CurrencyService.fetchExchangeRates(_fromCurrency);
    setState(() => _isLoading = false);
  }

  void _convert() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _result = CurrencyService.convert(amount, _fromCurrency, _toCurrency);
    });
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _convert();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.currency_exchange),
                const SizedBox(width: 8),
                const Text(
                  'Currency Converter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CurrencyDropdown(
                    value: _fromCurrency,
                    onChanged: (v) {
                      setState(() => _fromCurrency = v!);
                      _convert();
                    },
                  ),
                ),
                IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_horiz),
                ),
                Expanded(
                  child: _CurrencyDropdown(
                    value: _toCurrency,
                    onChanged: (v) {
                      setState(() => _toCurrency = v!);
                      _convert();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Result',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyService.getSymbol(_toCurrency)} ${_result.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _CurrencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: CurrencyService.availableCurrencies.map((c) {
        return DropdownMenuItem(value: c, child: Text(c));
      }).toList(),
      onChanged: onChanged,
    );
  }
}
