class ApiConfig {
  // URLs base
  static const String baseUrl = 'https://backend-wi7t.onrender.com';
  static const String cartBaseUrl = 'https://apipost-elt2.onrender.com';

  // Endpoints de categorías
  static const String categoriesEndpoint = '/api/categoria';
  static const String categoryProductsEndpoint =
      '/api/categoria/{id}/productos';

  // Endpoints de usuarios
  static const String userRegistrationEndpoint = '/api/usuarios/registrar';
  static const String userLoginEndpoint = '/api/usuarios/login/cliente';
  static const String passwordRecoveryEndpoint =
      '/api/usuarios/auth/recuperar-password';
  static const String passwordResetEndpoint =
      '/api/usuarios/auth/restablecer-password';

  // Endpoints de productos
  static const String productDetailEndpoint = '/api/productos/{id}';
  static const String presentationsEndpoint = '/api/unidades';

  // Endpoints de clientes
  static const String clientProfileEndpoint =
      '/api/clientes/perfil/{documento}';
  static const String clientOrdersEndpoint = '/api/clientes/mis-ventas';
  static const String clientRegistrationEndpoint = '/api/clientes/registro';

  // Endpoints de ventas
  static const String salesEndpoint = '/api/ventas';
  static const String orderPdfEndpoint = '/api/ventas/{id}/pdf';

  // Configuración de debug
  static const bool debugMode = false; // Cambiar a false en producción

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
