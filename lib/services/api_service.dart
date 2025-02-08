import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String baseUrl = 'http://177.53.213.246:8210/api';

  static const Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  /// Método auxiliar para manejar respuestas
  static Future<dynamic> _handleResponse(http.Response response) async {
    final dynamic responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw Exception(
          responseData['message'] ?? 'Error desconocido del servidor');
    }
  }

  /// Método genérico para realizar solicitudes POST
  static Future<dynamic> _post(
      String endpoint, Map<String, String> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// Método para iniciar sesión
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    return await _post('login', {'username': username, 'password': password});
  }

  /// Método para obtener los datos del cliente
  static Future<Map<String, dynamic>> getClientData(
      String identificacion) async {
    return await _post('datos-cliente', {'identificacion': identificacion});
  }

  /// Método para obtener el historial de pagos
  static Future<List<Map<String, dynamic>>> getPaymentHistory(
      String identificacion) async {
    final response =
        await _post('historial-pagos', {'identificacion': identificacion});

    print(
        "📡 Respuesta del servidor: $response"); // 🔍 Verifica qué está llegando

    if (response['status'] == 'success' && response['data'] is List) {
      List<Map<String, dynamic>> paymentHistory =
          List<Map<String, dynamic>>.from(response['data']);

      for (var payment in paymentHistory) {
        print("🛠 Procesando pago: $payment"); // 🔍 Ver cada pago en la lista

        if (payment.containsKey('id_factura')) {
          // ✅ Verifica si tiene 'id_factura'
          final String baseUrl = 'http://177.53.213.246:8210/';
          final String comprobantePath =
              'public/comprobantes/comprobante_${payment['id_factura']}.pdf';

          payment['comprobante_url'] =
              Uri.parse(baseUrl).resolve(comprobantePath).toString();
          print(
              "✅ URL Generada: ${payment['comprobante_url']}"); // 🔍 Ver la URL final
        } else {
          print(
              "❌ Este pago no tiene 'id_factura'. No se puede generar la URL.");
        }
      }

      return paymentHistory;
    } else {
      throw Exception('Datos no disponibles o formato incorrecto');
    }
  }

  /// Método para obtener los pagos pendientes
  static Future<List<Map<String, dynamic>>> getPendingPayments(
      String identificacion) async {
    final response =
        await _post('pagos-pendientes', {'identificacion': identificacion});
    if (response['status'] == 'success' && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    } else {
      throw Exception('Datos no disponibles o formato incorrecto');
    }
  }

  static Future<void> enviarPago(File archivo, String idCuentas) async {
    var url = Uri.parse("http://177.53.213.246:8210/api/enviar-pago");

    try {
      print("📤 Enviando solicitud a: $url");
      print("📂 Path del archivo: ${archivo.path}");
      print("📄 Nombre del archivo: ${path.basename(archivo.path)}");
      print("🆔 ID de cuenta: $idCuentas");

      // Detectar el tipo MIME del archivo
      String? mimeType =
          lookupMimeType(archivo.path) ?? "application/octet-stream";
      var mediaType = mimeType.split('/');

      var request = http.MultipartRequest("POST", url)
        ..fields['idcuentas_por_cobrar'] = idCuentas
        ..files.add(
          await http.MultipartFile.fromPath(
            'archivo[]', // 🔹 Adaptado para enviar como lista
            archivo.path,
            filename: path.basename(archivo.path),
            contentType: MediaType(mediaType[0], mediaType[1]),
          ),
        );

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      print("🔍 Respuesta del servidor: $responseString");

      if (response.statusCode == 200) {
        print("✅ Pago enviado correctamente.");
      } else {
        print("❌ Error al enviar el pago: ${response.statusCode}");
        print("⚠️ Detalles del error: $responseString");
      }
    } catch (e) {
      print("🚨 Error al realizar la solicitud: $e");
    }
  }
}
