import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pdf_viewer_page.dart';
import 'package:file_picker/file_picker.dart';
import 'login_page.dart';

class StudentProfilePage extends StatefulWidget {
  final int userId;

  StudentProfilePage({super.key, required this.userId});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  PlatformFile? newCertificate;
  bool isLoading = true;
  bool isEdit = false;

  final String baseUrl = "http://10.25.225.137/scholarfinder_api";
  final Color primaryPurple = const Color(0xFF4B0082);

  // Controllers
  final nameCtrl = TextEditingController();
  final genderCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final disabilityCtrl = TextEditingController();
  final eduCtrl = TextEditingController();
  final courseCtrl = TextEditingController();
  final yearCtrl = TextEditingController();
  final scoreCtrl = TextEditingController();
  final incomeCtrl = TextEditingController();
  final incomeCertCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
 
  final collegeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // ================= LOGIC (UNCHANGED) =================
  Future<void> pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() => newCertificate = result.files.first);
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/get_student_profile.php?user_id=${widget.userId}"));
      final data = json.decode(res.body);
      if (!mounted) return;
      if (data['status'] == 'success') {
        final d = data['data'];
        nameCtrl.text = d['name'] ?? '';
        genderCtrl.text = d['gender'] ?? '';
        categoryCtrl.text = d['category'] ?? '';
        disabilityCtrl.text = d['disability'] ?? '';
        eduCtrl.text = d['education_level'] ?? '';
        courseCtrl.text = d['course'] ?? '';
        yearCtrl.text = d['year_of_study'] ?? '';
        scoreCtrl.text = d['academic_score'] ?? '';
        incomeCtrl.text = d['income_range'] ?? '';
        incomeCertCtrl.text = d['income_certificate'] ?? '';
        stateCtrl.text = d['state'] ?? '';
       
        collegeCtrl.text = d['college_name'] ?? '';
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProfile() async {
  try {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/update_student_profile.php"),
    );

    // ================= TEXT FIELDS =================
    request.fields.addAll({
      "user_id": widget.userId.toString(),
      "name": nameCtrl.text,
      "gender": genderCtrl.text,
      "category": categoryCtrl.text,
      "disability": disabilityCtrl.text,
      "education_level": eduCtrl.text,
      "course": courseCtrl.text,
      "year_of_study": yearCtrl.text,
      "academic_score": scoreCtrl.text,
      "income_range": incomeCtrl.text,
      "state": stateCtrl.text,
      
      "college_name": collegeCtrl.text,
    });

    // ================= FILE UPLOAD =================
    if (newCertificate != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "income_certificate",
          newCertificate!.path!,
        ),
      );
    }

    // ================= SEND REQUEST =================
    final res = await request.send();
    final body = await res.stream.bytesToString();
    final data = json.decode(body);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data['message'])),
    );

    setState(() => isEdit = false);

    // 🔥 IMPORTANT → refresh from DB
    await fetchProfile();

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Update failed")),
    );
  }
}

  // ================= MODERN UI COMPONENTS =================

  Widget buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: primaryPurple, size: 22),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget inputField(String label, TextEditingController ctrl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        enabled: isEdit,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: isEdit ? Colors.white : const Color(0xFFF9F9F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryPurple)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Student Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryPurple,
        actions: [
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == "edit") setState(() => isEdit = true);
              if (value == "logout")
              { Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => LoginPage()),
  (route) => false,
);}
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "edit", child: ListTile(leading: Icon(Icons.edit), title: Text("Edit Profile"))),
              const PopupMenuItem(value: "logout", child: ListTile(leading: Icon(Icons.logout), title: Text("Logout"))),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: primaryPurple.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: primaryPurple),
                  ),
                  const SizedBox(height: 10),
                  Text(nameCtrl.text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Student ID: #${widget.userId}", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 25),

                  // Sections
                  buildSectionCard(
                    title: "Personal Details",
                    icon: Icons.badge_outlined,
                    children: [
                      inputField("Full Name", nameCtrl, Icons.person_outline),
                      inputField("Gender", genderCtrl, Icons.wc),
                      inputField("Category", categoryCtrl, Icons.category_outlined),
                      inputField("Disability Status", disabilityCtrl, Icons.accessible_forward),
                    ],
                  ),

                  buildSectionCard(
                    title: "Education",
                    icon: Icons.school_outlined,
                    children: [
                      inputField("Education Level", eduCtrl, Icons.auto_stories_outlined),
                      inputField("Course", courseCtrl, Icons.book_outlined),
                      inputField("Year of Study", yearCtrl, Icons.calendar_today_outlined),
                      inputField("Academic Score (%)", scoreCtrl, Icons.grade_outlined),
                      inputField("College Name", collegeCtrl, Icons.account_balance_outlined),
                    ],
                  ),

                  buildSectionCard(
                    title: "Financial Information",
                    icon: Icons.account_balance_wallet_outlined,
                    children: [
                      inputField("Annual Income Range", incomeCtrl, Icons.payments_outlined),
                      const SizedBox(height: 5),
                      const Text("Income Certificate", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                            const SizedBox(width: 10),
                            Expanded(child: Text(incomeCertCtrl.text.isEmpty ? "No file uploaded" : incomeCertCtrl.text, style: const TextStyle(fontSize: 13))),
                            if (incomeCertCtrl.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerPage(url: "$baseUrl/uploads/${incomeCertCtrl.text}")));
                                },
                              ),
                          ],
                        ),
                      ),
                      if (isEdit) ...[
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: pickCertificate,
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: const Text("Replace Certificate"),
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        if (newCertificate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("Ready: ${newCertificate!.name}", style: const TextStyle(color: Colors.green, fontSize: 12)),
                          ),
                      ],
                    ],
                  ),

                  buildSectionCard(
                    title: "Location Details",
                    icon: Icons.location_on_outlined,
                    children: [
                      inputField("State", stateCtrl, Icons.map_outlined),
                      
                    ],
                  ),

                  if (isEdit)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}