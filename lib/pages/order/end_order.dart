import 'package:flutter/material.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/courier.dart';
import 'package:mor_release/pages/order/member_order.dart';
import 'package:mor_release/pages/order/node_order.dart';
import 'package:mor_release/pages/order/widgets/shipmentArea.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class EndOrder extends StatefulWidget {
  final MainModel model;
  EndOrder(this.model);
  State<StatefulWidget> createState() {
    return _EndOrder();
  }
}

@override
class _EndOrder extends State<EndOrder> with SingleTickerProviderStateMixin {
  //final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  //final GlobalKey<FormBuilderState> _fbKeyII = GlobalKey<FormBuilderState>();
  String shipmetArea = '';
  int distrpoint = 0;
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;
  NodeOrder nodeOrder;
  bool _isloading = false;
  bool isSelected = false;
  bool _hasData = false;

  List<Region> distrPoints = [];
  List<ShipmentArea> shipmentAreas = [];

  String type;
  hasData(bool data) {
    setState(() {
      _hasData = data;
    });
  }

  /* getAreas() async {
    isloading(true);
    shipmentAreas =
        await widget.model.getShipmentAreas(widget.model.userInfo.distrId);
    shipmentAreas.forEach((a) => print(a.shipmentArea));
    distrPoints = await widget.model.getPoints();
    print('distrPoints length:${distrPoints.length}');
    if (shipmentAreas.length > 0) {
      setState(() {
        hasData(true);
        isloading(false);
        print('isloading:$_isloading');
      });
    } else {
      setState(() {
        hasData(false);
        isloading(false);
        print('isloading:$_isloading');
      });
    }
  }*/

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });

    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(
      begin: Colors.blue,
      end: Colors.black45,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: _curve,
      ),
    ));

    // getAreas();
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animateii() {}
  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget toggleii() {
    return FloatingActionButton(
        backgroundColor: Colors.white, onPressed: animateii, child: Container()
        /*AnimatedIcon(
        icon: AnimatedIcons.menu_home,
        progress: _animateIcon,
      ),*/
        );
  }

  Widget toggle(MainModel model) {
    return FloatingActionButton(
      elevation: 20,
      backgroundColor: _animateColor.value,
      onPressed: () {
        animate();
        setState(() {
          model.shipmentArea = '';
          model.shipmentName = '';
        });
      },
      tooltip: 'Toggle',
      child: AnimatedIcon(
        icon: AnimatedIcons.home_menu,
        progress: _animateIcon,
      ),
    );
  }

  void settings(MainModel model) async {
    await model.settingsData();
  }

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  TextEditingController controller = new TextEditingController();
  bool _isleader = false;
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      _isleader = model.userInfo.isleader;
      // model.rungiftState();
      settings(model);

      return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    model.userInfo.name,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    model.distrPointName,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.amberAccent,
                    ),
                  )
                ]),
            actions: <Widget>[
              !isOpened && model.docType == 'CR'
                  ? IconButton(
                      icon: Icon(
                        Icons.playlist_add,
                        color: Colors.white,
                        size: 34,
                      ),
                      onPressed: () async {
                        model.shipmentArea = '';
                        // _hasData
                        showDialog(
                            context: context,
                            builder: (_) => ShipmentPlace(
                                  model: model,
                                ));
                        /*? : showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      title: Text('Add Shipment Area'),
                                    ));*/
                      },
                    )
                  : Container()
            ],
            leading: model.isTypeing
                ? Container()
                : !isOpened
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                        ),
                        onPressed: () {
                          model.isTypeing = false;
                          Navigator.of(context).pop(null);
                        })
                    : Container(),
          ),
          floatingActionButton:
              _isleader && !model.isTypeing ? toggle(model) : toggleii(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          body: Card(
              elevation: 5,
              child: isOpened
                  ? NodeOrder(model, model.distrPoint)
                  : model.shipmentArea != '' && model.distrPoint != 0
                      ? MemberOrder(model, model.distrPoint,
                          areaId: model.shipmentArea)
                      : model.docType == 'CA'
                          ? MemberOrder(model, model.distrPoint, areaId: '')
                          : Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'اضغط على الرمز أعلاه لإضافة عنوان',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                        color: Colors.grey[500]),
                                  ),
                                  Center(
                                      child: Icon(
                                    Icons.playlist_add,
                                    size: 70,
                                    color: Colors.grey[300],
                                  )),
                                  Padding(
                                    padding: EdgeInsets.only(top: 55),
                                  ),
                                  model.userInfo.isleader
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              ' اضغط على الرمز أدناه لطلبيات الشجرة  ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.grey[500]),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: 55),
                                            ),
                                            Center(
                                                child: Icon(
                                              Icons.arrow_downward,
                                              size: 50,
                                              color: Colors.grey[300],
                                            )),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            )));
    });
  }
/*
  Widget distrPoint(BuildContext context) {
    return AlertDialog(
      content: FormBuilder(
        key: _fbKey,
        child: FormBuilderDropdown(
          attribute: "Point",
          decoration: InputDecoration(labelText: "Point"),
          initialValue: distrPoints[0].id,
          hint: Text('Select Point'),
          validators: [FormBuilderValidators.required()],
          onChanged: (value) {
            print('dropdown value:$value');
            setState(() {
              distrpoint = value;
            });
          },
          items: distrPoints
              .map((region) => DropdownMenuItem(
                  value: region.id, child: Text("${region.name}")))
              .toList(),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.pink[900],
            size: 34,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        distrPoints.length > 0
            ? IconButton(
                icon: Icon(
                  Icons.done,
                  color: Colors.green,
                  size: 34,
                ),
                onPressed: () async {
                  _fbKey.currentState.save();
                  setState(() {
                    distrpoint = _fbKey.currentState.value.values.first.toInt();
                  });

                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (_) => ShipmentPlace(model: widget.model));
                },
              )
            : Container(),
      ],
    );
  }*/
}
