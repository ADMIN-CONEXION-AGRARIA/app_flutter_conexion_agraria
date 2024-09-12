// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Asegúrate de tener este archivo generado para la configuración de Firebase.
import 'home.dart';
import 'login.dart';
import 'register.dart';
import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Este archivo es generado por Firebase CLI.
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conexión Agraria',
      theme: ThemeData(
        primarySwatch: Colors.green, // Cambia a azul si prefieres, según tus preferencias.
      ),
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) =>  const ProfileScreen(),
      },
    );
  }
}
