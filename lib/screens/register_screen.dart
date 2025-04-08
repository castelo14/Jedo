import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_screen.dart';

class RegisterScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

 Future<void> _register(BuildContext context) async {
    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    try {
      // Adicionar diretamente os dados no Firestore sem autenticação
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'surname': surname,
        'email': email,
        'phone': phone,
      });

      // Se o registro foi bem-sucedido, navega para a MapScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MapScreen()),
      );
    } catch (e) {
      print('Erro ao cadastrar: $e');
      // Exibir a mensagem de erro na tela
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao registrar!'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
              TextFormField(controller: surnameController, decoration: InputDecoration(labelText: 'Sobrenome')),
              TextFormField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextFormField(controller: phoneController, decoration: InputDecoration(labelText: 'Telefone')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _register(context),
                child: Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
