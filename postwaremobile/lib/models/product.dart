class Product {
  final int id;
  final String nombre;
  final String detalleproducto;
  final double precioventa;
  final int estado;
  final String imagen;
  final int stock;
  final int idcategoria;

  Product({
    required this.id,
    required this.nombre,
    required this.detalleproducto,
    required this.precioventa,
    required this.estado,
    required this.imagen,
    required this.stock,
    required this.idcategoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Manejar el precio que puede venir como String o double
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        // Remover cualquier carácter no numérico excepto el punto decimal
        final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(cleanValue) ?? 0.0;
      }
      return 0.0;
    }

    // Manejar el stock que puede venir como String o int
    int parseStock(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Product(
      id: json['idproducto'] ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      detalleproducto: json['detalleproducto']?.toString() ?? '',
      precioventa: parsePrice(json['precioventa']),
      estado: json['estado'] ?? 0,
      imagen: json['imagen']?.toString() ?? '',
      stock: parseStock(json['stock']),
      idcategoria: json['idcategoria'] ?? 0,
    );
  }

  // Método para formatear el precio en COP
  String get formattedPrice {
    return '\$${precioventa.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
