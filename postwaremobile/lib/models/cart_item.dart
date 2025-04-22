class CartItem {
  final int idproducto;
  final String nombre;
  final double precioventa;
  final String imagen;
  int cantidad;
  final int stock;

  CartItem({
    required this.idproducto,
    required this.nombre,
    required this.precioventa,
    required this.imagen,
    required this.cantidad,
    required this.stock,
  });

  double get subtotal => precioventa * cantidad;

  Map<String, dynamic> toJson() => {
        'idproducto': idproducto,
        'cantidad': cantidad,
        'precioventa': precioventa,
      };
}
