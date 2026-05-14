import 'package:flutter/material.dart';
import 'admin_trust_list_page.dart';

import 'login_page.dart';
import 'admin_analytics_page.dart';

class AdminDashboardPage extends StatelessWidget {
  final int userId;

  const AdminDashboardPage({super.key, required this.userId});

  final Color primaryPurple = const Color(0xFF4B0082);
  final Color surfaceColor = const Color(0xFFF8F9FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryPurple,
        title: const Text(
          "ADMIN PANEL",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
           onPressed: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => LoginPage()),
    (route) => false,
  );
},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: primaryPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "   SCHOLARFIND",
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "System Overview",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Administrator ID: #$userId",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- QUICK STATS SECTION ---
                  const Text(
                    "OPERATIONAL SUMMARY",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildStatCard("Active\nTrusts", "24", Icons.account_balance, Colors.blue),
                      const SizedBox(width: 15),
                      _buildStatCard("Total\nStudents", "1.2k", Icons.school, Colors.orange),
                    ],
                  ),
                  
                  const SizedBox(height: 30),

                  // --- ADMINISTRATIVE ACTIONS ---
                  const Text(
                    "MANAGEMENT CONTROLS",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
                  ),
                  const SizedBox(height: 15),

                  _buildActionCard(
                    context,
                    "Pending Trust Approvals",
                    "Review and verify new educational trusts",
                    Icons.verified_user_rounded,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminTrustListPage(userId: userId)),
                      );
                    },
                  ),

                  _buildActionCard(
                    context,
                    "System Analytics",
                    "Monitor scholarship disbursement trends",
                    Icons.analytics_rounded,
                    () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AdminAnalyticsPage(),
    ),
  );
},// Add logic later
                  ),

                  _buildActionCard(
                    context,
                    "User Management",
                    "Handle reports and account restrictions",
                    Icons.people_alt_rounded,
                    () {}, // Add logic later
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Statistics Mini-Cards
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 15),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.2)),
          ],
        ),
      ),
    );
  }

  // Main Dashboard Action Cards
  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.02)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryPurple, size: 26),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  },
  child: Icon(
    Icons.arrow_forward_ios_rounded,
    size: 16,
    color: Colors.grey[400],
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}