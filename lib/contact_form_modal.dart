import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactFormModal extends StatefulWidget {
  final String propertyId;

  const ContactFormModal({super.key, required this.propertyId});

  @override
  _ContactFormModalState createState() => _ContactFormModalState();
}

class _ContactFormModalState extends State<ContactFormModal> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _phone = '';
  String _message = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DatabaseReference userRef = FirebaseDatabase.instance
          .ref('Api/Users/${user.uid}');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _name = userData['nombre'] ?? '';
          _email = user.email ?? '';
          _phone = userData['telefono'] ?? '';
          _isLoading = false; // Se cargaron los datos, desactivar el estado de carga
        });
      } else {
        setState(() {
          _isLoading = false; // No se encontraron datos, pero ya no está cargando
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Usuario no autenticado, pero no está cargando
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final formData = {
        'propertyId': widget.propertyId,
        'name': _name,
        'email': _email,
        'phone': _phone,
        'message': _message,
      };

      try {
        final response = await http.post(
          Uri.parse('https://conexion-agraria-default-rtdb.firebaseio.com/Api/Contac.json'),
          body: json.encode(formData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulario enviado exitosamente')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al enviar el formulario')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: _isLoading
          ? SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Contáctenos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Nombre'),
                          initialValue: _name,
                          onSaved: (value) => _name = value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su nombre';
                            }
                            if (!RegExp(r'^[a-zA-Z]+ [a-zA-Z]').hasMatch(value)) {
                              return 'Por favor ingrese un nombre y un apellido';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Correo electrónico'),
                          initialValue: _email,
                          onSaved: (value) => _email = value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su correo electrónico';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Por favor ingrese un correo electrónico válido';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Teléfono'),
                          initialValue: _phone,
                          keyboardType: TextInputType.phone,
                          onSaved: (value) => _phone = value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su número de teléfono';
                            }
                            if (!RegExp(r'^\d{7,15}$').hasMatch(value)) {
                              return 'El teléfono debe tener entre 7 y 15 dígitos';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Mensaje'),
                          maxLines: 5,
                          onSaved: (value) => _message = value ?? '',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su mensaje';
                            }
                            if (value.length < 10 || value.length > 500) {
                              return 'El mensaje debe tener entre 10 y 500 caracteres';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Enviar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}