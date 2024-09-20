import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonPressed = false;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackbar(
          'Te hemos enviado un mensaje a tu correo.', Colors.green.shade600);
    } catch (e) {
      _showSnackbar('Error al intentar restablecer la contraseña.', Colors.red);
    }
  }

  void _showSnackbar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/logo.png', height: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Restablecer Contraseña',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  labelStyle: const TextStyle(color: Colors.grey),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.green.shade600, width: 2.0),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isButtonPressed = true;
                  });
                  await _resetPassword();
                  setState(() {
                    _isButtonPressed = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonPressed
                      ? const Color(0xFF212121) // Fondo negro al presionar
                      : Colors.green.shade600, // Fondo verde por defecto
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: _isButtonPressed
                      ? Colors.white // Texto blanco al presionar
                      : Colors.white, // Texto blanco por defecto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: _isButtonPressed
                      ? const BorderSide(
                          color: Color(0xFF212121),
                          width: 2.0) // Borde negro al presionar
                      : BorderSide(
                          color: Colors.green.shade600,
                          width: 2.0), // Borde verde por defecto
                ),
                child: const Text(
                  'RESTABLECER CONTRASEÑA',
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
