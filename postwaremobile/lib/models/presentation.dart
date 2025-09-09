import '../services/api_config.dart';

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
    // Debug: imprimir la estructura del JSON para diagnosticar
    if (ApiConfig.debugMode) {
      print('DEBUG: JSON de presentación: $json');
    }

    // Mapear el productoId con múltiples variantes posibles
    int productoId = 0;
    if (json['producto_idproducto'] != null) {
      productoId = json['producto_idproducto'] as int;
    } else if (json['productoId'] != null) {
      productoId = json['productoId'] as int;
    } else if (json['idproducto'] != null) {
      productoId = json['idproducto'] as int;
    } else if (json['producto_id'] != null) {
      productoId = json['producto_id'] as int;
    } else if (json['product_id'] != null) {
      productoId = json['product_id'] as int;
    }

    if (ApiConfig.debugMode) {
      print('DEBUG: ProductoId mapeado: $productoId');
    }

    return Presentation(
      idpresentacion: json['idpresentacion'] ?? 0,
      productoId: productoId,
      nombre: json['nombre'] ?? '',
      factorConversion: json['factor_conversion'] ?? 1,
      esPredeterminada: json['es_predeterminada'] ?? false,
      codigobarras: json['codigobarras'] ?? '',
      precioCompraPresentacion:
          (json['precio_compra_presentacion'] as num?)?.toDouble() ?? 0.0,
      precioVentaPresentacion:
          (json['precio_venta_presentacion'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
