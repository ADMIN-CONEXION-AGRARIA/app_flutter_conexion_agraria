import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Asegúrate de importar la pantalla de login

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Si no hay usuario autenticado, redirige a la pantalla de inicio de sesión
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });

      return Scaffold(
        appBar: AppBar(
          title: const Text('Perfil de Usuario'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si el usuario está autenticado, muestra su perfil
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            buildProfileAvatar(),
            const SizedBox(height: 20),
            buildProfileItem('Nombre', user.displayName ?? 'No disponible'),
            buildProfileItem('Correo electrónico', user.email ?? 'No disponible'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileAvatar() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget buildProfileItem(String title, String value) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
