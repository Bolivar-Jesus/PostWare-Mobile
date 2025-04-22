import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      // Obtener pedidos usando el ID de usuario guardado internamente en ApiService
      final orders = await _apiService.getClientOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No hay pedidos disponibles'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index] as Map<String, dynamic>;
                    // Extraer fecha sin hora
                    final rawDate = order['fechaventa'] as String? ?? '';
                    final dateOnly = rawDate.split('T').first;
                    // Obtener lista de productos
                    final items = order['productos'] as List<dynamic>? ?? [];
                    // Formatear el total en COP con separadores de miles
                    final totalRaw = order['total'];
                    final totalValue = (totalRaw is num)
                        ? totalRaw
                        : num.tryParse(totalRaw.toString()) ?? 0;
                    final formattedTotal = NumberFormat.currency(
                      locale: 'es_CO',
                      symbol: r'$',
                      decimalDigits: 0,
                    ).format(totalValue);
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido #${order['idventas']}',
                              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Fecha: $dateOnly',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Divider(height: 20.0),
                            // Lista de productos dentro del pedido
                            ...items.map((item) {
                              final prod = item['producto'] as Map<String, dynamic>?;
                              final imgUrl = prod?['imagen'] as String?;
                              final name = prod?['nombre'] ?? '';
                              final price = prod?['precioventa'] ?? '';
                              final qty = item['cantidad'] ?? '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    if (imgUrl != null && imgUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.network(
                                          imgUrl,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4.0),
                                          Text('Cantidad: $qty', style: const TextStyle(fontSize: 14.0)),
                                          Text('Precio: \$${price}', style: const TextStyle(fontSize: 14.0)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(height: 20.0),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total: $formattedTotal',
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}