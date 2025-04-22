import 'dart:developer' as developer;

class Client {
  final int id;
  final int documentocliente;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final int estado;

  Client({
    required this.id,
    required this.documentocliente,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.estado,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Procesando JSON de cliente: $json');
      
      // Extraer el ID correctamente
      final id = json['usuario_idusuario'] ?? json['id'] ?? 0;
      
      // Convertir documentocliente a int si viene como string
      int docCliente;
      if (json['documentocliente'] is String) {
        docCliente = int.tryParse(json['documentocliente']) ?? 0;
      } else {
        docCliente = json['documentocliente'] ?? 0;
      }
      
      return Client(
        id: id,
        documentocliente: docCliente,
        nombre: json['nombre'] ?? '',
        apellido: json['apellido'] ?? '',
        email: json['email'] ?? '',
        telefono: json['numerocontacto'] ?? json['telefono'] ?? '',
        estado: json['estado'] ?? 1,
      );
    } catch (e) {
      developer.log('Error al procesar JSON del cliente: $e');
      developer.log('JSON recibido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_idusuario': id,
      'documentocliente': documentocliente,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'numerocontacto': telefono,
      'estado': estado,
    };
  }
  
  @override
  String toString() {
    return 'Client{id: $id, documentocliente: $documentocliente, nombre: $nombre, apellido: $apellido, email: $email, telefono: $telefono, estado: $estado}';
  }
}