import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart' as charts;
import 'package:fl_chart/fl_chart.dart'; // Added import for PieChart

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int totalDonors = 0;
  double totalAmount = 0;
  int thisMonthCount = 0;
  double topDonation = 0;
  List monthlyData = [];
  List donations = [];
  int currentPage = 1;
  int totalPages = 1;
  List purposeData = [];

  @override
  void initState() {
    super.initState();
    fetchStats();
    fetchMonthlyDonations();
    fetchDonationTrends("monthly");
    fetchTopDonation();
    fetchDonations(page: 1);
    fetchDonorBreakdown();
    fetchPurposeData();
  }

  Future<void> fetchStats() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/stats'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        totalDonors = data['totalDonors'] ?? 0;
        totalAmount = (data['totalAmount'] ?? 0).toDouble();
        thisMonthCount = data['thisMonth'] ?? 0;
      });
    }
  }

  Future<void> fetchMonthlyDonations() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/monthly-donations'),
    );
    if (res.statusCode == 200) {
      setState(() {
        monthlyData = jsonDecode(res.body);
      });
    }
  }

  Future<void> fetchTopDonation() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/top-donation'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        topDonation = (data['topAmount'] ?? 0).toDouble();
      });
    }
  }

  Future<void> fetchDonations({int page = 1}) async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/donors?page=$page&limit=10'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        donations = data['donors'];
        currentPage = data['page'];
        totalPages = (data['total'] / data['limit']).ceil();
      });
    }
  }

  Future<void> fetchDonationTrends(String type) async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/trends?type=$type'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        monthlyData = data;
      });
    }
  }

  int newDonors = 0;
  int returningDonors = 0;

  Future<void> fetchDonorBreakdown() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/donor-breakdown'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        newDonors = data['newDonors'] ?? 0;
        returningDonors = data['returningDonors'] ?? 0;
      });
    }
  }

  void export(String format) async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/donors?page=1&limit=1000'),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['donors'];
      final post = await http.post(
        Uri.parse('https://backend-owxp.onrender.com/api/admin/export'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"format": format, "data": data}),
      );
      if (post.statusCode == 200) {
        final blob = html.Blob([post.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", "donation_report.$format")
              ..click();
        html.Url.revokeObjectUrl(url);
      }
    }
  }

  Future<void> fetchPurposeData() async {
    final res = await http.get(
      Uri.parse('https://backend-owxp.onrender.com/api/admin/purpose-summary'),
    );
    if (res.statusCode == 200) {
      setState(() {
        purposeData = jsonDecode(res.body);
      });
    }
  }

  Widget buildPurposePieChart(List<Map<String, dynamic>> data) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: List.generate(data.length, (i) {
            final item = data[i];
            return PieChartSectionData(
              value: double.tryParse(item['total'].toString()) ?? 0,

              color: colors[i % colors.length],
              title: item['donation_purpose'],
              radius: 80,
              titleStyle: TextStyle(fontSize: 14, color: Colors.white),
            );
          }),
        ),
      ),
    );
  }

  Widget buildChart() {
    return SizedBox(
      height: 300,
      child: charts.BarChart(
        charts.BarChartData(
          barGroups:
              monthlyData.map((e) {
                return charts.BarChartGroupData(
                  x: int.tryParse(e['month'] ?? '0') ?? 0,
                  barRods: [
                    charts.BarChartRodData(
                      toY: (e['amount'] ?? 0).toDouble(),
                      color: Colors.teal,
                    ),
                  ],
                );
              }).toList(),
          titlesData: charts.FlTitlesData(
            leftTitles: charts.AxisTitles(
              sideTitles: charts.SideTitles(showTitles: true),
            ),
            bottomTitles: charts.AxisTitles(
              sideTitles: charts.SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Donation Summary",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(
                "Total Donors",
                totalDonors.toString(),
                Icons.people,
              ),
              _buildStatCard(
                "Total Amount",
                "₹$totalAmount",
                Icons.attach_money,
              ),
              _buildStatCard(
                "This Month",
                "$thisMonthCount",
                Icons.calendar_today,
              ),
              _buildStatCard(
                "Top Donation",
                "₹$topDonation",
                Icons.stacked_line_chart,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Donor Breakdown",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard("New Donors", "$newDonors", Icons.fiber_new),
              const SizedBox(width: 16),
              _buildStatCard(
                "Returning Donors",
                "$returningDonors",
                Icons.repeat,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            "Donations by Purpose",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          purposeData.isEmpty
              ? CircularProgressIndicator()
              : buildPurposePieChart(
                List<Map<String, dynamic>>.from(purposeData),
              ),
          const SizedBox(height: 24),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.picture_as_pdf),
                onPressed: () => export("pdf"),
                label: Text("Export PDF"),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.table_view),
                onPressed: () => export("excel"),
                label: Text("Export Excel"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Recent Donations",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildTable(),
          const SizedBox(height: 16),
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.blue),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Mobile")),
          DataColumn(label: Text("Amount")),
          DataColumn(label: Text("Purpose")),
          DataColumn(label: Text("Date")),
        ],
        rows:
            donations.map((d) {
              return DataRow(
                cells: [
                  DataCell(Text(d['name'] ?? '-')),
                  DataCell(Text(d['mobile'] ?? '-')),
                  DataCell(Text("₹${d['amount'] ?? '-'}")),
                  DataCell(Text(d['donation_purpose'] ?? '-')),
                  DataCell(Text(d['created_at']?.split("T")[0] ?? '-')),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final page = index + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            onPressed: () => fetchDonations(page: page),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  currentPage == page ? Colors.blue : Colors.grey.shade200,
              foregroundColor:
                  currentPage == page ? Colors.white : Colors.black,
              minimumSize: Size(40, 36),
            ),
            child: Text(page.toString()),
          ),
        );
      }),
    );
  }
}
