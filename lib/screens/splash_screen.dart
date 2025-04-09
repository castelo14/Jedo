import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen1.dart';
import 'login_screen.dart'; // Tela de login

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Indicador de progresso
            ),
          );
        } else if (snapshot.hasData) {
          // Se o usuário estiver logado, navega para a tela do mapa
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MapScreen()),
            );
          });
          return Container(); // Exibe um container vazio enquanto redireciona
        } else {
          // Se não estiver logado, navega para a tela de login
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()), // Tela de login
            );
          });
          return Container(); // Exibe um container vazio enquanto redireciona
        }
      },
    );
  }
}
