import 'package:flutter/material.dart';
import '../models/currency_model.dart';
import '../utils/currency_flags.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllCurrenciesPage extends StatefulWidget {
  const AllCurrenciesPage({super.key});

  @override
  State<AllCurrenciesPage> createState() => _AllCurrenciesPageState();
}

class _AllCurrenciesPageState extends State<AllCurrenciesPage> {
  List<CurrencyModel> allCurrencies = [];
  List<CurrencyModel> filtered = [];
  bool isLoading = true;

  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCurrencies();
  }

  Future<void> fetchCurrencies() async {
    final res = await http.get(
      Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final rates = data['rates'] as Map<String, dynamic>;

      final list = rates.keys.map((code) {
        return CurrencyModel(code: code, name: code, flag: getFlag(code));
      }).toList()..sort((a, b) => a.code.compareTo(b.code));

      setState(() {
        allCurrencies = list;
        filtered = list;
        isLoading = false;
      });
    }
  }

  void onSearch(String value) {
    setState(() {
      filtered = allCurrencies
          .where((c) => c.code.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Currencies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchCtrl,
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search currency (USD, EUR...)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      return ListTile(
                        leading: Text(
                          c.flag,
                          style: const TextStyle(fontSize: 26),
                        ),
                        title: Text(c.code),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context, c.code);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
