class Client {
  final int id;
  final String tipodocumento;
  final int documentocliente;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final bool estado;
  final String municipio;
  final String complemento;
  final String direccion;
  final String barrio;

  Client({
    required this.id,
    required this.tipodocumento,
    required this.documentocliente,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.estado,
    required this.municipio,
    required this.complemento,
    required this.direccion,
    required this.barrio,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['usuario_idusuario'] ?? json['id'] ?? 0;
      int docCliente;
      if (json['documentocliente'] is String) {
        docCliente = int.tryParse(json['documentocliente']) ?? 0;
      } else {
        docCliente = json['documentocliente'] ?? 0;
      }
      return Client(
        id: id,
        tipodocumento: json['tipodocumento'] ?? '',
        documentocliente: docCliente,
        nombre: json['nombre'] ?? '',
        apellido: json['apellido'] ?? '',
        email: json['email'] ?? '',
        telefono: json['telefono'] ?? '',
        estado: json['estado'] is bool ? json['estado'] : (json['estado'] == 1),
        municipio: json['municipio'] ?? '',
        complemento: json['complemento'] ?? '',
        direccion: json['direccion'] ?? '',
        barrio: json['barrio'] ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_idusuario': id,
      'tipodocumento': tipodocumento,
      'documentocliente': documentocliente,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'estado': estado,
      'municipio': municipio,
      'complemento': complemento,
      'direccion': direccion,
      'barrio': barrio,
    };
  }

  @override
  String toString() {
    return 'Client{id: $id, tipodocumento: $tipodocumento, documentocliente: $documentocliente, nombre: $nombre, apellido: $apellido, email: $email, telefono: $telefono, estado: $estado, municipio: $municipio, complemento: $complemento, direccion: $direccion, barrio: $barrio}';
  }
}
