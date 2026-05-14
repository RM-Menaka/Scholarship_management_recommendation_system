import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApplyScholarshipPage extends StatefulWidget {
  final Map scholarship;
  final int userId;

  const ApplyScholarshipPage({
    super.key,
    required this.scholarship,
    required this.userId,
  });

  @override
  State<ApplyScholarshipPage> createState() =>
      _ApplyScholarshipPageState();
}

class _ApplyScholarshipPageState
    extends State<ApplyScholarshipPage> {

  Map<String, PlatformFile?> docs = {};
  List requiredDocs = [];

  final baseUrl = "http://10.25.225.137/scholarfinder_api";

  @override
  void initState() {
    super.initState();

    // ✅ SAFE DOCUMENT PARSE
    try {
      requiredDocs = json.decode(
          widget.scholarship['required_documents'] ?? "[]");
    } catch (e) {
      requiredDocs = [];
    }
  }

  // ================= FILE PICK =================
  Future<void> pickFile(String doc) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // 🔥 only PDF
    );

    if (result != null) {
      setState(() {
        docs[doc] = result.files.first;
      });
    }
  }

  // ================= SUBMIT =================
  Future<void> submit() async {

    // 🔥 VALIDATE FILES
    for (var doc in requiredDocs) {
      if (docs[doc] == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Upload $doc")));
        return;
      }
    }

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/apply_scholarship.php"),
    );

    request.fields.addAll({
      "user_id": widget.userId.toString(),
      "scholarship_id":
          widget.scholarship['scholarship_id'].toString(),

      // ✅ NO EXTRA JSON
      "extra_data": "{}",
    });

    // 🔥 FILE UPLOAD
    for (var doc in requiredDocs) {
      request.files.add(
        await http.MultipartFile.fromPath(
          doc,
          docs[doc]!.path!,
        ),
      );
    }

    final res = await request.send();
    final body = await res.stream.bytesToString();
    final data = json.decode(body);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(data['message'])));

    Navigator.pop(context);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text("Upload Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          // 🔥 DOCUMENT LIST
          if (requiredDocs.isEmpty)
            const Text(
              "No documents required",
              style: TextStyle(color: Colors.grey),
            ),

          ...requiredDocs.map((doc) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(doc),
                  subtitle: docs[doc] != null
                      ? Text(docs[doc]!.name)
                      : const Text("No file selected"),
                  trailing: ElevatedButton(
                    onPressed: () => pickFile(doc),
                    child: Text(
                        docs[doc] == null ? "Upload" : "Replace"),
                  ),
                ),
              )),

          const SizedBox(height: 20),

          // 🔥 SUBMIT
          ElevatedButton(
            onPressed: submit,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}