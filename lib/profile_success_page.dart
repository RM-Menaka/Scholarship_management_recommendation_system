import 'dart:async';
import 'package:flutter/material.dart';
import 'student_home_page.dart';
class ProfileSuccessPage extends StatefulWidget {
    final int userId; // 🔥 ADD THIS

  const ProfileSuccessPage({super.key, required this.userId});

  @override
  State<ProfileSuccessPage> createState() => _ProfileSuccessPageState();
}

class _ProfileSuccessPageState extends State<ProfileSuccessPage> {
  @override
  void initState() {
    super.initState();

    // ⏳ Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StudentHomePage(userId: widget.userId)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B0082), Color(0xFFE6E6FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 90),
                SizedBox(height: 24),
                Text(
                  "Profile Completed!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "We’ll help you find scholarships that match your journey.\n\nDon’t lose hope — the right opportunity is on its way ✨",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 28),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
