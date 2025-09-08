import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_service.dart';
import 'biometric_service.dart';

class OrderValidationService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Verifica si el usuario tiene huella registrada
  static Future<bool> hasBiometricEnrolled() async {
    try {
      final credentials = await AuthService.getSavedCredentials();
      final email = credentials['email'];

      if (email == null || email.isEmpty) return false;

      return await BiometricService.isAppFingerprintEnrolledForEmail(email);
    } catch (e) {
      return false;
    }
  }

  /// Solicita autenticación biométrica
  static Future<bool> authenticateWithBiometric() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canCheckBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'Confirma tu identidad para realizar el pedido',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  /// Solicita contraseña del usuario
  static Future<bool> authenticateWithPassword(BuildContext context) async {
    final credentials = await AuthService.getSavedCredentials();
    final savedPassword = credentials['password'];

    if (savedPassword == null || savedPassword.isEmpty) {
      return false;
    }

    final result = await _showPasswordDialog(context);
    if (result == null) return false;

    return result == savedPassword;
  }

  /// Muestra diálogo para ingresar contraseña
  static Future<String?> _showPasswordDialog(BuildContext context) async {
    final TextEditingController passwordController = TextEditingController();
    bool obscurePassword = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirmar Pedido'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresa tu contraseña para confirmar el pedido:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      Navigator.of(context).pop(value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (passwordController.text.isNotEmpty) {
                      Navigator.of(context).pop(passwordController.text);
                    }
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Método principal para validar pedido
  static Future<bool> validateOrder(BuildContext context) async {
    try {
      // Primero verificar si tiene huella registrada
      final hasBiometric = await hasBiometricEnrolled();

      if (hasBiometric) {
        // Intentar autenticación biométrica
        final biometricResult = await authenticateWithBiometric();
        if (biometricResult) {
          return true;
        }

        // Si falla la huella, mostrar opción de contraseña
        final usePassword = await _showBiometricFallbackDialog(context);
        if (usePassword) {
          return await authenticateWithPassword(context);
        }
        return false;
      } else {
        // No tiene huella, usar contraseña
        return await authenticateWithPassword(context);
      }
    } catch (e) {
      return false;
    }
  }

  /// Diálogo de fallback cuando falla la huella
  static Future<bool> _showBiometricFallbackDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Autenticación Fallida'),
              content: const Text(
                'La autenticación biométrica falló. ¿Deseas usar tu contraseña en su lugar?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Usar Contraseña'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
