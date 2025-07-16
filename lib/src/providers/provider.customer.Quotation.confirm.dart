import 'dart:convert';
import 'dart:io' as io2;

import 'package:appcotizaciones/src/constants/RepQuotation.dart';
import 'package:appcotizaciones/src/constants/listController.dart';
import 'package:appcotizaciones/src/models/billing.dart';
import 'package:appcotizaciones/src/models/currency.dart';
import 'package:appcotizaciones/src/models/customer.dart';
import 'package:appcotizaciones/src/models/delivery_time_model.dart';
import 'package:appcotizaciones/src/models/delivery_type_model.dart';
import 'package:appcotizaciones/src/models/payCondition.dart';
import 'package:appcotizaciones/src/models/pay_condition_model.dart';
import 'package:appcotizaciones/src/models/product_model.dart';
import 'package:appcotizaciones/src/models/quotation_model.dart';
import 'package:appcotizaciones/src/models/quotation_product_model.dart';
import 'package:appcotizaciones/src/models/quotationplusproducst.dart';
import 'package:appcotizaciones/src/models/report_quotation.dart';
import 'package:appcotizaciones/src/modelscrud/company_crt.dart';
import 'package:appcotizaciones/src/modelscrud/currency_crt.dart';
import 'package:appcotizaciones/src/modelscrud/deliveryTime_crt.dart';
import 'package:appcotizaciones/src/modelscrud/deliveryType_crt.dart';
import 'package:appcotizaciones/src/modelscrud/paycondition_crt.dart';
import 'package:appcotizaciones/src/modelscrud/product_crt.dart';
import 'package:appcotizaciones/src/modelscrud/quotationProduct_crt.dart';
import 'package:appcotizaciones/src/modelscrud/quotation_crt.dart';
import 'package:appcotizaciones/src/providers/changes.notifier.dart';
import 'package:appcotizaciones/src/screens/product_add_form.dart';
import 'package:appcotizaciones/src/search/search_customers.dart';
import 'package:appcotizaciones/src/utils/size_config.dart';
import 'package:appcotizaciones/src/widgets/appbars2.dart';
import 'package:appcotizaciones/src/widgets/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../models/company.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CustomerQuotationConfirm extends StatefulWidget {
  CustomerQuotationConfirm({Key? key}) : super(key: key);
  //final Map data;
  //CustomerQuotationConfirm({required this.data});

  @override
  _CustomerQuotationConfirmState createState() =>
      _CustomerQuotationConfirmState();
}

class _CustomerQuotationConfirmState extends State<CustomerQuotationConfirm> {
  //late Quotation _quotation0;
  //late List<QuotationProduct> _quotationproducts0;

  String _LoginUser = '';
  int _CodUser = 0;
  String _Company = '';
  String _CodCompany = '';

  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;
  bool _isInternet = true;

  /*Integration */

  DateTime selectedDate = DateTime.now();
  final DateFormat format = DateFormat("yyyy-MM-dd");
  late String dropdownvalue;

  bool loading = true, loader = false;

  List<Product> products = <Product>[];
  List<Currency> currency = <Currency>[];
  List<DeliveryType> deliveryTypes = <DeliveryType>[];
  List<DeliveryTime> deliveryTimes = <DeliveryTime>[];
  List<PayCondition> payConditions = <PayCondition>[];

  late Currency selectedCurrency;
  late DeliveryType selectedDeliveryType;
  late DeliveryTime selectedDeliveryTimes;
  late PayCondition selectedPayConditions;

  late Quotation _quotat_final;
  List<QuotationProduct> _listproduct_final = [];
  late Customer _cust;
  String _salesperson = "";

  List<PayCondition> _out_paycondition = [];
  List<DeliveryTime> _out_deliverytime = [];
  List<DeliveryType> _out_deliverytype = [];
  List<Currency> _out_currency = [];

  // CONTROLLERS
  TextEditingController customerController = TextEditingController();
  TextEditingController vendedorController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController socialController = TextEditingController();
  TextEditingController observationController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController lgvController = TextEditingController();

  GlobalKey<FormState> _key = GlobalKey<FormState>();

  /*Integration */
  @override
  void initState() {
    super.initState();

    //_quotation0 = widget.data['quotation'];
    //_quotationproducts0 = widget.data['quotationproducts'];

    dateController.text = format.format(DateTime.now());
    //customerController.text = "3453453";

    SharedPreferences.getInstance().then((res) {
      setState(() {
        _LoginUser = res.getString("usuario") ?? '';
        _Company = res.getString("empresa") ?? '';
        _CodUser = res.getInt("codigo") ?? 0;
        _CodCompany = res.getString("codcompany") ?? '';
      });
    });

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (this.mounted) {
        setState(() => _source = source);
      }
    });

    getValues();
  }

  Future getValues() async {
    CurrencyCtr currencycrt = new CurrencyCtr();
    DeliveryTypeCtr deliverytypecrt = new DeliveryTypeCtr();
    DeliveryTimeCrt deliverytimecrt = new DeliveryTimeCrt();
    PayConditionCtr payConditionCtr = new PayConditionCtr();
    ProductCtr productcrt = new ProductCtr();

    List<Currency> resCurrency = await currencycrt.getDataCurrency();
    List<DeliveryType> resDeliveryTypes =
        await deliverytypecrt.getDataDeliveryTipe();
    List<DeliveryTime> resDeliveryTimes =
        await deliverytimecrt.getDataDeliveryTime();
    List<PayCondition> resPaymentConditions =
        await payConditionCtr.getDataPayCondition();
    List<Product> allProducts = await productcrt.getDataProduct();
    // List<QuotationProduct> quotaionProducts = await DBProvider.db.getQuotationProducts();
    try {
      setState(() {
        currency = resCurrency;
        deliveryTypes = resDeliveryTypes;
        deliveryTimes = resDeliveryTimes;
        payConditions = resPaymentConditions;
        products = allProducts;
        loading = false;
      });
      // if(quotaionProducts.isNotEmpty){
      //   Future.forEach(quotaionProducts, (element) => setState((){
      //     ListItems.listItems.add(element);
      //   }));
      //   setState(() {
      //     loading = false;
      //   });
      // } else {
      //   setState(() {
      //     loading = false;
      //   });
      // }
    } catch (err) {
      print(err);
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<bool?> showWarning(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
                'Cuidado : Se perderan los datos ingresados !! \n ¿ Desea Salir ?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Si'),
              ),
            ],
          ));

  Future<int> fordelayed() async {
    return await Future.delayed(Duration(seconds: 1), () => 1);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datamap =
        ModalRoute.of(context)!.settings.arguments as QuotationPlusProducts;
    List<QuotationProduct> listproduct = datamap.listproduct;
    Customer cust = datamap.customer;
    String salesperson = datamap.salesperson;
    Quotation quotat = datamap.quotat;

    _cust = cust;
    _quotat_final = quotat;
    _listproduct_final = listproduct;
    _salesperson = salesperson;

    return WillPopScope(
      onWillPop: () async {
        bool? showpopup = await showWarning(context);
        if (showpopup == true) {
          Navigator.pushNamedAndRemoveUntil(
              context, 'listQuotas', (route) => false,
              arguments: cust);
        }
        //  _moveToScreen2(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBars(
          loginuser: _LoginUser,
          company: _Company,
          context: context,
          isOnline: _isInternet,
        ),
        body: FutureBuilder(
            future: fordelayed(),
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                _isInternet =
                    _source.keys.toList()[0] == ConnectivityResult.none
                        ? false
                        : true;

                _out_paycondition = payConditions
                    .where((o) => o.codPayCondition == quotat.payId)
                    .toList();

                _out_deliverytime = deliveryTimes
                    .where((o) => o.id == quotat.deliveryTimeId)
                    .toList();

                _out_deliverytype = deliveryTypes
                    .where((o) => o.id == quotat.deliveryTypeId)
                    .toList();

                _out_currency = currency
                    .where((o) => o.codCurrency == quotat.currencyId)
                    .toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        alignment: Alignment.center,
                        child: Form(
                          key: _key,
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                "CONFIRMACION DE COTIZACIÓN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 21.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding:
                                    EdgeInsets.only(left: 12.0, right: 12.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: quotat.state == 1
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                height: 20,
                                child: Container(
                                  child: Text(
                                    quotat.state == 1
                                        ? "Procesado"
                                        : "Pre - Procesado",
                                    textScaleFactor: 1,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = quotat.dateQuotation.toString(),
                                decoration: InputDecoration(labelText: "Fecha"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = cust.numRucCustomer.toString(),
                                decoration:
                                    InputDecoration(labelText: "Doc. Fiscal"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = quotat.nameBusiness.toString(),
                                decoration:
                                    InputDecoration(labelText: "Razon Social"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = salesperson,
                                decoration:
                                    InputDecoration(labelText: "Vendedor"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = _out_paycondition[0].strDescription!,
                                decoration: InputDecoration(
                                    labelText: "Condicion de Pago"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = _out_deliverytype[0].description,
                                decoration: InputDecoration(
                                    labelText: "Tipo de Entrega"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = _out_deliverytime[0].description,
                                decoration: InputDecoration(
                                    labelText: "Tiempo de Entrega"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              if (listproduct.isNotEmpty)
                                Container(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxHeight: 200, minHeight: 200),
                                    child: Scrollbar(
                                      // isAlwaysShown: true,
                                      child: ListView.separated(
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: listproduct.length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    listproduct[index]
                                                        .product_name
                                                        .toString()
                                                        .trimRight()
                                                        .trimLeft(),
                                                    style:
                                                        TextStyle(fontSize: 12),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Text(
                                                      listproduct[index]
                                                          .sub_total
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(
                                          height: 1.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = quotat.observation.toString(),
                                decoration:
                                    InputDecoration(labelText: "Observaciones"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = _out_currency[0]
                                      .strDescription
                                      .toString(),
                                decoration:
                                    InputDecoration(labelText: "Moneda"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = quotat.subTotal.toString(),
                                decoration:
                                    InputDecoration(labelText: "Sub Total"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = quotat.lgv.toString(),
                                decoration: InputDecoration(labelText: "IGV"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                //enabled: false,
                                readOnly: true,
                                controller: TextEditingController()
                                  ..text = quotat.total.toString(),
                                decoration: InputDecoration(labelText: "Total"),
                                // onSaved: (value) {
                                // customer.numRut = value.toString();
                                //},
                              ),
                              const SizedBox(height: 30),
                              OutlinedButton(
                                style: quotat.state == 0
                                    ? ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 20),
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      )
                                    : ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 50, vertical: 20),
                                        textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white),
                                      ),
                                // style: wi,
                                onPressed: () async {
                                  final msg_confirm = SnackBar(
                                      content: Text(
                                          ' La Cotización se registro con exito !'));
                                  final msg_wait = SnackBar(
                                      content: Text('Espere un momento....'));
                                  final msg_err = SnackBar(
                                      content: Text(
                                          'Tuvimos un error en el registro !! , Intentelo de nuevo.'));

                                  FocusScope.of(context).unfocus();
                                  String latitude = "";
                                  String longitude = "";

                                  if (_key.currentState!.validate()) {
                                    try {
                                      Position coordenadas =
                                          await _getGeoLocationPosition();
                                      latitude =
                                          coordenadas.latitude.toString();
                                      longitude =
                                          coordenadas.longitude.toString();
                                    } catch (e) {
                                      print(
                                          "Tenemos un error : " + e.toString());
                                    }

                                    QuotationCrt quotationCrt =
                                        new QuotationCrt();
                                    QuotationProductCrt quotationproductCrt =
                                        new QuotationProductCrt();

                                    //var val = 0;

                                    try {
                                      DateTime now = DateTime.now();
                                      String dateAndMoment =
                                          DateFormat('yyMMddkkmm').format(now);

                                      var cod = quotat.customerId.toString() +
                                          dateAndMoment;
                                      quotat.latitude = latitude;
                                      quotat.longitude = longitude;
                                      quotat.id = cod;

                                      final quotationid = await quotationCrt
                                          .insertQuotation(quotat);

                                      if (quotationid > 0) {
                                        int corre = 1;
                                        await Future.forEach(listproduct,
                                            (QuotationProduct element) async {
                                          element.quotation_id = quotat.id;
                                          element.id = quotat.id.toString() +
                                              corre.toString();

                                          await quotationproductCrt
                                              .insertQuotationProduct(element);
                                          // QuotationProduct res = await DBProvider.db.getSingleQuotationProducts(newId);
                                          corre = corre + 1;
                                        });

                                        /********************** Generamos PDF ******************/
                                        final directory =
                                            await getExternalStorageDirectory();
                                        CompanyCtr comp = new CompanyCtr();
                                        List<Company> arrCompany =
                                            await comp.getCompany(_CodCompany);

                                        ReportDataQuotation dataquotation =
                                            new ReportDataQuotation(
                                                path: directory!.path,
                                                codCompany: _CodCompany,
                                                quotationfin: _quotat_final,
                                                listprodquotationfin:
                                                    _listproduct_final,
                                                customer: _cust,
                                                salesperson: _salesperson,
                                                paycondition:
                                                    _out_paycondition[0]
                                                        .strDescription
                                                        .toString(),
                                                deliverytype:
                                                    _out_deliverytype[0]
                                                        .description
                                                        .toString(),
                                                deliverytime:
                                                    _out_deliverytime[0]
                                                        .description
                                                        .toString(),
                                                currency: _out_currency[0]
                                                    .codCurrency!,
                                                currencyName:
                                                    _out_currency[0].strName!,
                                                company: arrCompany[0],
                                                cur: _out_currency[0]);

                                        Reports reports = new Reports();
                                        reports.reportsEnableds(dataquotation);

                                        /********************** Generamos PDF ******************/
                                      }

                                      // print(quotationid);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(msg_confirm);
                                      Navigator.pushNamedAndRemoveUntil(context,
                                          'listQuotas', (route) => false,
                                          arguments: cust);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(e.toString())));
                                    }
                                  }
                                },
                                child: Row(
                                  textBaseline: TextBaseline.ideographic,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 30.0,
                                    ),
                                    Icon(
                                      Icons.request_page_outlined,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text(
                                      quotat.state == '1'
                                          ? 'Imprimir Procesado'
                                          : 'Imprimir Pre-Procesado',
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
            }),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1),
              label: 'Agregar',
              backgroundColor: Colors.green,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_search),
              label: 'Buscar',
              backgroundColor: Colors.green,
            ),
          ],
          currentIndex: 1,
          // selectedItemColor: Colors.blue,
          onTap: (int page) async {
            if (page == 2) {
              await showSearch(
                context: context,
                delegate: CustomerSearchDelegate(),
              );
            }
            if (page == 1) {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'customerNew', (route) => false);
            }
            if (page == 0) {
              Navigator.pushNamedAndRemoveUntil(
                  context, 'home', (route) => false);
            }
          },
        ),
      ),
    );
  }

  List<Widget> userTile() {
    final space = SizedBox(height: 8);
    return [
      Container(
        padding: EdgeInsets.all(20),
        //width: SizeConfig.screenWidth,
        color: Colors.grey.shade600,
        child: const Text(
          "Cotizaciones Agregar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      space,
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        // ignore: prefer_const_literals_to_create_immutables
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Icon(
                  Icons.account_circle,
                  size: 60,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                regularText('Cliente: Juan Tello'),
                regularText('Rubro: Ferretria'),
                regularText('Doc. Fiscal: +2234324'),
              ],
            ),
          ),
        ],
      ),
      space,
      space,
      space,
    ];
  }
}
