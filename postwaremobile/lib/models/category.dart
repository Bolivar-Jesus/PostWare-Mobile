class Category {
  final int id;
  final String nombre;
  final String? imagen;

  Category({
    required this.id,
    required this.nombre,
    this.imagen,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      imagen: json['imagen'],
    );
  }
}
