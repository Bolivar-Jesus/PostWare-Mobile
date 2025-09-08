import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import 'auth_service.dart';
import 'api_config.dart';
import 'order_validation_service.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  // Usar la configuración centralizada

  List<CartItem> get items => List.unmodifiable(_items);

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  int getItemCount(int productId) {
    final item = _items.firstWhere(
      (item) => item.idproducto == productId,
      orElse: () => CartItem(
        idproducto: productId,
        nombre: '',
        precioventa: 0,
        imagen: '',
        cantidad: 0,
        stock: 0,
        idpresentacion: 0,
      ),
    );
    return item.cantidad;
  }

  void addItem(CartItem item) {
    final existingItemIndex = _items.indexWhere(
      (i) => i.idproducto == item.idproducto,
    );

    if (existingItemIndex >= 0) {
      if (_items[existingItemIndex].cantidad < item.stock) {
        _items[existingItemIndex].cantidad++;
      }
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.idproducto == productId,
    );

    if (existingItemIndex >= 0) {
      if (_items[existingItemIndex].cantidad > 1) {
        _items[existingItemIndex].cantidad--;
      } else {
        _items.removeAt(existingItemIndex);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Método principal para crear orden con validación
  Future<Map<String, dynamic>> createOrderWithValidation(
      BuildContext context) async {
    if (_items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    // Primero validar la identidad del usuario
    final isValidated = await OrderValidationService.validateOrder(context);
    if (!isValidated) {
      return {
        'success': false,
        'message': 'Autenticación fallida. No se pudo confirmar tu identidad.',
      };
    }

    // Si la validación es exitosa, proceder con la creación del pedido
    return await _createOrderInternal();
  }

  /// Método interno para crear la orden (sin validación)
  Future<Map<String, dynamic>> _createOrderInternal() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.salesEndpoint}');
      final credentials = await AuthService.getSavedCredentials();
      final documentoCliente = credentials['documentocliente'];
      final token = await AuthService.getAuthToken();

      if (documentoCliente == null || documentoCliente.isEmpty) {
        throw Exception('El documento del cliente no está disponible');
      }

      final now = DateTime.now();
      final fechaVenta =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final productosFormateados = _items.map((item) => item.toJson()).toList();

      final ventaData = {
        'documentocliente': documentoCliente,
        'tipo': 'PEDIDO_MOVIL',
        'fechaventa': fechaVenta,
        'productos': productosFormateados,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(ventaData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        clear();
        return {
          'success': true,
          'message': 'Orden creada exitosamente',
          'data': responseData
        };
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['error'] ?? errorBody['message'] ?? 'Error desconocido';
        } catch (e) {
          errorMessage = response.body;
        }
        return {
          'success': false,
          'message': 'Error al crear la orden: $errorMessage'
        };
      }
    } catch (e, stackTrace) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Método legacy para compatibilidad (sin validación)
  @Deprecated('Usar createOrderWithValidation en su lugar')
  Future<Map<String, dynamic>> createOrder() async {
    return await _createOrderInternal();
  }
}
