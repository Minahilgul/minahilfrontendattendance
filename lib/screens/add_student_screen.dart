import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final teacherId = FirebaseAuth.instance.currentUser!.uid;
  final baseUrl = "http://localhost:8000/api";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Student"),
        backgroundColor: const Color(0xff1f4e79),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text("Add New Student"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1f4e79),
                ),
                onPressed: () => _showAddStudentPopup(context),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: http.get(Uri.parse('$baseUrl/teacher/$teacherId/approved-students')),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var data = jsonDecode(snapshot.data!.body);
                if (data['students'] == null || data['students'].isEmpty) {
                  return const Center(child: Text('Abhi koi approved student nahi hai'));
                }
                return ListView.builder(
                  itemCount: data['students'].length,
                  itemBuilder: (context, index) {
                    var student = data['students'][index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(student['name']),
                        subtitle: Text('Class: ${student['class']} | Roll: ${student['roll_no']} | Status: ${student['student_status']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentPopup(BuildContext context) {
    final nameController = TextEditingController();
    final rollController = TextEditingController();
    String selectedClass = '';
    String selectedStatus = 'Active';
    List classes = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return FutureBuilder(
            future: http.get(Uri.parse('$baseUrl/classes')),
            builder: (context, snap) {
              if (snap.hasData) {
                classes = jsonDecode(snap.data!.body)['classes'];
                if (selectedClass == '' && classes.isNotEmpty) {
                  selectedClass = classes[0]['name'];
                }
              }
              return AlertDialog(
                title: const Text('Add Student'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedClass.isEmpty ? null : selectedClass,
                        items: classes.map<DropdownMenuItem<String>>((c) {
                          return DropdownMenuItem<String>(
                            value: c['name'].toString(),
                            child: Text(c['name'].toString()),
                          );
                        }).toList(),
                        onChanged: (String? val) {
                          setState(() {
                            selectedClass = val!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: rollController,
                        decoration: const InputDecoration(
                          labelText: 'Roll No',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        items: ['Active', 'Inactive', 'Struck Out', 'On Leave']
                            .map((s) => DropdownMenuItem<String>(
                                  value: s,
                                  child: Text(s),
                                ))
                            .toList(),
                        onChanged: (String? val) {
                          setState(() {
                            selectedStatus = val!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () => _submitForApproval(nameController.text, selectedClass, rollController.text, selectedStatus),
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  Future<void> _submitForApproval(String name, String cls, String roll, String status) async {
    Navigator.pop(context);
    final body = {
      "name": name,
      "class": cls,
      "roll_no": roll,
      "student_status": status,
      "teacher_id": teacherId,
      "approval_status": "pending"
    };

    final response = await http.post(
      Uri.parse('$baseUrl/pending-students/'),
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student sent for admin approval')));
      setState(() {}); // list refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
    }
  }
}