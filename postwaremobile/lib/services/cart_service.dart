import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';
import 'auth_service.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];
  static const String baseUrl = 'https://apipost-elt2.onrender.com';

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

  Future<Map<String, dynamic>> createOrder(int documentoCliente) async {
    if (_items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    try {
      final url = Uri.parse('$baseUrl/api/ventas');

      // Calcular el total
      final totalFormateado = _items.fold(
    0.0, (sum, item) => sum + (item.precioventa * item.cantidad));

      // Preparar los productos
      final productosFormateados = _items.map((item) {
        return {
          'idproducto': item.idproducto,
          'cantidad': item.cantidad,
          'precioventa': item.precioventa,
        };
      }).toList();

      final ventaData = {
        'documentocliente': documentoCliente.toString(),
        'total': totalFormateado,
        'productos': productosFormateados
      };

      print('URL de la petición: $url');
      print('Datos enviados: ${jsonEncode(ventaData)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(ventaData),
      );

      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta completa del servidor: ${response.body}');

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
          print('Error detallado del servidor: $errorBody');
        } catch (e) {
          errorMessage = response.body;
          print('Error al parsear la respuesta: $e');
        }
        return {
          'success': false,
          'message': 'Error al crear la orden: $errorMessage'
        };
      }
    } catch (e, stackTrace) {
      print('Error detallado: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
