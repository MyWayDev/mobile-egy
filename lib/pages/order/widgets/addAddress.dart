import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/courier.dart';
import 'package:mor_release/pages/const.dart';
import 'package:mor_release/pages/order/widgets/shipmentArea.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:http/http.dart' as http;

class AddRegion extends StatefulWidget {
  final String memberId;
  final String region;
  AddRegion(this.memberId, this.region, {Key key}) : super(key: key);

  @override
  _AddRegionState createState() => _AddRegionState();
}

class _AddRegionState extends State<AddRegion> {
  String path = 'flamelink/environments/egyProduction/content/district/en-US/';
  FirebaseDatabase database = FirebaseDatabase.instance;

  //List<DropdownMenuItem> regions = [];
  List<DropdownMenuItem> areas = [];
  String selectedRegion;
  var regionSplit;
  bool _isLoading = false;

  void loading(bool l) {
    setState(() {
      _isLoading = l;
    });
  }

  /*void getRegions() async {
    DataSnapshot snapshot = await database.reference().child(path).once();

    Map<dynamic, dynamic> _areas = snapshot.value;
    List list = _areas.values.toList();
    List<District> fbRegion = list.map((f) => District.json(f)).toList();
    // .where((d) => d.enable == false);

    if (snapshot.value != null) {
      for (var t in fbRegion) {
        if (t.enable == false) {
          String sValue = "${t.districtId}" + " " + "${t.name}";
          regions.add(
            DropdownMenuItem(
                child: Text(
                  sValue,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[900]),
                ),
                value: sValue),
          );
        }
      }
    }
  }*/

  Future<List<ShipmentArea>> getAreas(String areaId) async {
    loading(true);

    List<ShipmentArea> shipmentAreas = [];
    areas.clear();
    final response = await http.get(
        'http://mywayegypt-api.azurewebsites.net/api/get_shipment_places_by_area_id/$areaId');
    if (response.statusCode == 200) {
      final _shipmentArea = json.decode(response.body) as List;
      shipmentAreas =
          _shipmentArea.map((s) => ShipmentArea.fromJson(s)).toList();
      shipmentAreas.forEach((a) => print(a.shipmentName));
      if (shipmentAreas.length != 0) {
        for (var t in shipmentAreas) {
          String aValue = "${t.shipmentArea}" + " " + "${t.shipmentName}";
          areas.add(
            DropdownMenuItem(
                child: Text(
                  aValue,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                value: aValue),
          );
        }
      }
    }
    loading(false);
    // print('AREAS LENGTH:${areas.length}');
    return shipmentAreas;
  }

  bool _hasData = false;

  void hasData(bool has) {
    setState(() {
      _hasData = has;
    });
  }

  @override
  void initState() {
    regionSplit = widget.region.split('\ ');
    hasData(true);

    getAreas(regionSplit.first);
    //getRegions();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Column(
        mainAxisSize: MainAxisSize.max,
        //  mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'أضف العنوان',
            softWrap: true,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            widget.region,
            softWrap: true,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          //  ScopedModelDescendant<MainModel>(
          //   builder: (BuildContext context, Widget child, MainModel model) {})
          /* SearchableDropdown(
            hint: Center(
              child: Text(
                'المحافظة',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            icon: Icon(
              Icons.location_searching,
              size: 24,
            ),
            iconEnabledColor: Colors.pink[200],
            iconDisabledColor: Colors.grey,
            items: regions,
            value: selectedRegion,
            onChanged: (value) async {
              hasData(false);
              setState(() {
                selectedRegion = value;
                regionSplit = selectedRegion.split('\ ');
                hasData(true);
              });
              await getAreas(regionSplit.first);
              setState(() {});
            },
          ),*/
          regionSplit != null
              ? Container(
                  child: areas.length > 0
                      ? AddAddress(
                          widget.memberId, areas, int.parse(regionSplit.first))
                      : Container(
                          child: LinearProgressIndicator(
                            backgroundColor: greyColor,
                          ),
                        ),
                )
              : Container()
        ],
      ),
      actions: <Widget>[
        ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
          return IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.red,
              size: 24,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (_) => ShipmentPlace(
                      model: model, isEdit: model.isBulk ? true : false));
            },
          );
        })
      ],
    ));
  }
}

class AddAddress extends StatefulWidget {
  final String memberId;
  final int regionId;
  final List<DropdownMenuItem> _areas;

  AddAddress(this.memberId, this._areas, this.regionId, {Key key})
      : super(key: key);

  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  final GlobalKey<FormBuilderState> _addressFormKey =
      GlobalKey<FormBuilderState>();
  bool isValid = false;
  String selectedArea;
  var areaSplit;
  bool _async = false;
  String errorText = 'لا يترك خاليا';
  void isAsync(bool l) {
    setState(() {
      _async = l;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List companies = [];
  Future<List> couriersList(String areaid, int distrPoint) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(
            'flamelink/environments/egyProduction/content/courier/en-US') //!enviroments/$firebaseDb
        .once();

    var courierList = snapshot
        .value; //! changed list to var in this line for firebase key genrated

    List ships = [];
    for (var c in courierList.values) {
      //! add .values to courierlist to loop through values while firebase key is generated
      if (c != null) {
        if (c['region'] == distrPoint && c['disabled'] != true) {
          for (var s in c['service']) {
            for (var a in s['areas']) {
              if (a.toString() == areaid) {
                print('a.string:=>${a.toString()}:areaid=$areaid');
                print(c['courierId']);
                ships.add(c);
              }
            }
          }
        }
      }
    }
    courierList = [];
    List companies = ships.map((f) => Courier.fromList(f)).toList();

    ships.clear();

    return companies;
  }

  final ShipmentArea _newAddressForm = ShipmentArea(
    shipmentDistrId: '',
    shipmentArea: '',
    shipmentName: '',
    shipmentAddress: '',
  );

  Area stateValue;

  @override
  Widget build(BuildContext context) {
    return !_async
        ? Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
            SearchableDropdown(
              isExpanded: true,
              hint: Center(
                child: Text(
                  'حدد المنطقة',
                  softWrap: true,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              icon: Icon(
                Icons.location_on,
                size: 24,
              ),
              iconEnabledColor: Colors.pink[200],
              iconDisabledColor: Colors.grey,
              items: widget._areas,
              value: selectedArea,
              onChanged: (value) {
                setState(() async {
                  selectedArea = value;
                  areaSplit = selectedArea.split('\ ');
                  _newAddressForm.shipmentArea = selectedArea.substring(7);
                  _newAddressForm.shipmentArea = areaSplit.first;
                  print('split:${_newAddressForm.shipmentArea}');
                  List cl =
                      await couriersList(areaSplit.first, widget.regionId);
                  if (cl.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: Text('منطقة الشحن غير مفعله حاليا',
                                  style: TextStyle(color: Colors.pink[900])),
                              actions: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ));
                  } else {
                    setState(() {
                      selectedArea = value;
                      areaSplit = selectedArea.split('\ ');
                      _newAddressForm.shipmentArea = selectedArea.substring(7);
                      _newAddressForm.shipmentArea = areaSplit.first;
                    });
                  }
                });
              },
            ),
            areaSplit != null
                ? FormBuilder(
                    key: _addressFormKey,
                    autovalidate: true,
                    child: FormBuilderTextField(
                      enableInteractiveSelection: false,
                      expands: false,
                      autocorrect: true,
                      autovalidate: true,
                      maxLengthEnforced: false,
                      maxLines: 3,
                      attribute: "comment",
                      decoration: InputDecoration(
                        labelText: "تفاصيل العنوان",
                        /*  border: OutlineInputBorder(
                        gapPadding: 20,
                        borderSide: BorderSide(color: Colors.red),
                      ),*/
                      ),
                      onChanged: (value) {
                        setState(() {
                          isValid = _addressFormKey.currentState.validate();
                          _newAddressForm.shipmentAddress = value;
                        });
                      },

                      //  valueTransformer: (text) => num.tryParse(text),
                      validators: [
                        FormBuilderValidators.required(errorText: errorText),
                        FormBuilderValidators.minLength(3,
                            errorText: errorText),
                        FormBuilderValidators.maxLength(500, errorText: ''),
                      ],
                    ))
                : Container(),
            isValid
                ? ScopedModelDescendant<MainModel>(builder:
                    (BuildContext context, Widget child, MainModel model) {
                    return ModalProgressHUD(
                      inAsyncCall: _async,
                      opacity: 0.65,
                      child: IconButton(
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 42,
                        ),
                        onPressed: () async {
                          String msg = "";
                          String distrId;
                          widget.memberId == null
                              ? distrId = model.userInfo.distrId
                              : distrId = widget.memberId;

                          if (_validateAndSave(distrId)) {
                            print(_newAddressForm
                                .postAddressToJson(_newAddressForm));
                            await _saveAddress(model, distrId);
                          }
                        },
                      ),
                    );
                  })
                : Container(),
          ])
        : Container(
            child: ColorLoader2(),
          );
  }

  bool _validateAndSave(String memberId) {
    final addressData = _addressFormKey.currentState;
    isAsync(true);
    if (addressData.validate() &&
        _newAddressForm.shipmentArea != null &&
        _newAddressForm.shipmentName != null) {
      _newAddressForm.shipmentDistrId = memberId;
      _newAddressForm.shipmentArea = areaSplit.first;
      _newAddressForm.shipmentName = selectedArea.substring(7);
      _addressFormKey.currentState.save();
      isAsync(false);
      return true;
    }
    isAsync(false);
    return false;
  }

  Future _saveAddress(MainModel model, String memberId) async {
    isAsync(true);
    print('distrPoint:${model.distrPoint}');
    List<ShipmentArea> list =
        await model.getShipmentAreas(memberId, model.distrPoint);
    if (list.length == 3) {
      String delId = list.first.shipmentId.toString();
      http.delete(
          'http://mywayegypt-api.azurewebsites.net/api/delete_distr_shipment_place_record/$delId');
    }
    String msg;

    http.Response response =
        await _newAddressForm.createPost(_newAddressForm, model.setStoreId);
    if (response.statusCode == 201) {
      msg = 'نجحت';
      isAsync(false);
      Navigator.of(context).pop();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                height: 110.0,
                width: 110.0,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          ' إضافة العنوان $msg ',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (msg == 'نجحت') {
                          showDialog(
                              context: context,
                              builder: (_) => ShipmentPlace(
                                    model: model,
                                    memberId: memberId,
                                    isEdit: model.isBulk ? true : false,
                                  ));
                        }
                      },
                      child: Container(
                        height: 35.0,
                        width: 35.0,
                        color: Colors.white,
                        child: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
    } else {
      msg = 'فشلت';
      isAsync(false);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                height: 110.0,
                width: 110.0,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          ' إضافة العنوان $msg ',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (msg == 'نجحت') {
                          showDialog(
                              context: context,
                              builder: (_) => ShipmentPlace(
                                    model: model,
                                    isEdit: model.isBulk ? true : false,
                                  ));
                        }
                      },
                      child: Container(
                        height: 35.0,
                        width: 35.0,
                        color: Colors.white,
                        child: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
  }
}
