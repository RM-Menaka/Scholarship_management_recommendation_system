import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  final int userId;

  const NotificationPage({super.key, required this.userId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List notifications = [];
  bool isLoading = true;

  final String baseUrl =
      "http://10.25.225.137/scholarfinder_api";

  Future<void> fetchNotifications() async {
    final res = await http.get(
      Uri.parse("$baseUrl/get_notifications.php?user_id=${widget.userId}"),
    );

    final data = json.decode(res.body);

    setState(() {
      notifications = data['data'] ?? [];
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF4B0082),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("No notifications"))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, i) {
                    final n = notifications[i];

                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(n['title']),
                      subtitle: Text(n['message']),
                    );
                  },
                ),
    );
  }
}