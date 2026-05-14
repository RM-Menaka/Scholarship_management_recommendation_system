import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewPage extends StatefulWidget {
  final int userId;
  final int scholarshipId;

  const ReviewPage({
    super.key,
    required this.userId,
    required this.scholarshipId,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int rating = 0;
  final commentCtrl = TextEditingController();
  bool isLoading = false;

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);

  // ⭐ ENHANCED STAR WIDGET
  Widget buildStar(int index) {
    bool isSelected = index <= rating;
    return GestureDetector(
      onTap: () => setState(() => rating = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isSelected ? Colors.amber : Colors.grey.shade400,
          size: 42, // Larger, more accessible touch target
        ),
      ),
    );
  }

  // 🔥 SUBMIT FUNCTION (LOGIC UNCHANGED)
  Future<void> submitReview() async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/submit_review.php"),
        body: {
          "user_id": widget.userId.toString(),
          "scholarship_id": widget.scholarshipId.toString(),
          "rating": rating.toString(),
          "comment": commentCtrl.text,
        },
      );

      final data = json.decode(res.body);
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor: data['status'] == "success" ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (data['status'] == "success") {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error"), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Provide Feedback",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: primaryPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Accents
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  // Professional Feedback Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          color: Colors.black.withOpacity(0.06),
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Your Opinion Matters",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "How would you rate the application process for this scholarship?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 32),

                        // ⭐ RATING SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) => buildStar(i + 1)),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          rating == 0 ? "Select a Star" : "Rating: $rating / 5",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rating == 0 ? Colors.grey : primaryPurple,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 💬 COMMENT BOX
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Additional Comments",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: commentCtrl,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "Tell us what could be improved...",
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF1F2F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: primaryPurple.withOpacity(0.3)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 🚀 SUBMIT BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryPurple,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Submit Feedback",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}