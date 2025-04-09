import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/map_screen.dart';
import 'screens/login_screen.dart'; // Adicionando a tela de login

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mototáxi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // você pode personalizar se quiser
      home: LoginScreen(), // inicializa com a tela de login
    );
  }
}