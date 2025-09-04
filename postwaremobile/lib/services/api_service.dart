import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/registration_request.dart';
import '../models/password_recovery_request.dart';
import '../models/login_request.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/client.dart';
import '../models/presentation.dart';
import '../services/auth_service.dart';
import 'api_config.dart';

class ApiService {
  Future<Map<String, dynamic>> registerUserAndClient(
    RegistrationRequest request,
  ) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.userRegistrationEndpoint}');

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          return {'success': true, 'data': responseData};
        } catch (e) {
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
          return {
            'success': false,
            'message': 'Error del servidor: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }

  Future<Map<String, dynamic>> requestPasswordRecovery(String email) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.passwordRecoveryEndpoint}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ??
                'Se ha enviado un correo con las instrucciones'
          };
        } catch (e) {
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
            'message': responseData['message'] ?? 'Error en la solicitud',
            'error': response.body,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Error del servidor: ${response.statusCode}',
            'error': response.body,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }

  Future<Map<String, dynamic>> resetPassword(
      {required String token, required String nuevaPassword}) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.passwordResetEndpoint}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'nuevaPassword': nuevaPassword,
        }),
      );
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'message': responseData['message'] ??
                'Contraseña restablecida correctamente'
          };
        } catch (e) {
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
            'message': responseData['message'] ?? 'Error en la solicitud',
            'error': response.body,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Error del servidor: ${response.statusCode}',
            'error': response.body,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userLoginEndpoint}');

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

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          if (responseData['success'] == true && responseData['data'] != null) {
            // Verificar que la estructura de datos sea correcta
            final data = responseData['data'] as Map<String, dynamic>;

            // Verificar que los campos requeridos estén presentes
            if (data['idusuario'] != null && data['token'] != null) {
              return {
                'success': true,
                'message':
                    responseData['message'] ?? 'Inicio de sesión exitoso',
                'data': data,
              };
            } else {
              return {
                'success': false,
                'message': 'Respuesta del servidor incompleta',
              };
            }
          } else {
            return {
              'success': false,
              'message':
                  responseData['message'] ?? 'Error en el inicio de sesión',
            };
          }
        } catch (e) {
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
                responseData['message'] ?? 'Error en el inicio de sesión',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Error del servidor: ${response.statusCode}',
          };
        }
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
      final url = Uri.parse('${ApiConfig.baseUrl}/api/categoria/$id');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Aquí no se debe retornar nada, ya que esta función no se usa
        // return Category.fromJson(responseData);
        // Puedes lanzar una excepción si se llama por error
        throw Exception(
            'No implementado: usa getAllCategories para obtener todas las categorías.');
      } else {
        throw Exception(
            'Error al obtener la categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener la categoría');
    }
  }

  // Método de prueba para verificar conectividad
  Future<bool> testConnection() async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.categoriesEndpoint}');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200 ||
          response.statusCode ==
              401; // 401 significa que el servidor responde pero requiere autenticación
    } on SocketException catch (e) {
      return false;
    } on TimeoutException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.categoriesEndpoint}');
      final token = await AuthService.getAuthToken();

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          if (responseData['data'] is List) {
            final categoriesData = responseData['data'] as List<dynamic>;
            return categoriesData
                .map((json) => Category.fromJson(json))
                .toList();
          } else if (responseData['data'] is Map) {
            // Si data es un Map, buscar la lista de categorías en diferentes claves posibles
            final data = responseData['data'] as Map<String, dynamic>;

            // Intentar diferentes claves comunes
            List<dynamic>? categoriesData;
            if (data.containsKey('categorias')) {
              categoriesData = data['categorias'] as List<dynamic>?;
            } else if (data.containsKey('items')) {
              categoriesData = data['items'] as List<dynamic>?;
            } else if (data.containsKey('list')) {
              categoriesData = data['list'] as List<dynamic>?;
            } else if (data.containsKey('data')) {
              categoriesData = data['data'] as List<dynamic>?;
            }

            if (categoriesData != null) {
              return categoriesData
                  .map((json) => Category.fromJson(json))
                  .toList();
            } else {
              throw Exception(
                  'No se encontró la lista de categorías en la respuesta. Estructura: $data');
            }
          } else {
            throw Exception(
                'Formato de datos inesperado: ${responseData['data'].runtimeType}');
          }
        } else {
          throw Exception(
              'Error en la respuesta del servidor: ${responseData['message'] ?? 'Sin mensaje'}');
        }
      } else {
        throw Exception(
            'Error al obtener las categorías: ${response.statusCode}. ${response.body}');
      }
    } on SocketException {
      throw Exception('Error de conexión de red. Verifica tu internet.');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Intenta nuevamente.');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> getCategoryProducts(int categoryId) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}/api/categoria/$categoryId/productos');
      final token = await AuthService.getAuthToken();

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          if (responseData['data'] is List) {
            final productsData = responseData['data'] as List<dynamic>;
            return productsData.map((json) => Product.fromJson(json)).toList();
          } else if (responseData['data'] is Map) {
            // Si data es un Map, buscar la lista de productos en diferentes claves posibles
            final data = responseData['data'] as Map<String, dynamic>;

            // Intentar diferentes claves comunes
            List<dynamic>? productsData;
            if (data.containsKey('productos')) {
              productsData = data['productos'] as List<dynamic>?;
            } else if (data.containsKey('items')) {
              productsData = data['items'] as List<dynamic>?;
            } else if (data.containsKey('list')) {
              productsData = data['list'] as List<dynamic>?;
            } else if (data.containsKey('data')) {
              productsData = data['data'] as List<dynamic>?;
            } else if (data.containsKey('resultados')) {
              productsData = data['resultados'] as List<dynamic>?;
            }

            if (productsData != null) {
              return productsData
                  .map((json) => Product.fromJson(json))
                  .toList();
            } else {
              throw Exception(
                  'No se encontró la lista de productos en la respuesta. Estructura: $data');
            }
          } else {
            throw Exception(
                'Formato de datos inesperado: ${responseData['data'].runtimeType}');
          }
        } else {
          throw Exception(
              'Error en la respuesta del servidor: ${responseData['message'] ?? 'Sin mensaje'}');
        }
      } else {
        throw Exception(
            'Error al obtener los productos: ${response.statusCode}. ${response.body}');
      }
    } on SocketException {
      throw Exception('Error de conexión de red. Verifica tu internet.');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Intenta nuevamente.');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Presentation>> getPresentations({int? productId}) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.presentationsEndpoint}');
      final token = await AuthService.getAuthToken();
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> presentationsJson =
            responseData['data']['unidades'];
        final allPresentations = presentationsJson
            .map((json) => Presentation.fromJson(json))
            .toList();
        if (productId != null) {
          return allPresentations
              .where((p) => p.productoId == productId)
              .toList();
        }
        return allPresentations;
      } else {
        throw Exception(
            'Error al obtener presentaciones: Código ${response.statusCode}, Respuesta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener presentaciones: $e');
    }
  }

  Future<Product> getProductDetail(int productId) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.productDetailEndpoint.replaceAll('{id}', productId.toString())}');
      final token = await AuthService.getAuthToken();
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Product.fromJson(responseData['data']);
      } else {
        throw Exception(
            'Error al obtener el detalle del producto: Código ${response.statusCode}, Respuesta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al obtener el detalle del producto: $e');
    }
  }

  // Obtener perfil del cliente por ID de usuario
  static Future<http.Response> obtenerPerfilCliente(int usuarioId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/clientes/usuario/$usuarioId');
    final response = await http.get(url);
    return response;
  }

  // Obtener pedidos por documento de cliente
  static Future<http.Response> obtenerPedidosPorCliente(
      String documentoCliente) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}/ventas/cliente/$documentoCliente');
    final response = await http.get(url);
    return response;
  }

  // Obtener perfil del cliente usando el ID de usuario guardado
  Future<Client> getClientProfile() async {
    final credentials = await AuthService.getSavedCredentials();
    final documentocliente = credentials['documentocliente'];
    if (documentocliente == null) {
      throw Exception('No se encontró el documento del cliente en la sesión.');
    }
    final token = await AuthService.getAuthToken();
    final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.clientProfileEndpoint.replaceAll('{documento}', documentocliente)}');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Client.fromJson(data['data']);
      } else {
        throw Exception(
            'Error en la respuesta del servidor: ${data['message'] ?? 'Sin mensaje'}');
      }
    } else {
      throw Exception('Error al obtener el perfil: ${response.statusCode}');
    }
  }

  // Actualizar perfil del cliente usando el ID de usuario guardado
  Future<void> updateClientProfile(Client client) async {
    final userId = await AuthService.getCurrentClientId();
    final url = Uri.parse('${ApiConfig.baseUrl}/api/clientes/miperfil/$userId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(client.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el perfil: ${response.statusCode}');
    }
  }

  // Actualizar perfil del cliente usando el ID de usuario guardado (parcial)
  Future<void> updateClientProfilePartial(
      int documentocliente, Map<String, dynamic> updatedFields,
      {bool enviarTodos = false, Map<String, dynamic>? todosLosCampos}) async {
    final token = await AuthService.getAuthToken();
    final url = Uri.parse(
        '${ApiConfig.baseUrl}${ApiConfig.clientProfileEndpoint.replaceAll('{documento}', documentocliente.toString())}');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(enviarTodos ? todosLosCampos : updatedFields),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el perfil: ${response.statusCode}');
    }
  }

  // Obtener pedidos del cliente usando la nueva ruta y estructura de la API
  Future<List<dynamic>> getClientOrders() async {
    final token = await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No autenticado. Inicia sesión nuevamente.');
    }
    final url =
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.clientOrdersEndpoint}');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['ventas'] != null) {
        return data['data']['ventas'] as List<dynamic>;
      } else {
        final msg = (data is Map && data.containsKey('message'))
            ? data['message']
            : 'No hay pedidos disponibles.';
        throw Exception(msg);
      }
    } else {
      try {
        final data = jsonDecode(response.body);
        final msg = (data is Map && data.containsKey('message'))
            ? data['message']
            : (data is Map && data.containsKey('error'))
                ? data['error']
                : response.body;
        throw Exception(
            'Error al cargar los pedidos: ${response.statusCode}. $msg');
      } catch (_) {
        throw Exception(
            'Error al cargar los pedidos: ${response.statusCode}. ${response.body}');
      }
    }
  }

  // Registro de cliente con la nueva API
  Future<Map<String, dynamic>> registerClient(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.clientRegistrationEndpoint}');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión. Por favor, intente nuevamente.',
      };
    }
  }

  // Descargar PDF de un pedido
  Future<Map<String, dynamic>> downloadOrderPDF(int orderId) async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No autenticado. Inicia sesión nuevamente.');
      }

      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.orderPdfEndpoint.replaceAll('{id}', orderId.toString())}');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/pdf',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;
        return {
          'success': true,
          'data': pdfBytes,
        };
      } else {
        throw Exception('Error al descargar el PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error descargando PDF: $e');
    }
  }
}
