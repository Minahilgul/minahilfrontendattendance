import 'package:flutter/material.dart';

class ViewAttendanceScreen extends StatelessWidget {
  const ViewAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Attendance"),
      ),
      body: const Center(
        child: Text("Attendance Screen"),
      ),
    );
  }
}