import 'package:attendence_verification/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import '../../core/services/teacher_service.dart';
import '../../core/services/device_service.dart';
import '../../core/theme/app_colors.dart';

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
  final TextEditingController addressController  = TextEditingController(); 
  final TextEditingController deviceIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  
  @override
  void initState() {
    super.initState();
    _fetchDeviceId(); // auto fill device ID on screen open
  }

  
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
    addressController.dispose(); // ADDED
    deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Teacher"),
        backgroundColor: AppColors.primary,
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
                  maxLength: 11,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the correct number";
                    }
                    if (!RegExp(r'^[0-9]{11}$').hasMatch(value.trim())) {
                      return "Please enter the correct number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Address field 
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // MAC field is auto-filled and read-only
                TextFormField(
                  controller: deviceIdController,
                  readOnly: true, // user cannot edit  auto filled
                  decoration: InputDecoration(
                    labelText: "Device ID (Auto Detected)",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.devices),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: GradientButton(
                    onPressed: _submitTeacher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
      address:          addressController.text.trim(), 
      deviceId: deviceIdController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Teacher added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to add teacher'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}