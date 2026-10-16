import 'package:appcotizaciones/src/modelscrud/api.configGeneral_crt.dart';
import 'package:appcotizaciones/src/modelscrud/synclog_crt.dart';
import 'package:appcotizaciones/src/models/response_error.dart';

class SyncService {
  /// Sincroniza todos los datos: sube lo pendiente y descarga lo nuevo.
  // Future<void> syncAll({
  //   required int codUser,
  //   required int codList,
  //   required String codCompany,
  //   required String position,
  //   required void Function(String paso)? onStep,
  // }) async {
  //   final configgeneral = ApiConfigGeneral();

  //   // 1. Subir Clientes
  //   onStep?.call("Subiendo nuevos clientes...");
  //   await _safeCall("Subir Clientes",
  //       () => configgeneral.executionRuleUploadClients(codUser));

  //   // 2. Subir Recibos
  //   onStep?.call("Subiendo nuevos recibos...");
  //   await _safeCall("Subir Recibos",
  //       () => configgeneral.executionRuleUploadBilling(codUser));

  //   // 3. Subir Cotizaciones
  //   onStep?.call("Subiendo nuevas cotizaciones...");
  //   await _safeCall("Subir Cotizaciones",
  //       () => configgeneral.executionRuleUploadQuotation(codUser));

  //   // 4. Subir Galerías
  //   onStep?.call("Subiendo galerías...");
  //   await _safeCall("Subir Galerías",
  //       () => configgeneral.executionRuleUploadGalleries(codUser));

  //   // 5. Subir Stock de productos
  //   onStep?.call("Actualizando stock de productos...");
  //   await _safeCall(
  //       "Subir Stock",
  //       () => configgeneral.executionRuleUploadStockProduct(
  //           codUser, codList, codCompany));

  //   // 6. Sincronizar Recibos y Cotizaciones
  //   onStep?.call("Sincronizando cotizaciones y recibos...");
  //   await _safeCall(
  //       "Sincronizar Quo/Bill",
  //       () => configgeneral.executionRuleUploadSyncQuoBill(
  //           codUser, position, codCompany));

  //   // 7. Guardar Log
  //   onStep?.call("Guardando registro de sincronización...");
  //   final log = SyncLogCtr();
  //   await log.saveLogtoUser(
  //       codUser, 'Sync-general', 'Sincronización finalizada');
  // }

  Future<void> syncAll({
    required int codUser,
    required int codList,
    required String codCompany,
    required String position,
    required void Function(String paso)? onStep,
  }) async {
    final configgeneral = ApiConfigGeneral();

    onStep?.call("Iniciando sincronización...");

    // 🔄 GRUPO 1: Subidas paralelas (clientes, recibos, cotizaciones, galerías)
    onStep?.call("Subiendo clientes, recibos, cotizaciones y galerías...");
    await Future.wait([
      _safeCall("Subir Clientes",
          () => configgeneral.executionRuleUploadClients(codUser)),
      _safeCall("Subir Recibos",
          () => configgeneral.executionRuleUploadBilling(codUser)),
      _safeCall("Subir Cotizaciones",
          () => configgeneral.executionRuleUploadQuotation(codUser)),
      _safeCall("Subir Galerías",
          () => configgeneral.executionRuleUploadGalleries(codUser)),
    ]);

    // 🔄 GRUPO 2: Stock y sincronización de Quo/Bill
    onStep?.call("Actualizando stock y sincronizando Quo/Bill...");
    await Future.wait([
      _safeCall(
        "Subir Stock",
        () => configgeneral.executionRuleUploadStockProduct(
            codUser, codList, codCompany),
      ),
      _safeCall(
        "Sincronizar Quo/Bill",
        () => configgeneral.executionRuleUploadSyncQuoBill(
            codUser, position, codCompany),
      ),
    ]);

    // 📝 Guardar Log
    onStep?.call("Guardando registro de sincronización...");
    final log = SyncLogCtr();
    await log.saveLogtoUser(
      codUser,
      'Sync-general',
      'Sincronización finalizada',
    );
  }

  /// Maneja errores de cada paso por separado
  Future<void> _safeCall(
      String stepName, Future<ResponseError> Function() apiCall) async {
    try {
      final resp = await apiCall();
      if (resp.error != 0) {
        throw Exception("[$stepName] ${resp.description}");
      }
    } catch (e) {
      print("❌ Error durante '$stepName': $e");
      rethrow;
    }
  }
}
