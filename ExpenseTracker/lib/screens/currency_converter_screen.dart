import 'package:flutter/material.dart';
import '../widgets/currency_converter.dart';

class CurrencyConverterScreen extends StatelessWidget {

  const CurrencyConverterScreen({super.key, required this.baseCurrency});
  final String baseCurrency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CurrencyConverterWidget(baseCurrency: baseCurrency),
      ),
    );
  }
}
