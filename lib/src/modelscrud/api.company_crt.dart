import 'package:appcotizaciones/src/api/api.autentication.dart';
import 'package:appcotizaciones/src/api/api.company.dart';
import 'package:appcotizaciones/src/models/autentication.dart';
import 'package:appcotizaciones/src/models/company.dart';
import 'package:appcotizaciones/src/models/lastCompany.dart';
import 'package:appcotizaciones/src/modelscrud/autentication_crt.dart';
import 'package:appcotizaciones/src/modelscrud/company_crt.dart';
import 'package:appcotizaciones/src/modelscrud/lastCompany_crud.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';

class ApiCompany {
  Future<int> syncAwaitingfromApi() async {
    Future.delayed(Duration(seconds: 0));
    return 3;
  }

  Future<void> updateLogoPath(int codCompany, String newPath) async {
    CompanyCtr crt = CompanyCtr();

    // Obtener la empresa por su codCompany
    Company? empresa = await crt.getCompanyById(codCompany);

    if (empresa != null) {
      // Crear una copia actualizada con el nuevo path del logo
      Company empresaActualizada = empresa.copyWith(str_logopath: newPath);

      // Ejecutar el update
      await crt.updateCompany(empresaActualizada);
    } else {
      print("⚠️ Empresa con codCompany $codCompany no encontrada.");
    }
  }

  Future<List<Company>> syncCompanyfromApi() async {
    CompanyApiProvider api = new CompanyApiProvider();
    CompanyCtr crt = new CompanyCtr();
    List<int> devol = [];

    // Obtenemos los usuarios de autenticacion

    List<Company> data = await api.getAllCompanys();
    int contador = data.length;
    //print(contador);

    if (contador > 0) {
      List<Company> empresasLocales = await crt.getAllCompany();
      Map<int, String> logosLocales = {
        for (var c in empresasLocales) c.codCompany!: c.str_logopath ?? ''
      };

// Elimina solo si es necesario, o reemplaza de uno en uno
      await crt.deleteAllCompany();

      Company compa = Company(codCompany: 0, strDesCompany: 'Elegir Empresa');
      await crt.insertCompany(compa);

      for (var company in data) {
        // Si existe un logo local, se lo volvemos a asignar
        if (logosLocales.containsKey(company.codCompany)) {
          company.str_logopath = logosLocales[company.codCompany];
        }
        await crt.insertCompany(company);
      }
    }

    List<Company> companies = await crt.getAllCompany();

    return companies;
  }

  // Future<List<LastCompany>> getlastCompany() async {
  //   LastCompanyCrt crt = new LastCompanyCrt();
  //   crt.getLastCompany();
  //   try {
  //     crt.
  //   } catch (e) {
  //   }
  // }
}
