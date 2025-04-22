import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _clientIdKey = 'client_id';
  static const String _authTokenKey = 'auth_token';
  static const String _documentoclienteKey = 'documentocliente';

  // Actualizar para guardar también el ID del cliente y el token
  static Future<void> saveCredentials(
      String email, String password, int clientId, String documentocliente,
      {String? authToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
    await prefs.setInt(_clientIdKey, clientId);
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_documentoclienteKey, documentocliente);

    if (authToken != null) {
      await prefs.setString(_authTokenKey, authToken);
    }
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_emailKey),
      'password': prefs.getString(_passwordKey),
      'clientId': prefs.getInt(_clientIdKey),
      'authToken': prefs.getString(_authTokenKey),
      'documentocliente': prefs.getString(_documentoclienteKey),
    };
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_clientIdKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_documentoclienteKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Método modificado para manejar mejor los errores
  static Future<int> getCurrentClientId() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getInt(_clientIdKey);

    // Para pruebas, si no hay ID guardado, usar un valor por defecto (5)
    if (clientId == null) {
      // Esto es solo para pruebas - en producción deberías manejar este caso de otra manera
      return 5; // ID de ejemplo que mencionaste
    }

    return clientId;
  }
}
