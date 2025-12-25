import 'package:currency_convertor/services/exchange_rate_graph.dart';
import 'package:flutter/material.dart';
import '../services/currency_api_service.dart';
import '../widgets/exchange_rate_graph.dart';
import '../screens/all_currencies_page.dart';

class CurrencyConvertorMaterialPage extends StatefulWidget {
  const CurrencyConvertorMaterialPage({super.key});

  @override
  State<CurrencyConvertorMaterialPage> createState() =>
      _CurrencyConvertorMaterialPageState();
}

class _CurrencyConvertorMaterialPageState
    extends State<CurrencyConvertorMaterialPage> {
  double result = 0.0;
  double currentRate = 0.0;

  bool isLoading = false;
  bool showTrendCard = false;
  bool isGraphLoading = false;

  String fromCurrency = 'USD';
  String toCurrency = 'INR';
  bool isSwapped = false;

  List<double> historicalRates = [];

  final TextEditingController textEditingController = TextEditingController();
  Future<void> convertCurrency() async {
    final amount = double.tryParse(textEditingController.text) ?? 0;

    if (amount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final rate = await CurrencyApiService.getRate(fromCurrency);

      setState(() {
        currentRate = rate;
        result = amount * rate;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching exchange rate')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void swapCurrencies() {
    setState(() {
      final temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
      isSwapped = !isSwapped;
      result = 0;
      textEditingController.clear();
    });
  }

  void showCalculationHelp() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How is this calculated?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Formula:'),
            const Text('Amount × Exchange Rate = Converted Value'),
            const SizedBox(height: 12),
            Text(
              '${textEditingController.text} $fromCurrency '
              '× ${currentRate.toStringAsFixed(2)} '
              '= ${result.toStringAsFixed(2)} $toCurrency',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadHistoricalData() async {
    setState(() => isGraphLoading = true);
    try {
      final data = await CurrencyApiService.getHistoricalRates(fromCurrency);
      setState(() => historicalRates = data);
    } catch (_) {}
    setState(() => isGraphLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black26),
      borderRadius: BorderRadius.circular(12),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF7B1FA2)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Currency Converter',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'check live rates and more',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final selected = await Navigator.push<String>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AllCurrenciesPage(),
                                    ),
                                  );
                                  if (selected != null) {
                                    setState(() {
                                      fromCurrency = selected;
                                      historicalRates.clear();
                                    });
                                  }
                                },
                                child: _currencyCard(fromCurrency),
                              ),

                              const SizedBox(height: 12),
                              AnimatedRotation(
                                turns: isSwapped ? 0.5 : 0,
                                duration: const Duration(milliseconds: 400),
                                child: GestureDetector(
                                  onTap: swapCurrencies,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.swap_vert,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),
                              _currencyCard(toCurrency),

                              const SizedBox(height: 12),

                              TextField(
                                controller: textEditingController,
                                decoration: InputDecoration(
                                  hintText: 'Enter amount',
                                  prefixIcon: const Icon(
                                    Icons.monetization_on_outlined,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: border,
                                  focusedBorder: border,
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),

                              const SizedBox(height: 16),

                              ElevatedButton(
                                onPressed: convertCurrency,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Convert'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          '${result.toStringAsFixed(2)} $toCurrency',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        TextButton(
                          onPressed: result == 0 ? null : showCalculationHelp,
                          child: const Text(
                            'How is this calculated?',
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                child: GestureDetector(
                  onTap: () async {
                    setState(() => showTrendCard = !showTrendCard);
                    if (historicalRates.isEmpty) {
                      await loadHistoricalData();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.show_chart, color: Colors.white),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: 16,
                bottom: showTrendCard ? 80 : -240,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 260,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox(
                      height: 120,
                      child: isGraphLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ExchangeRateGraph(rates: historicalRates),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currencyCard(String currency) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(currency, style: const TextStyle(fontSize: 16)),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
