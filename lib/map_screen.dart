import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Para Google Maps
import 'package:location/location.dart'; // Para manejar la ubicación del usuario
import 'dart:convert'; // Para decodificar JSON
import 'package:http/http.dart' as http; // Para realizar solicitudes HTTP
import 'package:permission_handler/permission_handler.dart'
    as perm_handler; // Para manejar permisos
import 'package:page_view_indicators/circle_page_indicator.dart'; // Para los indicadores de página en el slider de imágenes
import 'package:firebase_auth/firebase_auth.dart';
import 'contact_form_modal.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _initialPosition = const LatLng(0, 0);
  final Location _location = Location();
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  final List<Map<String, dynamic>> _properties = [];
  int currentPage = 1;
  LatLngBounds? _mapBounds;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _fetchProperties(LatLngBounds bounds) async {
    try {
     final response = await http.get(
        Uri.parse(
            'https://api-conexion-agraria-1.onrender.com/getCombinedData'),
        headers: {
          'x-secret-key':
              'supersecreta123', // Asegúrate de seguir usando tu clave secreta
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> propertiesData = json.decode(response.body);

        if (propertiesData.isNotEmpty) {
          setState(() {
            _properties.clear();
            for (var property in propertiesData) {
              _properties.add({
                "id": property['id'],
                "name": property['nombre'],
                "lat": property['latitud'],
                "lng": property['longitud'],
                "description": property['descripcion'],
                "price": property['precio_arriendo'],
                "measure": property['medida'],
                "address": property['direccion'],
                "image": property['imagenes'], // URL de la imagen
                "climate": property['clima'], // Clima
                "created_at": property['fecha_creacion'], // Fecha de creación
                "soil_type": property['tipo_tierra'], // Tipo de tierra
                "crop_type": property['tipo_cultivo'], // Cultivo
                "livestock_type": property['tipo_ganaderia'], // Ganadería
                "additional_details":
                    property['detalles_adicionales'], // Detalles adicionales
                "nearby_rivers": property['rios_cercanos'], // Ríos cercanos
                "available_services":
                    property['servicios_disponibles'], // Servicios
              });
            }
          });

          _addPropertyMarkers(bounds);
        }
      }
    } catch (e) {
      // Aquí eliminamos el manejo de errores
    }
  }

  void _addPropertyMarkers(LatLngBounds bounds) {
    _markers.clear(); // Limpia los marcadores anteriores
    for (var property in _properties) {
      LatLng propertyLocation = LatLng(property['lat'], property['lng']);
      if (bounds.contains(propertyLocation)) {
        // Solo muestra los predios dentro del área visible del mapa
        _markers.add(
          Marker(
            markerId: MarkerId(property['id']),
            position: propertyLocation,
            infoWindow: InfoWindow(
              title: property['name'],
              onTap: () {
                _onMarkerTapped(property); // Pasas el objeto completo
              },
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> _getUserLocation() async {
    perm_handler.PermissionStatus permission =
        await perm_handler.Permission.locationWhenInUse.status;

    if (!permission.isGranted) {
      permission = await perm_handler.Permission.locationWhenInUse.request();
      if (!permission.isGranted) {
        return;
      }
    }

    LocationData locationData = await _location.getLocation();
    LatLng userLocation =
        LatLng(locationData.latitude!, locationData.longitude!);

    setState(() {
      _initialPosition = userLocation;
      _isLoading = false;
    });

    _markers.add(
      Marker(
        markerId: const MarkerId('userLocation'),
        position: _initialPosition,
        infoWindow: const InfoWindow(title: 'Tu ubicación'),
      ),
    );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_initialPosition, 10),
    );

    // Aquí verificamos que _mapBounds no sea null antes de llamar a _fetchProperties
    if (_mapBounds != null) {
      _fetchProperties(_mapBounds!);
    }
  }

  void showTopSnackBar(BuildContext context, String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, // Puedes ajustar esta posición según el diseño
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.black, // Color de fondo del mensaje
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Insertar el Overlay en la pantalla
    Overlay.of(context)!.insert(overlayEntry);

    // Remover el Overlay después de 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Función que maneja el clic en un marcador
  void _onMarkerTapped(dynamic property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final List<String> imageUrls = property['image'] != null
            ? List<String>.from(property['image']
                .map((url) => url ?? 'lib/assets/default_image.png'))
            : ['lib/assets/default_image.png'];

        final _currentPageNotifier = ValueNotifier<int>(0);

        return StatefulBuilder(
          builder: (context, setState) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.37, end: 0.7),
              duration: const Duration(milliseconds: 800),
              builder: (context, size, child) {
                return DraggableScrollableSheet(
                  initialChildSize:
                      0.37, // Se ajustó a 0.37 como tamaño inicial
                  minChildSize: 0.37, // Tamaño mínimo del modal ahora es 0.37
                  maxChildSize: 0.7, // Tamaño máximo del modal es 0.7
                  builder: (context, scrollController) {
                    return AnimatedOpacity(
                      opacity: size == 0.7 ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 700),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        child: Stack(
                          children: [
                            ListView(
                              controller: scrollController,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(25.0),
                                  ),
                                  child: SizedBox(
                                    height: size == 0.37
                                        ? 150
                                        : 300, // Se redujo la altura a 200
                                    width: double.infinity,
                                    child: PageView.builder(
                                      itemCount: imageUrls.length,
                                      onPageChanged: (index) {
                                        _currentPageNotifier.value = index;
                                      },
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          imageUrls[index],
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        (loadingProgress
                                                                .expectedTotalBytes ??
                                                            1)
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              'lib/assets/default_image.png',
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    property['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Column(
                                    children: [
                                      // Primera fila: dirección, clima y medidas
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              property['address'],
                                              style: const TextStyle(
                                                fontSize:
                                                    11, // Fuente un poco más pequeña
                                                color: Color(
                                                    0xFF757575), // Gris más fuerte
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${property['climate']}',
                                              style: const TextStyle(
                                                fontSize:
                                                    11, // Fuente un poco más pequeña
                                                color: Color(
                                                    0xFF757575), // Gris más fuerte
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${property['measure']}',
                                              style: const TextStyle(
                                                fontSize:
                                                    11, // Fuente un poco más pequeña
                                                color: Color(
                                                    0xFF757575), // Gris más fuerte
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              6), // Espacio uniforme entre filas

                                      // Segunda fila: tipo de tierra, tipo de cultivo y ganadería
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Tipo de Tierra: ${property['soil_type']}',
                                              style: const TextStyle(
                                                fontSize:
                                                    11, // Fuente un poco más pequeña
                                                color: Color(
                                                    0xFF757575), // Gris más fuerte
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Tipo de Cultivo: ${property['crop_type'].join(', ')}',
                                              style: const TextStyle(
                                                fontSize:
                                                    11, // Fuente un poco más pequeña
                                                color: Color(
                                                    0xFF757575), // Gris más fuerte
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Ganadería: ${property['livestock_type'].join(', ')}',
                                              style: const TextStyle(
                                                fontSize:
                                                    11, // Fuente un poco más pequeña
                                                color: Color(
                                                    0xFF757575), // Gris más fuerte
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              8), // Espacio adicional antes del siguiente contenido
                                    ],
                                  ),
                                ),
                                if (size == 0.7)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 10),
                                    child: Text(
                                      '${property['description']}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                const SizedBox(
                                    height: 30), // Espacio para el precio fijo
                              ],
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                ), // Se eliminó la sombra aquí
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${property['price']} / mes',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (property['id'] != null) {
                                          final User? user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user != null) {
                                            // El usuario está autenticado, mostrar el formulario
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ContactFormModal(
                                                    propertyId: property['id']);
                                              },
                                            );
                                          } else {
                                            // Mostrar el mensaje en la parte superior usando Overlay
                                            showTopSnackBar(context,
                                                'Por favor, inicie sesión para contactar.');
                                          }
                                        } else {
                                          print('Error: ID del predio es null');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('Me interesa',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('lib/assets/logo.png', height: 30),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 8,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;

                // Verificamos la región visible cuando el mapa está listo
                _mapController?.getVisibleRegion().then((LatLngBounds bounds) {
                  _mapBounds = bounds;
                  _fetchProperties(bounds);
                });
              },
              onCameraIdle: () async {
                LatLngBounds newBounds =
                    await _mapController!.getVisibleRegion();
                if (_mapBounds != newBounds) {
                  _mapBounds = newBounds;
                  _fetchProperties(newBounds);
                }
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
