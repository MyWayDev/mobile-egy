import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/models/lock.dart';
import 'package:mor_release/scoped/connected.dart';

class StoreFloat extends StatefulWidget {
  final MainModel model;
  StoreFloat(this.model, {Key key}) : super(key: key);

  @override
  _StoreFloatState createState() => _StoreFloatState();
}

class _StoreFloatState extends State<StoreFloat>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Lock lock;

  @override
  void initState() {
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showNeedHelpButton();
  }

  dialogDistrPoints(BuildContext context, MainModel model) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              Align(
                  alignment: Alignment.topCenter,
                  child: ButtonBar(
                    children: <Widget>[
                      OutlineButton(
                          child: Icon(Icons.search),
                          onPressed: () {
                            Navigator.of(context).pop();

                            dialogAreas(context, widget.model);
                          }),
                    ],
                  )),
            ],
            backgroundColor: Color(0xFF303030),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                height: 380,
                width: 55,
                child: storesDialog(),
              ),
            ),
          );
        });
  }

  TextEditingController controller = new TextEditingController();
  dialogAreas(BuildContext context, MainModel model) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: <Widget>[
              /*  OutlineButton(
                  child: Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).pop();
                    dialogAreas(context, widget.model);
                  }),*/
              SizedBox(
                width: 50,
                height: 50,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "",
                    border: InputBorder.none,
                  ),
                  // style: TextStyle(fontSize: 18.0),
                  //onChanged: onSearchTextChanged,
                ),
              ),

              /*    IconButton(
                alignment: AlignmentDirectional.centerEnd,
                icon: Icon(Icons.cancel, size: 20.0),
                onPressed: () {
                  controller.clear();
                  // onSearchTextChanged('');
                },
              ),*/
            ],
            backgroundColor: Color(0xFF303030),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  height: 380,
                  width: 55,
                  child: areasDialog(),
                )),
          );
        });
  }

  String type;
  bool isSelected = false;

  Widget storesDialog() {
    return Scrollbar(
        child: ListView.builder(
      itemCount: widget.model.stores.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            RaisedButton(
              color: Colors.amberAccent,
              elevation: 8,
              child: widget.model.stores.length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.model.stores[index].name,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    )
                  : Text('Data Loading error'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black),
              ),
              onPressed: () async {
                setState(() {
                  widget.model.setStoreId = widget.model.stores[index].storeId;
                  widget.model.distrPoint = widget.model.stores[index].region;
                  widget.model.distrPointName = widget.model.stores[index].name;
                  widget.model.docType = widget.model.stores[index].docType;
                });
                print('distrPoint:${widget.model.distrPoint}');
                //await widget.model.getPoints(widget.model.stores[index].region);
                print('setStore:${widget.model.setStoreId}');
                print('name:${widget.model.distrPointName}');
                print('DocType:${widget.model.docType}');
                await widget.model.getPoints(widget.model.stores[index].region);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ));
  }

  Widget areasDialog() {
    return Scrollbar(
        child: ListView.builder(
      itemCount: widget.model.areaList.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            RaisedButton(
              color: Colors.lightBlueAccent,
              elevation: 8,
              child: widget.model.areaList.length > 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          widget.model.areaList[index].name,
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    )
                  : Text('Data Loading error'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.black),
              ),
              onPressed: () async {
                setState(() {
                  var _branch = widget.model.stores.firstWhere(
                      (s) => s.id == widget.model.areaList[index].branch);
                  widget.model.setStoreId = _branch.storeId;
                  widget.model.distrPoint = _branch.region;
                  widget.model.distrPointName = _branch.name;
                  widget.model.docType = _branch.docType;
                });

                //  await widget.model.getPoints(widget.model.stores[index].region);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ));
  }

  Widget _showNeedHelpButton() {
    return Padding(
      padding: widget.model.bulkOrder.length > 0 ||
              widget.model.itemorderlist.length > 0
          ? EdgeInsets.only(bottom: 26)
          : EdgeInsets.only(top: 16),
      child: Material(
        //Wrap with Material
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),

        elevation: 20.0,
        color: Colors.amber,
        clipBehavior: Clip.antiAliasWithSaveLayer, // Add This
        child: Opacity(
          opacity: widget.model.bulkOrder.length > 0 ||
                  widget.model.itemorderlist.length > 0
              ? .50
              : 1,
          child: MaterialButton(
            minWidth: 180.0,
            height: 30,
            color: Color(0xFF303030),
            child: Row(
              children: <Widget>[
                FadeTransition(
                  opacity: _animationController,
                  child: Icon(GroovinMaterialIcons.map_marker_radius,
                      color: Colors.amber, size: 20),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                ),
                Text(
                  widget.model.distrPointNames,
                  style: TextStyle(
                      fontSize: 13,
                      // fontWeight: FontWeight.bold,
                      color: Colors.amber[50]),
                ),
              ],
            ),
            onPressed: widget.model.bulkOrder.length > 0 ||
                    widget.model.itemorderlist.length > 0
                ? () {}
                : () {
                    dialogDistrPoints(context, widget.model);
                  },
          ),
        ),
      ),
    );
  }
}

class GiftFloat extends StatefulWidget {
  final MainModel model;
  GiftFloat(this.model, {Key key}) : super(key: key);

  @override
  _GiftFloatState createState() => _GiftFloatState();
}

class _GiftFloatState extends State<GiftFloat>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Lock lock;

  @override
  void initState() {
    _animationController = new AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showNeedHelpButton();
  }

  String type;
  bool isSelected = false;

  Widget _showNeedHelpButton() {
    return CircleAvatar(
      child: Icon(Icons.card_giftcard),
    );
  }
}
