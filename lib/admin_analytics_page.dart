import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);
  final Color surfaceColor = const Color(0xFFF8F9FD);

  bool isLoading = true;
  Map<String, int> appStatus = {};
  Map schStatus = {};
  List monthly = [];

  final List<Color> chartPalette = [
    const Color(0xFF6C5CE7), // Pending - Purple
    const Color(0xFF00B894), // Approved - Teal
    const Color(0xFFE17055), // Rejected - Orange
    const Color(0xFF0984E3), // Other - Blue
  ];

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/get_admin_analytics.php"));
      final data = json.decode(res.body);
      if (!mounted) return;
      setState(() {
        appStatus = {
          for (var i in data['application_status'])
            i['status'].toString(): int.parse(i['count'].toString())
        };
        schStatus = data['scholarship_status'];
        monthly = data['monthly_trend'];
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= PIE CHART WITH LABELS & LEGEND =================
  Widget modernPieChart(Map<String, int> data) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 45,
                  sections: data.entries.toList().asMap().entries.map((entry) {
                    int idx = entry.key;
                    var e = entry.value;
                    return PieChartSectionData(
                      value: e.value.toDouble(),
                      color: chartPalette[idx % chartPalette.length],
                      title: "${e.value}",
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("TOTAL", style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    data.values.fold(0, (sum, item) => sum + item).toString(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // --- THE LEGEND ---
        Wrap(
          spacing: 20,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: data.entries.toList().asMap().entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: chartPalette[entry.key % chartPalette.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.value.key,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ],
            );
          }).toList(),
        )
      ],
    );
  }

  // ================= LINE CHART WITH FIXED AXIS =================
  Widget modernLineChart() {
    if (monthly.isEmpty) return const Center(child: Text("Generating Trend Data..."));

    List<FlSpot> spots = [];
    for (int i = 0; i < monthly.length; i++) {
      spots.add(FlSpot(i.toDouble(), double.parse(monthly[i]['total'].toString())));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[100]!, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < monthly.length) {
                  // FIX: This takes the first 3 letters of the Month Name (Jan, Feb, etc.)
                  String rawMonth = monthly[index]['month'].toString();
                  String displayMonth = rawMonth.length > 3 ? rawMonth.substring(0, 3).toUpperCase() : rawMonth;
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(displayMonth, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(colors: [primaryPurple, Colors.blueAccent]),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [primaryPurple.withOpacity(0.2), primaryPurple.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget chartCard(String title, String subtitle, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 25),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryPurple,
        title: const Text("System Analytics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: primaryPurple,
                    padding: const EdgeInsets.only(bottom: 30, left: 25, right: 25),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Performance Hub", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text("Detailed breakdown of scholarship distribution", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  chartCard(
                    "Application Overview", 
                    "Distribution of student statuses", 
                    modernPieChart(appStatus)
                  ),
                  
                  chartCard(
                    "Scholarship Lifecycle", 
                    "Inventory of active vs. closed grants", 
                    modernPieChart({
                      "Active": int.parse(schStatus['active'].toString()),
                      "Closed": int.parse(schStatus['closed'].toString())
                    })
                  ),
                  
                  chartCard(
                    "Application Growth", 
                    "Monthly trend of scholarship submissions", 
                    SizedBox(height: 220, child: modernLineChart())
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}