import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List scholarships = [];
  bool isLoading = true;

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final searchCtrl = TextEditingController();

  // Colors to match your theme
  final Color primaryPurple = const Color(0xFF4B0082);
  final Color surfaceColor = const Color(0xFFF8F9FD);

  @override
  void initState() {
    super.initState();
    fetchScholarships();
  }

  // ================= FETCH (LOGIC UNCHANGED) =================
  Future<void> fetchScholarships([String search = ""]) async {
    setState(() => isLoading = true);

    try {
      final res = await http.get(
        Uri.parse("$baseUrl/search_scholarships.php?search=$search"),
      );

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

  // ================= PROFESSIONAL CARD =================
  Widget card(Map s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s['title'] ?? 'Scholarship Title',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: primaryPurple,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            
            // Details Row
            Row(
              children: [
                Icon(Icons.business_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  s['trust_name'] ?? 'Unknown Trust',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_outlined, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 6),
                    Text(
                      "₹${s['amount']}",
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    s['category'] ?? 'General',
                    style: TextStyle(
                      color: primaryPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            Text(
              s['description'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.4,
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
      backgroundColor: surfaceColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Explore",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryPurple,
      ),
      body: Column(
        children: [
          // 🔍 MODERN SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryPurple,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: TextField(
                controller: searchCtrl,
                decoration: InputDecoration(
                  hintText: "Search by trust or title...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: primaryPurple),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send_rounded, color: primaryPurple),
                    onPressed: () => fetchScholarships(searchCtrl.text),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onSubmitted: (value) => fetchScholarships(value),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 📋 LIST SECTION
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryPurple))
                : scholarships.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text(
                              "No scholarships found",
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: scholarships.length,
                        itemBuilder: (_, i) => card(scholarships[i]),
                      ),
          ),
        ],
      ),
    );
  }
}