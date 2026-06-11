import 'package:flutter/material.dart';
import '../core/services/student_service.dart';

class AddTeacherScreen extends StatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  State<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends State<AddTeacherScreen> {

  final TextEditingController nameController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  final _formKey = GlobalKey<FormState>();


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

          child: Column(

            children: [

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Teacher Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value!.isEmpty){
                    return "Enter teacher name";
                  }
                  return null;
                },
              ),

              const SizedBox(height:20),

              // TextFormField(
              //   controller: emailController,
              //   decoration: const InputDecoration(
              //     labelText: "Email",
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value){
              //     if(value!.isEmpty){
              //       return "Enter email";
              //     }
              //     return null;
              //   },
              // ),

              // const SizedBox(height:20),

              TextFormField(
                controller: classController,
                decoration: const InputDecoration(
                  labelText: "Class",
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value!.isEmpty){
                    return "Enter class";
                  }
                  return null;
                },
              ),

              const SizedBox(height:30),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: submitStudent,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1f4e79),
                  ),

                  child: const Text(
                    "Add Teacher",
                    style: TextStyle(fontSize:16),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitStudent() async {
    final name = nameController.text.trim();
    final studentClass = classController.text.trim();
    
    final success = await StudentService.addStudent(
      name: name,
      cls: studentClass,
    );

    if (success) {
      print("Student added successfully");
    } else {
      print("Failed to add student");
    }
  }
}