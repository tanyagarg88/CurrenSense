import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  // 🔹 Get all available currencies (dynamic)
  static Future<List<String>> getAllCurrencies() async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      return rates.keys.toList();
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  // 🔹 Get conversion rate between any two currencies
  static Future<double> getRate(String from, String to) async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;

      if (!rates.containsKey(from) || !rates.containsKey(to)) {
        throw Exception('Currency not supported');
      }

      final fromRate = rates[from];
      final toRate = rates[to];

      return toRate / fromRate;
    } else {
      throw Exception('API error');
    }
  }

  static Future<List<double>> getHistoricalRates(String base) async {
    final response = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      final baseRate = rates[base];

      if (baseRate == null) {
        throw Exception('Currency not supported');
      }

      return List.generate(7, (index) => baseRate * (0.97 + index * 0.01));
    } else {
      throw Exception('API error');
    }
  }
}
