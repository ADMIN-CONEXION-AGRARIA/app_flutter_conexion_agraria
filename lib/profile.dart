import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Importa Firebase Storage
import 'package:image_picker/image_picker.dart';
import 'dart:math'; // Importa para generar hash
import 'dart:typed_data';


import 'login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref('Api/Users');
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instancia de Storage

  TextEditingController _nameController = TextEditingController();
  TextEditingController _documentController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false; // Estado para controlar el modo de edición
  final ImagePicker _picker = ImagePicker(); // Para seleccionar imágenes
  String? _imageUrl; // Para guardar la URL de la imagen seleccionada

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
          _imageUrl = userData['imagenUrl']; // Cargar la imagen del perfil si existe
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
        'imagenUrl': _imageUrl, // Guardar la URL de la imagen en la base de datos
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

  // Función para generar un nombre de archivo único usando un hash
  String _generateHash() {
    final random = Random();
    final hash = List<int>.generate(20, (index) => random.nextInt(256));
    return hash.join();
  }

  Future<void> _pickImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    try {
      // Leer los bytes de la imagen
      Uint8List fileBytes = await pickedFile.readAsBytes();

      // Generar un nombre de archivo único para la imagen
      String imageHash = _generateHash();
      String filePath = 'users/$imageHash.png';

      // Subir la imagen a Firebase Storage usando putData
      final storageRef = _storage.ref().child(filePath);
      await storageRef.putData(fileBytes);

      // Obtener la URL de descarga de la imagen
      String downloadUrl = await storageRef.getDownloadURL();

      // Guardar la URL en la base de datos del usuario
      setState(() {
        _imageUrl = downloadUrl;
      });

      // Guardar en la base de datos de Firebase el hash como la imagen del usuario
      if (_user != null) {
        await _userRef.child(_user!.uid).update({'imagenUrl': _imageUrl});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen cargada exitosamente.')),
      );
    } catch (e) {
      print('Error al subir la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar la imagen.')),
      );
    }
  }
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
                'Perfil de Usuario',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF424242), // Gris más fuerte
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Círculo de imagen de perfil con icono de cámara
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      _imageUrl != null ? NetworkImage(_imageUrl!) : null,
                  child: _imageUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade700,
                      radius: 16,
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Texto "Editar mi perfil" o "Guardar cambios"
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_isEditing) {
                    _saveChanges(); // Guardar cambios si está en modo de edición
                  }
                  _isEditing = !_isEditing; // Cambiar el estado de edición
                });
              },
              child: Text(
                _isEditing ? 'Guardar cambios' : 'Editar mi perfil',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            buildProfileItem('Nombre de usuario', _nameController, false, Icons.person),
            buildProfileItem('Correo electrónico', _emailController, true, Icons.email),
            buildProfileItem('Número de documento', _documentController, false, Icons.document_scanner),
            buildProfileItem('Teléfono', _phoneController, false, Icons.phone),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Color negro para el botón de cerrar sesión
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
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
          Icon(icon,
              color: const Color(0xFF424242)), // Icono en gris oscuro constante
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              // Cambiar el color a verde si está en modo de edición
              style: TextStyle(
                  color: isDisabled || !_isEditing
                      ? const Color(0xFF424242)
                      : Colors.green),
              decoration: InputDecoration(
                labelText: title,
                labelStyle: const TextStyle(
                  color: Color(0xFF424242), // Reemplazando el gris oscuro
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
              enabled: _isEditing && !isDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
