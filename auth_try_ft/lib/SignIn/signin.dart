import 'dart:io';
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
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => {Navigator.pop(context)},
          ),
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
  final storage =
      FirebaseStorage.instanceFor(bucket: "gs://autheflutter.appspot.com")
          .ref();
  final database = FirebaseDatabase.instance.ref();
  File? _pickedFile;

  Future<void> registerUser() async {
    if (_pickedFile == null) {
      print('No file selected for upload.');
      return;
    }

    final fileName = _pickedFile!.path.split('/').last;
    final path = 'files/$fileName';
    final file = File(_pickedFile!.path);
    print(file);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      print(userCredential.user?.uid);
      final userId = userCredential.user?.uid;
      if (userId != null) {
        final path = '$userId/$fileName';
        final ref = storage.child(path);
        await ref.putFile(file);
        final downloadURL = await ref.getDownloadURL();

        await database
            .child("users/$userId")
            .set({"email": _email.text, "publicUrl": downloadURL});
        print("This is url of file : $downloadURL");

        print('User registered and file uploaded: $userId');
      }

      print('User registered and file uploaded: ${userCredential.user?.uid}');
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

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
      print('File selected: ${_pickedFile!.path}');
    } else {
      print("An error has occurred");
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
                obscureText: true,
              ),
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: Icon(Icons.sd_card),
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
