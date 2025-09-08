import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/theme_switch_button.dart';
import '../widgets/menu.dart'; // Importa el nuevo menú
import '../widgets/cart_icon.dart';
import 'cart_screen.dart';
import '../models/presentation.dart';

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
      String errorMsg = e.toString();
      if (errorMsg.toLowerCase().contains('no disponible')) {
        errorMsg = 'Este producto no está disponible.';
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error al cargar productos'),
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

  void _showProductDetails(Product product) async {
    final cart = Provider.of<CartService>(context, listen: false);
    List<Presentation> presentations = [];
    Presentation? selectedPresentation;
    bool loadingPresentations = true;
    String? errorPresentations;

    await showDialog(
      context: context,
      builder: (context) {
        int cantidadSeleccionada = cart.getItemCount(product.id);
        return Dialog(
          child: Material(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    // Cargar presentaciones solo una vez
                    if (loadingPresentations) {
                      ApiService()
                          .getPresentations(productId: product.id)
                          .then((result) {
                        setState(() {
                          presentations = result;
                          if (presentations.isNotEmpty) {
                            selectedPresentation = presentations.first;
                          }
                          loadingPresentations = false;
                        });
                      }).catchError((e) {
                        setState(() {
                          errorPresentations = e.toString();
                          loadingPresentations = false;
                        });
                      });
                    }
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
                              if (loadingPresentations)
                                const Center(child: CircularProgressIndicator())
                              else if (errorPresentations != null)
                                Text('Error: $errorPresentations',
                                    style: const TextStyle(color: Colors.red))
                              else if (presentations.isNotEmpty)
                                DropdownButton<Presentation>(
                                  value: selectedPresentation,
                                  isExpanded: true,
                                  items: presentations.map((p) {
                                    return DropdownMenuItem<Presentation>(
                                      value: p,
                                      child: Text(
                                          '${p.nombre} - ${p.precioVentaPresentacion.toStringAsFixed(0)}'),
                                    );
                                  }).toList(),
                                  onChanged: (p) {
                                    setState(() {
                                      selectedPresentation = p;
                                    });
                                  },
                                ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
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
                                    onPressed: (cantidadSeleccionada <
                                                product.stock &&
                                            selectedPresentation != null)
                                        ? () {
                                            setState(() {
                                              cantidadSeleccionada++;
                                            });
                                            cart.addItem(CartItem(
                                              idproducto: product.id,
                                              nombre: product.nombre,
                                              precioventa: selectedPresentation!
                                                  .precioVentaPresentacion,
                                              imagen: product.imagen,
                                              cantidad: 1,
                                              stock: product.stock,
                                              idpresentacion:
                                                  selectedPresentation!
                                                      .idpresentacion,
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
              ),
            ),
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
          const CartIcon(),
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
                                      child: (product.imagen != null &&
                                              product.imagen.isNotEmpty)
                                          ? Image.network(
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
                                                      color: Colors.red),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                  Icons.image_not_supported),
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
                                          Builder(
                                            builder: (context) {
                                              return FutureBuilder<
                                                  List<Presentation>>(
                                                future: ApiService()
                                                    .getPresentations(
                                                        productId: product.id),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8.0),
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  }
                                                  if (snapshot.hasError) {
                                                    return const Text(
                                                        'Error al cargar presentaciones',
                                                        style: TextStyle(
                                                            color: Colors.red));
                                                  }
                                                  final presentations =
                                                      snapshot.data ?? [];
                                                  if (presentations.isEmpty) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8.0),
                                                      child: Text(
                                                          'No disponible para la venta',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    );
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        Presentation?
                                                            selectedPresentation =
                                                            presentations.first;
                                                        int cantidad = 1;
                                                        await showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Selecciona presentación'),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      DropdownButton<
                                                                          Presentation>(
                                                                        value:
                                                                            selectedPresentation,
                                                                        isExpanded:
                                                                            true,
                                                                        items: presentations
                                                                            .map((p) {
                                                                          return DropdownMenuItem<
                                                                              Presentation>(
                                                                            value:
                                                                                p,
                                                                            child:
                                                                                Text('${p.nombre} - ${p.precioVentaPresentacion.toStringAsFixed(0)}'),
                                                                          );
                                                                        }).toList(),
                                                                        onChanged:
                                                                            (p) {
                                                                          setState(
                                                                              () {
                                                                            selectedPresentation =
                                                                                p;
                                                                          });
                                                                        },
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              12),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          IconButton(
                                                                            icon:
                                                                                const Icon(Icons.remove_circle_outline),
                                                                            onPressed: cantidad > 1
                                                                                ? () {
                                                                                    setState(() {
                                                                                      cantidad--;
                                                                                    });
                                                                                  }
                                                                                : null,
                                                                          ),
                                                                          Text(
                                                                              '$cantidad',
                                                                              style: const TextStyle(fontSize: 18)),
                                                                          IconButton(
                                                                            icon:
                                                                                const Icon(Icons.add_circle_outline),
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                cantidad++;
                                                                              });
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      child: const Text(
                                                                          'Cancelar'),
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed: selectedPresentation !=
                                                                              null
                                                                          ? () {
                                                                              Provider.of<CartService>(context, listen: false).addItem(CartItem(
                                                                                idproducto: product.id,
                                                                                nombre: product.nombre,
                                                                                precioventa: selectedPresentation!.precioVentaPresentacion,
                                                                                imagen: product.imagen,
                                                                                cantidad: cantidad,
                                                                                stock: product.stock,
                                                                                idpresentacion: selectedPresentation!.idpresentacion,
                                                                              ));
                                                                              Navigator.pop(context);
                                                                            }
                                                                          : null,
                                                                      child: const Text(
                                                                          'Agregar'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: const Text(
                                                          'Agregar al carrito'),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
