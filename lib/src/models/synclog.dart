import 'dart:convert';

class SyncLog {
  int codLog;
  int dteSyncDate;
  String strDay;
  String strhour;
  int codUser;
  String seccion;
  String strMessage;

  SyncLog(
      {required this.codLog,
      required this.dteSyncDate,
      required this.strDay,
      required this.strhour,
      required this.codUser,
      required this.seccion,
      required this.strMessage});

  Map<String, dynamic> toMap() {
    return {
      'codLog': codLog,
      'dteSyncDate': dteSyncDate,
      'strDay': strDay,
      'strhour': strhour,
      'codUser': codUser,
      'seccion': seccion,
      'strMessage': strMessage,
    };
  }

  factory SyncLog.fromMap(Map<String, dynamic> map) {
    return SyncLog(
      codLog: map['codLog'], // Obligatorio
      dteSyncDate: map['dteSyncDate'] ?? 0, // Usa 0 si falta
      strDay: map['strDay'] ?? '', // Usa cadena vacía si falta
      strhour: map['strhour'] ?? '', // Usa cadena vacía si falta
      codUser: map['codUser'] ?? 0, // Usa 0 si falta
      seccion: map['seccion'] ?? '', // Usa cadena vacía si falta
      strMessage: map['strMessage'] ?? '', // Usa cadena vacía si falta
    );
  }

  String toJson() => json.encode(toMap());

  factory SyncLog.fromJson(String source) =>
      SyncLog.fromMap(json.decode(source));
}
