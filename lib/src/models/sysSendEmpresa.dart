import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class send_empresa {
  int codEmpresa;
  int codUser;

  send_empresa({
    required this.codEmpresa,
    required this.codUser,
  });

  send_empresa copyWith({
    int? codEmpresa,
    int? codUser,
  }) {
    return send_empresa(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codUser: codUser ?? this.codUser,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'codEmpresa': codEmpresa});
    result.addAll({'codUser': codUser});

    return result;
  }

  factory send_empresa.fromMap(Map<String, dynamic> map) {
    return send_empresa(
      codEmpresa: map['codEmpresa']?.toInt() ?? 0,
      codUser: map['codUser']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'codEmpresa': codEmpresa,
        'codUser': codUser,
      };

  factory send_empresa.fromJson(String source) =>
      send_empresa.fromMap(json.decode(source));

  @override
  String toString() =>
      'send_empresa(codEmpresa: $codEmpresa, codUser: $codUser)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is send_empresa &&
        other.codEmpresa == codEmpresa &&
        other.codUser == codUser;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codUser.hashCode;
}
