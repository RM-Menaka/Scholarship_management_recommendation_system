import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'trust_dashboard_page.dart';

class TrustProfileSetupPage extends StatefulWidget {
  final int userId;
  const TrustProfileSetupPage({super.key, required this.userId});

  @override
  State<TrustProfileSetupPage> createState() =>
      _TrustProfileSetupPageState();
}

class _TrustProfileSetupPageState extends State<TrustProfileSetupPage> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Controllers
  final trustNameController = TextEditingController();
  final regNoController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final darpanIdController = TextEditingController();

  String? trustType, state, district;

  File? selectedFile;
  String? fileName;

  String? regError;

  final Color primaryPurple = const Color(0xFF4B0082);

  final List<String> trustTypes = [
    "Society (TN Societies Act)",
    "Public Charitable Trust",
    "Educational Trust",
    "Section 8 Company",
    "Government-Aided Trust",
  ];

  final List<String> states = ["Tamil Nadu"];

  final List<String> districts = [
    "Chennai",
    "Coimbatore",
    "Madurai",
    "Salem",
    "Tiruchirappalli",
    "Tirunelveli",
  ];

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";

  // ================= VALIDATION =================
  bool isValidRegistration(String regNo) {
    return RegExp(r'^[A-Za-z0-9/.-]{5,50}$')
        .hasMatch(regNo.trim());
  }

  // ================= FILE PICKER =================
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> submitTrustProfile() async {
    if (_isSubmitting) return;

    if (trustNameController.text.isEmpty ||
        regNoController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        trustType == null ||
        state == null ||
        district == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details")),
      );
      return;
    }

    if (!isValidRegistration(regNoController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid registration number")),
      );
      return;
    }

    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload certificate")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/save_trust_profile.php"),
      );

      request.fields.addAll({
        "user_id": widget.userId.toString(),
        "trust_name": trustNameController.text.trim(),
        "trust_type": trustType!,
        "registration_number": regNoController.text.trim(),
        "trust_email": emailController.text.trim(),
        "trust_phone": phoneController.text.trim(),
        "address": addressController.text.trim(),
        "state": state!,
        "district": district!,
        "darpan_id": darpanIdController.text.trim(),
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          selectedFile!.path,
        ),
      );

      var response = await request.send();
      var res = await response.stream.bytesToString();
      final data = json.decode(res);

      setState(() => _isSubmitting = false);

      if (data['status'] == 'success') {
        Navigator.pushReplacement(
        context,
        MaterialPageRoute(
        builder: (_) => TrustDashboardPage(userId: widget.userId),
        ),
);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed")),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trust Profile Setup"),
        backgroundColor: primaryPurple,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep++);
          } else {
            submitTrustProfile();
          }
        },
        onStepCancel:
            _currentStep == 0 ? null : () => setState(() => _currentStep--),
        steps: [

          // STEP 1: TRUST DETAILS
          Step(
            title: const Text("Trust Details"),
            content: Column(
              children: [
                textField(trustNameController, "Trust Name"),
                dropdown("Trust Type", trustTypes, (v) => trustType = v),

                TextField(
                  controller: regNoController,
                  onChanged: (v) {
                    setState(() {
                      regError = isValidRegistration(v)
                          ? null
                          : "Invalid registration number";
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Registration Number",
                    errorText: regError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                textField(
                    darpanIdController,
                    "NGO Darpan ID (Optional)"),
              ],
            ),
          ),

          // STEP 2: CONTACT
          Step(
            title: const Text("Contact"),
            content: Column(
              children: [
                textField(emailController, "Email"),
                textField(phoneController, "Phone"),
                textField(addressController, "Address", maxLines: 3),
              ],
            ),
          ),

          // STEP 3: LOCATION
          Step(
            title: const Text("Location"),
            content: Column(
              children: [
                dropdown("State", states, (v) => state = v),
                dropdown("District", districts, (v) => district = v),
              ],
            ),
          ),

          // STEP 4: UPLOAD
          Step(
            title: const Text("Verification"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload Registration Certificate (Required)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: pickFile,
                  child: const Text("Choose File"),
                ),

                if (fileName != null)
                  Text("Selected: $fileName"),

                const SizedBox(height: 10),

                const Text(
                  "Darpan ID is optional for faster verification",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // STEP 5: REVIEW
          Step(
            title: const Text("Review & Submit"),
            content: Column(
              children: [
                reviewTile("Trust Name", trustNameController.text),
                reviewTile("Type", trustType ?? ""),
                reviewTile("Registration No", regNoController.text),

                reviewTile(
                  "Darpan ID",
                  darpanIdController.text.isEmpty
                      ? "Not Provided"
                      : darpanIdController.text,
                ),

                reviewTile("Email", emailController.text),
                reviewTile("Phone", phoneController.text),
                reviewTile("Address", addressController.text),
                reviewTile("State", state ?? ""),
                reviewTile("District", district ?? ""),

                reviewTile(
                  "Document",
                  fileName ?? "Not uploaded ❌",
                ),

                const SizedBox(height: 10),

                const Text(
                  "Dashboard will be enabled only after admin approval",
                  style: TextStyle(color: Colors.red),
                ),

                if (_isSubmitting)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget textField(TextEditingController c, String l,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: l,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget dropdown(
      String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget reviewTile(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value.isEmpty ? "-" : value),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(value.isEmpty ? "No data" : value),
          ),
        );
      },
    );
  }
}