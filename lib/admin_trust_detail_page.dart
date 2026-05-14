import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminTrustDetailPage extends StatelessWidget {
  final Map trust;
  final int userId;

  const AdminTrustDetailPage({
    super.key,
    required this.trust,
    required this.userId,
  });

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);

  String safe(dynamic value) => value?.toString() ?? "N/A";

  // ================= LOGIC (UNCHANGED) =================
  Future<void> updateStatus(BuildContext context, String status) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/update_trust_status.php"),
        body: {
          "user_id": userId.toString(),
          "trust_id": safe(trust['trust_id']),
          "status": status,
        },
      );
      final data = json.decode(res.body);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Updated"), behavior: SnackBarBehavior.floating),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating status")),
      );
    }
  }

  Future<void> openPDF(BuildContext context) async {
    final file = trust['registration_certificate'];
    if (file == null || file.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No certificate uploaded")));
      return;
    }
    final uri = Uri.parse("$baseUrl/uploads/$file");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unable to open document")));
    }
  }

  // ================= MODERN COMPONENTS =================

  Widget infoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryPurple, letterSpacing: 1)),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ],
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
        backgroundColor: primaryPurple,
        title: const Text("Verification Details", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Hero
            Container(
              width: double.infinity,
              color: primaryPurple,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: const Icon(Icons.account_balance_rounded, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    safe(trust['trust_name']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(safe(trust['trust_type']).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    infoSection("LEGAL INFORMATION", [
                      infoRow(Icons.fingerprint, "Registration Number", safe(trust['registration_number'])),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => openPDF(context),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text("Preview Registration Certificate"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryPurple,
                            side: BorderSide(color: primaryPurple.withOpacity(0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ]),
                    
                    infoSection("CONTACT DETAILS", [
                      infoRow(Icons.email_outlined, "Email Address", safe(trust['trust_email'])),
                      infoRow(Icons.phone_android_outlined, "Phone Number", safe(trust['trust_phone'])),
                      infoRow(Icons.location_on_outlined, "Headquarters", safe(trust['address'])),
                      infoRow(Icons.map_outlined, "Region", "${safe(trust['district'])}, ${safe(trust['state'])}"),
                    ]),

                    const SizedBox(height: 10),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => updateStatus(context, "approved"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: const Text("APPROVE TRUST", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => updateStatus(context, "rejected"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red[600],
                              side: BorderSide(color: Colors.red[100]!),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: const Text("REJECT", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}