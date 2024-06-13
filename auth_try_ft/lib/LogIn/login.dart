// ignore_for_file: empty_catches

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyLoginForm());
}

class MyLoginForm extends StatelessWidget {
  const MyLoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = "Auth App";
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
  // ignore: library_private_types_in_public_api
  _FormContainerState createState() => _FormContainerState();
}

class _FormContainerState extends State<FormContainer> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final database = FirebaseDatabase.instance.ref();
  bool password = true;
  String? imgProfile;
  String? userEmail;

  void registerUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      final userID = userCredential.user?.uid;
      if (userID != null) {
        final getData = await database.child("users/$userID").get();
        if (getData.exists) {
          final userData = getData.value as Map?;
          setState(() {
            userEmail = userData?['email'] ?? 'none';
            imgProfile = userData?['photoURL'] ?? 'none';
          });
        } else {}
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
      } else if (e.code == 'email-already-in-use') {}
    } catch (e) {}
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
                obscureText: password,
                decoration: const InputDecoration(
                    labelText: "Enter Your Password", filled: true),
              ),
              ElevatedButton(
                  onPressed: registerUser, child: const Text("Login")),
              if (imgProfile != null && imgProfile != 'none')
                Image.network(imgProfile!)
              else
                const Text("No profile image available"),
              if (userEmail != null && userEmail != 'none')
                Text(userEmail!)
              else
                const Text("No Email Existed"),
              FloatingActionButton(
                onPressed: () => setState(() {
                  if (password == true) {
                    password = false;
                  } else if (password == false) {
                    password = true;
                  }
                }),
                child: const Icon(Icons.remove_red_eye),
              )
            ],
          ),
        ),
      ),
    );
  }
}
