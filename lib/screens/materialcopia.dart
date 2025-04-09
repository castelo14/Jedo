import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jedo/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isEmailLogin = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _loginWithEmail(BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login com email realizado com sucesso')),
      );
      // TODO: Navegar para a tela principal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  void _loginWithPhone(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login com telefone ainda não implementado')),
    );
    // Para implementar login via telefone, será necessário usar: `verifyPhoneNumber`, `codeSent`, etc.
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Digite seu e-mail';
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Digite seu número de telefone';
    if (!RegExp(r'^\d{9,15}$').hasMatch(value)) return 'Telefone inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Digite sua senha';
    if (value.length < 6) return 'Senha deve ter ao menos 6 caracteres';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Entre usando seu email ou número de telefone.',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
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
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    if (!_isEmailLogin)
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 30),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text(
                        'Logar',
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
