import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/pages/order/widgets/payment.dart';
import 'package:mor_release/pages/order/widgets/storeFloat.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class NewMemberPage extends StatefulWidget {
  //final List<Area> areas;
  // NewMemberPage(this.areas);
  State<StatefulWidget> createState() {
    return _NewMemberPage();
  }
}

//final FirebaseDatabase dataBase = FirebaseDatabase.instance;
@override
class _NewMemberPage extends State<NewMemberPage> {
  DateTime selected;
  String path = 'flamelink/environments/egyProduction/content/region/en-US/';
  FirebaseDatabase database = FirebaseDatabase.instance;
  TextEditingController controller = new TextEditingController();

  final GlobalKey<FormState> _newMemberFormKey = GlobalKey<FormState>();

  List<DropdownMenuItem> items = [];
  List<DropdownMenuItem> places = [];
  String selectedValue;
  String placeValue;
  var areaSplit;
  var placeSplit;

  bool _loading = false;

  @override
  void initState() {
    getPlaces();
    //  getAreas();
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _showDateTimePicker(String userId) async {
    selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050));
    // locale: Locale('fr'));
    setState(() {});
  }

  //final model = MainModel();
  void getAreas() async {
    DataSnapshot snapshot = await database.reference().child(path).once();

    Map<dynamic, dynamic> _areas = snapshot.value;
    List list = _areas.values.toList();
    List<Region> fbRegion = list.map((f) => Region.json(f)).toList();

    if (snapshot.value != null) {
      for (var t in fbRegion) {
        String sValue = "${t.regionId}" + " " + "${t.name}";
        items.add(
          DropdownMenuItem(
              child: Text(
                sValue,
                style: TextStyle(fontSize: 11),
              ),
              value: sValue),
        );
      }
    }
  }

  AreaPlace getplace(String id) {
    AreaPlace place;
    place = areaPlace.firstWhere((p) => p.shipmentPlace == id);
    print(
        'shipmentPlace:${place.shipmentPlace}:spName${place.spName}:areaId:${place.areaId}');
    return place;
  }

  List<AreaPlace> areaPlace;
  void getPlaces() async {
    areaPlace = [];
    final response = await http.get(
        'http://mywayegypt-api.azurewebsites.net/api/get_all_shipment_places/');
    if (response.statusCode == 200) {
      final _shipmentArea = json.decode(response.body) as List;
      areaPlace = _shipmentArea.map((s) => AreaPlace.json(s)).toList();
      //areaPlace.forEach((a) => print(a.spName));
    } else {
      areaPlace = [];
    }

    if (areaPlace.isNotEmpty) {
      for (var t in areaPlace) {
        String sValue = "${t.shipmentPlace}" + " " + "${t.spName}";
        places.add(
          DropdownMenuItem(
              child: Text(
                sValue,
                style: TextStyle(fontSize: 12),
              ),
              value: sValue),
        );
      }
    }
  }

  final NewMember _newMemberForm = NewMember(
    sponsorId: null,
    familyName: null,
    name: null,
    personalId: null,
    birthDate: null,
    email: null,
    telephone: null,
    address: null,
    areaId: null,
    bankAccoutName: null,
    bankAccountNumber: null,
    taxNumber: null,
    serviceCenter: null,
  );

  Area stateValue;
  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  bool veri = false;
  //int _courier;
  User _nodeData;

  void resetVeri() {
    controller.clear();
    setState(() {
      veri = false;
      _isloading = false;
    });
  }

  bool validData;
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  bool validateAndSave(String userId, String sc) {
    final form = _newMemberFormKey.currentState;
    isloading(true);
    if (form.validate() && selected != null && placeSplit.first != null) {
      _newMemberForm.birthDate =
          DateFormat('yyyy-MM-dd').format(selected).toString();
      _newMemberForm.email = userId;
      _newMemberForm.areaId = getplace(placeSplit.first).areaId;
      _newMemberForm.serviceCenter = sc;
      setState(() {
        validData = true;
      });
      // isloading(true);
      print('valide entry $validData');
      _newMemberFormKey.currentState.save();

      print('${_newMemberForm.sponsorId}:${_newMemberForm.birthDate}');
      isloading(false);
      return true;
    }
    isloading(false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: null,
            label: StoreFloat(model),
            isExtended: true,
            elevation: 30,
            backgroundColor: Colors.transparent),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        resizeToAvoidBottomPadding: false,
        body: ModalProgressHUD(
          child: Container(
            child: buildRegForm(context),
          ),
          inAsyncCall: _isloading,
          opacity: 0.6,
          progressIndicator: ColorLoader2(),
        ),
      );
    });
  }

  Widget buildRegForm(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        child: Form(
          key: _newMemberFormKey,
          child: ListView(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    primary: true,
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              contentPadding: EdgeInsets.only(left: 8),
                              leading: Icon(Icons.vpn_key,
                                  size: 25.0, color: Colors.pink[500]),
                              title: TextFormField(
                                textAlign: TextAlign.center,
                                controller: controller,
                                enabled: !veri ? true : false,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  hintText: ' ادخل رقم العضو الراعى',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) => value.isEmpty
                                    ? 'Code is Empty !!'
                                    : RegExp('[0-9]').hasMatch(value)
                                        ? null
                                        : 'invalid code !!',
                                onSaved: (_) {
                                  _newMemberForm.sponsorId = _nodeData.distrId;
                                },
                              ),
                              trailing: IconButton(
                                icon: !veri && controller.text.length > 0
                                    ? Icon(
                                        Icons.check,
                                        size: 30.0,
                                        color: Colors.blue,
                                      )
                                    : controller.text.length > 0
                                        ? Icon(
                                            Icons.close,
                                            size: 28.0,
                                            color: Colors.grey,
                                          )
                                        : Container(),
                                color: Colors.pink[900],
                                onPressed: () async {
                                  isloading(true);
                                  if (!veri) {
                                    veri = await model.leaderVerification(
                                        controller.text.padLeft(8, '0'));
                                    if (veri) {
                                      _nodeData = await model.nodeJson(
                                          controller.text.padLeft(8, '0'));
                                      _nodeData.distrId == '00000000'
                                          ? resetVeri()
                                          : controller.text =
                                              _nodeData.distrId +
                                                  ' ' +
                                                  _nodeData.name;
                                    } else {
                                      resetVeri();
                                    }
                                  } else {
                                    resetVeri();
                                  }
                                  isloading(false);
                                },
                                splashColor: Colors.pink,
                              ),
                            ),
                            ModalProgressHUD(
                                inAsyncCall: _loading,
                                opacity: 0.6,
                                progressIndicator: ColorLoader2(),
                                child: veri
                                    ? Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: <Widget>[
                                            ListTile(
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(model.settings.catCode,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .lightGreen[900],
                                                          fontSize: 15,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  veri
                                                      ? Container(
                                                          /*margin: const EdgeInsets.only(top: 8.0),
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),*/
                                                          child: Row(
                                                            children: <Widget>[
                                                              /*margin: const EdgeContainer(
                                      padding: EdgeInsets.only(right: 10.0),
                                    ),*/
                                                              Center(
                                                                child:
                                                                    IconButton(
                                                                  icon: Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .check_circle,
                                                                      color: Colors
                                                                              .greenAccent[
                                                                          400],
                                                                      size: 42,
                                                                    ),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    String msg =
                                                                        '';
                                                                    if (validateAndSave(
                                                                        model
                                                                            .userInfo
                                                                            .distrId,
                                                                        model
                                                                            .setStoreId)) {
                                                                      msg = await _saveNewMember(
                                                                          model
                                                                              .userInfo
                                                                              .distrId,
                                                                          model
                                                                              .docType,
                                                                          model
                                                                              .setStoreId);
                                                                      showReview(
                                                                          context,
                                                                          msg);

                                                                      _newMemberFormKey
                                                                          .currentState
                                                                          .reset();

                                                                      PaymentInfo(
                                                                              model)
                                                                          .flushAction(
                                                                              context)
                                                                          .show(
                                                                              context);
                                                                    }

                                                                    //  s

                                                                    //_newMemberFormKey.currentState.reset();
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container()
                                                ],
                                              ),
                                              leading: RawMaterialButton(
                                                child: Icon(
                                                  GroovinMaterialIcons
                                                      .calendar_check,
                                                  size: 24.0,
                                                  color: Colors.white,
                                                ),
                                                shape: CircleBorder(),
                                                highlightColor:
                                                    Colors.pink[500],
                                                elevation: 8,
                                                fillColor: Colors.pink[500],
                                                onPressed: () {
                                                  _showDateTimePicker(
                                                      model.userInfo.distrId);
                                                },
                                                splashColor: Colors.pink[900],
                                              ),
                                              title: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 30),
                                                child: selected != null
                                                    ? Text(
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(selected)
                                                            .toString())
                                                    : Text(''),
                                              ),
                                              subtitle: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 1),
                                                child: selected == null
                                                    ? Text('تاريخ الميلاد')
                                                    : Text(''),
                                              ),

                                              //trailing:
                                            ),
                                            Divider(
                                              height: 4,
                                              color: Colors.black,
                                            ),
                                            TextFormField(
                                              autovalidate: true,
                                              decoration: InputDecoration(
                                                  labelText: 'اسم العضو',
                                                  contentPadding:
                                                      EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                      GroovinMaterialIcons
                                                          .format_title,
                                                      color: Colors.pink[500])),
                                              /* validator: (value) {
                                              String _msg;
                                              value.length > 6
                                                  ? _msg =
                                                      'Nama anggota tidak valid'
                                                  : _msg = null;
                                              return _msg;
                                            },*/
                                              keyboardType: TextInputType.text,
                                              onSaved: (String value) {
                                                _newMemberForm.name = value;
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: 'الرقم القومي',
                                                  contentPadding:
                                                      EdgeInsets.all(4.0),
                                                  icon: Icon(
                                                      Icons.assignment_ind,
                                                      color: Colors.pink[500])),
                                              /*  'validator: (value) {
                                              String _msg;
                                              value.length <=16
                                                  ? _msg =
                                                      'خطأ فى حفظ الرقم الوطنى'
                                                  : _msg = null;
                                              return _msg;
                                            },*/
                                              autocorrect: true,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              keyboardType: TextInputType.text,
                                              onSaved: (String value) {
                                                _newMemberForm.personalId =
                                                    value;
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: 'رقم الهاتف',
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  contentPadding:
                                                      EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                    Icons.phone,
                                                    color: Colors.pink[500],
                                                  )),
                                              validator: (value) {
                                                String _msg;
                                                value.length < 8
                                                    ? _msg =
                                                        ' خطأ فى حفظ الهاتف'
                                                    : _msg = null;
                                                return _msg;
                                              },
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: true),
                                              onSaved: (String value) {
                                                _newMemberForm.telephone =
                                                    value;
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: 'العنوان',
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  contentPadding:
                                                      EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                    GroovinMaterialIcons.home,
                                                    color: Colors.pink[500],
                                                  )),
                                              validator: (value) {
                                                String _msg;
                                                value.length < 9
                                                    ? _msg =
                                                        'خطأ فى حفظ العنوان'
                                                    : _msg = null;
                                                return _msg;
                                              },
                                              keyboardType: TextInputType.text,
                                              onSaved: (String value) {
                                                _newMemberForm.address = value;
                                              },
                                            ),
                                            /*  TextFormField(
                                              decoration: InputDecoration(
                                                  labelText:
                                                      'Bank Account Name',
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  contentPadding:
                                                      EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                    GroovinMaterialIcons.bank,
                                                    color: Colors.pink[500],
                                                  )),
                                              validator: (value) {
                                                String _msg;
                                                value.length < 3
                                                    ? _msg = 'Name is too short'
                                                    : _msg = null;
                                                return _msg;
                                              },
                                              keyboardType: TextInputType.text,
                                              onSaved: (String value) {
                                                _newMemberForm.bankAccoutName =
                                                    value;
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText:
                                                      'Bank Account Number',
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  contentPadding:
                                                      EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                    GroovinMaterialIcons
                                                        .numeric,
                                                    color: Colors.pink[500],
                                                  )),
                                              /*  validator: (value) {
                                              String _msg;
                                              value.length < 16
                                                  ? _msg =
                                                      'Account# is too short'
                                                  : _msg = null;
                                              return _msg;
                                            },*/
                                              keyboardType:
                                                  TextInputType.number,
                                              onSaved: (String value) {
                                                _newMemberForm
                                                    .bankAccountNumber = value;
                                              },
                                            ),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                  labelText: 'Tax Number',
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  contentPadding:
                                                      EdgeInsets.all(2.0),
                                                  icon: Icon(
                                                    GroovinMaterialIcons
                                                        .tag_text_outline,
                                                    color: Colors.pink[500],
                                                  )),
                                              /*  validator: (value) {
                                              String _msg;
                                              value.length < 12
                                                  ? _msg = 'Tax is too short'
                                                  : _msg = null;
                                              return _msg;
                                            },*/
                                              keyboardType:
                                                  TextInputType.number,
                                              onSaved: (String value) {
                                                _newMemberForm.taxNumber =
                                                    value;
                                              },
                                            ),*/
                                            Container(
                                              width: 300,
                                              child: Wrap(children: <Widget>[
                                                Icon(Icons.add_location,
                                                    color: Colors.pink[500]),
                                                SearchableDropdown(
                                                  //style: TextStyle(fontSize: 12),
                                                  hint: Text('المنطقه'),
                                                  iconEnabledColor:
                                                      Colors.pink[200],
                                                  iconDisabledColor:
                                                      Colors.grey,
                                                  items: places,
                                                  value: selectedValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedValue = value;
                                                      placeSplit = selectedValue
                                                          .split('\ ');
                                                      print(placeSplit);
                                                    });
                                                  },
                                                )
                                              ]), /* Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SearchableDropdown(
                                                  hint: Text('region'),
                                                  icon: Icon(
                                                    Icons
                                                        .arrow_drop_down_circle,
                                                    size: 28,
                                                  ),
                                                  iconEnabledColor:
                                                      Colors.pink[200],
                                                  iconDisabledColor:
                                                      Colors.grey,
                                                  items: items,
                                                  value: selectedValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedValue = value;
                                                      areaSplit = selectedValue
                                                          .split('\ ');
                                                      _newMemberForm.areaId =
                                                          areaSplit.first;
                                                      print(
                                                          'split:${_newMemberForm.areaId}');
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),*/
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container()),
                          ]),
                    ),
                  )),
            ],
          ),
        ), //this line
      );
    });
  }

  String errorM = '';
  Future<String> _saveNewMember(
      String user, String docType, String storeId) async {
    print('docType:$docType:storeId:$storeId');
    Id body;
    String msg;
    isloading(true);
    print(_newMemberForm.postNewMemberToJson(_newMemberForm));
    Response response = await _newMemberForm.createPost(
        _newMemberForm,
        user,
        getplace(placeSplit.first).shipmentPlace,
        getplace(placeSplit.first).spName,
        docType,
        storeId);
    if (response.statusCode == 201) {
      body = Id.fromJson(json.decode(response.body));
      msg = body.id;
      print("body.id${body.id}");
    } else {
      msg = "خطأ في حفظ البيانات";
    }
    print(response.statusCode);
    print(msg);
    isloading(false);
    return msg;
  }

  Future<bool> showReview(BuildContext context, String msg) {
    return showDialog(
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
                        'رقم العضويه: $msg',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.pink[900],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/bottomnav', (_) => false);
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
  }
/*
  void _regPressed() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (validateAndSave()) {
      await initlegacyData(_registrationFormData['userId'])
          .catchError((e) => '');
      await fireData(_registrationFormData['userId']).catchError((e) => '');
      if (!_legacyDataExits || _fireDataExits) {
        errorM = 'wrong code';
        print('legacyDataExits:$_legacyDataExits');
        print('fireDataExits:$_fireDataExits');
        isloading(false);
        print(errorM);
      } else {
        print('legacyDataExits:$_legacyDataExits');
        print('fireDataExits:$_fireDataExits');
        errorM = 'Good to GO';
        print(errorM);
        validateAndSubmit();
      }
    }
        TextFormField(
                        decoration: InputDecoration(
                            labelText: 'ID sponsor',
                            contentPadding: EdgeInsets.all(8.0),
                            icon: Icon(Icons.vpn_key, color: Colors.pink[500])),
                        //autocorrect: true,
                        autofocus: true,
                        //autovalidate: true,
                        // initialValue: '00000000',
                        validator: (value) => value.isEmpty
                            ? 'ID member !!'
                            : RegExp('[0-9]').hasMatch(value)
                                ? null
                                : 'ID member !!',
                        keyboardType: TextInputType.number,
                        onSaved: (String value) {
                          _newMemberFormData['sponsorId'] =
                              value.padLeft(8, '0');
                        },
                      ),
  }*/
}

class Id {
  String id;

  Id({this.id});

  factory Id.fromJson(Map<String, dynamic> json) {
    return Id(id: json['id']);
  }
}
/*
import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/pages/order/widgets/payment.dart';
import 'package:mor_release/pages/order/widgets/shipmentArea.dart';
import 'package:mor_release/pages/order/widgets/storeFloat.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class NewMemberPage extends StatefulWidget {
  //final List<Area> areas;
  // NewMemberPage(this.areas);
  State<StatefulWidget> createState() {
    return _NewMemberPage();
  }
}

//final FirebaseDatabase dataBase = FirebaseDatabase.instance;
@override
class _NewMemberPage extends State<NewMemberPage> {
  DateTime selected;
  String path = 'flamelink/environments/egyProduction/content/district/en-US/';
  FirebaseDatabase database = FirebaseDatabase.instance;
  TextEditingController controller = new TextEditingController();

  final GlobalKey<FormState> _newMemberFormKey = GlobalKey<FormState>();

  List<DropdownMenuItem> items = [];
  List<DropdownMenuItem> places = [];
  String selectedValue;
  String placeValue;
  var areaSplit;
  var placeSplit;

  bool _loading = false;

  @override
  void initState() {
    getDistrict();
    //  getAreas();
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _showDateTimePicker(String userId) async {
    selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050));
    // locale: Locale('fr'));
    setState(() {});
  }

  //final model = MainModel();
  void getAreas() async {
    DataSnapshot snapshot = await database.reference().child(path).once();

    Map<dynamic, dynamic> _areas = snapshot.value;
    List list = _areas.values.toList();
    List<District> fbRegion = list.map((f) => District.json(f)).toList();

    if (snapshot.value != null) {
      for (var t in fbRegion) {
        String sValue = "${t.districtId}" + " " + "${t.name}";
        items.add(
          DropdownMenuItem(
              child: Text(
                sValue,
                style: TextStyle(fontSize: 11),
              ),
              value: sValue),
        );
      }
    }
  }

  AreaPlace getplace(String id) {
    AreaPlace place;
    place = areaPlace.firstWhere((p) => p.shipmentPlace == id);
    print(
        'shipmentPlace:${place.shipmentPlace}:spName${place.spName}:areaId:${place.areaId}');
    return place;
  }

  void getDistrict() async {
    DataSnapshot snapshot = await database.reference().child(path).once();

    Map<dynamic, dynamic> _areas = snapshot.value;
    List list = _areas.values.toList();
    List<District> fbRegion = list.map((f) => District.json(f)).toList();

    if (snapshot.value != null) {
      for (var t in fbRegion) {
        String sValue = "${t.districtId}" + " " + "${t.name}";
        places.add(
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

  List<AreaPlace> areaPlace;
  void getPlaces() async {
    areaPlace = [];
    final response = await http.get(
        'http://mywayegypt-api.azurewebsites.net/api/get_all_shipment_places/');
    if (response.statusCode == 200) {
      final _shipmentArea = json.decode(response.body) as List;
      areaPlace = _shipmentArea.map((s) => AreaPlace.json(s)).toList();
      //areaPlace.forEach((a) => print(a.spName));
    } else {
      areaPlace = [];
    }

    if (areaPlace.isNotEmpty) {
      for (var t in areaPlace) {
        String sValue = "${t.shipmentPlace}" + " " + "${t.spName}";
        places.add(
          DropdownMenuItem(
              child: Text(
                sValue,
                style: TextStyle(fontSize: 12),
              ),
              value: sValue),
        );
      }
    }
  }

  final NewMember _newMemberForm = NewMember(
    sponsorId: null,
    familyName: null,
    name: null,
    personalId: null,
    birthDate: null,
    email: null,
    telephone: null,
    address: null,
    areaId: null,
    bankAccoutName: null,
    bankAccountNumber: null,
    taxNumber: null,
    serviceCenter: null,
  );

  Area stateValue;

  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  bool veri = false;
  //int _courier;
  User _nodeData;

  void resetVeri() {
    controller.clear();
    setState(() {
      veri = false;
      _isloading = false;
    });
  }

  bool validData;
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  bool validateAndSave(String userId, String sc) {
    final form = _newMemberFormKey.currentState;
    isloading(true);
    if (form.validate() && selected != null && placeSplit.first != null) {
      _newMemberForm.birthDate =
          DateFormat('yyyy-MM-dd').format(selected).toString();
      _newMemberForm.email = userId;
      _newMemberForm.areaId =
          placeSplit.first; //getplace(placeSplit.first).areaId;
      _newMemberForm.serviceCenter = sc;
      setState(() {
        validData = true;
      });
      // isloading(true);
      print('valide entry $validData');
      _newMemberFormKey.currentState.save();

      print('${_newMemberForm.sponsorId}:${_newMemberForm.birthDate}');
      isloading(false);
      return true;
    }
    isloading(false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: null,
            label: StoreFloat(model),
            isExtended: true,
            elevation: 30,
            backgroundColor: Colors.transparent),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        resizeToAvoidBottomPadding: false,
        body: ModalProgressHUD(
          child: Container(
            child: buildRegForm(context),
          ),
          inAsyncCall: _isloading,
          opacity: 0.6,
          progressIndicator: ColorLoader2(),
        ),
      );
    });
  }

  Widget buildRegForm(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        child: Form(
          key: _newMemberFormKey,
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            contentPadding: EdgeInsets.only(left: 8),
                            leading: Icon(Icons.vpn_key,
                                size: 25.0, color: Colors.pink[500]),
                            title: TextFormField(
                              textAlign: TextAlign.center,
                              controller: controller,
                              enabled: !veri ? true : false,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: ' ادخل رقم العضو الراعى',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value.isEmpty
                                  ? 'Code is Empty !!'
                                  : RegExp('[0-9]').hasMatch(value)
                                      ? null
                                      : 'invalid code !!',
                              onSaved: (_) {
                                _newMemberForm.sponsorId = _nodeData.distrId;
                              },
                            ),
                            trailing: IconButton(
                              icon: !veri && controller.text.length > 0
                                  ? Icon(
                                      Icons.check,
                                      size: 30.0,
                                      color: Colors.blue,
                                    )
                                  : controller.text.length > 0
                                      ? Icon(
                                          Icons.close,
                                          size: 28.0,
                                          color: Colors.grey,
                                        )
                                      : Container(),
                              color: Colors.pink[900],
                              onPressed: () async {
                                isloading(true);
                                if (!veri) {
                                  veri = await model.leaderVerification(
                                      controller.text.padLeft(8, '0'));
                                  if (veri) {
                                    _nodeData = await model.nodeJson(
                                        controller.text.padLeft(8, '0'));
                                    _nodeData.distrId == '00000000'
                                        ? resetVeri()
                                        : controller.text = _nodeData.distrId +
                                            ' ' +
                                            _nodeData.name;
                                  } else {
                                    resetVeri();
                                  }
                                } else {
                                  resetVeri();
                                }
                                isloading(false);
                              },
                              splashColor: Colors.pink,
                            ),
                          ),
                          ModalProgressHUD(
                              inAsyncCall: _loading,
                              opacity: 0.6,
                              progressIndicator: ColorLoader2(),
                              child: veri
                                  ? Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          ListTile(
                                            trailing: Text('10 EGP',
                                                style: TextStyle(
                                                    color:
                                                        Colors.lightGreen[900],
                                                    fontSize: 15,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            leading: RawMaterialButton(
                                              child: Icon(
                                                GroovinMaterialIcons
                                                    .calendar_check,
                                                size: 24.0,
                                                color: Colors.white,
                                              ),
                                              shape: CircleBorder(),
                                              highlightColor: Colors.pink[500],
                                              elevation: 8,
                                              fillColor: Colors.pink[500],
                                              onPressed: () {
                                                _showDateTimePicker(
                                                    model.userInfo.distrId);
                                              },
                                              splashColor: Colors.pink[900],
                                            ),
                                            title: Padding(
                                              padding: EdgeInsets.only(top: 30),
                                              child: selected != null
                                                  ? Text(
                                                      DateFormat('yyyy-MM-dd')
                                                          .format(selected)
                                                          .toString())
                                                  : Text(''),
                                            ),
                                            subtitle: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 1),
                                              child: selected == null
                                                  ? Text('تاريخ الميلاد')
                                                  : Text(''),
                                            ),

                                            //trailing:
                                          ),
                                          Divider(
                                            height: 4,
                                            color: Colors.black,
                                          ),
                                          TextFormField(
                                            autovalidate: true,
                                            decoration: InputDecoration(
                                                labelText: 'اسم العضو',
                                                contentPadding:
                                                    EdgeInsets.all(2.0),
                                                icon: Icon(
                                                    GroovinMaterialIcons
                                                        .format_title,
                                                    color: Colors.pink[500])),
                                            /* validator: (value) {
                                              String _msg;
                                              value.length > 6
                                                  ? _msg =
                                                      'Nama anggota tidak valid'
                                                  : _msg = null;
                                              return _msg;
                                            },*/
                                            keyboardType: TextInputType.text,
                                            onSaved: (String value) {
                                              _newMemberForm.name = value;
                                            },
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                                labelText: 'الرقم القومى',
                                                contentPadding:
                                                    EdgeInsets.all(4.0),
                                                icon: Icon(Icons.assignment_ind,
                                                    color: Colors.pink[500])),
                                            /*  'validator: (value) {
                                              String _msg;
                                              value.length <=16
                                                  ? _msg =
                                                      'خطأ فى حفظ الرقم الوطنى'
                                                  : _msg = null;
                                              return _msg;
                                            },*/
                                            autocorrect: true,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            keyboardType: TextInputType.text,
                                            onSaved: (String value) {
                                              _newMemberForm.personalId = value;
                                            },
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                                labelText: 'رقم الهاتف',
                                                filled: true,
                                                fillColor: Colors.transparent,
                                                contentPadding:
                                                    EdgeInsets.all(2.0),
                                                icon: Icon(
                                                  Icons.phone,
                                                  color: Colors.pink[500],
                                                )),
                                            validator: (value) {
                                              String _msg;
                                              value.length < 8
                                                  ? _msg = ' خطأ فى حفظ  الهاتف'
                                                  : _msg = null;
                                              return _msg;
                                            },
                                            keyboardType:
                                                TextInputType.numberWithOptions(
                                                    signed: true),
                                            onSaved: (String value) {
                                              _newMemberForm.telephone = value;
                                            },
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                                labelText: 'العنوان',
                                                filled: true,
                                                fillColor: Colors.transparent,
                                                contentPadding:
                                                    EdgeInsets.all(2.0),
                                                icon: Icon(
                                                  GroovinMaterialIcons.home,
                                                  color: Colors.pink[500],
                                                )),
                                            validator: (value) {
                                              String _msg;
                                              value.length < 9
                                                  ? _msg = 'خطأ فى حفظ العنوان'
                                                  : _msg = null;
                                              return _msg;
                                            },
                                            keyboardType: TextInputType.text,
                                            onSaved: (String value) {
                                              _newMemberForm.address = value;
                                            },
                                          ),
                                          // TextFormField(
                                          //   decoration: InputDecoration(
                                          //       labelText: 'Bank Account Name',
                                          //       filled: true,
                                          //       fillColor: Colors.transparent,
                                          //       contentPadding:
                                          //           EdgeInsets.all(2.0),
                                          //       icon: Icon(
                                          //         GroovinMaterialIcons.bank,
                                          //         color: Colors.pink[500],
                                          //       )),
                                          //   validator: (value) {
                                          //     String _msg;
                                          //     value.length < 3
                                          //         ? _msg = 'Name is too short'
                                          //         : _msg = null;
                                          //     return _msg;
                                          //   },
                                          //   keyboardType: TextInputType.text,
                                          //   onSaved: (String value) {
                                          //     _newMemberForm.bankAccoutName =
                                          //         value;
                                          //   },
                                          // ),
                                          // TextFormField(
                                          //   decoration: InputDecoration(
                                          //       labelText:
                                          //           'Bank Account Number',
                                          //       filled: true,
                                          //       fillColor: Colors.transparent,
                                          //       contentPadding:
                                          //           EdgeInsets.all(2.0),
                                          //       icon: Icon(
                                          //         GroovinMaterialIcons.numeric,
                                          //         color: Colors.pink[500],
                                          //       )),
                                          //   /*  validator: (value) {
                                          //     String _msg;
                                          //     value.length < 16
                                          //         ? _msg =
                                          //             'Account# is too short'
                                          //         : _msg = null;
                                          //     return _msg;
                                          //   },*/
                                          //   keyboardType: TextInputType.number,
                                          //   onSaved: (String value) {
                                          //     _newMemberForm.bankAccountNumber =
                                          //         value;
                                          //   },
                                          // ),
                                          // TextFormField(
                                          //   decoration: InputDecoration(
                                          //       labelText: 'Tax Number',
                                          //       filled: true,
                                          //       fillColor: Colors.transparent,
                                          //       contentPadding:
                                          //           EdgeInsets.all(2.0),
                                          //       icon: Icon(
                                          //         GroovinMaterialIcons
                                          //             .tag_text_outline,
                                          //         color: Colors.pink[500],
                                          //       )),
                                          //   /*  validator: (value) {
                                          //     String _msg;
                                          //     value.length < 12
                                          //         ? _msg = 'Tax is too short'
                                          //         : _msg = null;
                                          //     return _msg;
                                          //   },*/
                                          //   keyboardType: TextInputType.number,
                                          //   onSaved: (String value) {
                                          //     _newMemberForm.taxNumber = value;
                                          //   },
                                          // ),
                                          Container(
                                            width: 300,
                                            child: Wrap(children: <Widget>[
                                              Icon(Icons.add_location,
                                                  color: Colors.pink[500]),
                                              SearchableDropdown(
                                                //style: TextStyle(fontSize: 12),
                                                hint: Text('المنطقه'),
                                                iconEnabledColor:
                                                    Colors.pink[200],
                                                iconDisabledColor: Colors.grey,
                                                items: places,
                                                value: selectedValue,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedValue = value;
                                                    placeSplit = selectedValue
                                                        .split('\ ');
                                                    print(placeSplit);
                                                  });
                                                },
                                              )
                                            ]), /* Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                SearchableDropdown(
                                                  hint: Text('region'),
                                                  icon: Icon(
                                                    Icons
                                                        .arrow_drop_down_circle,
                                                    size: 28,
                                                  ),
                                                  iconEnabledColor:
                                                      Colors.pink[200],
                                                  iconDisabledColor:
                                                      Colors.grey,
                                                  items: items,
                                                  value: selectedValue,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedValue = value;
                                                      areaSplit = selectedValue
                                                          .split('\ ');
                                                      _newMemberForm.areaId =
                                                          areaSplit.first;

                                                      print(
                                                          'split:${_newMemberForm.areaId}');
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),*/
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container()),
                        ]),
                  ),
                ),
              ),
              veri
                  ? Container(
                      margin: const EdgeInsets.only(top: 8.0),
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(right: 10.0),
                          ),
                          Expanded(
                              child: SingleChildScrollView(
                            child: IconButton(
                              icon: Center(
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent[400],
                                  size: 42,
                                ),
                              ),
                              onPressed: () async {
                                String msg = '';
                                if (validateAndSave(
                                    model.userInfo.distrId, model.setStoreId)) {
                                  msg = await _saveNewMember(
                                      model.userInfo.distrId,
                                      model.docType,
                                      model.setStoreId);
                                  showReview(context, msg);

                                  _newMemberFormKey.currentState.reset();

                                  // PaymentInfo(model)
                                  //     .flushAction(context)
                                  //     .show(context);

                                }

                                //  s

                                //_newMemberFormKey.currentState.reset();
                              },
                            ),
                          )),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      );
    });
  }

  String errorM = '';
  Future<String> _saveNewMember(
      String user, String docType, String storeId) async {
    print('docType:$docType:storeId:$storeId');
    Id body;
    String msg;
    isloading(true);
    print(_newMemberForm.postNewMemberToJson(_newMemberForm));
    Response response = await _newMemberForm.createPost(
        _newMemberForm,
        user,
        '100058', //getplace(placeSplit.first).shipmentPlace,
        'جسر السويس', //getplace(placeSplit.first).spName,
        docType,
        storeId);
    if (response.statusCode == 201) {
      body = Id.fromJson(json.decode(response.body));
      msg = body.id;
      print("body.id${body.id}");
    } else {
      msg = "خطأ فى حفظ البيانات";
    }
    print(response.statusCode);
    print(msg);
    isloading(false);

    return msg;
  }

  Future<bool> showReview(BuildContext context, String msg) {
    return showDialog(
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
                        'رقم العضويه : ' + msg.substring(0, 8),
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.pink[900],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/bottomnav', (_) => false);
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
  }
/*
  void _regPressed() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (validateAndSave()) {
      await initlegacyData(_registrationFormData['userId'])
          .catchError((e) => '');
      await fireData(_registrationFormData['userId']).catchError((e) => '');
      if (!_legacyDataExits || _fireDataExits) {
        errorM = 'wrong code';
        print('legacyDataExits:$_legacyDataExits');
        print('fireDataExits:$_fireDataExits');
        isloading(false);
        print(errorM);
      } else {
        print('legacyDataExits:$_legacyDataExits');
        print('fireDataExits:$_fireDataExits');
        errorM = 'Good to GO';
        print(errorM);
        validateAndSubmit();
      }
    }
        TextFormField(
                        decoration: InputDecoration(
                            labelText: 'ID sponsor',
                            contentPadding: EdgeInsets.all(8.0),
                            icon: Icon(Icons.vpn_key, color: Colors.pink[500])),
                        //autocorrect: true,
                        autofocus: true,
                        //autovalidate: true,
                        // initialValue: '00000000',
                        validator: (value) => value.isEmpty
                            ? 'ID member !!'
                            : RegExp('[0-9]').hasMatch(value)
                                ? null
                                : 'ID member !!',

                        keyboardType: TextInputType.number,
                        onSaved: (String value) {
                          _newMemberFormData['sponsorId'] =
                              value.padLeft(8, '0');
                        },
                      ),
  }*/
}

class Id {
  String id;

  Id({this.id});

  factory Id.fromJson(Map<String, dynamic> json) {
    return Id(id: json['id']);
  }
}
*/
