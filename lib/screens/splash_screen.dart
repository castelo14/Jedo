import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';
import 'register_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: Future.value(FirebaseAuth.instance.currentUser),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          return MapScreen();
        } else {
          return RegisterScreen();
        }
      },
    );
  }
}
