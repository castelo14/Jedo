import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jedo/screens/register_screen.dart';
import 'map_screen.dart';

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
        // Caso o e-mail não seja encontrado
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('E-mail não registrado!'),
        ));
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
        // Caso o telefone não seja encontrado
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Telefone não registrado!'),
        ));
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Center(
              //  child: Image.asset(
              //    'assets/logo.jpeg', // Caminho da sua imagem
              //    width: 120, // Ajuste o tamanho da imagem
              //    height: 120, // Ajuste o tamanho da imagem
              //  ),
              //),
              Image.asset(
                'assets/logo.png', 
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, color: Colors.red, size: 50);
                },
              ),
              //const SizedBox(height: 40),
              Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
               ),
              //const SizedBox(height: 10),
              //Text(
              //  'Entre usando seu email ou número de telefone.',
              //  style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              //  textAlign: TextAlign.center,
              //),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Email'),
                    selected: _isEmailLogin,
                    onSelected: (val) {
                      setState(() => _isEmailLogin = true);
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Telefone'),
                    selected: !_isEmailLogin,
                    onSelected: (val) {
                      setState(() => _isEmailLogin = false);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_isEmailLogin)
                      TextFormField(
                        style: TextStyle(
                          //fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                          hintStyle: TextStyle(color: Colors.white70),
                          fillColor: const Color.fromARGB(26, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    if (!_isEmailLogin)
                      TextFormField(
                         style: TextStyle(
                          //fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        controller: phoneController,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.white70),
                          labelText: 'Telefone',
                          prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                      ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_isEmailLogin) {
                            _loginWithEmail(context);
                          } else {
                            _loginWithPhone(context);
                          }
                        }
                        
                        },
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Entrar",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen())
                        );
                      },
                      child: const Text(
                        'Não tem conta? Cadastre-se',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
