import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref('Api/Users');
  final User? _user = FirebaseAuth.instance.currentUser;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _documentController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (_user != null) {
      _emailController.text = _user!.email ?? '';
    }
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      final userSnapshot = await _userRef.child(_user!.uid).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        setState(() {
          _nameController.text = userData['nombre'] ?? '';
          _documentController.text = userData['numero_documento'] ?? '';
          _phoneController.text = userData['telefono'] ?? '';
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_user != null) {
      await _userRef.child(_user!.uid).update({
        'nombre': _nameController.text.trim(),
        'numero_documento': _documentController.text.trim(),
        'telefono': _phoneController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cambios guardados exitosamente.')),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });

      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/logo.png', height: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Editar Perfil',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey, // Color gris claro para el título
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            buildProfileItem(
                'Nombre de usuario', _nameController, false, Icons.person),
            buildProfileItem(
                'Correo electrónico', _emailController, true, Icons.email),
            buildProfileItem('Número de documento', _documentController, false,
                Icons.document_scanner),
            buildProfileItem('Teléfono', _phoneController, false, Icons.phone),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                side: BorderSide(
                  color: Colors.green.shade600,
                  width: 2.0,
                ),
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const Color(0xFF212121);
                    }
                    return Colors.green.shade600;
                  },
                ),
                side: MaterialStateProperty.resolveWith<BorderSide?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const BorderSide(
                        color: Color(0xFF212121),
                        width: 2.0,
                      );
                    }
                    return BorderSide(
                      color: Colors.green.shade600,
                      width: 2.0,
                    );
                  },
                ),
              ),
              child: const Text(
                'Guardar cambios',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                side: BorderSide(
                  color: Colors.red.shade600,
                  width: 2.0,
                ),
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const Color(0xFF212121);
                    }
                    return Colors.red.shade600;
                  },
                ),
                side: MaterialStateProperty.resolveWith<BorderSide?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return const BorderSide(
                        color: Color(0xFF212121),
                        width: 2.0,
                      );
                    }
                    return BorderSide(
                      color: Colors.red.shade600,
                      width: 2.0,
                    );
                  },
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileItem(String title, TextEditingController controller,
      bool isDisabled, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: isDisabled ? Colors.grey : Colors.black),
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                disabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              enabled: !isDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
