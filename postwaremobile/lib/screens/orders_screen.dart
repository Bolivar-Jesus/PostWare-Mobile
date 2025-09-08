import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/theme_switch_button.dart';
import '../widgets/cart_icon.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/download_service.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data'; // Added for Uint8List
import '../widgets/menu.dart';

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
      String errorMsg = e.toString();
      if (errorMsg.toLowerCase().contains('no hay pedidos')) {
        errorMsg = 'No tienes pedidos registrados.';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error al cargar pedidos'),
          content: Text(errorMsg,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  void _showOrderDetailDialog(Map<String, dynamic> order) {
    // Fecha formateada con hora
    final rawDate = order['fechaventa'] as String? ?? '';
    String formattedDate = rawDate;
    final parsed = DateTime.tryParse(rawDate);
    if (parsed != null) {
      formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(parsed.toLocal());
    }

    // Total formateado
    final totalRaw = order['total'];
    final totalValue =
        (totalRaw is num) ? totalRaw : num.tryParse(totalRaw.toString()) ?? 0;
    final formattedTotal = NumberFormat.currency(
      locale: 'es_CO',
      symbol: r'$',
      decimalDigits: 0,
    ).format(totalValue);

    final items = order['productos'] as List<dynamic>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalle del Pedido #${order['idventas']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: $formattedDate'),
              const SizedBox(height: 4.0),
              Text('Estado: ${order['estado']}'),
              Text('Tipo: ${order['tipo']}'),
              if (order['motivo_anulacion'] != null)
                Text('Motivo anulación: ${order['motivo_anulacion']}'),
              const SizedBox(height: 12.0),
              const Divider(),
              const SizedBox(height: 8.0),
              const Text(
                'Productos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              ...items.map((itm) {
                final item = itm as Map<String, dynamic>;
                final imgUrl = item['imagen'] as String?;
                final name = (item['nombre'] ?? '').toString();
                final qty = item['cantidad'] ?? 0;

                final priceRaw = item['precioventa'];
                final priceValue = (priceRaw is num)
                    ? priceRaw
                    : num.tryParse(priceRaw.toString()) ?? 0;
                final formattedPrice = NumberFormat.currency(
                  locale: 'es_CO',
                  symbol: r'$',
                  decimalDigits: 0,
                ).format(priceValue);

                final subtotalRaw = item['subtotal'];
                final subtotalValue = (subtotalRaw is num)
                    ? subtotalRaw
                    : num.tryParse(subtotalRaw.toString()) ?? 0;
                final formattedSubtotal = NumberFormat.currency(
                  locale: 'es_CO',
                  symbol: r'$',
                  decimalDigits: 0,
                ).format(subtotalValue);

                final presentacion =
                    item['presentacion'] as Map<String, dynamic>?;
                final presentacionNombre =
                    presentacion != null ? presentacion['nombre'] : null;
                final factor = presentacion != null
                    ? presentacion['factor_conversion']
                    : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text(
                              presentacionNombre != null &&
                                      presentacionNombre.toString().isNotEmpty
                                  ? '$name ($presentacionNombre)'
                                  : name,
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4.0),
                            if (presentacionNombre != null)
                              Text('Presentación: $presentacionNombre'),
                            if (factor != null)
                              Text('Factor conversión: $factor'),
                            Text('Cantidad: $qty'),
                            Text('Precio unitario: $formattedPrice'),
                            Text('Subtotal: $formattedSubtotal'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: $formattedTotal',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () => _downloadOrderPDF(order),
            icon: const Icon(Icons.download),
            label: const Text('Descargar PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadOrderPDF(Map<String, dynamic> order) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.0),
              Text('Descargando PDF...'),
            ],
          ),
        ),
      );

      // Descargar PDF
      final result = await _apiService.downloadOrderPDF(order['idventas']);

      // Cerrar diálogo de carga
      Navigator.of(context).pop();

      if (result['success'] == true) {
        final pdfBytes = result['data'] as Uint8List;
        final fileName =
            'pedido_${order['idventas']}_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // Descargar y abrir PDF
        await DownloadService.downloadAndOpenPDF(pdfBytes, fileName, context);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF descargado y abierto correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al descargar el PDF');
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error al descargar PDF'),
          content: Text('No se pudo descargar el PDF: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        actions: [
          const ThemeSwitchButton(),
          const CartIcon(),
          AppMenu(),
        ],
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

                    return InkWell(
                      onTap: () => _showOrderDetailDialog(order),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pedido #${order['idventas']}',
                                    style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Fecha: $dateOnly',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 8.0),
                              Text('Estado: ${order['estado']}'),
                              Text('Tipo: ${order['tipo']}'),
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
                      ),
                    );
                  },
                ),
    );
  }
}
