import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'post_scholarship_page.dart';
import 'my_scholarships_page.dart';
import 'trust_profile_page.dart';
import 'reviews_page.dart';

class TrustDashboardPage extends StatefulWidget {
  final int userId;
  

  const TrustDashboardPage({super.key, required this.userId});

  @override
  State<TrustDashboardPage> createState() => _TrustDashboardPageState();
}

class _TrustDashboardPageState extends State<TrustDashboardPage> {
  int currentIndex = 0;
  int applicantsCount = 0;
  String verificationStatus = "pending";
  bool isLoading = true;

  // 🔥 NEW STATS
  int activeCount = 0;
  int closedCount = 0;
  int totalCount = 0;
  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  fetchStats(); // 🔥 ALWAYS REFRESH
}

  final String baseUrl =
      "http://10.25.225.137/scholarfinder_api";

  // ================= FETCH STATUS =================
  Future<void> fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/get_trust_profile.php?user_id=${widget.userId}",
        ),
      );

      final data = json.decode(response.body);
      

      if (!mounted) return;

      if (data['status'] == 'success') {
        setState(() {
          verificationStatus =
              data['data']['verification_status'] ?? "pending";
        });
      }
    } catch (e) {
      debugPrint("Status error: $e");
    }
  }

  // ================= FETCH STATS =================
  Future<void> fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/get_my_scholarships.php?user_id=${widget.userId}",
        ),
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (data['status'] == 'success') {
        setState(() {
          activeCount =
              int.parse(data['stats']['active'].toString());
          closedCount =
              int.parse(data['stats']['closed'].toString());
          totalCount =
              int.parse(data['stats']['total'].toString());
          applicantsCount =
              int.parse(data['stats']['applicants'].toString());
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Stats error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStatus();
    fetchStats(); // ✅ IMPORTANT
  }

  // ================= STATUS COLOR =================
  Color getStatusColor() {
    switch (verificationStatus) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String getStatusText() {
    switch (verificationStatus) {
      case "approved":
        return "Approved ✅";
      case "rejected":
        return "Rejected ❌";
      default:
        return "Pending ⏳";
    }
  }

  // ================= NAVIGATION =================
  void handleNavigation(int index) {
    setState(() {
      currentIndex = index;
    });

    if (index == 1) {
      if (verificationStatus != "approved") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              verificationStatus == "rejected"
                  ? "Your account was rejected by admin"
                  : "Your account is not approved yet",
            ),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PostScholarshipPage(userId: widget.userId),
        ),
      );
    }

    if (index == 2) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          MyScholarshipsPage(userId: widget.userId),
    ),
  ).then((_) {
    fetchStats(); // 🔥 REFRESH AFTER RETURN
  });
}

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              TrustProfilePage(userId: widget.userId),
        ),
      );
    }
  }

  // ================= STAT CARD =================
  Widget statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                const Color(0xFF4B0082).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF4B0082)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFF4B0082),
        title: const Text("Trust Dashboard"),
        actions: [
  IconButton(
    icon: const Icon(Icons.refresh),
    onPressed: fetchStats,
  )
],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 STATUS DISPLAY
                  Row(
                    children: [
                      const Text("Status: "),
                      Text(
                        getStatusText(),
                        style: TextStyle(
                          color: getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 🔥 WARNING BANNER
                  if (verificationStatus != "approved")
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin:
                          const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: verificationStatus == "rejected"
                            ? Colors.red.shade100
                            : Colors.orange.shade100,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Text(
                        verificationStatus == "rejected"
                            ? "Your account was rejected. Contact admin."
                            : "Account under verification. Posting disabled.",
                        style: TextStyle(
                          color: verificationStatus == "rejected"
                              ? Colors.red
                              : Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const Text(
                    "Scholarship Statistics",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      statCard("Active", "$activeCount",
                          Icons.school),
                      statCard("Closed", "$closedCount",
                          Icons.lock),
                      statCard("Total", "$totalCount",
                          Icons.list),
                      statCard("Applicants", "$applicantsCount", Icons.people),
                    ],
                  ),
                  const SizedBox(height: 20),

Container(
  child: InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewsPage(userId: widget.userId),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18), // 🔥 MATCH statCard
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                const Color(0xFF4B0082).withOpacity(0.1),
            child: const Icon(Icons.star, color: Color(0xFF4B0082)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "View Reviews",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    ),
  ),
),
                ],
              ),
            ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: handleNavigation,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          NavigationDestination(
            icon: Icon(
              Icons.add_circle_outline,
              color: verificationStatus == "approved"
                  ? null
                  : Colors.grey,
            ),
            selectedIcon: const Icon(Icons.add_circle),
            label: "Post",
          ),
          const NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: "Scholarships",
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}