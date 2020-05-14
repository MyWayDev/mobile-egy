import 'package:flutter/material.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/courier.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/pages/order/order_cash.dart';
import 'package:mor_release/pages/order/widgets/order_courier.dart';
import 'package:mor_release/pages/order/widgets/shipmentArea.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class NodeOrder extends StatefulWidget {
  final MainModel model;
  final int distrPoint;
  NodeOrder(this.model, this.distrPoint);
  @override
  State<StatefulWidget> createState() {
    return _NodeOrder();
  }
}

@override
class _NodeOrder extends State<NodeOrder> {
  String type;
  List<ShipmentArea> shipmentAreas = [];
  List<Region> distrPoints = [];
  bool isSelected = false;

  bool _isloading = true;
  bool _hasData = false;

  hasData(bool data) {
    setState(() {
      _hasData = data;
    });
  }

  isloading(bool loading) {
    setState(() {
      _isloading = loading;
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

  final GlobalKey<FormState> _orderFormKey = GlobalKey<FormState>();

  final Map<String, dynamic> _orderFormData = {
    'id': null,
    'areaId': null,
    'name': null,
  };
  void isLoading() {
    bool o;
    shipment.length > 0 ? o = false : o = true;
    setState(() {
      loading = o;
    });
  }

  bool isTyping;

  void getTyping(MainModel model) {
    setState(() {
      model.isTypeing = isTyping;
    });
  }

  bool loading = false;

  bool veri = false;
  //int _courier;
  User _nodeData;
  Courier selectedCourier;
  List<Courier> shipment = [];

  void resetVeri(MainModel model) {
    controller.clear();
    setState(() {
      veri = false;
      isTyping = false;
    });
    getTyping(model);
    shipment = [];
  }

  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        child: Form(
          key: _orderFormKey,
          child: Column(
            children: <Widget>[
              Container(
                height: 50,
                child: ListTile(
                  //  contentPadding: EdgeInsets.all(0),
                  leading:
                      Icon(Icons.vpn_key, size: 24.0, color: Colors.pink[500]),
                  title: TextFormField(
                    textAlign: TextAlign.center,
                    controller: controller,
                    enabled: !veri ? true : false,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم العضو',
                      hintStyle: TextStyle(color: Colors.grey[400]),

                      //contentPadding: EdgeInsets.all(5.0),
                    ),
                    // controller: ,
                    //autocorrect: true,
                    //autofocus: true,
                    //autovalidate: true,
                    //initialValue: _isleader ? null : model.userInfo.distrId,

                    keyboardType: TextInputType.number,
                    validator: (value) => value.isEmpty
                        ? 'Code is Empty !!'
                        : RegExp('[0-9]').hasMatch(value)
                            ? null
                            : 'invalid code !!',
                    onSaved: (String value) {
                      _orderFormData['id'] = value.padLeft(8, '0');
                    },
                  ),
                  trailing: IconButton(
                    icon: !veri && controller.text.length > 0
                        ? Icon(
                            Icons.check,
                            size: 29.0,
                            color: Colors.blue,
                          )
                        : controller.text.length > 0
                            ? Icon(
                                Icons.close,
                                size: 24.0,
                                color: Colors.grey,
                              )
                            : Container(),
                    color: Colors.pink[900],
                    onPressed: () async {
                      shipmentAreas = [];
                      if (!veri) {
                        isTyping = true;
                        getTyping(model);
                        veri = await model.leaderVerification(
                            controller.text.padLeft(8, '0'));
                        if (veri) {
                          isTyping = true;
                          getTyping(model);
                          _nodeData = await model
                              .nodeJson(controller.text.padLeft(8, '0'));
                          _nodeData.distrId == '00000000'
                              ? resetVeri(model)
                              : controller.text =
                                  _nodeData.distrId + '    ' + _nodeData.name;
                          model.shipmentArea = '';
                          /* showDialog(
                              context: context,
                              builder: (_) => ShipmentPlace(
                                  model: model, memberId: _nodeData.distrId));
                          print(shipment.length);*/
                          //  await getAreas(_nodeData.distrId);

                          model.docType == 'CR' &&
                                  _nodeData.distrId != '00000000'
                              ? showDialog(
                                  context: context,
                                  builder: (_) => ShipmentPlace(
                                      model: model,
                                      memberId: _nodeData.distrId))
                              : null;
                        } else {
                          resetVeri(model);
                        }
                      } else {
                        resetVeri(model);
                      }
                    },
                    splashColor: Colors.pink,
                  ),
                ),
              ),
              veri &&
                      controller.text.length >= 8 &&
                      model.shipmentArea != '' &&
                      model.docType == 'CR'
                  ? BuildCourierOrder(model, _nodeData.distrId)
                  : veri &&
                          controller.text.length >= 8 &&
                          model.shipmentArea == '' &&
                          model.docType == 'CA'
                      ? BuildCashOrder(model, _nodeData.distrId)
                      : Container()
              // buildCourierOrder(context, model),
            ],
          ),
        ),
      );
    });
  }
}

class BuildCashOrder extends StatefulWidget {
  final MainModel model;
  final String distrId;

  BuildCashOrder(this.model, this.distrId);

  @override
  _BuildCashOrderState createState() => _BuildCashOrderState();
}

class _BuildCashOrderState extends State<BuildCashOrder> {
  List<Courier> shipment = [];
  void initNodeCourierList(MainModel model) async {
    shipment = await model.couriersList(model.shipmentArea, model.distrPoint);
  }

  @override
  void initState() {
    //initNodeCourierList(widget.model);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return shipment.length == 0 &&
            widget.model.shipmentArea == '' &&
            widget.distrId != '00000000'
        ? Card(
            color: Colors.grey[100],
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Flexible(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              CashOrder(widget.distrId,
                                  widget.model.userInfo.distrId),
                            ],
                          ))
                    ],
                  ),
                )
              ],
            ),
          )
        : Container();
  }
}

class BuildCourierOrder extends StatefulWidget {
  final MainModel model;
  final String distrId;

  BuildCourierOrder(this.model, this.distrId);

  @override
  _BuildCourierOrderState createState() => _BuildCourierOrderState();
}

class _BuildCourierOrderState extends State<BuildCourierOrder> {
  List<Courier> shipment = [];
  void initNodeCourierList(MainModel model) async {
    shipment = await model.couriersList(model.shipmentArea, model.distrPoint);
  }

  @override
  void initState() {
    initNodeCourierList(widget.model);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return shipment.length > 0 && widget.model.shipmentArea != ''
        ? Card(
            color: Colors.grey[100],
            child: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Flexible(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              CourierOrder(
                                  shipment,
                                  widget.model.shipmentArea,
                                  widget.distrId,
                                  widget.model.userInfo.distrId),
                            ],
                          ))
                    ],
                  ),
                )
              ],
            ),
          )
        : Container();
  }
}
