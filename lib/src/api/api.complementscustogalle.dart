import 'dart:convert';

import 'package:appcotizaciones/src/models/sysSendEmpresa.dart';
import 'package:appcotizaciones/src/modelscrud/complementscustomergallery_crt.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:appcotizaciones/src/config/variables.dart';
import 'package:appcotizaciones/src/helpers/database_helper.dart';
import 'package:appcotizaciones/src/models/complementsCustoGalle.dart';
import 'package:appcotizaciones/src/models/customer.dart';
import 'package:appcotizaciones/src/models/gallery.dart';
import 'package:appcotizaciones/src/models/galleryDetail.dart';
import 'package:appcotizaciones/src/models/galleryDetailSubtipos.dart';
import 'package:appcotizaciones/src/models/galleryExport.dart';
import 'package:appcotizaciones/src/models/response_error.dart';

class ComplementsCustomerGalleries {
  DatabaseHelper con = new DatabaseHelper();

  var url_complements =
      DIR_URL + "Appstock/controller/services/listarCustomerGallery.php";
  var url_upload_galleries =
      DIR_URL + "Appstock/controller/services/insertarGalleries.php";

  Future<List<ComplementsCustoGalle>> downloadComplementsCustomerGalleries(
      int codempresa, int codUser) async {
    send_empresa reqe =
        new send_empresa(codEmpresa: codempresa, codUser: codUser);

    final payload = jsonEncode(reqe);
    try {
      final response = await http.post(
        Uri.parse(url_complements),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept-Encoding': 'gzip'
        },
        body: payload,
      );

      final isGzip =
          response.headers['content-encoding']?.contains('gzip') ?? false;
      final bytes = response.bodyBytes;
      final String decodedJson = utf8.decode(response.bodyBytes);
      final parsedJson = json.decode(decodedJson);

      if (response.statusCode == 200) {
        print(">> entramos");
        // final List<dynamic> data = jsonDecode(response.body);
        // return data.map((e) => ComplementsCustoGalle.fromMap(e)).toList();
        if (parsedJson is List && parsedJson.isNotEmpty) {
          print(
              "Terminamos Download de Customer, Galleries y llevamos esto a sqlite");
          return [ComplementsCustoGalle.fromMap(parsedJson[0])];
          // return [];
        }

        if (parsedJson is Map && parsedJson.containsKey('error')) {
          print("Error desde API: ${parsedJson['description']}");
          return [];
        }

        print("Estructura inesperada: $parsedJson");
        return [];
      } else {
        print("Error HTTP ${response.statusCode}:");
        print(decodedJson);
        return [];
      }
    } catch (e) {
      print("Excepción al obtener complementos: $e");
      return [];
    }
  }

  Future<ResponseError> batchInsertComplementscustogalle(
      List<ComplementsCustoGalle> complements) async {
    // var dbconn = await con.db;
    // Batch batch = dbconn.batch();
    int estado = 0;
    ResponseError responseerror =
        new ResponseError(description: '', error: 1, success: 0);

    ComplementsCustomerGalleriesCrud crud =
        new ComplementsCustomerGalleriesCrud();

    responseerror = await crud.insertAllComplements(complements);
    return responseerror;
  }

  Future<ResponseError> uploadGalleriesExport(
      List<GalleryExport> listExport) async {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsondata =
        encoder.convert(listExport).toString(); //json.encode(listExport);

    // print(jsondata);

    // ResponseError error =
    //     new ResponseError(description: "", error: 0, success: 0);
    final response = await http.post(
      Uri.parse(url_upload_galleries),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsondata,
    );

    final error = ResponseError(description: '', error: 1, success: 0);

    if (response.statusCode == 200) {
      final Map<String, dynamic> map = jsonDecode(response.body);
      error.description = map['description'];
      error.error = map['cant'] > 0 ? 2 : 1;
      // result.success = map['error'] == 0 ? 1 : 0;
    } else {
      error.description = response.body.toString();
    }

    return error;
  }
}
