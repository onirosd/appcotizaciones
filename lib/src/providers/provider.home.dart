import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appcotizaciones/src/models/autentication.dart';
import 'package:appcotizaciones/src/models/billing.dart';
import 'package:appcotizaciones/src/models/customer.dart';
import 'package:appcotizaciones/src/models/indicators.dart';
import 'package:appcotizaciones/src/models/querys.dart';
import 'package:appcotizaciones/src/models/quotation_model.dart';
import 'package:appcotizaciones/src/models/quotation_product_model.dart';
import 'package:appcotizaciones/src/models/quotationplusproducst.dart';
import 'package:appcotizaciones/src/models/response_error.dart';
import 'package:appcotizaciones/src/models/synclog.dart';
import 'package:appcotizaciones/src/models/tiperson.dart';
import 'package:appcotizaciones/src/modelscrud/api.complements.dart';
import 'package:appcotizaciones/src/modelscrud/api.configGeneral_crt.dart';
import 'package:appcotizaciones/src/modelscrud/autentication_crt.dart';
import 'package:appcotizaciones/src/modelscrud/billing_crt.dart';
import 'package:appcotizaciones/src/modelscrud/billingquotation_crt.dart';
import 'package:appcotizaciones/src/modelscrud/configGeneral_crt.dart';
import 'package:appcotizaciones/src/modelscrud/customer_crt.dart';
import 'package:appcotizaciones/src/modelscrud/indicators_crt.dart';
import 'package:appcotizaciones/src/modelscrud/quotationProduct_crt.dart';
import 'package:appcotizaciones/src/modelscrud/quotation_crt.dart';
import 'package:appcotizaciones/src/modelscrud/synclog_crt.dart';
import 'package:appcotizaciones/src/modelscrud/tiperson_crt.dart';
import 'package:appcotizaciones/src/providers/authentication_provider.dart';
import 'package:appcotizaciones/src/providers/changes.notifier.dart';
import 'package:appcotizaciones/src/search/search_customers.dart';
import 'package:appcotizaciones/src/widgets/appbars2.dart';

import 'package:appcotizaciones/src/services/sync_service.dart';

//import 'db_provider.dart';

class ProviderHome extends StatefulWidget {
  //Nav({Key? key}) : super(key: key);

  @override
  _ProviderHome createState() => _ProviderHome();
}

class _ProviderHome extends State<ProviderHome> {
  int _selectedIndex = 0;
  String _LoginUser = '';
  String _Company = '';
  int _CodUser = 0;

  String _CodList = '1';

  String _Nombre = "";
  String _Position = "";
  String _Celphone = "";

  String _PositionVal = "";

  String _codCompany = "";

  int _TotalPending = 0;

  String _mensaje = "";
  // SharedPreferencesTest preferences = new SharedPreferencesTest();
  bool _isInternet = true;

  String _pasoActual = '';
  bool _isSyncing = false;

  SyncLog _lastlogUser = new SyncLog(
      codLog: 0,
      codUser: 0,
      dteSyncDate: 0,
      strDay: "",
      strhour: "",
      seccion: "",
      strMessage: "");
  List<TiPerson> _dataPerson = [];
  List<SelectPendingSync> _totalPending = [];
  List<SelectPendingSync> _totalPendingRegisters = [];
  List<Ti_IndicatorsUser> _indicators = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _Positon = '';
  //TiPerson _dataTiPerson = new TiPerson(codPerson: 0, strCelphone: "", strDesPerson: "", strPosition: "");
  //String _online = '';

  Map _source = {ConnectivityResult.none: false};
  final MyConnectivity _connectivity = MyConnectivity.instance;

  void _setPasoActual(String paso) {
    setState(() {
      _pasoActual = paso;
    });
  }

  void _setIsSyncing(bool val) {
    setState(() {
      _isSyncing = val;
    });
  }

  _getPreferences() async {
    TiPersonCtr crtPerson = new TiPersonCtr();
    SyncLogCtr crt = new SyncLogCtr();
    ConfigGeneralCtr crt_config = new ConfigGeneralCtr();
    IndicatorsCtr indi = new IndicatorsCtr();

    await SharedPreferences.getInstance().then((res) {
      setState(() {
        _LoginUser = res.getString("usuario")!;
        _Company = res.getString("empresa")!;
        _CodUser = res.getInt("codigo")!;
        _CodList = res.getString("codlist")!;
        _PositionVal = res.getString("posicion")!;
        _Positon = res.getString("posicion") ?? '';
        _codCompany = res.getString("codcompany") ?? '0';
      });
    });

    await indi.getDataIndicators().then((value) {
      setState(() {
        _indicators = value;
        // print(value);
        //_lastlogUser = value.length > 0 ? value[0] : _lastlogUser;
      });
    });

    await crtPerson.getdataPersonfromUser(_CodUser).then((value2) {
      // print(value2[0].toString());
      setState(() {
        print(value2);
        _dataPerson = value2;
      });
    });

    await crt.getLastLogFromUser(_CodUser).then((value) {
      setState(() {
        print(value);
        _lastlogUser = value.length > 0 ? value[0] : _lastlogUser;
      });
    });

    await crt_config.getTotalPendingSync().then((value) {
      setState(() {
        _totalPending = value;
        // print(value);
        //_lastlogUser = value.length > 0 ? value[0] : _lastlogUser;
      });
    });

    await crt_config.getPendingSync().then((value) {
      setState(() {
        _totalPendingRegisters = value;
        // print(value);
        //_lastlogUser = value.length > 0 ? value[0] : _lastlogUser;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    if (this.mounted) {
      _getPreferences();
      Future.delayed(Duration.zero, () async {
        await _getPreferences();
      });
    }

    // print(_dataPerson.toString() + "------  entrando en init --------");

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (mounted) {
        setState(() => _source = source);
      }
    });

    //print("esto debe entrar primero");
    //SyncLogCtr crt        = new SyncLogCtr();
    //TiPersonCtr crtPerson = new TiPersonCtr();

    // print(_LoginUser + "-----------------------------------");
  }

  _onItemTapped(int page) async {
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
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isInternet =
        _source.keys.toList()[0] == ConnectivityResult.none ? false : true;
    String nombre = "";

    // print(_dataPerson.toString() + "-------------------------------------vvv");
    _dataPerson.forEach((element) {
      _Nombre = element.strDesPerson!;
      _Celphone = element.strCelphone!;
      _Position = element.strPosition!;
    });

    _totalPending.forEach((element) {
      _TotalPending = element.cantidad;
    });

    final ButtonStyle raisedButtonStyleSync = ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue[500],
        alignment: Alignment.center,
        fixedSize: Size(150, 50),
        // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
        ));

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, 'login');

        //  _moveToScreen2(context);
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: // AppBar(
            AppBars(
          loginuser: _LoginUser,
          company: _Company,
          context: context,
          isOnline: _isInternet,
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                // _datosPerfil(
                //   tiperson: _dataPerson,
                // ),
                if (_isSyncing)
                  Consumer<AuthenticationProvider>(
                    builder: (context, auth, _) {
                      if (!auth.isLoading) return SizedBox.shrink();

                      return Container(
                        padding: EdgeInsets.all(10),
                        color: Color.fromARGB(187, 7, 93, 233),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                auth.pasoActual,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                Container(
                  //margin: EdgeInsets.only(top: 40),
                  color: Color.fromARGB(255, 125, 184, 255),
                  height: 120,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            SizedBox(height: 17),
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(top: 0, left: 20),
                                  child: _datosSincronizacion2(
                                    context: context,
                                    isInternet: _isInternet,
                                    codUser: _CodUser,
                                    sync: _lastlogUser,
                                    tSyncPending: _TotalPending,
                                    registersPendigs: _totalPendingRegisters,
                                    codList: int.parse(_CodList),
                                    indicators: _indicators,
                                    sca: _scaffoldKey,
                                    position1: _PositionVal,
                                    cod_company: _codCompany.toString(),
                                    onStepUpdate: (paso) {
                                      Provider.of<AuthenticationProvider>(
                                              context,
                                              listen: false)
                                          .setPaso(paso);
                                    },
                                    onSyncStateChange: _setIsSyncing,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(children: [
                              Container(
                                margin: EdgeInsets.only(top: 0, left: 20),
                                child: Text(
                                  "Ultima Actualización",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ]),
                            Row(children: [
                              Container(
                                margin: EdgeInsets.only(top: 0, left: 20),
                                child: Text(
                                  "${_lastlogUser.strDay} ${_lastlogUser.strhour}",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ])
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: new Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(_Nombre,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            Container(
                              color: Colors.blue[500],
                              height: 30,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: new Icon(
                                      Icons.group,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Text(_Position,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      // ElevatedButton(
                      //   child: const Text('Sincronizar'),
                      //   onPressed: () {},
                      // )
                    ],
                  ),
                ),
                Container(
                  child: tabladata(position: _Position),
                )

                // ChangeNotifierProvider(
                //   create: (_) => AuthenticationProvider(),
                //   child: _datosSincronizacion(
                //     isInternet: _isInternet,
                //     codUser: _CodUser,
                //     sync: _lastlogUser,
                //     tSyncPending: _TotalPending,
                //     registersPendigs: _totalPendingRegisters,
                //     codList: int.parse(_CodList),
                //     indicators: _indicators,
                //     sca: _scaffoldKey,
                //     position1: _PositionVal,
                //   ),
                // ),
              ]),
            )
            // _CustomAppBar()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
              backgroundColor: Color.fromRGBO(0, 47, 80, 1),
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
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: (int page) async {
            _onItemTapped(page);
          },
          /* (int page) async {
            _onItemTapped(page);
          },*/
        ),
      ),
    );
  }
  /*
  @override
  void dispose() {
    _connectivity.disposeStream();
    super.dispose();
  }
  */
}

class _datosPerfil extends StatelessWidget {
  List<TiPerson>? tiperson;
  _datosPerfil({required this.tiperson});

  @override
  Widget build(BuildContext context) {
    // print(tiperson!.strDesPerson);
    String? nombre = tiperson!.length > 0 ? tiperson![0].strDesPerson : "";
    String? celphone = tiperson!.length > 0 ? tiperson![0].strCelphone : "";
    String? position = tiperson!.length > 0 ? tiperson![0].strPosition : "";

    return Container(
      //margin: EdgeInsets.only(top: 40),
      color: Colors.blueAccent,
      height: 160,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 120,
            ),
          ),
          Expanded(
              flex: 4,
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(nombre!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: new Icon(
                          Icons.group,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(position!),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: new Icon(
                          Icons.phone_android,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(celphone!),
                      )
                    ],
                  ),
                ],
              ))
        ],
      ),
    );
  }
}

class tabladata extends StatefulWidget {
  String position;

  tabladata({required this.position});

  @override
  State<tabladata> createState() => _tabladataState();
}

class _tabladataState extends State<tabladata> {
  Billingquotation_crt crt = new Billingquotation_crt();
  Filtros filtro = new Filtros(flag: 0, tipo: "", tipo_estado: "");
  Future<List<SelectBillingQuotation>>? _bullquot;
  // String position;
  // _tabladataState({required this.position});

  var _droptipo;
  var tipo_items = [
    'Todos',
    'Cotizacion',
    'Recibo',
  ];

  var tipo_items2 = {
    'Todos': 0,
    'Cotizacion': 1,
    'Recibo': 2,
  };
  var _droptipoestado;
  List<String> tipo_estados = [
    'Todos',
    'Pre-Procesado',
    'Procesado Sync',
    'Procesado NoSync',
  ];

  var tipo_estados2 = {
    'Todos': -1,
    'Pre-Procesado': 0,
    'Procesado Sync': 2,
    'Procesado NoSync': 1
  };

  _runFuture() {
    _bullquot =
        crt.getSelectBillingQuoatation(filtro, tipo_estados2, tipo_items2);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        // padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              color: Color.fromARGB(187, 7, 93, 233),
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.filter_alt,
                      size: 40,
                      color: Color.fromARGB(220, 56, 56, 56),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: DropdownButton(
                                  value: _droptipo,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color.fromARGB(220, 56, 56, 56),
                                  ),
                                  elevation: 16,
                                  style: const TextStyle(
                                    color: Color.fromARGB(220, 56, 56, 56),
                                  ),
                                  underline: Container(
                                    height: 2,
                                    color: Color.fromARGB(220, 56, 56, 56),
                                  ),
                                  items: tipo_items.map((String items) {
                                    return DropdownMenuItem(
                                        value: items, child: Text(items));
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _droptipo = newValue.toString();
                                      filtro.tipo = newValue.toString();
                                    });
                                  },
                                  hint: //and here
                                      Text(
                                    "Tipo Doc",
                                    style: TextStyle(
                                      color: Color.fromARGB(220, 255, 255, 255),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: <Widget>[
                              Container(
                                child: DropdownButton(
                                  value: _droptipoestado,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color.fromARGB(220, 56, 56, 56),
                                  ),
                                  elevation: 16,
                                  style: const TextStyle(
                                    color: Color.fromARGB(220, 56, 56, 56),
                                  ),
                                  underline: Container(
                                    height: 2,
                                    color: Color.fromARGB(220, 56, 56, 56),
                                  ),
                                  items: tipo_estados.map((String items) {
                                    return DropdownMenuItem(
                                        value: items, child: Text(items));
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _droptipoestado = newValue.toString();
                                      filtro.tipo_estado = newValue.toString();
                                    });
                                  },
                                  hint: //and here
                                      Text(
                                    "Tipo Estado",
                                    style: TextStyle(
                                      color: Color.fromARGB(220, 255, 255, 255),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              Container(
                                width: 70,
                                child: OutlinedButton(
                                  child: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Color.fromARGB(220, 255, 255, 255),
                                  ),
                                  onPressed: () {
                                    _runFuture();
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: _bullquot == null
                  ? Text("")
                  : _tabladatos(
                      lists: _bullquot,
                      position: widget.position,
                      filtro: filtro),
            )
          ],
        ),
      ),
    );
  }
}

class _tabladatos extends StatelessWidget {
  String position;
  Future<List<SelectBillingQuotation>>? lists;
  Filtros filtro;

  _tabladatos(
      {required this.position, required this.lists, required this.filtro});

  Billingquotation_crt crt = new Billingquotation_crt();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: lists,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<SelectBillingQuotation> list = snapshot.data;

            return Center(
              child: _ListQuotation(list, position, filtro),
            );
          }
        });
  }
}

class _ListQuotation extends StatelessWidget {
  //final Customer customer;
  final List<SelectBillingQuotation> listBillingQuotation;
  final String position;
  final Filtros filtro;
  const _ListQuotation(this.listBillingQuotation, this.position, this.filtro);

  Widget build(BuildContext context) {
    //QuotationCrt crt = new QuotationCrt();
    //List<SelectQuotation> listQuotations =
    //  await crt.getSelectQuotationByCustomer(customer.codCustomer.toString());
    const double widthbetweenrows = 25;
    const double widthbetweencolumns = 3;
    return Container(
      child: SizedBox(
        height: 500,
        child: ListView(
          //padding: const EdgeInsets.all(16),
          children: [
            PaginatedDataTable(
                //header: Text('Header Text'),
                rowsPerPage: 7,
                headingRowHeight: widthbetweenrows,
                columnSpacing: widthbetweencolumns,
                // dataRowHeight: widthbetweencolumns,
                columns: [
                  DataColumn(label: Text('Nro.')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Monto')),
                  DataColumn(label: Text('Prod')),
                  DataColumn(label: Text('Est')),
                  DataColumn(
                      label: Text(
                    'Act',
                  )),
                ],
                source: _DataSource(
                    context, listBillingQuotation, position, filtro)),
          ],
        ),
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final List<SelectBillingQuotation> listQuotations;
  final String position;
  final Filtros filtro;

  _DataSource(this.context, this.listQuotations, this.position, this.filtro) {
    _rows = listQuotations;
  }

  //_DataSource(this.context, this.customer, this.crt) {
  //  _rows = crt.getSelectQuotationByCustomer(customer.codCustomer) as List<SelectQuotation>;
  // }

  final BuildContext context;
  List<SelectBillingQuotation> _rows = [];

  // _rows.add(_Row('Cell A1', 'CellB1', 'CellC1', 1));

  int _selectedCount = 0;
  var change = 0;
  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= _rows.length) return null;
    final row = _rows[index];
    return DataRow.byIndex(
      index: index,
      selected: row.selected,
      /*onSelectChanged: (value) {
        int change = value == true ? 1 : -1;
        //if (value != null) {
        //  change = value;
        //}
        //_selectedCount = value;
        if (row.selected != change) {
          _selectedCount += change;
          assert(_selectedCount >= 0);
          row.selected = change;
          notifyListeners();
        }
      },*/

      cells: [
        DataCell(Text(row.id.toString().substring(
            row.id.toString().length - 10, row.id.toString().length))),
        DataCell(Text(DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(row.fec.toString())))),
        DataCell(Text(double.parse(row.total.toString()).toStringAsFixed(2))),
        DataCell(Text(row.prods.toString())),
        DataCell(row.numstate == 0
            ? Icon(
                Icons.error_rounded,
                color: Colors.red,
              )
            : (row.numstate == 1
                ? Icon(
                    Icons.cloud_off_sharp,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.cloud_done_outlined,
                    color: Colors.green,
                  ))),
        DataCell(Row(
          children: [
            Visibility(
              visible: row.numstate == 1 || row.numstate == 2 ? true : false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.manage_search,
                        color: Colors.blue, size: 30),
                    tooltip: 'Increase volume by 10',
                    onPressed: () async {
                      print(filtro.tipo + "---------cabecera");
                      if (row.tipo == "1") {
                        QuotationCrt crt1 = new QuotationCrt();
                        QuotationProductCrt crt2 = new QuotationProductCrt();
                        AuthenticationCtr crt3 = new AuthenticationCtr();
                        CustomerCtr cust = new CustomerCtr();

                        List<Quotation> data =
                            await crt1.getDataQuotationsperCode(row.id);

                        List<QuotationProduct> dataProducts =
                            await crt2.getDataQuotationProductsperCode(row.id);

                        List<Authentication> dataSalesPerson = await crt3
                            .getDataUserAutentication(data[0].userId!);

                        print(row.codCustomer);

                        List<Customer> listCustomer =
                            await cust.getCustomerBycodUser(row.codCustomer);

                        QuotationPlusProducts concatdata =
                            new QuotationPlusProducts(
                                quotat: data[0],
                                listproduct: dataProducts,
                                customer: listCustomer[0],
                                salesperson: dataSalesPerson[0].strNameUser,
                                main_switch: 1);

                        Navigator.pushNamedAndRemoveUntil(
                            context, 'QuotationShow', (route) => false,
                            arguments: concatdata);
                      } else {
                        BillingCrt crt = new BillingCrt();
                        List<Billing> data =
                            await crt.getDataBillingsperCode(row.id);

                        print(filtro.tipo);

                        Billingandflag billingandflag = new Billingandflag(
                            billingdata: data[0], switch1: 1);

                        Navigator.pushNamedAndRemoveUntil(
                            context, 'BillingShow', (route) => false,
                            arguments: billingandflag);
                      }
                    },
                  ),
                ],
              ),
            ),
            position == 'SUPERVISOR' || position == 'ADMIN'
                ? Visibility(
                    visible: row.numstate == 2 ? true : false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_notifications_rounded,
                              color: Colors.blue, size: 30),
                          tooltip: 'Increase volume by 10',
                          onPressed: () async {
                            if (row.tipo == "1") {
                              QuotationCrt crt1 = new QuotationCrt();
                              QuotationProductCrt crt2 =
                                  new QuotationProductCrt();
                              AuthenticationCtr crt3 = new AuthenticationCtr();
                              CustomerCtr cust = new CustomerCtr();

                              List<Customer> listCustomer = await cust
                                  .getCustomerBycodUser(row.codCustomer);

                              List<Quotation> data =
                                  await crt1.getDataQuotationsperCode(row.id);
                              Quotation quo = data[0];
                              quo.state = "5";
                              quo.updateflg = 1;

                              crt1.updateQuotation(quo);

                              Navigator.pushNamedAndRemoveUntil(
                                  context, 'home', (route) => false,
                                  arguments: listCustomer[0]);
                            } else {
                              BillingCrt crt = new BillingCrt();
                              CustomerCtr cust = new CustomerCtr();
                              List<Billing> data =
                                  await crt.getDataBillingsperCode(row.id);
                              Billing bill1 = data[0];
                              bill1.flgState = 5;
                              List<Customer> listCustomer = await cust
                                  .getCustomerBycodUser(row.codCustomer);

                              crt.updateBilling(bill1);

                              Navigator.pushNamedAndRemoveUntil(
                                  context, 'home', (route) => false,
                                  arguments: listCustomer[0]);
                            }
                          },
                        ),
                      ],
                    ),
                  )
                : Text(""),
            Visibility(
              visible: row.numstate == 0 || row.numstate == 5 ? true : false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        color: Colors.blue, size: 25),
                    tooltip: 'Increase volume by 10',
                    onPressed: () async {
                      if (row.tipo == "1") {
                        QuotationCrt crt1 = new QuotationCrt();
                        QuotationProductCrt crt2 = new QuotationProductCrt();
                        AuthenticationCtr crt3 = new AuthenticationCtr();
                        CustomerCtr cust = new CustomerCtr();

                        List<Customer> listCustomer =
                            await cust.getCustomerBycodUser(row.codCustomer);

                        List<Quotation> data =
                            await crt1.getDataQuotationsperCode(row.id);

                        List<QuotationProduct> dataProducts =
                            await crt2.getDataQuotationProductsperCode(row.id);

                        List<Authentication> dataSalesPerson = await crt3
                            .getDataUserAutentication(data[0].userId!);

                        QuotationPlusProducts concatdata =
                            new QuotationPlusProducts(
                                quotat: data[0],
                                listproduct: dataProducts,
                                customer: listCustomer[0],
                                salesperson: dataSalesPerson[0].strNameUser,
                                main_switch: 1);

                        Navigator.pushNamedAndRemoveUntil(
                            context, 'QuotationEdit', (route) => false,
                            arguments: concatdata);
                      } else {
                        BillingCrt crt = new BillingCrt();
                        List<Billing> data =
                            await crt.getDataBillingsperCode(row.id);

                        Billingandflag billingflag =
                            Billingandflag(billingdata: data[0], switch1: 1);

                        Navigator.pushNamedAndRemoveUntil(
                            context, 'BillingEdit', (route) => false,
                            arguments: billingflag);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        )),
      ],
    );
  }

  @override
  int get rowCount => _rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

// class _datosSincronizacion2 extends StatelessWidget {
//   BuildContext context;
//   bool isInternet;
//   int codUser;
//   SyncLog? sync;
//   int tSyncPending;
//   List<SelectPendingSync> registersPendigs;
//   int codList;
//   List<Ti_IndicatorsUser> indicators;
//   GlobalKey<ScaffoldState> sca;
//   String position1;
//   String cod_company;

//   _datosSincronizacion2(
//       {required this.context,
//       required this.isInternet,
//       required this.codUser,
//       required this.sync,
//       required this.tSyncPending,
//       required this.registersPendigs,
//       required this.codList,
//       required this.indicators,
//       required this.sca,
//       required this.position1,
//       required this.cod_company});

//   String mensaje = " ";

//   final ButtonStyle raisedButtonStyleSync = ElevatedButton.styleFrom(
//       foregroundColor: Colors.white,
//       backgroundColor: Colors.blue[500],
//       alignment: Alignment.center,
//       fixedSize: Size(150, 50),
//       // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(2)),
//       ));

//   Widget build(BuildContext mainContext) {
//     final loginForm = Provider.of<AuthenticationProvider>(mainContext);

//     return Container(
//       height: 60,
//       margin: EdgeInsets.only(top: 0, right: 20),
//       child: OutlinedButton(
//         style: raisedButtonStyleSync,
//         onPressed: loginForm.isLoading || isInternet == false
//             ? null
//             : () async {
//                 loginForm.isLoading = true;

//                 final syncService = SyncService();

//                 try {
//                   await syncService.syncAll(
//                     codUser: codUser,
//                     codList: codList,
//                     codCompany: cod_company,
//                     position: position1,
//                     onStep: (paso) {
//                       print(
//                           "🔄 $paso"); // o usar un snackbar si deseas mostrar al usuario
//                       // Ejemplo opcional con ScaffoldMessenger
//                       /*
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(paso), duration: Duration(milliseconds: 800)),
//               );
//               */
//                     },
//                   );

//                   Navigator.pushNamed(context, "home");
//                 } catch (e) {
//                   print("❌ Error de sincronización: $e");

//                   // También puedes mostrar un mensaje visual aquí si quieres:
//                   /*
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//           );
//           */
//                 } finally {
//                   loginForm.isLoading = false;
//                 }
//               },
//         child: Text(isInternet
//             ? loginForm.isLoading
//                 ? 'Espere'
//                 : 'Sincronizar'
//             : "Sin Internet"),
//       ),
//     );
//   }
// }

class _datosSincronizacion2 extends StatefulWidget {
  final BuildContext context;
  final bool isInternet;
  final int codUser;
  final SyncLog? sync;
  final int tSyncPending;
  final List<SelectPendingSync> registersPendigs;
  final int codList;
  final List<Ti_IndicatorsUser> indicators;
  final GlobalKey<ScaffoldState> sca;
  final String position1;
  final String cod_company;
  // final String onStepUpdate;
  // final bool onSyncStateChange;

  final void Function(String paso)? onStepUpdate; // ← Agregado
  final void Function(bool syncing)? onSyncStateChange; // ← Agregado

  _datosSincronizacion2(
      {required this.context,
      required this.isInternet,
      required this.codUser,
      required this.sync,
      required this.tSyncPending,
      required this.registersPendigs,
      required this.codList,
      required this.indicators,
      required this.sca,
      required this.position1,
      required this.cod_company,
      required this.onStepUpdate,
      required this.onSyncStateChange});

  @override
  State<_datosSincronizacion2> createState() => _datosSincronizacion2State();
}

class _datosSincronizacion2State extends State<_datosSincronizacion2> {
  // String pasoActual = "";
  final ButtonStyle raisedButtonStyleSync = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.blue[500],
    alignment: Alignment.center,
    fixedSize: Size(150, 50),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<AuthenticationProvider>(
      context,
      listen: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton(
          style: raisedButtonStyleSync,
          onPressed: loginForm.isLoading || widget.isInternet == false
              ? null
              : () async {
                  loginForm.isLoading = true;

                  widget.onSyncStateChange
                      ?.call(true); // Mostrar barra de progreso

                  final syncService = SyncService();

                  try {
                    await syncService.syncAll(
                      codUser: widget.codUser,
                      codList: widget.codList,
                      codCompany: widget.cod_company,
                      position: widget.position1,
                      onStep: (paso) {
                        // ✅ Actualiza directamente en el Provider
                        loginForm.setPaso(paso);
                      },
                    );

                    loginForm.setPaso('✅ ¡Sincronización completada!');
                    await Future.delayed(Duration(seconds: 1));
                    loginForm.setPaso('');
                    widget.onSyncStateChange?.call(false);
                    loginForm.isLoading = false;
                  } catch (e) {
                    print("❌ Error de sincronización: $e");
                    loginForm.setPaso('');
                    widget.onSyncStateChange?.call(false);
                    loginForm.isLoading = false;
                  }
                },
          child: Text(widget.isInternet
              ? loginForm.isLoading
                  ? 'Espere...'
                  : 'Sincronizar'
              : "Sin Internet"),
        ),
        SizedBox(height: 8),
        // if (loginForm.isLoading)
        //   Container(
        //     margin: EdgeInsets.only(top: 8),
        //     constraints: BoxConstraints(maxWidth: 200), // Le damos un límite
        //     child: Row(
        //       children: [
        //         SizedBox(
        //           width: 20,
        //           height: 20,
        //           child: CircularProgressIndicator(strokeWidth: 2),
        //         ),
        //         SizedBox(width: 10),
        //         Flexible(
        //           // ✅ Usamos Flexible en lugar de Expanded
        //           child: Text(
        //             pasoActual,
        //             style: TextStyle(fontSize: 13, color: Colors.black87),
        //             maxLines: 2,
        //             overflow: TextOverflow.ellipsis,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}

class Billingandflag {
  Billing billingdata;
  int? switch1;

  Billingandflag({
    required this.billingdata,
    this.switch1,
  });

  Billingandflag copyWith({
    Billing? billingdata,
    int? switch1,
  }) {
    return Billingandflag(
      billingdata: billingdata ?? this.billingdata,
      switch1: switch1 ?? this.switch1,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'billingdata': billingdata.toMap()});
    if (switch1 != null) {
      result.addAll({'switch1': switch1});
    }

    return result;
  }

  factory Billingandflag.fromMap(Map<String, dynamic> map) {
    return Billingandflag(
      billingdata: Billing.fromMap(map['billingdata']),
      switch1: map['switch1']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Billingandflag.fromJson(String source) =>
      Billingandflag.fromMap(json.decode(source));

  @override
  String toString() =>
      'Billingandflag(billingdata: $billingdata, switch1: $switch1)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Billingandflag &&
        other.billingdata == billingdata &&
        other.switch1 == switch1;
  }

  @override
  int get hashCode => billingdata.hashCode ^ switch1.hashCode;
}

class Filtros {
  int flag;
  String tipo;
  String tipo_estado;

  Filtros({
    required this.flag,
    required this.tipo,
    required this.tipo_estado,
  });

  Filtros copyWith({
    int? flag,
    String? tipo,
    String? tipo_estado,
  }) {
    return Filtros(
      flag: flag ?? this.flag,
      tipo: tipo ?? this.tipo,
      tipo_estado: tipo_estado ?? this.tipo_estado,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'flag': flag});
    result.addAll({'tipo': tipo});
    result.addAll({'tipo_estado': tipo_estado});

    return result;
  }

  factory Filtros.fromMap(Map<String, dynamic> map) {
    return Filtros(
      flag: map['flag']?.toInt() ?? 0,
      tipo: map['tipo'] ?? '',
      tipo_estado: map['tipo_estado'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Filtros.fromJson(String source) =>
      Filtros.fromMap(json.decode(source));

  @override
  String toString() =>
      'Filtros(flag: $flag, tipo: $tipo, tipo_estado: $tipo_estado)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Filtros &&
        other.flag == flag &&
        other.tipo == tipo &&
        other.tipo_estado == tipo_estado;
  }

  @override
  int get hashCode => flag.hashCode ^ tipo.hashCode ^ tipo_estado.hashCode;
}
