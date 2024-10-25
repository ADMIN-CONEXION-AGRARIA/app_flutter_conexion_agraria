import 'package:flutter/material.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contact_form_modal.dart';

class PropertyDetails extends StatefulWidget {
  final dynamic property;

  const PropertyDetails({super.key, required this.property});

  @override
  _PropertyDetailsState createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails> {
  final _currentPageNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final List<String> imageUrls =
        List<String>.from(widget.property['imagenes']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Slider de imágenes usando PageView
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: PageView.builder(
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        _currentPageNotifier.value = index;
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  // Indicador de la página actual
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: CirclePageIndicator(
                      itemCount: imageUrls.length,
                      currentPageNotifier: _currentPageNotifier,
                    ),
                  ),
                  // Icono de flecha para regresar
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Información de la propiedad
              // Información de la propiedad
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property['nombre'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.property['direccion']}, ${widget.property['municipio']}, ${(widget.property['departamento'] is List ? widget.property['departamento'] : []).join(', ')}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.property['descripcion'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        children: [
                          // Columna izquierda
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.terrain,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Tipo Tierra: ${widget.property['tipo_tierra']}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.agriculture_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Cultivo: ${(widget.property['tipo_cultivo'] is List ? widget.property['tipo_cultivo'] : []).join(', ')}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.pets_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Ganadería: ${(widget.property['tipo_ganaderia'] is List ? widget.property['tipo_ganaderia'] : []).join(', ')}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.brightness_6_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Clima: ${widget.property['clima']}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Columna central
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.crop_free,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Medidas: ${widget.property['medida']}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Distancia: ${widget.property['detalles_adicionales']['distancia_ciudad']}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.landscape_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Topografía: ${widget.property['detalles_adicionales']['topografia']}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.map_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Zonificación: ${widget.property['detalles_adicionales']['zonificacion']}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Columna derecha
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Acceso: ${widget.property['detalles_adicionales']['acceso']}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.water_damage_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Ríos Cercanos: ${(widget.property['rios_cercanos'] is List ? widget.property['rios_cercanos'] : []).join(', ')}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.local_offer_outlined,
                                        color: Colors.grey, size: 14),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Servicios: ${(widget.property['servicios_disponibles'] is List ? widget.property['servicios_disponibles'] : []).join(', ')}',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Botón fijo en la parte inferior con sombra
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${widget.property['precio_arriendo']} / mes',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha de creación: ${widget.property['fecha_creacion']}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.property['id'] != null) {
                        // Verificar si el usuario está autenticado
                        final User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // El usuario está autenticado, mostrar el formulario
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ContactFormModal(
                                propertyId:
                                    widget.property['id'] ?? 'ID no disponible',
                              );
                            },
                          );
                        } else {
                          // El usuario no está autenticado, mostrar un mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Por favor, inicie sesión para contactar.')),
                          );
                        }
                      } else {
                        print('Error: ID del predio es null');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Me interesa',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
