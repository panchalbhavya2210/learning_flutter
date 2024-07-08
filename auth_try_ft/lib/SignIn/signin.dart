import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart';
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

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
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        theme: ThemeData(colorScheme: lightDynamic, useMaterial3: true),
        title: appTitle,
        home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => {Navigator.pop(context)},
            ),
            title: const Text(appTitle),
          ),
          body: const Center(
            child: FormContainer(),
          ),
        ),
      );
    });
  }
}

class FormContainer extends StatefulWidget {
  const FormContainer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FormContainerState createState() => _FormContainerState();
}

class _FormContainerState extends State<FormContainer> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final storage =
      FirebaseStorage.instanceFor(bucket: "gs://autheflutter.appspot.com")
          .ref();
  final database = FirebaseDatabase.instance.ref();
  File? _pickedFile;

  Future<void> registerUser() async {
    if (_pickedFile == null) {
      return;
    }

    final fileName = _pickedFile!.path.split('/').last;
    final file = File(_pickedFile!.path);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      final userId = userCredential.user?.uid;
      if (userId != null) {
        final path = '$userId/$fileName';
        final ref = storage.child(path);
        await ref.putFile(file);
        final downloadURL = await ref.getDownloadURL();

        await database
            .child("users/$userId")
            .set({"email": _email.text, "photoURL": downloadURL});
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
      } else if (e.code == 'email-already-in-use') {}
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                    labelText: "Enter Your Email", filled: true),
              ),
              TextField(
                controller: _password,
                decoration: const InputDecoration(
                    labelText: "Enter Your Password", filled: true),
                obscureText: true,
              ),
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.sd_card),
                label: const Text("Pick Image"),
              ),
              ElevatedButton(
                onPressed: registerUser,
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
