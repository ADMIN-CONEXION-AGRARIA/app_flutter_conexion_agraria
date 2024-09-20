import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'register.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Por favor ingresa todos los campos.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Redirige a HomeScreen después de iniciar sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException {
      _showSnackbar('Usuario o contraseña incorrecta.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            Colors.redAccent, // Puedes ajustar el color del snackbar
        duration: const Duration(seconds: 2), // Duración del snackbar
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Inicio de Sesión',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey, // Color gris claro para el título
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle:
                      const TextStyle(color: Colors.grey), // Color gris claro
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade600),
                  ),
                  border: const UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle:
                      const TextStyle(color: Colors.grey), // Color gris claro
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.shade600),
                  ),
                  border: const UnderlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600, // Color verde inicial
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.white, // Color de texto blanco
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: BorderSide(
                      color: Colors.green.shade600,
                      width: 2.0), // Borde verde inicial
                ).copyWith(
                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors
                            .green.shade600; // Texto verde cuando se presiona
                      }
                      return Colors.white;
                    },
                  ),
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
                            color: Color(0xFF212121),
                            width: 2.0); // Borde negro al presionar
                      }
                      return BorderSide(
                          color: Colors.green.shade600,
                          width: 2.0); // Borde verde por defecto
                    },
                  ),
                ),
                child: const Text(
                  'INICIAR SESIÓN', // Texto en mayúsculas y bold
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // Negrita
                    letterSpacing: 1.5, // Espaciado entre letras
                  ),
                ),
              ),
              const SizedBox(
                  height: 24.0), // Espacio adicional entre botón y textos
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.white.withOpacity(0.3), // Fondo al presionar
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color(
                            0xFF212121); // Texto negro cuando se presiona
                      }
                      return const Color(0xFF424242); // Gris oscuro por defecto
                    },
                  ),
                ),
                child: const Text(
                  '¿No tienes una cuenta? Regístrate',
                ),
              ),
              const SizedBox(
                  height: 8.0), // Espacio adicional entre los dos textos
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all<Color>(
                    Colors.white.withOpacity(0.3), // Fondo al presionar
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color(
                            0xFF212121); // Texto negro cuando se presiona
                      }
                      return const Color(0xFF424242); // Gris oscuro por defecto
                    },
                  ),
                ),
                child: const Text(
                  'Olvidé mi contraseña',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
