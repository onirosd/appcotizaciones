import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionUtil {
  // Singleton para mantener una única instancia
  static final ConnectionUtil _singleton = ConnectionUtil._internal();
  ConnectionUtil._internal();

  // Método para obtener la instancia
  static ConnectionUtil getInstance() => _singleton;

  // Estado actual de la conexión
  bool hasConnection = false;

  // StreamController para notificar cambios en la conexión
  StreamController connectionChangeController = StreamController.broadcast();

  // flutter_connectivity
  final Connectivity _connectivity = Connectivity();

  void initialize() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

  // Listener de flutter_connectivity
  void _connectionChange(ConnectivityResult result) {
    hasInternetConnection();
  }

  // Stream para suscribirse a cambios en la conexión
  Stream get connectionChange => connectionChangeController.stream;

  Future<bool> hasInternetConnection() async {
    bool previousConnection = hasConnection;

    var connectivityResult = await _connectivity.checkConnectivity();
    // Verificar si el dispositivo está conectado a una red móvil o Wi-Fi
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // Verificar si hay conexión a internet
      hasConnection = await InternetConnectionChecker().hasConnection;
    } else {
      // No hay conexión a redes móviles ni Wi-Fi
      hasConnection = false;
    }

    // Si el estado de conexión cambió, notificar a los listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}
