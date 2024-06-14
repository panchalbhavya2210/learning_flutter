library user;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

String? imgString;
String? userEmail;
String? userID;

Future<void> loadUserData() async {
  final completer = Completer<void>();
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
      completer.complete();
    } else {
      final database = FirebaseDatabase.instance.ref();
      userID = user.uid;
      final getData = await database.child("users/$userID").get();
      if (getData.exists) {
        final userData = getData.value as Map?;

        userEmail = userData?['email'];
        imgString = userData?['photoURL'];
      }
      completer.complete();
    }
  });
  return completer.future;
}
