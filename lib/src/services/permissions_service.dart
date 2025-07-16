import 'package:permission_handler/permission_handler.dart';
import 'package:appcotizaciones/src/preferences/sharedpreferencestest.dart';

class PermissionService {
  final SharedPreferencesTest _preferences = SharedPreferencesTest();

  /// Solicita permisos esenciales si es la primera ejecución
  Future<void> requestPermissionsOnFirstInstall() async {
    // Verifica si es la primera ejecución
    final isFirstRun = await _preferences.isFirstRun();

    if (isFirstRun) {
      // Solicita los permisos necesarios
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.camera,
        Permission.storage,
        if (await Permission.photos.isGranted) Permission.photos,
      ].request();

      // Maneja permisos denegados si es necesario
      if (statuses[Permission.location]!.isDenied) {
        print("Permiso de ubicación denegado.");
      }
      if (statuses[Permission.camera]!.isDenied) {
        print("Permiso de cámara denegado.");
      }
      if (statuses[Permission.storage]!.isDenied) {
        print("Permiso de almacenamiento denegado.");
      }

      // Marca que ya no es la primera ejecución
      await _preferences.setFirstRunCompleted();
    }
  }
}
