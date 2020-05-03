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
          return Dialog(
            backgroundColor: Color(0xFF303030),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 3),
                      height: 385,
                      width: 220,
                      child: storesDialog()),
                ],
              ),
            ),
          );
        });
  }

  String type;
  bool isSelected = false;

  Widget storesDialog() {
    return ListView.builder(
      itemCount: widget.model.stores.length,
      itemBuilder: (context, index) {
        return RaisedButton(
          color: Colors.amberAccent,
          elevation: 5,
          child: widget.model.stores.length > 0
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(widget.model.stores[index].name,
                        style: TextStyle(color: Colors.black)),
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
            //  await widget.model.getPoints(widget.model.stores[index].region);
            print('setStore:${widget.model.setStoreId}');
            print('name:${widget.model.distrPointName}');
            print('DocType:${widget.model.docType}');
            await widget.model.getPoints(widget.model.stores[index].region);

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _showNeedHelpButton() {
    return Padding(
      padding: widget.model.bulkOrder.length > 0 ||
              widget.model.itemorderlist.length > 0
          ? EdgeInsets.only(bottom: 26)
          : EdgeInsets.only(top: 16),
      child: Material(
        //Wrap with Material
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),

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
                    Padding(padding: EdgeInsets.only(right: 8)),
                    Text(widget.model.distrPointNames,
                        style: TextStyle(
                            fontSize: 13,
                            // fontWeight: FontWeight.bold,
                            color: Colors.amber[50])),
                  ],
                ),
                onPressed: widget.model.bulkOrder.length > 0 ||
                        widget.model.itemorderlist.length > 0
                    ? () {}
                    : () {
                        dialogDistrPoints(context, widget.model);
                      })),
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

  String type;
  bool isSelected = false;

  Widget _showNeedHelpButton() {
    return CircleAvatar(child: Icon(Icons.card_giftcard));
  }
}
