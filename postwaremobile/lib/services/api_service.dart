import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/registration_request.dart';
import '../models/password_recovery_request.dart';
import '../models/login_request.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/client.dart';
import '../services/auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://backend-wi7t.onrender.com';

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

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/usuarios/login');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Inicio de sesión exitoso',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el inicio de sesión',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }

  Future<Category> getCategory(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/categorias/$id');

      developer.log('Obteniendo categoría: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Category.fromJson(responseData);
      } else {
        throw Exception(
            'Error al obtener la categoría: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error obteniendo categoría: $e');
      throw Exception('Error de conexión al obtener la categoría');
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final url = Uri.parse('$baseUrl/api/categorias');

      developer.log('Obteniendo categorías: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> categoriesJson = responseData['data'];
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener las categorías: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error obteniendo categorías: $e');
      throw Exception('Error de conexión al obtener las categorías');
    }
  }

  Future<List<Product>> getCategoryProducts(int categoryId) async {
    try {
      final url =
          Uri.parse('$baseUrl/api/productos/categoria/$categoryId/productos');

      developer.log('Obteniendo productos de categoría: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      developer.log('Código de estado: ${response.statusCode}');
      developer.log('Respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Verificar si la respuesta tiene la estructura esperada
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> productsJson = responseData['data'];
          developer
              .log('Número de productos encontrados: ${productsJson.length}');

          final products = productsJson.map((json) {
            try {
              return Product.fromJson(json);
            } catch (e) {
              developer.log('Error al procesar producto: $e');
              developer.log('JSON del producto: $json');
              rethrow;
            }
          }).toList();

          return products;
        } else {
          developer.log('Respuesta inesperada: $responseData');
          throw Exception('Formato de respuesta inválido');
        }
      } else {
        developer.log('Error en la respuesta: ${response.statusCode}');
        developer.log('Cuerpo de la respuesta: ${response.body}');
        throw Exception(
            'Error al obtener los productos: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error obteniendo productos: $e');
      throw Exception('Error de conexión al obtener los productos: $e');
    }
  }

  // Obtener perfil del cliente por ID de usuario
  static Future<http.Response> obtenerPerfilCliente(int usuarioId) async {
    final url = Uri.parse('$baseUrl/clientes/usuario/$usuarioId');
    final response = await http.get(url);
    return response;
  }

  // Obtener pedidos por documento de cliente
  static Future<http.Response> obtenerPedidosPorCliente(
      String documentoCliente) async {
    final url = Uri.parse('$baseUrl/ventas/cliente/$documentoCliente');
    final response = await http.get(url);
    return response;
  }

  // Obtener perfil del cliente usando el ID de usuario guardado
  Future<Client> getClientProfile() async {
    final userId = await AuthService.getCurrentClientId();
    final url = Uri.parse('$baseUrl/api/clientes/miperfil/$userId');
    developer.log('Obteniendo perfil del cliente: $url');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    developer.log('Código de estado: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Client.fromJson(data);
    } else {
      throw Exception('Error al obtener el perfil: ${response.statusCode}');
    }
  }

  // Actualizar perfil del cliente usando el ID de usuario guardado
  Future<void> updateClientProfile(Client client) async {
    final userId = await AuthService.getCurrentClientId();
    final url = Uri.parse('$baseUrl/api/clientes/miperfil/$userId');
    developer.log('Actualizando perfil del cliente: $url');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(client.toJson()),
    );
    developer.log('Código de estado: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el perfil: ${response.statusCode}');
    }
  }

  // Obtener pedidos del cliente usando el ID de usuario guardado
  Future<List<dynamic>> getClientOrders() async {
    final userId = await AuthService.getCurrentClientId();
    final url = Uri.parse('$baseUrl/api/ventas/mis-ventas/$userId');
    developer.log('Obteniendo pedidos del cliente: $url');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    developer.log('Código de estado: ${response.statusCode}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error al cargar los pedidos: ${response.statusCode}');
    }
  }
}
