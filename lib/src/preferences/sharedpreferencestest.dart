import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesTest {
  /// Instantiation of the SharedPreferences library
  static final String _user = "usuario";
  static final String _company = "empresa";
  static final String _codCompany = "codcompany";
  static final String _codList = "codlist";
  static final String _codUser = "codigo";
  static final String _isInternet = "internet";
  static final String _position = "posicion";
  static final String _logopath = "";
  static final String _almacen = "almacen";
  static final String _isFirstRun =
      "isFirstRun"; // Nuevo flag para controlar la primera ejecución

  /// Método que verifica si es la primera ejecución
  Future<bool> isFirstRun() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstRun) ??
        true; // Devuelve true si no existe el flag
  }

  /// Método para marcar que ya no es la primera ejecución
  Future<bool> setFirstRunCompleted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isFirstRun, false);
  }

  /// ------------------------------------------------------------
  /// Métodos existentes (no se modifican)
  /// ------------------------------------------------------------
  Future<String?> getAlmacen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getString(_almacen);
    });
  }

  Future<String?> getPosition() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getString(_position);
    });
  }

  Future<String?> getCodList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getString(_codList);
    });
  }

  Future<String?> getCodCompany() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getString(_codCompany);
    });
  }

  Future<String?> getLogoPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getString(_logopath);
    });
  }

  Future<String?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getString(_user);
    });
  }

  Future<String?> getCompany() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getString(_company);
    });
  }

  Future<bool?> getInternet() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getBool(_isInternet);
    });
  }

  Future<int?> getcodUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return Future.delayed(Duration(seconds: 1), () async {
      return await prefs.getInt(_codUser);
    });
  }

  Future<bool> setAlmacen(String codAlmacen) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_almacen, codAlmacen);
  }

  Future<bool> setCodCompany(String codCompany) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_codCompany, codCompany);
  }

  Future<bool> setLogoPath(String logoPath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_logopath, logoPath);
  }

  Future<bool> setCodList(String codList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_codList, codList);
  }

  Future<bool> setUser(String user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_user, user);
  }

  Future<bool> setCompany(String company) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_company, company);
  }

  Future<bool> setInternet(bool internet) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isInternet, internet);
  }

  Future<bool> setcodUser(int codUser) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(_codUser, codUser);
  }

  Future<bool> setPosition(String position) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_position, position);
  }
}
