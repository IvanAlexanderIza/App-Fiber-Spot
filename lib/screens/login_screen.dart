import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Para tipografía moderna
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Para animaciones de carga
import '../services/api_service.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final response = await ApiService.login(username, password);

      if (response['status'] == 'success') {
        final data = response['data'];
        // Obtener los datos del cliente
        final clientDataResponse =
            await ApiService.getClientData(data['identificacion']);

        if (clientDataResponse['status'] == 'success') {
          // Pasa los datos del cliente a la pantalla de bienvenida
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WelcomeScreen(
                username: data['nombre_cliente'],
                identificacion: data['identificacion'],
                clientData:
                    clientDataResponse['data'], // Pasa los datos del cliente
              ),
            ),
          );
        } else {
          _showErrorSnackBar(
              'Error al obtener datos del cliente: ${clientDataResponse['message']}');
        }
      } else {
        // Mostrar el mensaje de error del servidor
        _showErrorSnackBar(' ${response['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error al conectar con el servidor: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.purple[50],
      body: SingleChildScrollView(
        child: FadeTransition(
          opacity: _animation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Imagen o logo principal
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/logo.png',
                    height: size.height * 0.2,
                  ),
                ),
                const SizedBox(height: 15),
                // Título
                Text(
                  '¡Bienvenido!',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
                const SizedBox(height: 8),
                // Imagen debajo del texto de bienvenida
                Image.asset(
                  'assets/bienvenida.png', // Cambia esto por el nombre real de tu imagen
                  height: 150, // Ajusta el tamaño según necesites
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                // Formulario
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo de usuario
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.purple),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre de usuario es obligatorio';
                          } else if (value.length < 3) {
                            return 'Debe tener al menos 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Campo de contraseña
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.purple),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La contraseña es obligatoria';
                          } else if (value.length < 6) {
                            return 'Debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      // Botón de inicio de sesión
                      _isLoading
                          ? const SpinKitCircle(color: Colors.purple, size: 50)
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple[700],
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Iniciar sesión',
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
                const SizedBox(height: 20),
                // Recuperar contraseña
                const SizedBox(height: 50),
                // Pie de página
                Text(
                  'Copyright © 2025 Fiber Spot | Proveedor de Internet',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
