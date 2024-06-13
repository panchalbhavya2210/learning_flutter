import 'package:auth_try_ft/LogIn/login.dart';
import 'package:auth_try_ft/SignIn/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    user.main();
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Auth app"),
      ),
      body: Column(
        children: [
          ElevatedButton.icon(
              onPressed: () => {Navigator.pushNamed(context, '/signup')},
              icon: const Icon(Icons.abc),
              label: const Text("Sign Up")),
          ElevatedButton.icon(
              onPressed: () => {Navigator.pushNamed(context, '/login')},
              icon: const Icon(Icons.abc),
              label: const Text("Login")),
          if (user.imgString != null && user.imgString != 'none')
            Image.network(user.imgString!)
          else
            const Text("No profile image available"),
          Text(user.userEmail.toString())
        ],
      ),
    ));
  }
}
