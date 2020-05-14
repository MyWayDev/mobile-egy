import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mor_release/widgets/save_bulk_dialog.dart';
import 'package:mor_release/widgets/save_dialog.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderSave extends StatelessWidget {
  final String courierId;
  final double courierFee;
  final double courierDiscount;
  final String distrId;
  final String note;
  final String userId;
  final String areaId;
  final formatter = new NumberFormat("#,###.##");

  OrderSave(this.courierId, this.courierFee, this.courierDiscount, this.distrId,
      this.note, this.areaId, this.userId);
  double orderTotal(MainModel model) {
    return model.orderSum() + model.settings.adminFee;
  }

  double bulkOrderCourierFee(MainModel model) {
    double finalCourierFee = courierFee - courierDiscount;
    return finalCourierFee;
  }

  double bulkOrderTotal(MainModel model) {
    double finalBulkOrderSum = model.bulkOrderSum() + model.settings.adminFee;
    return finalBulkOrderSum;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return saveButton(context, model);
    });
  }

  Widget saveButton(BuildContext context, MainModel model) {
    return !model.isBulk
        ? Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      splashColor: Theme.of(context).primaryColor,
                      color: Colors.tealAccent[400],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            formatter.format((orderTotal(model)) + courierFee) +
                                ' EGP',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          Transform.translate(
                            offset: Offset(2.0, 0.0),
                            child: Container(
                                padding: const EdgeInsets.only(right: 2.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'اجمالى الطلبيه',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      //  textDirection: TextDirection.rtl,
                                      //   textAlign: TextAlign.right,
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        model.isBalanceChecked = true;

                        // model.promoOrderList.forEach(
                        //   (f) => print('bp?:${model.orderBp() / f.bp} qty:${f.qty}'));
                        //model.isTypeing = false;
                        showDialog(
                            context: context,
                            builder: (_) => SaveDialog(
                                courierId,
                                (courierFee - courierDiscount),
                                distrId,
                                note,
                                areaId,
                                userId));
                      })),
            ],
          )
        : Column(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      splashColor: Theme.of(context).primaryColor,
                      color: Colors.tealAccent[400],
                      child: Transform.translate(
                        offset: Offset(2.0, 0.0),
                        child: Container(
                            padding: const EdgeInsets.only(right: 2.0),
                            child: ListTile(
                              trailing: Text(
                                'اجمالى الطلبيه',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                textAlign: TextAlign.right,
                                //  textDirection: TextDirection.rtl,
                              ),
                              leading: Text(
                                formatter.format((bulkOrderTotal(model)) +
                                        bulkOrderCourierFee(model)) +
                                    ' EGP',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                      ),
                      /*   awaitExpanded(
                            child: Container(),
                          ),*/

                      onPressed: () async {
                        model.isBalanceChecked = true;

                        // model.promoOrderList.forEach(
                        //   (f) => print('bp?:${model.orderBp() / f.bp} qty:${f.qty}'));
                        model.isTypeing = false;
                        /*   await model.saveBulkOrders(model.bulkOrder,
                            (courierFee - courierDiscount), note, courierId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BottomNav(model.userInfo.distrId),
                          ),
                        );*/

                        showDialog(
                            context: context,
                            builder: (_) => SaveBulkDialog(
                                courierId,
                                (courierFee - courierDiscount),
                                distrId,
                                note,
                                areaId,
                                userId));
                      })),
            ],
          );
  }
}

/*

 */
