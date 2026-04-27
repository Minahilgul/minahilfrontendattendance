import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {

  final TextEditingController nameController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();
  final TextEditingController classController = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Student"),
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
                  labelText: "Student Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value!.isEmpty){
                    return "Enter student name";
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
                    "Add Student",
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
    //Get the data from the form
    final name = nameController.text;
    final studentClass = classController.text;
    final body = {
      "name": name,
      "class": studentClass,
      "is_present": false,
    };

    //Submit data to the server

    final url = "http://localhost:8000/api/students/";
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
       body: jsonEncode(body),
       
       headers: {
        "Content-Type": "application/json"},
        );

    //Show success message or fail message based on status
    if(response.statusCode == 200){
      print("Student added successfully");
    }
    else{
     print("Failed to add student");
     print(response.body);
    }
      
    
  }
}