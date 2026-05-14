import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin_trust_detail_page.dart';

class AdminTrustListPage extends StatefulWidget {
  final int userId;

  const AdminTrustListPage({super.key, required this.userId});

  @override
  State<AdminTrustListPage> createState() => _AdminTrustListPageState();
}

class _AdminTrustListPageState extends State<AdminTrustListPage> {
  List trusts = [];
  bool isLoading = true;

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);
  final Color surfaceColor = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    fetchTrusts();
  }

  // ================= FETCH (LOGIC UNCHANGED) =================
  Future<void> fetchTrusts() async {
    setState(() => isLoading = true);
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/get_pending_trusts.php?user_id=${widget.userId}"))
          .timeout(const Duration(seconds: 10));

      final data = json.decode(res.body);

      if (data['status'] == 'success') {
        setState(() {
          trusts = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Error loading data")),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server connection error")),
        );
      }
    }
  }

  // ================= PROFESSIONAL CARD =================
  Widget _buildTrustCard(Map trust) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: primaryPurple.withOpacity(0.1),
          child: Icon(Icons.account_balance_outlined, color: primaryPurple, size: 20),
        ),
        title: Text(
          trust['trust_name'] ?? "Unnamed Trust",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              trust['trust_email'] ?? "No Email provided",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 6),
            // Badge for Trust Type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                (trust['trust_type'] ?? "General").toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
        onTap: () async {
          // Navigating and waiting for a potential 'refresh' signal from detail page
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminTrustDetailPage(
                trust: trust,
                userId: widget.userId,
              ),
            ),
          );
          if (result == true) fetchTrusts(); // Refresh if updated
        },
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryPurple,
        title: const Text(
          "Trust Verification",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: fetchTrusts,
            tooltip: "Reload List",
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : Column(
              children: [
                // Summary Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  color: primaryPurple.withOpacity(0.05),
                  child: Text(
                    "PENDING REQUESTS: ${trusts.length}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  child: trusts.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: primaryPurple,
                          onRefresh: fetchTrusts,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: trusts.length,
                            itemBuilder: (context, index) => _buildTrustCard(trusts[index]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Clear for now!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const Text(
            "No pending trust approvals found.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}