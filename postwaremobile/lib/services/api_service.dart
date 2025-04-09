import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/registration_request.dart';
import '../models/password_recovery_request.dart';

class ApiService {
  static const String baseUrl = 'https://apipost-elt2.onrender.com';

  Future<Map<String, dynamic>> registerUserAndClient(
    RegistrationRequest request,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/usuarios/registrar');

      // Log de la petición
      developer.log('Enviando petición a: $url');
      developer.log('Datos: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'usuario': {
            'nombreusuario': request.usuario['nombreusuario'],
            'email': request.usuario['email'],
            'contrasena': request.usuario['contrasena'],
            'rol_idrol': 2
          },
          'cliente': {
            'documentocliente': int.parse(request.cliente['documentocliente']),
            'nombre': request.cliente['nombre'],
            'apellido': request.cliente['apellido'],
            'email': request.cliente['email'],
            'numerocontacto': request.cliente['numerocontacto']
          }
        }),
      );

      // Log de la respuesta
      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          return {'success': true, 'data': responseData};
        } catch (e) {
          developer.log('Error decodificando JSON: $e');
          return {
            'success': false,
            'message': 'Error procesando la respuesta del servidor',
          };
        }
      } else {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Error en el registro',
          };
        } catch (e) {
          developer.log('Error decodificando JSON de error: $e');
          return {
            'success': false,
            'message': 'Error del servidor: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      developer.log('Error de conexión: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }

  Future<Map<String, dynamic>> requestPasswordRecovery(
    PasswordRecoveryRequest request,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/usuarios/solicitar-recuperacion');

      developer.log('Enviando solicitud de recuperación a: $url');
      developer.log('Email: ${request.email}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': request.email,
        }),
      );

      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'message': responseData['msg'] ??
                'Se ha enviado un correo con las instrucciones'
          };
        } catch (e) {
          developer.log('Error decodificando JSON: $e');
          return {
            'success': false,
            'message': 'Error procesando la respuesta del servidor',
          };
        }
      } else {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['msg'] ?? 'Error en la solicitud',
          };
        } catch (e) {
          developer.log('Error decodificando JSON de error: $e');
          return {
            'success': false,
            'message': 'Error del servidor: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      developer.log('Error de conexión: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    PasswordResetRequest request,
  ) async {
    try {
      final url = Uri.parse(
          '$baseUrl/api/usuarios/restablecer-contrasena/${request.token}');

      developer.log('Enviando solicitud de restablecimiento a: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nuevaContrasena': request.newPassword,
        }),
      );

      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'message':
                responseData['msg'] ?? 'Contraseña restablecida correctamente'
          };
        } catch (e) {
          developer.log('Error decodificando JSON: $e');
          return {
            'success': false,
            'message': 'Error procesando la respuesta del servidor',
          };
        }
      } else {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message':
                responseData['msg'] ?? 'Error al restablecer la contraseña',
          };
        } catch (e) {
          developer.log('Error decodificando JSON de error: $e');
          return {
            'success': false,
            'message': 'Error del servidor: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      developer.log('Error de conexión: $e');
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }
}
