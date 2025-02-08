class Cliente {
  final String idUsuario;
  final String identificacion;
  final String nombreCliente;
  final String telefonoMovil;
  final String sector;
  final String direccion;
  final String fechaContrato;

  Cliente({
    required this.idUsuario,
    required this.identificacion,
    required this.nombreCliente,
    required this.telefonoMovil,
    required this.sector,
    required this.direccion,
    required this.fechaContrato,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idUsuario: json['id_usuario'],
      identificacion: json['identificacion'],
      nombreCliente: json['nombre_cliente'],
      telefonoMovil: json['telefono_movil'],
      sector: json['sector'],
      direccion: json['direccion'],
      fechaContrato: json['fecha_contrato'],
    );
  }
}
