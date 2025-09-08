import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Claves para almacenar el estado de huella por email
  static String _getBiometricEnabledKey(String email) =>
      'biometric_enabled_$email';
  static String _getBiometricSecretKey(String email) =>
      'biometric_secret_$email';

  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      print('Error verificando disponibilidad de biometría: $e');
      return false;
    }
  }

  static Future<bool> enrollFingerprintForApp(String email) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        print('Biometría no disponible para enrolamiento');
        return false;
      }

      // Autenticar al usuario para enrolar la huella
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Registra tu huella para iniciar sesión en esta app',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          biometricOnly: true,
          stickyAuth: false,
        ),
      );

      if (!didAuthenticate) {
        print('Usuario canceló o falló la autenticación durante enrolamiento');
        return false;
      }

      // Generar un secreto único para este email
      final secret = DateTime.now().millisecondsSinceEpoch.toString();

      // Guardar en almacenamiento seguro
      await _secureStorage.write(
          key: _getBiometricSecretKey(email), value: secret);

      // Marcar como habilitado en SharedPreferences (más confiable para verificación rápida)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_getBiometricEnabledKey(email), true);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isAppFingerprintEnrolledForEmail(String email) async {
    try {
      // Verificar primero en SharedPreferences (más rápido)
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_getBiometricEnabledKey(email)) ?? false;

      if (!isEnabled) {
        return false;
      }

      // Verificar que el secreto esté en almacenamiento seguro
      final secret =
          await _secureStorage.read(key: _getBiometricSecretKey(email));
      final isEnrolled = secret != null && secret.isNotEmpty;

      return isEnrolled;
    } catch (e) {
      print('Error verificando enrolamiento de huella: $e');
      return false;
    }
  }

  static Future<bool> authenticateWithAppFingerprint(String email) async {
    try {
      // Verificar que esté enrolado
      final enrolled = await isAppFingerprintEnrolledForEmail(email);
      if (!enrolled) {
        print('Huella no enrolada para: $email');
        return false;
      }

      // Autenticar con huella
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Usa tu huella para iniciar sesión',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          biometricOnly: true,
          stickyAuth: false,
        ),
      );

      if (!didAuthenticate) {
        print('Autenticación con huella falló para: $email');
        return false;
      }

      // Verificar que el secreto coincida
      final secret =
          await _secureStorage.read(key: _getBiometricSecretKey(email));
      final isValid = secret != null && secret.isNotEmpty;

      return isValid;
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearAppFingerprintEnrollment(String email) async {
    try {
      // Limpiar de almacenamiento seguro
      await _secureStorage.delete(key: _getBiometricSecretKey(email));

      // Limpiar de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getBiometricEnabledKey(email));
    } catch (e) {
      // Error silencioso
    }
  }

  static Future<void> clearAllBiometricEnrollments() async {
    try {
      // Limpiar todas las claves relacionadas con biometría
      await _secureStorage.deleteAll();

      // Limpiar todas las claves de SharedPreferences que empiecen con 'biometric_enabled_'
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('biometric_enabled_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Error silencioso
    }
  }
}
