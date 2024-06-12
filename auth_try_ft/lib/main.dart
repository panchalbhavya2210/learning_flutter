import 'package:auth_try_ft/LogIn/login.dart';
import 'package:auth_try_ft/SignIn/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

//

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/signup': (context) => MyForm(),
      '/login': (context) => MyLoginForm(),
    },
    theme:
        ThemeData(primaryColor: Colors.blueAccent, primarySwatch: Colors.red),
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("Auth app"),
      ),
      body: Column(
        children: [
          ElevatedButton.icon(
              onPressed: () => {Navigator.pushNamed(context, '/signup')},
              icon: Icon(Icons.abc),
              label: const Text("Sign Up")),
          ElevatedButton.icon(
              onPressed: () => {Navigator.pushNamed(context, '/login')},
              icon: Icon(Icons.abc),
              label: const Text("Login")),
        ],
      ),
    )
        // home:
        );
  }
}
