library user;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

String? imgString;
String? userEmail;
String? userID;

void main() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user == null) {
    } else {
      final database = FirebaseDatabase.instance.ref();
      userID = user.uid;
      final getData = await database.child("users/$userID").get();
      if (getData.exists) {
        final userData = getData.value as Map?;

        userEmail = userData?['email'];
        imgString = userData?['photoURL'];
      }
    }
  });
}
