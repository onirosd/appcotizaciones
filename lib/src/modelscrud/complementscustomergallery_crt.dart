import 'package:sqflite/sqflite.dart';
import 'package:appcotizaciones/src/helpers/database_helper.dart';
import 'package:appcotizaciones/src/models/complementsCustoGalle.dart';
import 'package:appcotizaciones/src/models/response_error.dart';

class ComplementsCustomerGalleriesCrud {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<ResponseError> insertAllComplements(
      List<ComplementsCustoGalle> data) async {
    final db = await _dbHelper.db;
    final batch = db.batch();
    final result = ResponseError(description: '', error: 1, success: 0);

    try {
      if (data.isEmpty) return result;

      final item = data.first;

      item.customer?.forEach((c) => batch.insert('Customer', c.toMap()));
      item.gallery?.forEach((g) => batch.insert('Gallery', g.toMap()));
      item.galleryDetail
          ?.forEach((gd) => batch.insert('GalleryDetail', gd.toMap()));
      item.galleriesdetailsubtipos
          ?.forEach((gs) => batch.insert('GalleryDetailSubtipos', gs.toMap()));

      await batch.commit(noResult: true, continueOnError: true);

      result.success = 1;
      result.error = 0;
      result.description =
          'Carga Clientes,Imagenes : Tablas de Clientes y Galerias Sincronizadas con Exito';
    } catch (e) {
      result.description = 'Carga Clientes,Imagenes : \$e';
    }

    return result;
  }
}
