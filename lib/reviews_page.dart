import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewsPage extends StatefulWidget {
  final int userId;

  const ReviewsPage({super.key, required this.userId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List reviews = [];
  bool isLoading = true;

  final Color primaryPurple = const Color(0xFF4B0082);
  final baseUrl = "http://10.25.225.137/scholarfinder_api";

  Future<void> fetchReviews() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/get_reviews.php?user_id=${widget.userId}"),
      );

      final data = json.decode(res.body);

      if (!mounted) return;

      setState(() {
        reviews = data['data'] ?? [];
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
    fetchReviews();
  }

  // Professional Star Rating Builder
  Widget buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: index < rating ? Colors.amber : Colors.grey[300],
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Student Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryPurple))
          : Column(
              children: [
                // --- TOP SUMMARY HEADER ---
                if (reviews.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primaryPurple,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Trust Reputation",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              _calculateAverage(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Based on ${reviews.length} reviews",
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                // --- REVIEWS LIST ---
                Expanded(
                  child: reviews.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: reviews.length,
                          itemBuilder: (_, i) {
                            final r = reviews[i];
                            return _buildReviewCard(r);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Helper to calculate average rating string
  String _calculateAverage() {
    if (reviews.isEmpty) return "0.0";
    double total = 0;
    for (var r in reviews) {
      total += double.tryParse(r['rating'].toString()) ?? 0;
    }
    return (total / reviews.length).toStringAsFixed(1);
  }

  Widget _buildReviewCard(Map r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryPurple.withOpacity(0.1),
                      child: Icon(Icons.person, size: 18, color: primaryPurple),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      r['name'] ?? "Anonymous Student",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                buildStars(int.parse(r['rating'].toString())),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              r['comment'] ?? "No comment provided.",
              style: TextStyle(color: Colors.grey[800], height: 1.4, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.school_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Review for: ${r['title']}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No reviews received yet",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}