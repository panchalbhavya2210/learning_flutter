import 'dart:io';

import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyForm());
}

class MyForm extends StatelessWidget {
  const MyForm({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = "Auth App";
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const Center(
          child: FormContainer(),
        ),
      ),
    );
  }
}

class FormContainer extends StatefulWidget {
  const FormContainer({super.key});

  @override
  _FormContainerState createState() => _FormContainerState();
}

class _FormContainerState extends State<FormContainer> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void registerUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      print(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
    } else {
      print("An error has been occure");
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _email,
                decoration: InputDecoration(
                    labelText: "Enter Your Email", filled: true),
              ),
              TextField(
                controller: _password,
                decoration: InputDecoration(
                    labelText: "Enter Your Password", filled: true),
              ),
              ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: Icon(Icons.sd_card),
                  label: const Text("Pick Image")),
              ElevatedButton(
                  onPressed: registerUser, child: const Text("Sign Up")),
            ],
          ),
        ),
      ),
    );
  }
}
