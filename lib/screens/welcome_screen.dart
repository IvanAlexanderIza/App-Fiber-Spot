// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:io';

class WelcomeScreen extends StatefulWidget {
  final String idUsuario;
  final String username;
  final String identificacion;
  final Map<String, dynamic> clientData;
  // Recibe los datos del cliente
  const WelcomeScreen({
    Key? key,
    required this.idUsuario,
    required this.username,
    required this.identificacion,
    required this.clientData, // Recibe los datos del cliente
  }) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<List<Map<String, dynamic>>>? paymentHistory;
  Future<List<Map<String, dynamic>>>? pendingPayments;
  File? _imageFile;
  @override
  void initState() {
    super.initState();
    // Verifica que los datos del cliente no sean nulos
    print("Datos del cliente: ${widget.clientData}");
    paymentHistory = ApiService.getPaymentHistory(widget.identificacion);
    pendingPayments = ApiService.getPendingPayments(widget.identificacion);
  }

  void cerrarSesion(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login'); // Redirige al login
  }

  Future<void> _changePassword() async {
    String? newPassword = await _showPasswordDialog(context);

    if (newPassword != null && newPassword.isNotEmpty) {
      try {
        var updateResponse =
            await ApiService.updatePassword(widget.idUsuario, newPassword);

        if (updateResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Contraseña actualizada exitosamente'),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Error al actualizar la contraseña: ${updateResponse['message']}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al actualizar la contraseña: $e'),
        ));
      }
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();
    bool _isPasswordVisible =
        false; // Variable para controlar la visibilidad de la contraseña

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cambiar Contraseña',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue[800], // Color del título
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
          ),
          contentPadding: EdgeInsets.all(20), // Padding general
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Ingresa la nueva contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue), // Borde azul
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors.blueAccent), // Borde cuando está enfocado
                  ),
                  prefixIcon:
                      Icon(Icons.lock, color: Colors.blue), // Ícono de candado
                  hintStyle: TextStyle(
                      color: Colors.grey[600]), // Color del texto del hint
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15), // Padding dentro del TextField
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off, // Cambia el ícono
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      // Cambia el estado de visibilidad de la contraseña
                      _isPasswordVisible = !_isPasswordVisible;
                      // Necesitamos que la UI se actualice
                      (context as Element)
                          // ignore: invalid_use_of_protected_member
                          .reassemble(); // Actualiza el estado para que el ícono cambie
                    },
                  ),
                ),
                obscureText:
                    !_isPasswordVisible, // Si la contraseña está visible o no
              ),
              SizedBox(
                  height: 15), // Espacio entre el campo de texto y los botones
            ],
          ),
          actions: <Widget>[
            // Botón Cancelar
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey[400], // Color de fondo del botón
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Bordes redondeados
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20), // Padding del botón
              ),
              child: Text('Cancelar'),
            ),
            // Botón Aceptar
            TextButton(
              onPressed: () {
                // Verificar si el campo de contraseña está vacío
                if (passwordController.text.isEmpty) {
                  // Mostrar el mensaje de error usando _showErrorDialog
                  _showErrorDialog(
                      context, 'Por favor ingresa una nueva contraseña');
                } else {
                  // Retorna la nueva contraseña si no está vacía
                  Navigator.of(context).pop(passwordController.text);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Color de fondo del botón
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10.0), // Bordes redondeados
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20), // Padding del botón
              ),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Fondo blanco para mayor claridad
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                25.0), // Bordes más redondeados para un diseño moderno
          ),
          elevation: 15, // Agregar sombra más profunda para un efecto 3D
          title: Row(
            children: [
              Icon(
                Icons
                    .warning_amber_rounded, // Ícono más llamativo de advertencia
                color: const Color.fromARGB(
                    255, 255, 0, 0), // Un toque de naranja para captar atención
                size: 30,
              ),
              SizedBox(width: 15),
              Text(
                '¡Atención!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(
                      255, 255, 0, 0), // Color llamativo para el título
                ),
              ),
            ],
          ),
          content: Padding(
            padding: EdgeInsets.symmetric(
                vertical:
                    15), // Añadí un poco más de padding para que el contenido tenga aire
            child: Text(
              message,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black87, // Texto oscuro para mayor contraste
                fontFamily: 'Montserrat', // Usé una fuente más elegante
                fontWeight:
                    FontWeight.w500, // Peso medio para una lectura suave
              ),
              textAlign: TextAlign
                  .center, // Centrar el mensaje de error para mayor claridad
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Texto blanco para el botón
                backgroundColor: const Color.fromARGB(
                    255, 251, 0, 0), // Fondo naranja para el botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      30.0), // Bordes bien redondeados para suavizar
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal:
                        35), // Aumenté el padding para hacerlo más cómodo
                textStyle: TextStyle(
                  fontSize: 17, // Aumenté el tamaño del texto del botón
                  fontWeight:
                      FontWeight.bold, // Hacer que el texto sea más destacado
                ),
              ),
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientData = widget.clientData; // Obtén los datos del cliente

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 30,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'config') {
                await _changePassword();
              } else if (value == 'logout') {
                // Acción para cerrar sesión
                cerrarSesion(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'config',
                child: Text('cambiar contraseña'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.purple[50], // Color de fondo
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Container con el saludo
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(122, 234, 234, 234),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Bienvenido ${widget.username}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 18, 28, 105),
                      ),
                    ),
                  ),
                ),
                // Container con la imagen de promoción
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 68, 138, 255),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/promocion.jpeg', // Asegúrate de que la imagen esté en assets
                      fit: BoxFit
                          .contain, // Para que se vea completa sin recortes
                    ),
                  ),
                ),
                // Container con los 3 cards de manera horizontal
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: [
                      _buildServiceCard(
                        icon: Icons.person_2_rounded,
                        label: 'Visualizar datos',
                        color: Colors.orange,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return _buildDataModal(clientData);
                            },
                          );
                        },
                      ),
                      _buildServiceCard(
                        icon: Icons.account_balance_wallet,
                        label: 'Historial de pagos',
                        color: Colors.green,
                        onTap: () {
                          if (paymentHistory != null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return _buildPaymentHistoryModal();
                              },
                            );
                          } else {
                            print("Historial de pagos no disponible");
                          }
                        },
                      ),
                      _buildServiceCard(
                        icon: Icons.pending_actions,
                        label: 'Pagos pendientes',
                        color: Colors.green,
                        onTap: () {
                          if (paymentHistory != null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return _buildPendingPaymentsModal();
                              },
                            );
                          } else {
                            print("Historial de pagos no disponible");
                          }
                        },
                      ),
                      _buildServiceCard(
                        icon: Icons.router,
                        label: 'Planes',
                        color: Colors.blue,
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Cerrar",
                            barrierColor: Colors.black.withOpacity(
                                0.5), // Fondo oscuro semitransparente
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      // Contenedor principal del modal
                                      Center(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.85, // 85% del ancho de la pantalla
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.95, // 70% del alto de la pantalla
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Slider de imágenes
                                              Expanded(
                                                child: CarouselSlider(
                                                  options: CarouselOptions(
                                                    autoPlay: true,
                                                    enlargeCenterPage: true,
                                                    aspectRatio: 4 / 3,
                                                    viewportFraction: 1.0,
                                                  ),
                                                  items: [
                                                    'assets/planprincipal.jpeg',
                                                    'assets/plansuperfiber.jpeg',
                                                    'assets/planmegafiber.jpeg',
                                                    'assets/planultrafiber.jpeg',
                                                    'assets/planhyperfiber.jpeg',
                                                  ].map((imagePath) {
                                                    return Builder(
                                                      builder: (BuildContext
                                                          context) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          12)),
                                                          child: Image.asset(
                                                            imagePath, // Imagen del slider
                                                            fit: BoxFit.cover,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Botón de cierre en la esquina superior derecha
                                      Positioned(
                                        top: 40,
                                        right: 20,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white, size: 30),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Cierra el modal
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      _buildServiceCard(
                        icon: Icons.loyalty,
                        label: 'Promociones',
                        color: Colors.purple,
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Cerrar",
                            barrierColor: Colors.black.withOpacity(
                                0.5), // Fondo oscuro semitransparente
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      // Contenedor principal del modal
                                      Center(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              1.0, // Aumentando el ancho al 90%
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.85, // Ajustando el alto al 80%
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // Slider de imágenes
                                              Expanded(
                                                child: CarouselSlider(
                                                  options: CarouselOptions(
                                                    autoPlay: true,
                                                    enlargeCenterPage: true,
                                                    aspectRatio: 16 /
                                                        9, // Ajustando el aspecto a 16:9
                                                    viewportFraction:
                                                        1.0, // Asegurando que ocupe todo el espacio
                                                  ),
                                                  items: [
                                                    'assets/promocionprincipal.jpeg',
                                                    'assets/promocionsuperfiber.jpeg',
                                                    'assets/promocionmegafiber.jpeg',
                                                    'assets/promocionultrafiber.jpeg',
                                                    'assets/promocionhyperfiber.jpeg',
                                                  ].map((imagePath) {
                                                    return Builder(
                                                      builder: (BuildContext
                                                          context) {
                                                        return ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          12)),
                                                          child: Image.asset(
                                                            imagePath, // Imagen del slider
                                                            fit: BoxFit
                                                                .contain, // Asegura que cubra el contenedor
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Botón de cierre en la esquina superior derecha
                                      Positioned(
                                        top: 40,
                                        right: 20,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white, size: 30),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Cierra el modal
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal para mostrar los pagos pendientes
  Widget _buildPendingPaymentsModal() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 16,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: pendingPayments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No cuenta con pagos pendientes.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
            );
          } else {
            final payments = snapshot.data!;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado con diseño atractivo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pagos pendientes',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Contenido del modal con scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar cada pago en el historial
                        for (var payment in payments) _buildPendingRow(payment),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botón "Cerrar"
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // ignore: duplicate_ignore
                            // ignore: deprecated_member_use
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Modal para mostrar los pagos pendientes
  Widget _buildPendingRow(Map<String, dynamic> payment) {
    // Convertir 'valor_pendiente' a double si es una cadena
    double valorPendiente =
        double.tryParse(payment['valor_pendiente'].toString()) ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          // Al hacer clic, mostrar el modal con los detalles del pago
          _showPaymentDetailsModal(payment);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2), // Sombra sutil hacia abajo
              ),
            ],
          ),
          child: Column(
            children: [
              // Encabezado con diseño atractivo
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Detalles de Pago',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Contenido del modal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalle: ${payment['detalle_cuenta']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha: ${payment['fecha_inicio_cobro']}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valor pendiente: \$${valorPendiente.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botón "Pagar Ahora" con InkWell
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        // Aquí puedes agregar la lógica para iniciar el pago
                        _showPaymentDetailsModal(payment);
                        print("Pagar Ahora button clicked");
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Pagar Ahora',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentDetailsModal(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 16,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlueAccent],
                        ),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Detalles de Pago',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de cobro: ${payment['fecha_inicio_cobro']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Detalle: ${payment['detalle_cuenta']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Monto pendiente: \$${(double.tryParse(payment['valor_pendiente'].toString()) ?? 0.0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    // Cuadro para elegir imagen
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Tomar foto'),
                                        onTap: () async {
                                          final picker = ImagePicker();
                                          final image = await picker.pickImage(
                                              source: ImageSource.camera);
                                          if (image != null) {
                                            setState(() {
                                              _imageFile = File(image.path);
                                            });
                                          }
                                          Navigator.pop(
                                              context); // Cierra el bottom sheet
                                        },
                                      ),
                                      ListTile(
                                        leading:
                                            const Icon(Icons.photo_library),
                                        title:
                                            const Text('Elegir de la galería'),
                                        onTap: () async {
                                          // Prevent multiple image picker instances
                                          if (_imageFile == null) {
                                            final picker = ImagePicker();
                                            final image =
                                                await picker.pickImage(
                                                    source:
                                                        ImageSource.gallery);

                                            if (image != null) {
                                              setState(() {
                                                _imageFile = File(image.path);
                                              });
                                            }
                                            Navigator.pop(
                                                context); // Cierra el bottom sheet
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(70), // Tamaño mayor
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue,
                              width: 3, // Ancho de borde más grueso
                            ),
                          ),
                          child: _imageFile == null
                              ? Column(
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload,
                                      size:
                                          60, // Tamaño más grande para el icono
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Adjuntar Imagen',
                                      style: TextStyle(
                                        fontSize:
                                            18, // Tamaño más grande para el texto
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit
                                        .cover, // Ajuste de la imagen para cubrir el cuadro
                                    height: 200,
                                    width: double.infinity,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_imageFile == null) {
                            // Mostrar un cuadro de diálogo personalizado si no hay imagen
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.deepPurple[
                                      50], // Fondo suave para el diálogo
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        15.0), // Bordes redondeados
                                  ),
                                  title: Text(
                                    '¡Atención!',
                                    style: TextStyle(
                                      color: const Color.fromARGB(255, 255, 18,
                                          18), // Título en color púrpura
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  content: Text(
                                    'Por favor, adjunta una imagen antes de proceder con el pago.',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: const Color.fromARGB(
                                            255,
                                            255,
                                            18,
                                            18), // Color de fondo del botón
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10), // Botón con bordes redondeados
                                        ),
                                      ),
                                      child: Text('Cerrar'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Cerrar el diálogo
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }

                          try {
                            await ApiService.enviarPago(
                              _imageFile!,
                              payment['idcuentas_por_cobrar'].toString(),
                            );
                            Navigator.pop(context); // Cierra el modal
                            _showPaymentConfirmation(payment);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al enviar el pago: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Enviar Pago',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showPaymentConfirmation(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pago realizado con éxito',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'El pago de \$${(double.tryParse(payment['valor_pendiente'].toString()) ?? 0.0).toStringAsFixed(2)} ha sido procesado.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cierra el modal de confirmación
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cerrar',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataModal(Map<String, dynamic> clientData) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado con diseño atractivo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Datos del Cliente',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Contenido del modal
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStyledDataRow(
                    'Identificación:', clientData['identificacion']),
                _buildStyledDataRow('Nombre:', clientData['nombre_cliente']),
                _buildStyledDataRow(
                    'Teléfono Móvil:', clientData['telefono_movil']),
                _buildStyledDataRow('Sector:', clientData['sector']),
                _buildStyledDataRow('Dirección:', clientData['direccion']),
                _buildStyledDataRow(
                    'Fecha de Contrato:', clientData['fecha_contrato']),
              ],
            ),
          ),
          // Botón más atractivo con efecto InkWell
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Diseño mejorado de las filas de datos
  Widget _buildStyledDataRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modal para mostrar el historial de pagos
  Widget _buildPaymentHistoryModal() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 16,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: paymentHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red))),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                  child: Text('No hay historial de pagos.',
                      style: TextStyle(fontSize: 16))),
            );
          } else {
            final payments = snapshot.data!;

            // Concatenamos la IP con la URL de cada pago si existe
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado con diseño atractivo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Historial de Pagos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenido del modal
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: payments.length,
                          separatorBuilder: (context, index) =>
                              Divider(color: Colors.grey.shade300),
                          itemBuilder: (context, index) {
                            final payment = payments[index];
                            return _buildPaymentRow(payment);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón más atractivo con efecto InkWell
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Diseño del modal de historial de pagos
  Widget _buildPaymentRow(Map<String, dynamic> payment) {
    double valorPagado = double.tryParse(payment['total'].toString()) ?? 0.0;

    return GestureDetector(
      onTap: () async {
        if (payment.containsKey('comprobante_url')) {
          final url = Uri.parse(payment['comprobante_url']);
          print("🌍 Abriendo URL: $url");

          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            print("❌ No se pudo abrir el comprobante.");
          } else {
            print("✅ Comprobante abierto correctamente.");
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalle: ${payment['detalle_pago']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                        height: 8), // Space between 'Detalle' and 'Total'
                    Text(
                      'Total: \$${valorPagado.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.receipt_long,
                color: Colors.blue,
                size: 35,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
