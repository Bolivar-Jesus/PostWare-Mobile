import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/theme_switch_button.dart';
import '../widgets/menu.dart'; // Importa el nuevo menú
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.getCategoryProducts(widget.categoryId);
      if (mounted) {
        setState(() {
          _products = products;
          _filteredProducts = products;
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

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products
            .where((product) =>
                product.nombre.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showProductDetails(Product product) {
    final cart = Provider.of<CartService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        int cantidadSeleccionada = cart.getItemCount(product.id);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: Image.network(
                          product.imagen,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.detalleproducto,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product.formattedPrice,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Stock: ${product.stock}',
                              style: TextStyle(
                                fontSize: 16,
                                color: product.stock > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: cantidadSeleccionada > 0
                                  ? () {
                                      setState(() {
                                        cantidadSeleccionada--;
                                      });
                                      cart.removeItem(product.id);
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 32,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '$cantidadSeleccionada',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: cantidadSeleccionada < product.stock
                                  ? () {
                                      setState(() {
                                        cantidadSeleccionada++;
                                      });
                                      cart.addItem(CartItem(
                                        idproducto: product.id,
                                        nombre: product.nombre,
                                        precioventa: product.precioventa,
                                        imagen: product.imagen,
                                        cantidad: 1,
                                        stock: product.stock,
                                      ));
                                    }
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 32,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          const ThemeSwitchButton(),
          AppMenu(), // Usar el nuevo menú aquí
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Buscar productos',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay productos disponibles',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final cantidad = cart.getItemCount(product.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => _showProductDetails(product),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        product.imagen,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.nombre,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            product.formattedPrice,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                onPressed: cantidad > 0
                                                    ? () {
                                                        cart.removeItem(
                                                            product.id);
                                                      }
                                                    : null,
                                                icon: const Icon(Icons
                                                    .remove_circle_outline),
                                              ),
                                              Text(
                                                '$cantidad',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: cantidad <
                                                        product.stock
                                                    ? () {
                                                        cart.addItem(CartItem(
                                                          idproducto:
                                                              product.id,
                                                          nombre:
                                                              product.nombre,
                                                          precioventa: product
                                                              .precioventa,
                                                          imagen:
                                                              product.imagen,
                                                          cantidad: 1,
                                                          stock: product.stock,
                                                        ));
                                                      }
                                                    : null,
                                                icon: const Icon(
                                                    Icons.add_circle_outline),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        alignment: Alignment.topRight,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
            child: const Icon(Icons.shopping_cart),
          ),
          if (cart.items.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${cart.items.length}', // Muestra la cantidad de productos únicos
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
