import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'notification_page.dart';
import 'apply_scholarship_page.dart';

class ScholarshipListPage extends StatefulWidget {
  final int? userId;
  const ScholarshipListPage({super.key, this.userId});

  @override
  State<ScholarshipListPage> createState() => _ScholarshipListPageState();
}

class _ScholarshipListPageState extends State<ScholarshipListPage> {
  List scholarships = [];
  bool isLoading = true;

  final Color primaryPurple = const Color(0xFF4B0082);
  final Color surfaceColor = const Color(0xFFF8F9FD);
  final String baseUrl = "http://10.25.225.137/scholarfinder_api";

  @override
  void initState() {
    super.initState();
    fetchScholarships();
  }

  Future<void> fetchScholarships() async {
    // ... Logic remains same ...
    if (widget.userId == null) {
      setState(() {
        scholarships = [
          {
            "scholarship_id": "1",
            "title": "Merit-Based Excellence Scholarship",
            "trust_name": "ABC Education Trust",
            "education_level": "UG",
            "min_percentage": "75",
            "max_income": "200,000",
            "eligible_states": "Tamil Nadu",
            "match_score": 88,
            "amount": "50,000",
            "application_end_date": "2026-06-30",
            "category": "Merit",
            "reason": "Matches your high academic record and income bracket."
          }
        ];
        isLoading = false;
      });
      return;
    }
    // Existing API Logic...
    try {
      final res = await http.get(Uri.parse("$baseUrl/get_recommended_scholarships.php?user_id=${widget.userId}"));
      final data = json.decode(res.body);
      if (!mounted) return;
      setState(() {
        scholarships = data['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> applyScholarship(int scholarshipId) async {
    // ... Existing apply logic ...
  }

  Widget dataChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

 Widget scholarshipCard(Map sch) {
    final matchScore = double.tryParse(sch['match_score']?.toString() ?? "0") ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
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
                        sch['title'] ?? "Scholarship Title",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (matchScore >= 80)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Best Match",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Professional Trust & Email Row
                Row(
                  children: [
                    Icon(Icons.business_outlined, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      sch['trust_name'] ?? "Unknown Trust",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("•", style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(width: 8),
                    Icon(Icons.mail_outline_rounded, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                      (sch['trust_email'] != null && sch['trust_email'].toString().isNotEmpty)
                      ? sch['trust_email']
                     : "No email",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                       ),
                      overflow: TextOverflow.ellipsis,
                                  ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Requirement Grid
                Wrap(
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    dataChip(Icons.school_outlined, sch['education_level'], Colors.blueGrey),
                    dataChip(Icons.analytics_outlined, "${sch['min_percentage']}% Min", Colors.blueGrey),
                    dataChip(Icons.account_balance_wallet_outlined, "₹${sch['max_income']}", Colors.blueGrey),
                    dataChip(Icons.calendar_today_outlined, sch['application_end_date'] ?? "N/A", Colors.blueGrey),
                  ],
                ),
                
                const Divider(height: 32),

                // Match Score Section
                Row(
                  children: [
                    const Text(
                      "Compatibility Score",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const Spacer(),
                    Text(
                      "${matchScore.toInt()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: matchScore / 100,
                    backgroundColor: Colors.grey[100],
                    color: Colors.orange,
                    minHeight: 6,
                  ),
                ),
                if (sch['reason'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    sch['reason'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "GRANT AMOUNT",
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      "₹${sch['amount']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (sch['application_status'] == null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplyScholarshipPage(
                            scholarship: sch,
                            userId: widget.userId!,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Apply Now", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Applied (${sch['application_status']})",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
        backgroundColor: primaryPurple,
        title: const Text("Recommended Scholarships", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage(userId: widget.userId ?? 0)));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : scholarships.isEmpty
              ? const Center(child: Text("No scholarships found at the moment."))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: scholarships.length,
                  itemBuilder: (context, index) => scholarshipCard(scholarships[index]),
                ),
    );
  }
}