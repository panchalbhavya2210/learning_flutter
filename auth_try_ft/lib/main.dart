import 'package:auth_try_ft/LogIn/login.dart';
import 'package:auth_try_ft/SignIn/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_data.dart' as user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/signup': (context) => const MyForm(),
      '/login': (context) => const MyLoginForm(),
    },
    theme:
        ThemeData(primaryColor: Colors.blueAccent, primarySwatch: Colors.red),
    home: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = user.loadUserData();
  }

  signOutUser() async {
    print("user signed out");
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Auth app"),
      ),
      body: FutureBuilder<void>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => {Navigator.pushNamed(context, '/signup')},
                  icon: const Icon(Icons.abc),
                  label: const Text("Sign Up"),
                ),
                if (user.userID != "" || user.userID != null)
                  const Text("logged in")
                else
                  const Text("not logged in"),
                if (user.imgString != null && user.imgString != 'none')
                  Image.network(user.imgString!)
                else
                  const Text("No profile image available"),
                Text(user.userEmail.toString()),
                ElevatedButton(
                    onPressed: () => {signOutUser()},
                    child: const Text("sign out"))
              ],
            );
          }
        },
      ),
    );
  }
}
