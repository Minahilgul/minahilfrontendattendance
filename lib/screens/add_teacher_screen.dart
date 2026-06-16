import 'package:flutter/material.dart';
import '../core/services/teacher_service.dart'; // FIX: was importing student_service.dart

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();   // FIX: uncommented
  final TextEditingController passwordController = TextEditingController(); // FIX: added
  final TextEditingController phoneController = TextEditingController();    // FIX: added
  final TextEditingController macController = TextEditingController();      // FIX: added

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    macController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Teacher"),
        backgroundColor: const Color(0xff1f4e79),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // FIX: wrapped in ScrollView so all fields fit
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Teacher Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter teacher name";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // FIX: email field restored — required by backend
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter email";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // FIX: password field added — required by backend
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return "Enter password";
                    if (value.length < 6) return "Min 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // FIX: phone field added — expected by backend
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // FIX: MAC address field added — expected by backend
                TextFormField(
                  controller: macController,
                  decoration: const InputDecoration(
                    labelText: "Device MAC Address",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitTeacher, // FIX: renamed to _submitTeacher
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1f4e79),
                    ),
                    child: const Text(
                      "Add Teacher",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIX: was calling StudentService.addStudent() — now calls TeacherService.addTeacher()
  Future<void> _submitTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await TeacherService.addTeacher(
      username: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phone: phoneController.text.trim(),
      deviceMacAddress: macController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Teacher added successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to add teacher'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}