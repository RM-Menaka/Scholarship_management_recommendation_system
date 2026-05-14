import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'review_page.dart';

class AppliedScholarshipsPage extends StatefulWidget {
  final int userId;

  const AppliedScholarshipsPage({super.key, required this.userId});

  @override
  State<AppliedScholarshipsPage> createState() =>
      _AppliedScholarshipsPageState();
}

class _AppliedScholarshipsPageState extends State<AppliedScholarshipsPage> {
  List applications = [];
  bool isLoading = true;

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);

  // ================= FETCH (LOGIC UNCHANGED) =================
  Future<void> fetchApplications() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_applied_scholarships.php?user_id=${widget.userId}"),
      );

      final data = json.decode(res.body);

      if (!mounted) return;

      setState(() {
        applications = data['data'] ?? [];
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
    fetchApplications();
  }

  // ================= STATUS COLOR =================
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange; // Pending
    }
  }

  // ================= PROFESSIONAL CARD =================
  Widget card(Map app) {
    Color statusColor = getStatusColor(app['status']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE & TRUST
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['title'] ?? 'Scholarship Title',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: primaryPurple,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            app['trust_name'] ?? 'Unknown Trust',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // STATUS BADGE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    app['status'].toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

            // FOOTER INFO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // AMOUNT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "GRANT AMOUNT",
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹${app['amount']}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                
                // DATE
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "APPLIED ON",
                      style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app['applied_at'] ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),

// ⭐ REVIEW BUTTON
if (app['status'] == "Approved" || app['status'] == "Rejected")
  SizedBox(
    width: double.infinity,
    child: ElevatedButton(
     onPressed: () {
  print("APP DATA: $app"); // 🔥 debug (keep this for now)

  final rawId = app['scholarship_id'];

  if (rawId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Scholarship ID missing")),
    );
    return;
  }

  final scholarshipId = int.tryParse(rawId.toString());

  if (scholarshipId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid scholarship ID")),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReviewPage(
        userId: widget.userId,
        scholarshipId: scholarshipId,
      ),
    ),
  );
},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        "Give Review ⭐",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Applications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : RefreshIndicator(
              onRefresh: fetchApplications, // Pull to refresh logic
              color: primaryPurple,
              child: applications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text(
                            "No applications found",
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: applications.length,
                      itemBuilder: (_, i) => card(applications[i]),
                    ),
            ),
    );
  }
}