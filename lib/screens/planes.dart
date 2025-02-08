import 'package:flutter/material.dart';

class DetallesPlanesScreen extends StatelessWidget {
  final List<String> imagenes = [
    'assets/superfiber.jpeg',
    'assets/megafiber.jpeg',
    'assets/ultrafiber.jpeg',
    'assets/hyperfiber.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles de Planes',
          style: TextStyle(
            fontSize: 30,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columnas
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: imagenes.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagenes[index],
                fit: BoxFit.cover, // Ajusta bien las imágenes
              ),
            );
          },
        ),
      ),
    );
  }
}
