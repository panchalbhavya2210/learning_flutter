import 'package:auth_try_ft/LogIn/login.dart';
import 'package:auth_try_ft/SignIn/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'user_data.dart' as user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.red);
        ColorScheme darkColorScheme = darkDynamic ??
            ColorScheme.fromSeed(
                seedColor: Colors.red, brightness: Brightness.dark);

        return MaterialApp(
          initialRoute: '/',
          routes: {
            '/signup': (context) => const MyForm(),
            '/login': (context) => const MyLoginForm(),
          },
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true, // Ensures use of Material You design
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true, // Ensures use of Material You design
          ),
          themeMode: ThemeMode.system,
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
