import 'package:shared_preferences/shared_preferences.dart';
import 'biometric_service.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _authTokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userPasswordKey = 'user_password';
  static const String _userDocumentoKey = 'user_documento';
  static const String _rememberCredentialsKey = 'remember_credentials';

  static Future<void> saveCredentials({
    required int userId,
    required String name,
    required String email,
    required String role,
    required String token,
    String? password,
    String? documentocliente,
    bool rememberCredentials = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
    await prefs.setString(_authTokenKey, token);
    if (password != null) {
      await prefs.setString(_userPasswordKey, password);
    }
    if (documentocliente != null) {
      await prefs.setString(_userDocumentoKey, documentocliente);
    }
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setBool(_rememberCredentialsKey, rememberCredentials);
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getInt(_userIdKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'role': prefs.getString(_userRoleKey),
      'token': prefs.getString(_authTokenKey),
      'password': prefs.getString(_userPasswordKey),
      'documentocliente': prefs.getString(_userDocumentoKey),
      'rememberCredentials': prefs.getBool(_rememberCredentialsKey) ?? false,
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
    await prefs.remove(_userPasswordKey);
    await prefs.remove(_userDocumentoKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  static Future<void> clearCredentialsRespectingPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberCredentialsKey) ?? false;

    if (remember) {
      // Solo borra el token y estado de login, pero deja email y password
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userRoleKey);
      await prefs.remove(_authTokenKey);
      await prefs.setBool(_isLoggedInKey, false);
      // Deja email, password, documentocliente y rememberCredentials
      // También deja el estado de huella habilitada
    } else {
      // Borra todo incluyendo el estado de huella habilitada
      final email = prefs.getString(_userEmailKey);
      if (email != null && email.isNotEmpty) {
        await BiometricService.clearAppFingerprintEnrollment(email);
      }
      await clearCredentials();
      await prefs.remove(_rememberCredentialsKey);
    }
  }

  // Método modificado para manejar mejor los errores
  static Future<int> getCurrentClientId() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getInt(_userIdKey);
    if (clientId == null) {
      throw Exception('ID de cliente no encontrado');
    }
    return clientId;
  }

  static Future<String> getCurrentClientDocument() async {
    final prefs = await SharedPreferences.getInstance();
    final document = prefs.getString(_userDocumentoKey);
    if (document == null || document.isEmpty) {
      throw Exception('Documento del cliente no encontrado');
    }
    return document;
  }

  static Future<void> logout() async {
    await clearCredentialsRespectingPreference();
  }
}
