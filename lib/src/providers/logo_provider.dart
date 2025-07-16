import 'package:flutter/material.dart';

class LogoProvider extends ChangeNotifier {
  String? _logoPath;

  String? get logoPath => _logoPath;

  void setLogo(String? path) {
    _logoPath = path;
    notifyListeners(); // Notifica a los widgets que escuchan
  }
}
