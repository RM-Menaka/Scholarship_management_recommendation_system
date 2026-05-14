import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class TrustProfilePage extends StatefulWidget {
  final int userId;
  const TrustProfilePage({super.key, required this.userId});

  @override
  State<TrustProfilePage> createState() => _TrustProfilePageState();
}

class _TrustProfilePageState extends State<TrustProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isEditing = false;
  bool isLoading = true; // ✅ NEW
  String verificationStatus = "pending";

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";

  // ================= FETCH PROFILE =================
  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/get_trust_profile.php?user_id=${widget.userId}"),
      );

      final data = json.decode(response.body);

      if (!mounted) return;

      if (data['status'] == 'success') {
        final profile = data['data'];

        setState(() {
          nameController.text = profile['trust_name'] ?? "";
          emailController.text = profile['trust_email'] ?? "";
          phoneController.text = profile['trust_phone'] ?? "";
          locationController.text =
              "${profile['district'] ?? ""}, ${profile['state'] ?? ""}";
          descriptionController.text = profile['trust_type'] ?? "";
          verificationStatus = profile['verification_status'] ?? "pending";

          isLoading = false; // ✅ FIXED
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching profile: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // ================= INPUT FIELD =================
  Widget inputField(String label, TextEditingController controller, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEditing && verificationStatus == "approved",
          keyboardType: type,
          inputFormatters: label == "Phone Number"
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10)
                ]
              : null,
          validator: (value) {
            if (value == null || value.isEmpty) return "Enter $label";

            if (label == "Email Address") {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return "Invalid email";
              }
            }

            if (label == "Phone Number" && value.length != 10) {
              return "Phone must be 10 digits";
            }

            return null;
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF4B0082)),
            filled: true,
            fillColor: (isEditing && verificationStatus == "approved")
                ? Colors.white
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  // ================= STATUS =================
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

  // ================= SAVE =================
  void saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() => isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated")),
      );
    }
  }

  // ================= LOGOUT =================
  void handleLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B0082),
        title: const Text("Trust Profile"),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') {
                if (verificationStatus != "approved") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Editing allowed only after admin approval"),
                    ),
                  );
                  return;
                }

                isEditing
                    ? saveProfile()
                    : setState(() => isEditing = true);
              } else if (value == 'logout') {
                handleLogout();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(isEditing ? "Save" : "Edit"),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text("Logout"),
              ),
            ],
          )
        ],
      ),

      // 🔥 FIXED BODY
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    // HEADER
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF4B0082),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            child: Icon(Icons.business, size: 40),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            "Status: ${getStatusText()}",
                            style: TextStyle(
                              color: getStatusColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          if (verificationStatus == "approved")
                            const Text(
                              "You can now edit and post scholarships",
                              style: TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          inputField("Trust Name", nameController,
                              Icons.account_balance),
                          inputField("Email Address", emailController,
                              Icons.email),
                          inputField("Phone Number", phoneController,
                              Icons.phone),
                          inputField("Location", locationController,
                              Icons.location_on),
                          inputField("Trust Type", descriptionController,
                              Icons.category),

                          if (isEditing &&
                              verificationStatus == "approved")
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: saveProfile,
                                child: const Text("Save Changes"),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}