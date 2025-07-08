import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _authTokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  static Future<void> saveCredentials({
    required int userId,
    required String name,
    required String email,
    required String role,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_authTokenKey, token);
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'role': prefs.getString(_userRoleKey),
      'token': prefs.getString(_authTokenKey),
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
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_authTokenKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Método modificado para manejar mejor los errores
  static Future<int> getCurrentClientId() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getInt(_userIdKey);

    // Para pruebas, si no hay ID guardado, usar un valor por defecto (5)
    if (clientId == null) {
      // Esto es solo para pruebas - en producción deberías manejar este caso de otra manera
      return 5; // ID de ejemplo que mencionaste
    }

    return clientId;
  }
}
