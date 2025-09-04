class Presentation {
  final int idpresentacion;
  final int productoId;
  final String nombre;
  final int factorConversion;
  final bool esPredeterminada;
  final String codigobarras;
  final double precioCompraPresentacion;
  final double precioVentaPresentacion;

  Presentation({
    required this.idpresentacion,
    required this.productoId,
    required this.nombre,
    required this.factorConversion,
    required this.esPredeterminada,
    required this.codigobarras,
    required this.precioCompraPresentacion,
    required this.precioVentaPresentacion,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    return Presentation(
      idpresentacion: json['idpresentacion'],
      productoId: json['producto_idproducto'],
      nombre: json['nombre'],
      factorConversion: json['factor_conversion'],
      esPredeterminada: json['es_predeterminada'],
      codigobarras: json['codigobarras'],
      precioCompraPresentacion:
          (json['precio_compra_presentacion'] as num).toDouble(),
      precioVentaPresentacion:
          (json['precio_venta_presentacion'] as num).toDouble(),
    );
  }
}
