import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'applicant_detail_page.dart';

class ApplicantsPage extends StatefulWidget {
  final int scholarshipId;

  const ApplicantsPage({super.key, required this.scholarshipId});

  @override
  State<ApplicantsPage> createState() => _ApplicantsPageState();
}

class _ApplicantsPageState extends State<ApplicantsPage> {
  List applicants = [];
  bool isLoading = true;

  final baseUrl = "http://10.25.225.137/scholarfinder_api";

  Future<void> fetchApplicants() async {
    final res = await http.get(
      Uri.parse("$baseUrl/get_applicants.php?scholarship_id=${widget.scholarshipId}"),
    );

    final data = json.decode(res.body);

    setState(() {
      applicants = data['data'] ?? [];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchApplicants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Applicants")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: applicants.length,
              itemBuilder: (_, i) {
                final a = applicants[i];

                return ListTile(
                  title: Text(a['name'] ?? "Student"),
                  subtitle: Text("Status: ${a['status']}"),
                  trailing: const Icon(Icons.arrow_forward_ios),

                  onTap: () async {
  final refresh = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ApplicantDetailPage(data: a),
    ),
  );

  if (refresh == true) {
    fetchApplicants(); // 🔥 refresh list
  }
},
                  
                );
              },
            ),
    );
  }
}