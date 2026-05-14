import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostScholarshipPage extends StatefulWidget {
  final int userId;

  const PostScholarshipPage({super.key, required this.userId});

  @override
  State<PostScholarshipPage> createState() => _PostScholarshipPageState();
}

class _PostScholarshipPageState extends State<PostScholarshipPage> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final slotsController = TextEditingController();
  final minPercentageController = TextEditingController();
  final maxIncomeController = TextEditingController();

  // 🔥 NEW (ALREADY DECLARED BUT NOT USED BEFORE)
  final docsController = TextEditingController();
  final fieldsController = TextEditingController();

  DateTime? deadline;

  String? category;
  String? educationLevel;
  String genderPreference = "Any";

  final Color primaryPurple = const Color(0xFF4B0082);
  final String baseUrl = "http://10.25.225.137/scholarfinder_api";

  final categories = ["Merit", "Need", "Sports", "Minority", "Other"];
  final educationLevels = ["School", "UG", "PG", "PhD"];
  final genders = ["Any", "Male", "Female", "Other"];

  // ================= DATE PICKER =================
  Future<void> pickDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> submitScholarship() async {
    if (!_formKey.currentState!.validate()) return;

    if (educationLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select education level")),
      );
      return;
    }

    if (deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select deadline")),
      );
      return;
    }
   
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/post_scholarship.php"),
        body: {
          "trust_id": widget.userId.toString(),
          "title": titleController.text,
          "description": descriptionController.text,
          "category": category ?? "",
          "amount": amountController.text,
          "total_slots": slotsController.text,
          "education_level": educationLevel!,
          "min_percentage": minPercentageController.text,
          "max_income": maxIncomeController.text,
          "gender_preference": genderPreference,
          "application_start_date":
              DateTime.now().toString().split(" ")[0],
          "application_end_date":
              deadline.toString().split(" ")[0],

          // 🔥 IMPORTANT ADDITIONS
          "required_documents": json.encode(
            docsController.text
                .split(",")
                .map((e) => e.trim())
                .toList(),
          ),

          
        },
      );

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scholarship Posted Successfully")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  // ================= INPUT FIELD =================
  Widget inputField(String label, TextEditingController controller,
      IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) =>
            value == null || value.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ================= DROPDOWN =================
  Widget dropdown(String label, List<String> items,
      Function(String?) onChanged) {
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Scholarship"),
        backgroundColor: primaryPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              inputField("Title", titleController, Icons.title),
              inputField(
                  "Description", descriptionController, Icons.description),

              dropdown("Category", categories, (v) => category = v),
              dropdown("Education Level", educationLevels,
                  (v) => educationLevel = v),

              Row(
                children: [
                  Expanded(
                      child: inputField(
                          "Amount", amountController, Icons.money)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: inputField(
                          "Slots", slotsController, Icons.group)),
                ],
              ),

              Row(
                children: [
                  Expanded(
                      child: inputField("Min %", minPercentageController,
                          Icons.percent)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: inputField("Max Income",
                          maxIncomeController, Icons.money)),
                ],
              ),

              dropdown("Gender", genders,
                  (v) => genderPreference = v ?? "Any"),

              const SizedBox(height: 10),

              ListTile(
                title: Text(deadline == null
                    ? "Select Deadline"
                    : "Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickDeadline,
              ),

              const SizedBox(height: 20),

              // 🔥 NEW SECTION
              inputField(
                "Required Documents (comma separated)",
                docsController,
                Icons.description,
              ),

              

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: submitScholarship,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                  ),
                  child: const Text(
                    "POST",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}