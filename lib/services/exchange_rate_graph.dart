import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExchangeRateGraph extends StatelessWidget {
  final List<double> rates;

  const ExchangeRateGraph({super.key, required this.rates});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: rates
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              barWidth: 3,
              color: const Color.fromARGB(255, 74, 184, 74),
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color.fromARGB(
                  255,
                  240,
                  241,
                  236,
                ).withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
