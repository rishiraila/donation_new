import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int totalDonors = 0;
  double totalAmount = 0;
  int thisMonth = 0;
  List<Map<String, dynamic>> monthlyData = [];

  @override
  void initState() {
    super.initState();
    fetchStats();
    fetchMonthlyData();
     fetchTopDonation(); 
  }
  double _getChartMaxY() {
  if (monthlyData.isEmpty) return 10000;
  double maxVal = monthlyData.map((e) => e['amount'] as double).reduce((a, b) => a > b ? a : b);
  return ((maxVal / 2000).ceil() * 2000).toDouble();
}

  double topDonation = 0;

Future<void> fetchTopDonation() async {
  final res = await http.get(Uri.parse('https://backend-owxp.onrender.com/api/admin/top-donor'));
  if (res.statusCode == 200) {
    final data = json.decode(res.body);
    setState(() {
      topDonation = double.parse(data['topAmount'].toString());
    });
  }
}


  Future<void> fetchStats() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/stats'),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        totalDonors = data['totalDonors'];
        totalAmount = double.parse(data['totalAmount'].toString());
        thisMonth = data['thisMonth'];
      });
    }
  }

  Future<void> fetchMonthlyData() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/monthly-donation'),
    );
    if (res.statusCode == 200) {
      final List decoded = json.decode(res.body);
      setState(() {
        monthlyData =
            decoded
                .map(
                  (e) => {
                    'month': e['month'],
                    'amount': double.tryParse(e['amount'].toString()) ?? 0,
                  },
                )
                .toList();
      });
    }
  }

  Widget buildStatCard(String title, dynamic value, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [BarChartRodData(toY: y, color: Colors.blueAccent, width: 18)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              buildStatCard("Total Donors", totalDonors, Colors.blue),
              buildStatCard(
                "Total Amount",
                "₹${totalAmount.toStringAsFixed(2)}",
                Colors.green,
              ),
              buildStatCard("This Month", thisMonth, Colors.orange),
              buildStatCard("Top Donation", "₹${topDonation.toStringAsFixed(2)}", Colors.purple),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Monthly Donations",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
  height: 250, // reduced height to avoid vertical scroll
  width: double.infinity,
  child: BarChart(
    BarChartData(
      maxY: _getChartMaxY(), // Dynamic max value
      barGroups: monthlyData.asMap().entries.map((e) {
        return barGroup(e.key, e.value['amount']);
      }).toList(),
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              if (value.toInt() < monthlyData.length) {
                return Text(
                  monthlyData[value.toInt()]['month'].substring(0, 3),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2000,
            getTitlesWidget: (value, _) {
              return Text(
                '₹${value.toInt()}',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
    ),
  ),
),

        ],
      ),
    );
  }
}
