import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'applicants_page.dart';
class MyScholarshipsPage extends StatefulWidget {
  final int userId;

  const MyScholarshipsPage({super.key, required this.userId});

  @override
  
  State<MyScholarshipsPage> createState() => _MyScholarshipsPageState();
  
}

class _MyScholarshipsPageState extends State<MyScholarshipsPage> {
  List scholarships = [];
  bool isLoading = true;

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);

  Future<void> fetchData() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_my_scholarships.php?user_id=${widget.userId}"),
      );

      final data = json.decode(res.body);

      setState(() {
        scholarships = data['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> deleteScholarship(int id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Scholarship"),
            content: const Text("Are you sure you want to remove this listing?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    final res = await http.post(
      Uri.parse("$baseUrl/delete_scholarship.php"),
      body: {"scholarship_id": id.toString()},
    );

    final data = json.decode(res.body);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
    fetchData();

    Navigator.pop(context, true);
  }

  Future<void> extendDeadline(int id) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    final res = await http.post(
      Uri.parse("$baseUrl/extend_deadline.php"),
      body: {
        "scholarship_id": id.toString(),
        "new_date": picked.toIso8601String().split('T')[0],
      },
    );

    final data = json.decode(res.body);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
    fetchData();
  }

  Widget dataRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }

  Widget statBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget card(Map s) {
    bool isActive = s['status_live'] == "active";

    return GestureDetector(
      onTap: () {
         Navigator.push(
         context,
         MaterialPageRoute(
          builder: (_) => ApplicantsPage(
            scholarshipId: int.parse(s['scholarship_id'].toString()),
          ),
        ),
      );// 🔥 Future: Navigate to applicants page
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          s['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: primaryPurple,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? "Active" : "Expired",
                          style: TextStyle(
                            color: isActive ? Colors.green[700] : Colors.red[700],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  dataRow(Icons.payments_outlined, "Amount: ₹${s['amount']}"),
                  dataRow(Icons.category_outlined, "Category: ${s['category']}"),
                  dataRow(Icons.event_available_outlined, "Deadline: ${s['application_end_date']}"),

                  const SizedBox(height: 16),

                  // 🔥 WRAP STATS
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      statBox(
                        icon: Icons.people_outline,
                        label: "Applicants",
                        value: "${s['applicants_count'] ?? 0}",
                        color: Colors.blue,
                      ),
                      statBox(
                        icon: Icons.check_circle,
                        label: "Approved",
                        value: "${s['approved_count'] ?? 0}",
                        color: Colors.green,
                      ),
                      statBox(
                        icon: Icons.hourglass_top,
                        label: "Pending",
                        value: "${s['pending_count'] ?? 0}",
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton.icon(
                    onPressed: () => extendDeadline(
  int.parse(s['scholarship_id'].toString()),
),
                    icon: const Icon(Icons.calendar_month_outlined, size: 20),
                    label: const Text("Extend Deadline"),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
                  ),
                  const SizedBox(height: 20, child: VerticalDivider()),
                  TextButton.icon(
                    onPressed: () => deleteScholarship(
  int.parse(s['scholarship_id'].toString()),
),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text("Delete"),
                    style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("My Scholarships", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : scholarships.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.layers_clear_outlined, size: 60, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text("No scholarships posted yet", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: scholarships.length,
                  itemBuilder: (_, i) => card(scholarships[i]),
                ),
    );
  }
}