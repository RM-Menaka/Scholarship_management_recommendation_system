import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pdf_viewer_page.dart';

class ApplicantDetailPage extends StatelessWidget {
  final Map data;

  const ApplicantDetailPage({super.key, required this.data});

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);

  // ================= LOGIC (UNCHANGED) =================
  Future<void> updateStatus(BuildContext context, String status) async {
    final res = await http.post(
      Uri.parse("$baseUrl/update_application_status.php"),
      body: {
        "application_id": data['application_id'].toString(),
        "status": status,
      },
    );

    final jsonData = json.decode(res.body);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(jsonData['message']),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryPurple,
      ),
    );

    Navigator.pop(context);
  }

  // ================= MODERN COMPONENTS =================

  Widget infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: primaryPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryPurple, letterSpacing: 0.5)),
          const Divider(height: 24),
          ...children,
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
        title: const Text("Applicant Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primaryPurple.withOpacity(0.1),
                    child: Icon(Icons.person_outline, size: 40, color: primaryPurple),
                  ),
                  const SizedBox(height: 12),
                  Text(data['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(data['email'], style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Basic & Contact Info
            sectionCard(
              title: "CONTACT INFORMATION",
              children: [
                infoTile(Icons.phone_android_rounded, "Phone Number", data['phone']),
                infoTile(Icons.location_on_outlined, "State/Location", data['state']),
              ],
            ),

            // Academic Info
            sectionCard(
              title: "ACADEMIC BACKGROUND",
              children: [
                infoTile(Icons.school_outlined, "Education Level", data['education_level']),
                infoTile(Icons.assignment_turned_in_outlined, "Academic Score", "${data['academic_score']}%"),
              ],
            ),

            // Financial Info
            sectionCard(
              title: "FINANCIAL STATUS",
              children: [
                infoTile(Icons.account_balance_wallet_outlined, "Annual Income Range", data['income_range']),
              ],
            ),

            // Documents Info
            sectionCard(
              title: "VERIFICATION DOCUMENTS",
              children: [
                Builder(
                  builder: (context) {
                    Map docs = {};
                    try {
                      if (data['documents'] != null && data['documents'].toString().isNotEmpty) {
                        docs = json.decode(data['documents']);
                      }
                    } catch (e) {
                      docs = {};
                    }

                    if (docs.isEmpty) {
                      return const Text("No documents uploaded", style: TextStyle(color: Colors.grey, fontSize: 13));
                    }

                    return Column(
                      children: docs.entries.map<Widget>((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                            title: Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            subtitle: Text(entry.value, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: const Icon(Icons.open_in_new, size: 20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerPage(url: "$baseUrl/uploads/${entry.value}"),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Status Indicator
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Current Status: ${data['status']}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: primaryPurple, fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Builder(
              builder: (context) {
                String status = data['status'];

                if (status == "Pending") {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => updateStatus(context, "Approved"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Approve", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => updateStatus(context, "Rejected"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                }

                if (status == "Approved") {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => updateStatus(context, "Revoked"),
                      icon: const Icon(Icons.undo),
                      label: const Text("Revoke Approval"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade800,
                        side: BorderSide(color: Colors.orange.shade800),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  );
                }

                return const Center(
                  child: Text("Decision finalized. No further actions.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}