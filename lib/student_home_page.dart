import 'package:flutter/material.dart';
import 'explore_page.dart';
import 'scholarship_list_page.dart';
import 'applied_scholarships_page.dart';
import 'student_profile_page.dart';

class StudentHomePage extends StatefulWidget {
  final int userId;

  const StudentHomePage({super.key, required this.userId});

  @override
  State<StudentHomePage> createState() =>
      _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int currentIndex = 0;

  late List pages;

  @override
  void initState() {
    super.initState();

    pages = [
      ScholarshipListPage(userId: widget.userId), // 🏠 Home
      AppliedScholarshipsPage(userId: widget.userId), // 📄 Applications
      ExplorePage(), // 🔍 Explore
      StudentProfilePage(userId: widget.userId), // 👤 Profile
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [

          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: "Applications",
          ),

          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Explore",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}