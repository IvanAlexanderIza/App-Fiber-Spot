import 'package:flutter/material.dart';
import 'package:frontend/screens/planes.dart';
import 'package:frontend/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class WelcomeScreen extends StatefulWidget {
  final String username;
  final String identificacion;
  final Map<String, dynamic> clientData;
  // Recibe los datos del cliente
  const WelcomeScreen({
    Key? key,
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
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Acción para las notificaciones
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'config') {
                // Acción para configuración
              } else if (value == 'logout') {
                // Acción para cerrar sesión
                cerrarSesion(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'config',
                child: Text('Configuración'),
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
                                              1.0, // 85% del ancho de la pantalla
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.85, // 70% del alto de la pantalla
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                          top: Radius.circular(
                                                              12)),
                                                  child: Image.asset(
                                                    'assets/planprincipal.jpeg', // Imagen de los planes
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetallesPlanesScreen(), // Navega a la nueva pantalla
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  child: Text(
                                                      "Ver más detalles",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ),
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
                          print("Abriendo soporte técnico...");
                        },
                      ),
                      _buildServiceCard(
                        icon: Icons.devices_other,
                        label: 'Productos',
                        color: Colors.teal,
                        onTap: () {
                          print("Mostrando información de contacto...");
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
                    const Text(
                      'Detalles del pago',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    // Mostrar imagen seleccionada
                    if (_imageFile != null) ...[
                      const Text(
                        'Foto del comprobante:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Botón "Pagar ahora" con lógica de envío

                    const SizedBox(height: 20),
                    // Botón para tomar foto
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            setState(() {
                              _imageFile = File(image.path);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Tomar foto'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Botón para elegir de la galería
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _imageFile = File(image.path);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Elegir de la galería'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_imageFile == null) {
                            // Mostrar mensaje si no hay imagen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Por favor, adjunta una imagen antes de pagar.'),
                                backgroundColor: Colors.red,
                              ),
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
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Enviar Pago'),
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
                    color: Colors.green,
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
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cerrar'),
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
                            color: Colors.green.withOpacity(0.3),
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
