import 'dart:async';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/bottom_nav.dart';
import 'package:mor_release/models/backOrder.dart';
import 'package:mor_release/models/item.order.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class SaveDialog extends StatefulWidget {
  final String courierId;
  final double courierFee;
  final String distrId;
  final String note;
  final String areaId;
  final String userId;

  SaveDialog(this.courierId, this.courierFee, this.distrId, this.note,
      this.areaId, this.userId);
  @override
  State<StatefulWidget> createState() {
    return _SaveDialog();
  }
}

@override
class _SaveDialog extends State<SaveDialog> {
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

  bool vbpSum = false;
  double exbpSum = 0;

  Future<bool> pointsLimit(MainModel model) async {
    bool _vbpSum = true;

    if (widget.distrId != '00000001') {
      double pointsSum = await model.validatePointsLimit(widget.distrId);
      if (pointsSum > model.settings.memberBPLimit) {
        print(pointsSum);
        exbpSum = pointsSum - model.settings.memberBPLimit;
        _vbpSum = false;
      }
    }

    return _vbpSum;
  }

  @override
  Widget build(BuildContext context) {
    return _saveDialog(context);
  }

  Widget _saveDialog(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ModalProgressHUD(
        child: model.giftPacks.length == 0 && model.isBalanceChecked
            ? Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  height: 495.0,
                  width: 310.0,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
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
                      Text(
                        widget.distrId,
                        style: TextStyle(fontSize: 12),
                      ),
                      Container(
                        height: getBackOrderList(model).isEmpty ? 380 : 200,
                        width: 275,
                        child: ListView.builder(
                          itemCount: getOrderList(model).length,
                          itemBuilder: (context, i) {
                            return orderCard(context, model, i);
                          },
                        ),
                      ),
                      getBackOrderList(model).isNotEmpty
                          ? Container(
                              height: 17,
                              child: Text('اصناف مستند فك الحجز'),
                            )
                          : Container(),
                      getBackOrderList(model).isNotEmpty
                          ? Container(
                              height: 150,
                              width: 275,
                              child: ListView.builder(
                                itemCount: getBackOrderList(model).length,
                                itemBuilder: (context, i) {
                                  return backOrderCard(context, model, i);
                                },
                              ),
                            )
                          : Container(),
                      Container(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                  model.distrBonusList.isNotEmpty
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                              Text(
                                                'خصم من المكافأة',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                  '${model.distrBonusDeductTotal()}',
                                                  style: TextStyle(
                                                      color: Colors.green[900],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])
                                      : Container(),
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
                                            vbpSum = await pointsLimit(model);
                                            if (vbpSum) {
                                              OrderMsg msg =
                                                  await model.orderBalanceCheck(
                                                      widget.courierId,
                                                      widget.courierFee,
                                                      widget.distrId,
                                                      widget.note +
                                                          model.shipmentAddress,
                                                      widget.areaId);
                                              if (model.orderBp() == 0 &&
                                                  getOrderList(model).length ==
                                                      0) {
                                                model.isTypeing = false;
                                                Navigator.pop(context);
                                                isLoading(false, model);
                                                showReview(context, msg.soid,
                                                    msg.amt, msg.error);
                                                model.isTypeing = false;
                                                // PaymentInfo(model)
                                                //     .flushAction(context)
                                                //     .show(context);
                                              } else {
                                                isLoading(false, model);
                                              }
                                            } else {
                                              isLoading(false, model);
                                              model
                                                  .flush(
                                                      context,
                                                      " ${exbpSum.toInt()}" +
                                                          " ب " +
                                                          " Bp ${model.settings.memberBPLimit} " +
                                                          "الشخصى")
                                                  .show(context);
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
              )
            : Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  height: 475.0,
                  width: 310.0,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                  child: Column(
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
                          itemCount: getOrderList(model).length,
                          itemBuilder: (context, i) {
                            return orderCard(context, model, i);
                          },
                        ),
                      ),
                      Container(
                          height: 125.0,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 1.0, right: 1.0),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      'تم تحديث الطلبيه حسب الكميات المتاحه الان',
                                      softWrap: true,
                                      // textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  RawMaterialButton(
                                    child: Icon(
                                      Icons.undo,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                    shape: CircleBorder(),
                                    highlightColor: Colors.pink[900],
                                    elevation: 3,
                                    fillColor: Colors.yellow[900],
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    splashColor: Colors.pink[900],
                                  ),
                                  Text(
                                    'الرجاء العوده للتعديل',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
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
                borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              height: 110.0,
              width: 110.0,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
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
                            /*  Text(
                              '$amt :total biaya',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),*/
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
      height: 56,
      child: Card(
        color: Color(0xFFFFFFF1),
        elevation: 5,
        child: ListTile(
          leading: Padding(
            padding: EdgeInsets.only(left: 25),
            child: Text(
              getOrderList(model)[i].qty.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          title: Center(
            child: Text(
              getOrderList(model)[i].itemId,
              style: TextStyle(color: Color(0xFFFF8C00), fontSize: 12),
            ),
          ),
          trailing: CircleAvatar(
            backgroundColor: Colors.grey[100],
            backgroundImage: NetworkImage(
              getOrderList(model)[i].img,
            ),
          ),
        ),
      ),
    );
  }

  Widget backOrderCard(BuildContext context, MainModel model, int i) {
    return Container(
      height: 47,
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
          trailing: Text(
            'فك حجز',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
