import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';
  static const String _cacheKey = 'exchange_rates_cache';
  static const String _cacheTimeKey = 'exchange_rates_time';

  static Map<String, double> _cachedRates = {};
  static String _baseCurrency = 'USD';

  static final Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'UGX': 'UGX',
    'KES': 'KES',
    'TZS': 'TZS',
    'NGN': '₦',
    'ZAR': 'R',
    'INR': '₹',
    'JPY': '¥',
    'CNY': '¥',
    'AUD': 'A\$',
    'CAD': 'C\$',
  };

  static List<String> get availableCurrencies => currencySymbols.keys.toList();

  static Future<void> fetchExchangeRates(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt(_cacheTimeKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Cache for 1 hour
      if (now - lastFetch < 3600000 &&
          _cachedRates.isNotEmpty &&
          _baseCurrency == baseCurrency) {
        return;
      }

      final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(
          (data['rates'] as Map).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ),
        );

        _cachedRates = rates;
        _baseCurrency = baseCurrency;

        await prefs.setString(_cacheKey, json.encode(rates));
        await prefs.setInt(_cacheTimeKey, now);
      }
    } catch (e) {
      // Load from cache if network fails
      await _loadFromCache();
    }
  }

  static Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      _cachedRates = Map<String, double>.from(
        (json.decode(cached) as Map).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      );
    }
  }

  static double convert(double amount, String from, String to) {
    if (from == to) return amount;
    if (_cachedRates.isEmpty) return amount;

    // Convert to base currency first, then to target
    final fromRate = _cachedRates[from] ?? 1.0;
    final toRate = _cachedRates[to] ?? 1.0;

    return amount * (toRate / fromRate);
  }

  static double? getRate(String currency) {
    return _cachedRates[currency];
  }

  static String getSymbol(String currency) {
    return currencySymbols[currency] ?? currency;
  }
}
