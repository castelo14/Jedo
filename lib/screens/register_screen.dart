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

  Future<bool> _verificarDuplicado(String email, String telefone) async {
    try {
      // Verificando se o e-mail já existe no Firestore
      final emailQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Verificando se o telefone já existe no Firestore
      final phoneQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: telefone)
          .get();

      // Se já existir algum e-mail ou telefone, retorna true (duplicado)
      return emailQuery.docs.isNotEmpty || phoneQuery.docs.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar duplicado: $e');
      return false;
    }
  }


  // Função para registrar o usuário
  Future<void> _register(BuildContext context) async {
    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    // Verificar se o e-mail ou telefone já estão cadastrados
    bool isDuplicado = await _verificarDuplicado(email, phone);

    if (isDuplicado) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('E-mail ou Telefone já cadastrados!'),
      ));
      return; // Impede o cadastro caso seja duplicado
    }

    try {
      // Adicionar os dados ao Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'surname': surname,
        'email': email,
        'phone': phone,
      });

      // Navega para a tela do mapa após o cadastro
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MapScreen()),
      );
    } catch (e) {
      print('Erro ao cadastrar: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao registrar!'),
      ));
    }
  }


  // Função para validar o formato do email
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

  // Função para validar o telefone
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
        title: Text('Cadastro'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/user.png')),
            //Center(
            //  child: Image.asset(
            //    'assets/images/user.png', // Caminho da sua imagem
            //    width: 150, // Ajuste o tamanho da imagem
            //    height: 150, // Ajuste o tamanho da imagem
            //  ),
            //),
            SizedBox(height: 32), // Espaço entre a imagem e o formulário

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo Nome
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Por favor, insira o nome' : null,
                  ),
                  SizedBox(height: 16),

                  // Campo Sobrenome
                  TextFormField(
                    controller: surnameController,
                    decoration: InputDecoration(
                      labelText: 'Sobrenome',
                      prefixIcon: Icon(Icons.person_add_alt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Por favor, insira o sobrenome' : null,
                  ),
                  SizedBox(height: 16),

                  // Campo Email
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
                  SizedBox(height: 16),

                  // Campo Telefone
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

                  // Botão de Cadastro
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _register(context);
                      }
                    },
                    style: _buttonStyle(),
                    child: Text(
                      'Cadastrar', style: TextStyle(color: Colors.black,
                      ),
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
ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent);