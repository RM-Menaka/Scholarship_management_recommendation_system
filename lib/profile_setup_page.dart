import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'profile_success_page.dart';

class ProfileSetupPage extends StatefulWidget {
  final int userId;

  const ProfileSetupPage({super.key, required this.userId});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  final nameController = TextEditingController();
  final scoreController = TextEditingController();

  String? gender,
      category,
      disability,
      educationLevel,
      yearOfStudy,
      incomeRange;

  PlatformFile? incomeFile;

  final String baseUrl =
      "http://10.25.225.137/scholarfinder_api";

  // ================= FILE PICK =================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        incomeFile = result.files.first;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> submitProfile() async {
    if (_isSubmitting) return;

    if (nameController.text.isEmpty ||
        gender == null ||
        category == null ||
        educationLevel == null ||
        yearOfStudy == null ||
        incomeRange == null ||
        scoreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill required fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/save_profile.php"),
      );

      request.fields.addAll({
        "user_id": widget.userId.toString(),
        "name": nameController.text,
        "gender": gender!,
        "category": category!,
        "disability": disability ?? "No",
        "education_level": educationLevel!,
        "year_of_study": yearOfStudy!,
        "academic_score": scoreController.text,
        "income_range": incomeRange!,
      });

      if (incomeFile != null) {
        request.files.add(
  await http.MultipartFile.fromPath(
    'income_certificate',
    incomeFile!.path!,
  ),
);
      }

      // 🔥 TIMEOUT FIX
      final response =
          await request.send().timeout(const Duration(seconds: 15));

      final res = await response.stream.bytesToString();
      final data = json.decode(res);

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (data['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProfileSuccessPage(userId: widget.userId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Error")),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error / Timeout")),
      );
    }
  }

  // ================= REVIEW =================
  Widget reviewItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("$label : ${value ?? '-'}"),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final steps = [

      // PERSONAL
      Step(
        title: const Text("Personal"),
        content: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: "Full Name"),
            ),
            dropdown("Gender", ["Male", "Female", "Other"],
                (v) => gender = v),
            dropdown("Category", ["SC", "ST", "OBC", "General"],
                (v) => category = v),
            dropdown("Disability", ["Yes", "No"],
                (v) => disability = v),
          ],
        ),
      ),

      // ACADEMIC
      Step(
        title: const Text("Academic"),
        content: Column(
          children: [
            dropdown("Education Level",
                ["School", "UG", "PG"], (v) => educationLevel = v),
            dropdown("Year of Study", ["1", "2", "3", "4"],
                (v) => yearOfStudy = v),
            TextField(
              controller: scoreController,
              decoration:
                  const InputDecoration(labelText: "CGPA / %"),
            ),
          ],
        ),
      ),

      // ECONOMIC
      Step(
        title: const Text("Economic"),
        content: Column(
          children: [
            dropdown("Income Range", [
              "Below 1L",
              "1L–2.5L",
              "2.5L–5L",
              "Above 5L"
            ], (v) => incomeRange = v),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.upload),
              label: const Text("Upload Income Certificate"),
            ),
            if (incomeFile != null)
              Text("Selected: ${incomeFile!.name}")
          ],
        ),
      ),

      // 🔥 REVIEW STEP (ADDED BACK)
      Step(
        title: const Text("Review"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            reviewItem("Name", nameController.text),
            reviewItem("Gender", gender),
            reviewItem("Category", category),
            reviewItem("Education", educationLevel),
            reviewItem("Year", yearOfStudy),
            reviewItem("Score", scoreController.text),
            reviewItem("Income", incomeRange),
            reviewItem(
                "Certificate", incomeFile?.name ?? "Not uploaded"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isSubmitting ? null : submitProfile,
              child: _isSubmitting
                  ? const CircularProgressIndicator(
                      color: Colors.white)
                  : const Text("Submit Profile"),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
        backgroundColor: const Color(0xFF4B0082),
      ),
      body: Stepper(
        currentStep: _currentStep,
        steps: steps,
        onStepContinue: () {
          if (_currentStep < steps.length - 1) {
            setState(() => _currentStep++);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
      ),
    );
  }

  Widget dropdown(
      String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}