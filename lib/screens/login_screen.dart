import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';
import 'register_screen.dart'; // Adiciona a tela de registro

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variável para alternar entre login por email ou telefone
  bool _isEmailLogin = true;

  // Função para login com e-mail
  Future<void> _loginWithEmail(BuildContext context) async {
    final email = emailController.text.trim();
    
    try {
      // Verifica se o e-mail existe no Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Se o e-mail foi encontrado, faz login com o e-mail
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login realizado com sucesso!'),
        ));
        
        // Navega para a tela do mapa
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MapScreen()),
        );
      } else {
        // Caso o e-mail não seja encontrado, direciona para a tela de registro
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('E-mail não registrado!'),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RegisterScreen()),
        );
      }
    } catch (e) {
      print('Erro ao tentar logar com e-mail: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao tentar logar com e-mail!'),
      ));
    }
  }

  // Função para login com telefone
  Future<void> _loginWithPhone(BuildContext context) async {
    final phone = phoneController.text.trim();
    
    try {
      // Verifica se o telefone existe no Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Se o telefone foi encontrado, faz login
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login realizado com sucesso!'),
        ));
        
        // Navega para a tela do mapa
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MapScreen()),
        );
      } else {
        // Caso o telefone não seja encontrado, direciona para a tela de registro
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Telefone não registrado!'),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RegisterScreen()),
        );
      }
    } catch (e) {
      print('Erro ao tentar logar com telefone: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao tentar logar com telefone!'),
      ));
    }
  }

  // Validação do email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um e-mail';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  // Validação do telefone
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o número de telefone';
    }
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Por favor, insira um telefone válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Switch entre login por e-mail ou telefone
                  SwitchListTile(
                    title: Text('Login com e-mail'),
                    value: _isEmailLogin,
                    onChanged: (bool value) {
                      setState(() {
                        _isEmailLogin = value;
                      });
                    },
                  ),
                  // Campo E-mail
                  if (_isEmailLogin)
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      validator: _validateEmail,
                    ),
                  // Campo Telefone
                  if (!_isEmailLogin)
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                  SizedBox(height: 32),

                  // Botão de Login
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (_isEmailLogin) {
                          _loginWithEmail(context);
                        } else {
                          _loginWithPhone(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
