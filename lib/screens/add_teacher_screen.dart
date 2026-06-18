import 'package:flutter/material.dart';
import '../core/services/teacher_service.dart';
import '../core/services/device_service.dart'; //  add this import

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {
  final TextEditingController nameController     = TextEditingController();
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController    = TextEditingController();
  final TextEditingController deviceIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // ✅ STEP 1: Add initState here
  @override
  void initState() {
    super.initState();
    _fetchDeviceId(); // auto fill device ID on screen open
  }

  // ✅ STEP 2: Add this function here
  Future<void> _fetchDeviceId() async {
    final id = await DeviceService.getDeviceId();
    setState(() {
       deviceIdController.text = id; // auto fills the MAC field
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    deviceIdController.dispose();
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller:  nameController,
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
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ MAC field is now auto-filled and read-only
                TextFormField(
                  controller: deviceIdController,
                  readOnly: true, // user cannot edit — auto filled
                  decoration: const InputDecoration(
                    labelText: "Device ID (Auto Detected)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.devices),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitTeacher,
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

  Future<void> _submitTeacher() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await TeacherService.addTeacher(
      username:         nameController.text.trim(),
      email:            emailController.text.trim(),
      password:         passwordController.text.trim(),
      phone:            phoneController.text.trim(),
      deviceId: deviceIdController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teacher added successfully!'),
          backgroundColor: Colors.green,
        ),
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