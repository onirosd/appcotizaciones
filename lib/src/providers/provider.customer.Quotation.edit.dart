import 'dart:convert';
import 'dart:io' as io2;

import 'package:appcotizaciones/src/constants/RepQuotation.dart';
import 'package:appcotizaciones/src/constants/listController.dart';
import 'package:appcotizaciones/src/constants/listControllerEdit.dart';
import 'package:appcotizaciones/src/constants/listProdModify.dart';
import 'package:appcotizaciones/src/models/currency.dart';
import 'package:appcotizaciones/src/models/customer.dart';
import 'package:appcotizaciones/src/models/delivery_time_model.dart';
import 'package:appcotizaciones/src/models/delivery_type_model.dart';
import 'package:appcotizaciones/src/models/payCondition.dart';
import 'package:appcotizaciones/src/models/product_model.dart';
import 'package:appcotizaciones/src/models/quotation_model.dart';
import 'package:appcotizaciones/src/models/quotation_product_model.dart';
import 'package:appcotizaciones/src/models/quotationplusproducst.dart';
import 'package:appcotizaciones/src/models/report_quotation.dart';
import 'package:appcotizaciones/src/models/selcurrency.dart';
import 'package:appcotizaciones/src/modelscrud/currency_crt.dart';
import 'package:appcotizaciones/src/modelscrud/deliveryTime_crt.dart';
import 'package:appcotizaciones/src/modelscrud/deliveryType_crt.dart';
import 'package:appcotizaciones/src/modelscrud/paycondition_crt.dart';
import 'package:appcotizaciones/src/modelscrud/product_crt.dart';
import 'package:appcotizaciones/src/modelscrud/quotationProduct_crt.dart';
import 'package:appcotizaciones/src/modelscrud/quotation_crt.dart';
import 'package:appcotizaciones/src/providers/changes.notifier.dart';
import 'package:appcotizaciones/src/screens/product_add_edit_form.dart';
import 'package:appcotizaciones/src/screens/product_edit_edit_form.dart';

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

import 'package:appcotizaciones/src/screens/product_edit_form.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../models/company.dart';
import '../modelscrud/company_crt.dart';

class CustomerQuotationEdit extends StatefulWidget {
  CustomerQuotationEdit({Key? key}) : super(key: key);

  @override
  _CustomerQuotationEditState createState() => _CustomerQuotationEditState();
}

class _CustomerQuotationEditState extends State<CustomerQuotationEdit> {
  String _LoginUser = '';
  int _CodUser = 0;
  String _Company = '';
  String _CodCompany = '';
  late Customer _customer;

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

  Currency selectedCurrency = new Currency(codCurrency: 0, strDescription: '');
  late DeliveryType selectedDeliveryType;
  late DeliveryTime selectedDeliveryTimes;
  late PayCondition selectedPayConditions;

  // CONTROLLERS
  TextEditingController customerController = TextEditingController();
  TextEditingController vendedorController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController socialController = TextEditingController();
  TextEditingController observationController = TextEditingController();
  TextEditingController subTotalController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController lgvController = TextEditingController();

  Company datacompany = new Company(
      codCompany: 0,
      codCurrency: '',
      numImpuesto: '',
      strAddress: '',
      strDesCompany: '',
      strLogo: '',
      strPhone: '',
      strPrintFormat: '',
      strRucCompany: '');

  late int _stateQuotation = 0;

  GlobalKey<FormState> _key = GlobalKey<FormState>();

  List<QuotationProduct> _updQuotationProducts = [];
  late Quotation _updQuotation;
  late String _updSalesperson;

  PayCondition _payed =
      new PayCondition(codPayCondition: 1, strDescription: "Contado");

  int _contador = 0;
  int _bloquearCurrency = 0;

  /*Integration */

  void initState() {
    super.initState();

    dateController.text = format.format(DateTime.now());
    //customerController.text = "3453453";

    SharedPreferences.getInstance().then((res) {
      setState(() {
        _LoginUser = res.getString("usuario") ?? '';
        _Company = res.getString("empresa") ?? '';
        _CodUser = res.getInt("codigo") ?? 0;
        _CodCompany = res.getString("codcompany") ?? '';
      });

      getCompany(res.getString("codcompany") ?? '0');
    });

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (this.mounted) {
        setState(() => _source = source);
      }
    });

    getValues();
  }

  Future getCompany(String codCompany) async {
    // ProductStockCtr productStockCtr = ProductStockCtr();
    // int codMoneda = ListItems.listmoneda[0].codmoneda;
    //ProductCtr productcrt = ProductCtr();
    CompanyCtr com = new CompanyCtr();
    try {
      List<Company> listCompany = await com.getCompany(codCompany);

      setState(() {
        datacompany = listCompany[0];
        ListItemsEdit.listIgv.add("");
        ListItemsEdit.listIgv[0] = datacompany.numImpuesto.toString();
      });
    } catch (err) {
      print(err);
    }
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

  Future<bool?> showWarning(BuildContext context) async => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
                'Se perderan los cambios !! \r, ¿ Quieres salir de la edición ?'),
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final customer = ModalRoute.of(context)!.settings.arguments as Customer;
    final quotationplusproducts =
        ModalRoute.of(context)!.settings.arguments as QuotationPlusProducts;

    ListItemsEdit.listIgv.add(datacompany.numImpuesto.toString());

    _customer = quotationplusproducts.customer;
    _updQuotationProducts = quotationplusproducts.listproduct;
    _updQuotation = quotationplusproducts.quotat;
    _updSalesperson = quotationplusproducts.salesperson;

    QuotationCrt crt = new QuotationCrt();

    //List<SelectQuotation> listQuotations =
    //  crt.getSelectQuotationByCustomer(customer.codCustomer.toString())
    //    as List<SelectQuotation>;

    _isInternet =
        _source.keys.toList()[0] == ConnectivityResult.none ? false : true;

    return WillPopScope(
      onWillPop: () async {
        bool? showpopup = await showWarning(context);
        if (showpopup == true) {
          Navigator.pushNamedAndRemoveUntil(
              context, 'listQuotas', (route) => false,
              arguments: _customer);
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...userTile(),
              if (loading)
                Center(
                    child: CircularProgressIndicator(
                  color: Colors.blue,
                )),
              if (!loading)
                quoteAffForm(_customer, _updQuotationProducts, _updQuotation,
                    _updSalesperson)
            ],
          ),
        ),
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
      space,
      // Container(
      //   padding: EdgeInsets.all(20),
      //   //width: SizeConfig.screenWidth,
      //   color: Colors.grey.shade600,
      //   child: const Text(
      //     "Cotizaciones Agregar",
      //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      //   ),
      // ),
      // space,
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
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                regularText('Cliente: ' + _customer.strName.toString()),
                // regularText('Rubro: Ferretria'),
                regularText('Doc. Fiscal: ${_customer.numRucCustomer}'),
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

  Widget quoteAffForm(
      Customer cust,
      List<QuotationProduct> updQuotationProducts,
      Quotation updQuotation,
      String updSalesperson) {
    final space = SizedBox(height: 8);

    if (_contador == 0) {
      customerController.text = cust.codCustomer.toString();
      vendedorController.text = updQuotation.customerId.toString();
      socialController.text = updQuotation.nameBusiness.toString();
      subTotalController.text = updQuotation.subTotal.toString();
      lgvController.text = updQuotation.lgv.toString();
      totalController.text = updQuotation.total.toString();
      observationController.text = updQuotation.observation.toString();

      ListItemsEdit.listmoneda.clear();
      Cmoneda n = new Cmoneda(codmoneda: updQuotation.currencyId!);
      ListItemsEdit.listmoneda.add(n);

      ListItemsEdit.listItems.clear();
      ListItemsEdit.listItems.addAll(updQuotationProducts);
      _contador = _contador + 1;

      if (ListItemsEdit.listItems.length > 0) {
        _bloquearCurrency = 1;
      }
    }

    return Form(
      key: _key,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            regularText('Fecha'),
            // textField('Pick a date', dateController, _selectDate),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Icon(
                    Icons.calendar_today,
                    size: 25, //SizeConfig.textMultiplier * 2.3,
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Text(
                    updQuotation.dateQuotation.toString(),
                  ),

                  /*DateTimeField(
                    initialValue:
                        DateTime.parse(updQuotation.dateQuotation.toString()),
                    format: format,
                    controller: dateController,
                    validator: (value) =>
                        value == null ? "Field is required!" : null,
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                  ),*/
                ),
              ],
            ),
            space,

            regularText('N* Cotizacion'),
            space,
            regularTexthide2(updQuotation.id.toString()),
            space,

            regularText('Doc. Fiscal'),
            normalField(
              hint: cust.numRucCustomer,
              controller: TextEditingController(
                  text: cust.numRucCustomer), //--customerController,
              readOnly: true,
              maxLine: 1,
              inputType: TextInputType.text,
              validator: (value) => value!.isEmpty ? "Field is empty!" : null,
            ),
            space,

            regularText('Razon Social'),
            normalField(
              controller: socialController,
              readOnly: true,
              maxLine: 1,
              inputType: TextInputType.text,
              validator: (value) => value!.isEmpty ? "Field is empty!" : null,
            ),
            space,

            regularText('Vendedor'),
            normalField(
              hint: _LoginUser.toString(),
              controller: TextEditingController(
                text: updSalesperson,
              ),
              readOnly: true,
              maxLine: 1,
              inputType: TextInputType.text,
              validator: (value) => value!.isEmpty ? "Field is empty!" : null,
            ),
            space,

            // PAYMENT CONDITIONS
            //regularText('Condicion de Pago'),

            DropdownButtonFormField(
              decoration: InputDecoration(labelText: "Condición de Pago"),
              // decoration: textInputDecoration,
              value: updQuotation.payId,

              items: payConditions.map((emap) {
                return DropdownMenuItem(
                  value:
                      emap.codPayCondition != null ? emap.codPayCondition : 0,
                  child: Text(emap.strDescription!),
                );
              }).toList(),

              onChanged: (val) async {
                //  print(val.toString() + '_________');
                if (val != null) {
                  updQuotation.payId = val as int;
                } else {
                  updQuotation.payId = 0;
                }

                //updQuotation.payId = val.
                //  setState(() {
                //   loginForm.company = val.toString();
                //});
              },
              onSaved: (newValue) => FocusScope.of(context).unfocus(),
              onTap: () => FocusScope.of(context).unfocus(),
              /*onSaved: (val) {
                                if (val != null) {
                                  billing.codBank = val as int;
                                } else {
                                  billing.codBank = 0;
                                }

                                //print('saved');
                              },*/
            ),
            //normalDropdown(payConditions, updQuotation.payId!.toInt()),

/*
            // DELIVERY TYPES
            regularText('Tipo de Entrega'),
            normalDropdown(deliveryTypes, updQuotation.deliveryTypeId!.toInt()),
            space,

            

            // DELIVERY TIMES
            regularText('Tiempo de Entrega'),
            normalDropdown(deliveryTimes, updQuotation.deliveryTimeId!.toInt()),
            space,
*/
            space,

            DropdownButtonFormField(
              decoration: InputDecoration(labelText: "Tipo de Entrega"),
              // decoration: textInputDecoration,
              value: updQuotation.deliveryTypeId,

              items: deliveryTypes.map((emap) {
                return DropdownMenuItem(
                  value: emap.id != null ? emap.id : 0,
                  child: Text(emap.description),
                );
              }).toList(),

              onChanged: (val) async {
                //  print(val.toString() + '_________');
                if (val != null) {
                  updQuotation.deliveryTypeId = val as int;
                } else {
                  updQuotation.deliveryTypeId = 0;
                }
              },
              onSaved: (newValue) => FocusScope.of(context).unfocus(),
              onTap: () => FocusScope.of(context).unfocus(),
            ),
            space,

            DropdownButtonFormField(
              decoration: InputDecoration(labelText: "Tiempo de Entrega"),
              // decoration: textInputDecoration,
              value: updQuotation.deliveryTimeId,

              items: deliveryTimes.map((emap) {
                return DropdownMenuItem(
                  value: emap.id != null ? emap.id : 0,
                  child: Text(emap.description),
                );
              }).toList(),

              onChanged: (val) async {
                //  print(val.toString() + '_________');
                if (val != null) {
                  updQuotation.deliveryTimeId = val as int;
                } else {
                  updQuotation.deliveryTimeId = 0;
                }
              },
              onSaved: (newValue) => FocusScope.of(context).unfocus(),
              onTap: () => FocusScope.of(context).unfocus(),
            ),

            space,

            DropdownButtonFormField(
              decoration: InputDecoration(labelText: "Moneda"),
              // decoration: textInputDecoration,
              value: updQuotation.currencyId,

              items: currency.map((emap) {
                return DropdownMenuItem(
                  value: emap.codCurrency != null ? emap.codCurrency : 0,
                  child: Text(emap.strDescription.toString()),
                );
              }).toList(),

              onChanged: _bloquearCurrency == 1
                  ? null
                  : (val) async {
                      //  print(val.toString() + '_________');
                      if (val != null) {
                        updQuotation.currencyId = val as int;
                        ListItemsEdit.listmoneda[0].codmoneda = val as int;
                      } else {
                        updQuotation.currencyId = 0;
                      }
                    },
              onSaved: (newValue) => FocusScope.of(context).unfocus(),
              onTap: () => FocusScope.of(context).unfocus(),
            ),

            // CHOOSE PRODUCTS
            popup(),
            space,

            // LIST PRODUCTS
            if (ListItemsEdit.listItems.isNotEmpty)
              Container(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200, minHeight: 200),
                  child: Scrollbar(
                    // isAlwaysShown: true,
                    child: ListView.separated(
                      physics: AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: ListItemsEdit.listItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(
                                  ListItemsEdit.listItems[index].product_name
                                      .toString()
                                      .trimRight()
                                      .trimLeft(),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    ListItemsEdit.listItems[index].sub_total
                                        .toString(),
                                    style: TextStyle(fontSize: 10),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 12, // space between two icons
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  // print("deleted");
                                  var subTotal = double.tryParse(ListItemsEdit
                                      .listItems
                                      .elementAt(index)
                                      .sub_total);
                                  setState(() {
                                    subTotalController.text = (double.tryParse(
                                                subTotalController.text == ''
                                                    ? '0'
                                                    : subTotalController
                                                        .text)! -
                                            subTotal!)
                                        .toStringAsFixed(2);
                                    lgvController.text = (double.tryParse(
                                                subTotalController.text == ''
                                                    ? '0'
                                                    : subTotalController
                                                        .text)! *
                                            double.parse(datacompany.numImpuesto
                                                .toString()))
                                        .toStringAsFixed(2);
                                    totalController.text = (double.tryParse(
                                                subTotalController.text == ''
                                                    ? '0'
                                                    : subTotalController
                                                        .text)! +
                                            (double.tryParse(
                                                    subTotalController.text ==
                                                            ''
                                                        ? '0'
                                                        : subTotalController
                                                            .text)! *
                                                double.parse(datacompany
                                                    .numImpuesto
                                                    .toString())))
                                        .toStringAsFixed(2);
                                    ListItemsEdit.listItems.removeAt(index);
                                  });
                                  if (ListItemsEdit.listItems.length == 0) {
                                    _bloquearCurrency = 0;
                                  }
                                },
                                icon: Icon(Icons.delete_outlined),
                              ),

                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    ListSelProduct.listproduct.clear();
                                    ListSelProduct.indexprod = index;

                                    ListSelProduct.listproduct
                                        .add(ListItemsEdit.listItems[index]);
                                  });

                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return openDialogueEdit();
                                      }).then((value) {
                                    if (value != null) {
                                      double subTotal = 0;
                                      ListItemsEdit.listItems
                                          .forEach((element) {
                                        subTotal +=
                                            double.tryParse(element.sub_total)!;
                                      });
                                      setState(() {
                                        subTotalController.text =
                                            subTotal.toStringAsFixed(2);
                                        lgvController.text = (subTotal *
                                                double.parse(datacompany
                                                    .numImpuesto
                                                    .toString()))
                                            .toStringAsFixed(2);
                                        totalController.text = (subTotal +
                                                (subTotal *
                                                    double.parse(datacompany
                                                        .numImpuesto
                                                        .toString())))
                                            .toStringAsFixed(2);
                                      });

                                      if (ListItemsEdit.listItems.length > 0) {
                                        _bloquearCurrency = 1;
                                      }
                                    }
                                  });
                                },
                                icon: Icon(Icons.edit),
                              ), // icon-1
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 1.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

            space,

            regularText('Observaciones'),
            normalField(
              controller: observationController,
              maxLine: 1,
              inputType: TextInputType.text,
              // validator: (value) => value!.isEmpty ? "Field is empty!" : null,
            ),

            space,
            /*
            // CURRENCY DROP DOWN
            regularText('Moneda'),
            normalDropdown(currency, updQuotation.currencyId!.toInt()),
            space, */

            regularText('Subtotal'),
            normalField(
                controller: subTotalController,
                maxLine: 1,
                readOnly: true,
                validator: (value) => value!.isEmpty ? "Field is empty!" : null,
                inputType: TextInputType.number),
            space,

            regularText(
                '+${(double.parse(datacompany.numImpuesto.toString()) * 100).toStringAsFixed(0)}% lgv'),
            normalField(
                controller: lgvController,
                maxLine: 1,
                readOnly: true,
                validator: (value) => value!.isEmpty ? "Field is empty!" : null,
                inputType: TextInputType.number),
            space,

            regularText('Total'),
            normalField(
                controller: totalController,
                maxLine: 1,
                readOnly: true,
                validator: (value) => value!.isEmpty ? "Field is empty!" : null,
                inputType: TextInputType.number),
            space,
            space,

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal),
                ),
                onPressed: () async {
                  final msg_edit = SnackBar(
                      content:
                          Text(' La Cotización se actualizo con exito. !'));

                  final msg_err = SnackBar(
                      content: Text(
                          'Tuvimos un error en el registro !! , Intentelo de nuevo.'));

                  //QuotationCrt quotationCrt = new QuotationCrt();

                  FocusScope.of(context).unfocus();
                  if (_key.currentState!.validate()) {
                    QuotationCrt quotationCrt = new QuotationCrt();
                    QuotationProductCrt quotationproductCrt =
                        new QuotationProductCrt();

                    //var res = await quotationCrt.insertQuotation(Quotation(

                    //Quotation quotation = new Quotation(
                    //upd createDate: DateTime.now().toString(),
                    updQuotation.total = totalController.text;
                    updQuotation.subTotal = subTotalController.text;
                    updQuotation.dateQuotation = dateController.text;
                    // company: ,
                    //updQuotation.currencyId = selectedCurrency.codCurrency;
                    // updQuotation.dateQuotation: dateController.text,
                    //updQuotation.deliveryTimeId = selectedDeliveryTimes.id;
                    //updQuotation.deliveryTypeId = selectedDeliveryType.id;
                    updQuotation.lgv = lgvController.text;
                    updQuotation.nameBusiness = socialController.text;
                    // createUser: ,
                    updQuotation.observation = observationController.text;
                    //updQuotation.payId =
                    //  selectedPayConditions.codPayCondition;
                    updQuotation.state = '0';
                    updQuotation.updateflg = -1;

                    try {
                      setState(() => loader = true);
                      // print(updQuotation);
                      // print(ListItemsEdit.listItems);

                      if (await quotationCrt.updateQuotation(updQuotation) >
                          0) {
                        await quotationproductCrt
                            .deleteQuotationProductsperCode(
                                updQuotation.id.toString());

                        int corre = 1;
                        await Future.forEach(ListItemsEdit.listItems,
                            (QuotationProduct element) async {
                          element.quotation_id = updQuotation.id;
                          element.id =
                              updQuotation.id.toString() + corre.toString();

                          await quotationproductCrt
                              .insertQuotationProduct(element);

                          corre = corre + 1;
                        });

                        /********************** Generamos PDF ******************/

                        List<PayCondition> payConditions2 = payConditions
                            .where(
                                (o) => o.codPayCondition == updQuotation.payId)
                            .toList();

                        List<DeliveryTime> deliveryTimes2 = deliveryTimes
                            .where((o) => o.id == updQuotation.deliveryTimeId)
                            .toList();

                        List<DeliveryType> deliveryTypes2 = deliveryTypes
                            .where((o) => o.id == updQuotation.deliveryTypeId)
                            .toList();

                        List<Currency> currency2 = currency
                            .where(
                                (o) => o.codCurrency == updQuotation.currencyId)
                            .toList();
                        final directory = await getExternalStorageDirectory();

                        CompanyCtr comp = new CompanyCtr();
                        List<Company> arrCompany =
                            await comp.getCompany(_CodCompany);

                        ReportDataQuotation dataquotation =
                            new ReportDataQuotation(
                                path: directory!.path,
                                codCompany: _CodCompany,
                                quotationfin: updQuotation,
                                listprodquotationfin: ListItemsEdit.listItems,
                                customer: cust,
                                salesperson: updSalesperson,
                                paycondition: payConditions2[0]
                                    .strDescription
                                    .toString(),
                                deliverytype:
                                    deliveryTypes2[0].description.toString(),
                                deliverytime:
                                    deliveryTimes2[0].description.toString(),
                                currency: currency2[0].codCurrency!,
                                currencyName: currency2[0].strName!,
                                company: arrCompany[0],
                                cur: currency2[0]);

                        Reports reports = new Reports();
                        reports.reportsEnableds(dataquotation);

                        /********************** Generamos PDF ******************/
                      }

                      setState(() {
                        loader = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(msg_edit);

                      Navigator.pushNamedAndRemoveUntil(
                          context, 'listQuotas', (route) => false,
                          arguments: cust);
                    } catch (err) {
                      setState(() {
                        loader = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err.toString())));
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    if (loader)
                      Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                    else ...[
                      Text("Imprimir Pre - Procesado",
                          style: TextStyle(fontSize: 15.0)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.error_outlined),
                    ],
                  ],
                ),
              ),
            ),
            space,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal),
                ),
                onPressed: () async {
                  final msg_confirm = SnackBar(
                      content: Text(' La Cotización se registro con exito !'));

                  final msg_err = SnackBar(
                      content: Text(
                          'Tuvimos un error en el registro !! , Intentelo de nuevo.'));

                  //QuotationCrt quotationCrt = new QuotationCrt();

                  FocusScope.of(context).unfocus();
                  if (_key.currentState!.validate()) {
                    QuotationCrt quotationCrt = new QuotationCrt();
                    QuotationProductCrt quotationproductCrt =
                        new QuotationProductCrt();

                    //var res = await quotationCrt.insertQuotation(Quotation(

                    //Quotation quotation = new Quotation(
                    //upd createDate: DateTime.now().toString(),
                    updQuotation.total = totalController.text;
                    updQuotation.subTotal = subTotalController.text;
                    updQuotation.dateQuotation = dateController.text;
                    // company: ,
                    //updQuotation.currencyId = selectedCurrency.codCurrency;
                    // updQuotation.dateQuotation: dateController.text,
                    //updQuotation.deliveryTimeId = selectedDeliveryTimes.id;
                    //updQuotation.deliveryTypeId = selectedDeliveryType.id;
                    updQuotation.lgv = lgvController.text;
                    updQuotation.nameBusiness = socialController.text;
                    // createUser: ,
                    updQuotation.observation = observationController.text;
                    //updQuotation.payId =
                    //  selectedPayConditions.codPayCondition;
                    updQuotation.state = '1';
                    updQuotation.updateflg = -1;

                    try {
                      setState(() => loader = true);
                      print(updQuotation);
                      print(ListItemsEdit.listItems);

                      if (await quotationCrt.updateQuotation(updQuotation) >
                          0) {
                        await quotationproductCrt
                            .deleteQuotationProductsperCode(
                                updQuotation.id.toString());

                        int corre = 1;
                        await Future.forEach(ListItemsEdit.listItems,
                            (QuotationProduct element) async {
                          element.quotation_id = updQuotation.id;
                          element.id =
                              updQuotation.id.toString() + corre.toString();

                          await quotationproductCrt
                              .insertQuotationProduct(element);

                          corre = corre + 1;
                        });

                        /********************** Generamos PDF ******************/

                        List<PayCondition> payConditions2 = payConditions
                            .where(
                                (o) => o.codPayCondition == updQuotation.payId)
                            .toList();

                        List<DeliveryTime> deliveryTimes2 = deliveryTimes
                            .where((o) => o.id == updQuotation.deliveryTimeId)
                            .toList();

                        List<DeliveryType> deliveryTypes2 = deliveryTypes
                            .where((o) => o.id == updQuotation.deliveryTypeId)
                            .toList();

                        List<Currency> currency2 = currency
                            .where(
                                (o) => o.codCurrency == updQuotation.currencyId)
                            .toList();
                        final directory = await getExternalStorageDirectory();

                        CompanyCtr comp = new CompanyCtr();
                        List<Company> arrCompany =
                            await comp.getCompany(_CodCompany);

                        ReportDataQuotation dataquotation =
                            new ReportDataQuotation(
                                path: directory!.path,
                                codCompany: _CodCompany,
                                quotationfin: updQuotation,
                                listprodquotationfin: ListItemsEdit.listItems,
                                customer: cust,
                                salesperson: updSalesperson,
                                paycondition: payConditions2[0]
                                    .strDescription
                                    .toString(),
                                deliverytype:
                                    deliveryTypes2[0].description.toString(),
                                deliverytime:
                                    deliveryTimes2[0].description.toString(),
                                currency: currency2[0].codCurrency!,
                                currencyName: currency2[0].strName!,
                                company: arrCompany[0],
                                cur: currency2[0]);

                        Reports reports = new Reports();
                        reports.reportsEnableds(dataquotation);

                        // if (_CodCompany == "1") {
                        //   reports.reportsQuotation_refermat(dataquotation);
                        // } else {
                        //   reports.reportsQuotation(dataquotation);
                        // }
                      }

                      setState(() {
                        loader = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(msg_confirm);

                      Navigator.pushNamedAndRemoveUntil(
                          context, 'listQuotas', (route) => false,
                          arguments: cust);
                    } catch (err) {
                      setState(() {
                        loader = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err.toString())));
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    if (loader)
                      Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                    else ...[
                      Text("Imprimir Procesado",
                          style: TextStyle(fontSize: 15.0)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.check_circle_rounded),
                    ],
                  ],
                ),
              ),
            ),
            space,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 154, 160, 154),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal),
                ),
                onPressed: () async {
                  int validar = 0;
                  await showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('Confirmar la Anulación'),
                          content: const Text(
                              'Estas seguro que deseas anular la cotización ?'),
                          actions: [
                            // The "Yes" button
                            TextButton(
                                onPressed: () async {
                                  //QuotationCrt quotationCrt = new QuotationCrt();

                                  // FocusScope.of(context).unfocus();
                                  print(">>> entrando 0001 hasta");
                                  if (_key.currentState!.validate()) {
                                    QuotationCrt quotationCrt =
                                        new QuotationCrt();
                                    QuotationProductCrt quotationproductCrt =
                                        new QuotationProductCrt();

                                    updQuotation.total = totalController.text;
                                    updQuotation.subTotal =
                                        subTotalController.text;
                                    updQuotation.dateQuotation =
                                        dateController.text;

                                    updQuotation.lgv = lgvController.text;
                                    updQuotation.nameBusiness =
                                        socialController.text;
                                    // createUser: ,
                                    updQuotation.observation =
                                        observationController.text;
                                    //updQuotation.payId =
                                    //  selectedPayConditions.codPayCondition;
                                    updQuotation.state = '99';
                                    updQuotation.updateflg = -1;

                                    // try {
                                    print(">>>>>> llegando al try");
                                    if (await quotationCrt
                                            .updateQuotation(updQuotation) >
                                        0) {
                                      await quotationproductCrt
                                          .deleteQuotationProductsperCode(
                                              updQuotation.id.toString());

                                      int corre = 1;
                                      await Future.forEach(
                                          ListItemsEdit.listItems,
                                          (QuotationProduct element) async {
                                        element.quotation_id = updQuotation.id;
                                        element.id =
                                            updQuotation.id.toString() +
                                                corre.toString();

                                        await quotationproductCrt
                                            .insertQuotationProduct(element);

                                        corre = corre + 1;
                                      });
                                    }
                                    validar = 1;
                                    print(">>>>> llegamos a este punto ");

                                    // Navigator.pushNamedAndRemoveUntil(
                                    //     context, 'listQuotas', (route) => false,
                                    //     arguments: cust);
                                    // } catch (err) {

                                    // }
                                  }

                                  Navigator.of(context).pop();
                                },
                                child: const Text('Aceptar')),

                            TextButton(
                                onPressed: () {
                                  // Close the dialog
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancelar'))
                          ],
                        );
                      });
                  // print(">>>>> llegamos aqui");
                  if (validar == 1) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, 'listQuotas', (route) => false,
                        arguments: cust);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    if (loader)
                      Center(
                          child: CircularProgressIndicator(
                        color: Colors.white,
                      ))
                    else ...[
                      Text("Anular Cotización",
                          style: TextStyle(fontSize: 15.0)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.cancel),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }

  Widget normalDropdown(List<dynamic> items, int initialvalue) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField(
        isExpanded: true,
        value: _payed,
        icon: Icon(Icons.keyboard_arrow_down),
        validator: (value) => value == null ? "Field is empty!" : null,
        items: items.map((item) {
          return DropdownMenuItem(
              value: item,
              child: Text(item.runtimeType == Currency ||
                      item.runtimeType == PayCondition
                  ? item.strDescription
                  : item.description));
        }).toList(),
        onSaved: (newValue) => FocusScope.of(context).unfocus(),
        onTap: () => FocusScope.of(context).unfocus(),
        onChanged: (value) {
          setState(() {
            if (value.runtimeType == Currency)
              selectedCurrency = value as Currency;
            if (value.runtimeType == DeliveryTime)
              selectedDeliveryTimes = value as DeliveryTime;
            if (value.runtimeType == DeliveryType)
              selectedDeliveryType = value as DeliveryType;
            if (value.runtimeType == PayCondition)
              selectedPayConditions = value as PayCondition;
            // dropdownvalue = value.toString();
          });
        },
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    print("tappes");
    // FocusScope.of(context).unfocus();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(
        () => selectedDate = picked,
      );
    }
  }

  Widget popup() {
    print(" ------------------- entrando ------------------ ");
    print(ListItemsEdit.listmoneda);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(
                width: 5.0,
                color: Colors.grey.shade400,
              )),
          onPressed: () {
            // ListItemsEdit.listmoneda.clear();
            // Cmoneda m = new Cmoneda(codmoneda: selectedCurrency.codCurrency!);
            // ListItemsEdit.listmoneda.add(m);
            // _displayTextInputDialog;
            showDialog(
                context: context,
                builder: (context) {
                  return openDialogue();
                }).then((value) {
              if (value != null) {
                double subTotal = 0;
                ListItemsEdit.listItems.forEach((element) {
                  subTotal += double.tryParse(element.sub_total)!;
                });
                setState(() {
                  subTotalController.text = subTotal.toStringAsFixed(2);
                  ;
                  lgvController.text = (subTotal *
                          double.parse(datacompany.numImpuesto.toString()))
                      .toStringAsFixed(2);
                  ;
                  totalController.text = (subTotal +
                          (subTotal *
                              double.parse(datacompany.numImpuesto.toString())))
                      .toStringAsFixed(2);
                  ;
                });
              }

              if (ListItemsEdit.listItems.length > 0) {
                _bloquearCurrency = 1;
              }
            });
          },
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Elegir Productos",
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )),
    );
  }

  Widget openDialogue() {
    return ProductEditForm();
  }

  Widget openDialogueEdit() {
    return ProductEditEditForm();
  }

  void _moveToScreen2(BuildContext context) {
    Navigator.pushReplacementNamed(context, "listQuotas");
  }
}
