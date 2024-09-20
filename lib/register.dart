import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart'; // Importa la pantalla de login

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _docNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _role; // Para almacenar el rol seleccionado

  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('Api/Users');

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();
    final docNumber = _docNumberController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_validateEmail(email)) {
      _showSnackbar('Por favor, introduce un correo válido.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackbar('Las contraseñas no coinciden.');
      return;
    }

    if (_role == null) {
      _showSnackbar('Por favor, selecciona un rol.');
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _database.child(userCredential.user!.uid).set({
        'nombre': name,
        'correo': email,
        'numero_documento': docNumber,
        'telefono': phone,
        'role_id': _role,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException {
      _showSnackbar('Error al crear la cuenta.');
    }
  }

  bool _validateEmail(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegExp.hasMatch(email);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red, // Fondo rojo para el Snackbar
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/logo.png', height: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Center(
                child: Text(
                  'Registro de Usuario',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey, // Color gris claro para el título
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Espacio extra debajo del texto
              TextField(
                controller: _emailController,
                style: const TextStyle(
                    color: Colors.black), // Texto negro al escribir
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: const TextStyle(
                      color: Colors.grey), // Color gris del label
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.grey), // Solo borde inferior gris
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Colors.green), // Borde inferior verde al enfocarse
                  ),
                  prefixIcon: const Icon(Icons.email,
                      color: Colors.grey), // Ícono de correo
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  prefixIcon: const Icon(Icons.person,
                      color: Colors.grey), // Ícono de nombre
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _docNumberController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Número de Documento',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  prefixIcon: const Icon(Icons.credit_card,
                      color: Colors.grey), // Ícono de documento
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  prefixIcon: const Icon(Icons.phone,
                      color: Colors.grey), // Ícono de teléfono
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _role,
                style: const TextStyle(
                    color: Colors.black), // Texto negro al seleccionar
                decoration: InputDecoration(
                  labelText: 'Rol',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  prefixIcon: const Icon(Icons.group,
                      color: Colors.grey), // Ícono de rol
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'Rol_propietario', child: Text('Propietario')),
                  DropdownMenuItem(
                      value: 'Rol_cliente', child: Text('Cliente')),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  prefixIcon: const Icon(Icons.lock,
                      color: Colors.grey), // Ícono de contraseña
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  labelStyle: const TextStyle(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  prefixIcon: const Icon(Icons.lock,
                      color: Colors.grey), // Ícono de confirmación
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green.shade600, // Fondo verde por defecto
                  minimumSize:
                      const Size(double.infinity, 50), // Tamaño del botón
                  foregroundColor: Colors.white, // Texto blanco
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8.0), // Esquinas redondeadas
                  ),
                  side: BorderSide(
                    color: Colors.green.shade600, // Borde verde por defecto
                    width: 2.0,
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color(
                            0xFF212121); // Fondo negro al presionar
                      }
                      return Colors.green.shade600; // Fondo verde por defecto
                    },
                  ),
                  side: MaterialStateProperty.resolveWith<BorderSide?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const BorderSide(
                          color: Color(0xFF212121), // Borde negro al presionar
                          width: 2.0,
                        );
                      }
                      return BorderSide(
                        color: Colors.green.shade600, // Borde verde por defecto
                        width: 2.0,
                      );
                    },
                  ),
                ),
                child: const Text(
                  'Registrar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
