class ProductSubtotalResult {
  final bool empaqueValido;
  final String mensajeEmpaque;
  final String pesoTexto;
  final String subTotalTexto;
  final String? totalConIgvTexto;
  final String? precioConIgvTexto;

  ProductSubtotalResult({
    required this.empaqueValido,
    required this.mensajeEmpaque,
    required this.pesoTexto,
    required this.subTotalTexto,
    required this.totalConIgvTexto,
    required this.precioConIgvTexto,
  });
}

class ProductSubtotalHelper {
  static ProductSubtotalResult calcular({
    required int categoriaProducto,
    required double diametro,
    required double interno,
    required double longitud,
    required double cantidad,
    required int empaque,
    required String precioTexto,
    required double precioMinimo,
    required double precioMaximo,
    required double igv,
  }) {
    if (cantidad % empaque != 0) {
      return ProductSubtotalResult(
        empaqueValido: false,
        mensajeEmpaque: "Error : Cantidad debe ser multiplo del empaque",
        pesoTexto: "0.000",
        subTotalTexto: "0",
        totalConIgvTexto: null,
        precioConIgvTexto: null,
      );
    }

    double peso = 0;
    double price = 0;

    if (categoriaProducto == 1) {
      peso = ((diametro * diametro * 0.62 * (longitud + 5) / 100000) -
              (interno * interno * 0.62 * longitud / 100000)) *
          cantidad *
          1.07;
    }
    if (categoriaProducto == 2) {
      peso =
          (((diametro * diametro * 0.62 * (longitud + 5)) / 100) * cantidad) /
              1000;
    }
    if (categoriaProducto == 3) {
      peso = (diametro * interno * longitud * 8.025 * cantidad) / 1000000;
    }
    if (categoriaProducto == 4) {
      peso = diametro *
          diametro *
          0.23 *
          ((longitud / 1000) + 0.005) /
          100 *
          cantidad;
    }
    if (categoriaProducto == 5) {
      // Categoria 5 debe usar el diametro interno ingresado por usuario.
      // Si no existe interno (> 0), mantenemos fallback al diametro de catalogo.
      final diametroBase = interno > 0 ? interno : diametro;
      peso = (diametroBase * diametroBase * 0.82 * longitud * cantidad) /
          100000;
    }
    if (categoriaProducto == 6) {
      peso = (diametro * interno * longitud * 2.8 * cantidad) / 1000000;
    }
    if (categoriaProducto == 7) {
      peso = (diametro * interno * longitud * 8.05 * cantidad) / 1000000;
    }
    if (categoriaProducto == 8) {
      peso = cantidad;
    }
    if (categoriaProducto == 9) {
      peso = ((diametro * 1 * longitud) / 1000) * cantidad;
    }

    // Mostrar el peso con 3 decimales, pero mantener el valor interno
    // con precision completa para evitar doble redondeo en subtotal.
    final pesoTexto = peso.toStringAsFixed(3);

    if (precioTexto.trim() == '') {
      return ProductSubtotalResult(
        empaqueValido: true,
        mensajeEmpaque: "",
        pesoTexto: pesoTexto,
        subTotalTexto: "0",
        totalConIgvTexto: null,
        precioConIgvTexto: null,
      );
    }

    final precioValor = double.parse(precioTexto);
    if (precioValor < precioMinimo || precioValor > precioMaximo) {
      return ProductSubtotalResult(
        empaqueValido: true,
        mensajeEmpaque: "",
        pesoTexto: pesoTexto,
        subTotalTexto: "0",
        totalConIgvTexto: null,
        precioConIgvTexto: null,
      );
    }

    price = precioValor;
    final subtotal = price * peso;

    return ProductSubtotalResult(
      empaqueValido: true,
      mensajeEmpaque: "",
      pesoTexto: pesoTexto,
      subTotalTexto: subtotal.toStringAsFixed(2),
      totalConIgvTexto: (subtotal + (subtotal * igv)).toStringAsFixed(2),
      precioConIgvTexto: (price + (price * igv)).toStringAsFixed(2),
    );
  }
}
