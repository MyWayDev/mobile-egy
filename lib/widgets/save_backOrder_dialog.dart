import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/bottom_nav.dart';
import 'package:mor_release/models/backOrder.dart';
import 'package:mor_release/models/item.order.dart';
import 'package:mor_release/pages/order/widgets/distrBonusList.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class BackOrderSaveDialog extends StatefulWidget {
  final String courierId;
  final double courierFee;
  final String distrId;
  final String note;
  final String areaId;
  final String userId;

  BackOrderSaveDialog(this.courierId, this.courierFee, this.distrId, this.note,
      this.areaId, this.userId);
  @override
  State<StatefulWidget> createState() {
    return _BackOrderSaveDialog();
  }
}

@override
class _BackOrderSaveDialog extends State<BackOrderSaveDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void isLoading(bool o, MainModel model) {
    setState(() {
      model.loading = o;
    });
  }

  List<ItemOrder> getOrderList(MainModel model) {
    return model.itemorderlist.where((test) => test.bp != 0).toList();
  }

  List<BackOrder> getBackOrderList(MainModel model) {
    List<BackOrder> bOs = [];
    for (BackOrderRelease _backOrdersList in model.backOrdersList) {
      for (BackOrder _backOrder in _backOrdersList.backOrder) {
        if (_backOrder != null) {
          bOs.add(_backOrder);
        }
      }
    }

    return bOs;
  }

  @override
  Widget build(BuildContext context) {
    return _saveDialog(context);
  }

  Widget _saveDialog(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ModalProgressHUD(
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Card(
                  elevation: 3,
                  color: Colors.grey[100],
                  child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            'الكمية',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            'الكود',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Text(
                            '#',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                ),
                Container(
                  height: 300,
                  width: 275,
                  child: ListView.builder(
                    itemCount: getBackOrderList(model).length,
                    itemBuilder: (context, i) {
                      return orderCard(context, model, i);
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            RawMaterialButton(
                              child: Icon(
                                Icons.undo,
                                size: 24.0,
                                color: Colors.white,
                              ),
                              shape: CircleBorder(),
                              highlightColor: Colors.pink[900],
                              elevation: 3,
                              fillColor: Colors.yellowAccent[700],
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              splashColor: Colors.pink[900],
                            ),
                            !model.loading
                                ? RawMaterialButton(
                                    child: Icon(
                                      Icons.done_all,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                    shape: CircleBorder(),
                                    highlightColor: Colors.pink[900],
                                    elevation: 3,
                                    fillColor: Colors.green,
                                    onPressed: () async {
                                      isLoading(true, model);
                                      if (model.distrBonusList.isNotEmpty) {
                                        model.distrBonusList = null;
                                      }
                                      OrderMsg msg = await model.saveOrder(
                                          widget.courierId,
                                          model.settings.backOrderFee
                                              .toDouble(),
                                          widget.distrId,
                                          widget.note,
                                          widget.areaId,
                                          isbackOrderOnly: true);

                                      if (model.orderBp() == 0 &&
                                          getOrderList(model).length == 0) {
                                        model.isTypeing = false;
                                        Navigator.pop(context);
                                        isLoading(false, model);
                                        showReview(context, msg.soid, msg.amt,
                                            msg.error);
                                        model.isTypeing = false;
                                        // PaymentInfo(model)
                                        // .flushAction(context)
                                        // .show(context);
                                      } else {
                                        isLoading(false, model);
                                      }
                                    },
                                    splashColor: Colors.pink[900],
                                  )
                                : Container(),
                          ]),
                    )),
              ],
            ),
          ),
        ),
        inAsyncCall: model.loading,
        opacity: 0.6,
        progressIndicator: ColorLoader2(),
      );
    });
  }

  Future<bool> showReview(
      BuildContext context, String soid, double amt, String error) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Container(
              height: 90.0,
              width: 90.0,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30.0)),
              child: Column(
                children: <Widget>[
                  soid != null || amt != 0 || soid != ''
                      ? Column(
                          children: <Widget>[
                            Text(
                              'رقم الطلبية : $soid',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : Column(
                          children: <Widget>[
                            Text(
                              '$error',
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                          ],
                        ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNav(widget.userId),
                            // ItemDetails(widget.itemData[widget.index])
                          ),
                          (_) => false);
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

  Widget orderCard(BuildContext context, MainModel model, int i) {
    return Container(
      height: 60,
      child: Card(
        color: Colors.yellowAccent[100],
        elevation: 5,
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(left: 25),
            child: Text(
              getBackOrderList(model)[i].qty.toInt().toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          title: Center(
            child: Text(
              getBackOrderList(model)[i].itemId,
              style: TextStyle(color: Colors.blue[800], fontSize: 12),
            ),
          ),
          trailing: Text('فك حجز'),
        ),
      ),
    );
  }
}
