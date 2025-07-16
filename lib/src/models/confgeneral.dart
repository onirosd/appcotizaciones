import 'dart:convert';

class ConfGeneral {
  int codconfigGeneral;
  String strCodOperation;
  String strDescription;
  int flgEnabled;
  String pivot1;
  String pivot2;
  String pivot3;
  int codUser;
  int flgSync;

  ConfGeneral({
    required this.codconfigGeneral,
    required this.strCodOperation,
    required this.strDescription,
    required this.flgEnabled,
    required this.pivot1,
    required this.pivot2,
    required this.pivot3,
    required this.codUser,
    required this.flgSync,
  });

  Map<String, dynamic> toMap() {
    return {
      'codconfigGeneral': codconfigGeneral,
      'strCodOperation': strCodOperation,
      'strDescription': strDescription,
      'flgEnabled': flgEnabled,
      'pivot1': pivot1,
      'pivot2': pivot2,
      'pivot3': pivot3,
      'codUser': codUser,
      'flgSync': flgSync,
    };
  }

  factory ConfGeneral.fromMap(Map<String, dynamic> map) {
    return ConfGeneral(
      codconfigGeneral: map['codconfigGeneral'], // Obligatorio
      strCodOperation:
          map['strCodOperation'] ?? '', // Usa cadena vacía si no está presente
      strDescription: map['strDescription'] ?? '', // Usa cadena vacía si falta
      flgEnabled: map['flgEnabled'] ?? 0, // Usa 0 si no está presente
      pivot1: map['pivot1'] ?? '', // Usa cadena vacía si falta
      pivot2: map['pivot2'] ?? '', // Usa cadena vacía si falta
      pivot3: map['pivot3'] ?? '', // Usa cadena vacía si falta
      codUser: map['codUser'] ?? 0, // Usa 0 si no está presente
      flgSync: map['flgSync'] ?? 0, // Usa 0 si no está presente
    );
  }

  String toJson() => json.encode(toMap());

  factory ConfGeneral.fromJson(String source) =>
      ConfGeneral.fromMap(json.decode(source));
}
