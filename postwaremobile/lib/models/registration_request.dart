class RegistrationRequest {
  final Map<String, dynamic> usuario;
  final Map<String, dynamic> cliente;

  RegistrationRequest({required this.usuario, required this.cliente});

  Map<String, dynamic> toJson() => {'usuario': usuario, 'cliente': cliente};
}
