import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

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
      final clientId = await AuthService.getCurrentClientId();
      final orders = await _apiService.getClientOrders(clientId);
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
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Pedido ID: ${order['idventas']}'),
                        subtitle: Text('Total: \$${order['total']}'),
                        trailing: Text('Fecha: ${order['fechaventa']}'),
                        onTap: () {
                          // Aquí puedes agregar lógica para mostrar detalles del pedido
                        },
                      ),
                    );
                  },
                ),
    );
  }
}