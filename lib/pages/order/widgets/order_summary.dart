import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderSummary extends StatelessWidget {
  final String courierId;
  final double courierFee;
  final String distrId;
  final String note;
  final double courierDiscount;
  final formatter = new NumberFormat("#,###");
  final doubleFormat = new NumberFormat("####.##");

  OrderSummary(this.courierId, this.courierFee, this.distrId, this.note,
      this.courierDiscount);

  double finalCourierFee() {
    return courierFee - courierDiscount;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return !model.isBulk
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                model.orderBp() > 0
                    ? Container(
                        height: 130,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          // scrollDirection: Axis.vertical,
                          children: <Widget>[
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'إجمالى الوزن',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right
                                  ),
                                  leading: Text(
                                    doubleFormat.format(model.orderWeight()) +
                                        ' Kg',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                  trailing: Icon(
                                    GroovinMaterialIcons.weight_kilogram,
                                    size: 22,
                                    color: Colors.black,
                                    
                                  ),
                                )),
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'اجمالي النقاط',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                  leading: Text(
                                    model.orderBp().toString() + ' Bp',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  trailing: Icon(
                                    Icons.trending_up,
                                    size: 22,
                                    color: Colors.green,
                                  ),
                                )),
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'مصاريف الشحن',
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  leading: courierDiscount != null &&
                                          courierDiscount > 0
                                      ? Container(
                                          color: Colors.yellow[100],
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                "(" +
                                                    formatter.format(
                                                        courierFee ?? 0) +
                                                    ' EGP',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                " " +
                                                    "- " +
                                                    ((courierDiscount.toInt() /
                                                                courierFee
                                                                    .toInt()) *
                                                            100)
                                                        .toInt()
                                                        .toString() +
                                                    '%' +
                                                    ")",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.pink[900]),
                                              ),
                                              Text(
                                                " " +
                                                    formatter.format(
                                                        finalCourierFee() ??
                                                            0) +
                                                    '  EGP',
                                                softWrap: true,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ))
                                      : Text(
                                          formatter.format(courierFee ?? 0) +
                                              ' EGP',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                  trailing: Icon(
                                    Icons.local_shipping,
                                    size: 22,
                                    color: Colors.pink[900],
                                  ),
                                )),
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'الإجمالي',
                                    style: TextStyle(fontSize: 14),
                                    textAlign: TextAlign.right,
                                  ),
                                  leading: Text(
                                    formatter.format(model.orderSum()) + ' EGP',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  trailing: Icon(
                                    Icons.monetization_on,
                                    size: 22,
                                    color: Colors.yellow[600],
                                  ),
                                )),
                            /* Container(
                          height: 27,
                          child: ListTile(
                            title: Text(
                                formatter.format(model.settings.adminFee) +
                                    ' EGP'),
                            trailing: Icon(
                              Icons.more_horiz,
                              color: Colors.pink[900],
                            ),
                            leading: Text(
                              'Biaya Admin',
                              //  textDirection: TextDirection.rtl,
                            ),
                          )),*/
                          ],
                        ),
                      )
                    : Container()
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                model.bulkOrderBp() > 0
                    ? Container(
                        height: 130,
                        child: ListView(
                          physics: NeverScrollableScrollPhysics(),
                          // scrollDirection: Axis.vertical,
                          children: <Widget>[
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'إجمالى الوزن',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.right,
                                  ),
                                  leading: Text(
                                    doubleFormat
                                            .format(model.bulkOrderWeight()) +
                                        ' Kg',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  trailing: Icon(
                                    GroovinMaterialIcons.weight_kilogram,
                                    size: 22,
                                    color: Colors.black,
                                  ),
                                )),
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'اجمالي النقاط',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    // textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.right,
                                  ),
                                  leading: Text(
                                    model.bulkOrderBp().toInt().toString() +
                                        ' Bp',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  trailing: Icon(
                                    Icons.trending_up,
                                    size: 22,
                                    color: Colors.green,
                                  ),
                                )),
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'مصاريف الشحن',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                    // textDirection: TextDirection.rtl,
                                        textAlign: TextAlign.right,
                                  ),
                                  leading: courierDiscount != null &&
                                          courierDiscount > 0
                                      ? Container(
                                          color: Colors.yellow[100],
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                "(" +
                                                    formatter.format(
                                                        courierFee ?? 0) +
                                                    ' EGP',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                " " +
                                                    "- " +
                                                    ((courierDiscount.toInt() /
                                                                courierFee
                                                                    .toInt()) *
                                                            100)
                                                        .toInt()
                                                        .toString() +
                                                    '%' +
                                                    ")",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.pink[900]),
                                              ),
                                              Text(
                                                " " +
                                                    formatter.format(
                                                        finalCourierFee() ??
                                                            0) +
                                                    '  EGP',
                                                softWrap: true,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ))
                                      : Text(
                                          formatter.format(courierFee ?? 0) +
                                              ' EGP',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                  trailing: Icon(
                                    Icons.local_shipping,
                                    size: 22,
                                    color: Colors.pink[900],
                                  ),
                                )),
                            Container(
                                height: 27,
                                child: ListTile(
                                  title: Text(
                                    'الإجمالي',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold),
                                    // textDirection: TextDirection.rtl,
                                  ),
                                  leading: Text(
                                    formatter.format(model.bulkOrderSum()) +
                                        ' EGP',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  trailing: Icon(
                                    Icons.monetization_on,
                                    size: 22,
                                    color: Colors.yellow[900],
                                  ),
                                )),
                            /* Container(
                          height: 27,
                          child: ListTile(
                            title: Text(
                                formatter.format(model.settings.adminFee) +
                                    ' EGP'),
                            trailing: Icon(
                              Icons.more_horiz,
                              color: Colors.pink[900],
                            ),
                            leading: Text(
                              'Biaya Admin',
                              //  textDirection: TextDirection.rtl,
                            ),
                          )),*/
                          ],
                        ),
                      )
                    : Container()
              ],
            );
    });
  }
}
/* @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Flex(
        direction: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: Text(
              orderTotal(model).toString() + ' EGP',
              style: TextStyle(
                  color: Colors.pink[900], fontWeight: FontWeight.bold),
            ),
            trailing: RaisedButton(
              child: Text(
                'Menyimpan',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              color: Colors.green,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (_) => SaveDialog(
                        courierId, courierFee, model.userInfo.distrId, note));

                print(
                    'courierId:$courierId fee:$courierFee distr:${model.userInfo.distrId}note:$note');
                
                                                          model.orderBalanceCheck(
                                                            stateValue
                                                                .courierId,
                                                            courierFee);
              },
            ),
            title: Text(
              'Total pesanan',
              style: TextStyle(fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      );
    });
  }*/
