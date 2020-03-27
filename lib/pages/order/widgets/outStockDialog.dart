import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart';
import 'package:mor_release/models/item.order.dart';
import 'package:mor_release/pages/order/widgets/payment.dart';
import 'package:mor_release/scoped/connected.dart';

class OutStock extends StatelessWidget {
  final List<ItemOrder> balanceCheckOutPut;
  OutStock(this.balanceCheckOutPut);

  Flushbar flushAction(BuildContext context) {
    Flushbar flush = Flushbar(
      isDismissible: false,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.bounceIn,
      forwardAnimationCurve: Curves.fastOutSlowIn,

      mainButton: FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          GroovinMaterialIcons.close_circle_outline,
          color: Colors.red,
        ),
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      title: 'Out Of Stock List',
      messageText: Container(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Scrollbar(
                child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                  height: 300,
                  width: 275,
                  child: ListView.builder(
                    itemCount: balanceCheckOutPut.length,
                    itemBuilder: (context, i) {
                      return outStockCard(context, balanceCheckOutPut, i);
                    },
                  ),
                ),
              ]),
            )),
          )),
      //  message: 'Silahkan Lakukan Pembayaran Melalui',
      icon: Icon(
        GroovinMaterialIcons.alert,
        color: Colors.yellow,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.red[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    );
    return flush;
  }

  @override
  Widget build(BuildContext context) {
    return flushAction(context);
  }

  final formatter = new NumberFormat("#,###");
  Widget outStockCard(
      BuildContext context, List<ItemOrder> balanceCheckOutPut, int i) {
    return Center(
        child: Container(
            height: 35,
            child: ListTile(
              leading: Text(
                '${balanceCheckOutPut[i].itemId}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Qty ${balanceCheckOutPut[i].qty.toString()}',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                  Text(
                    'Bp ${balanceCheckOutPut[i].name}',
                    style: TextStyle(color: Colors.red[900], fontSize: 12),
                  ),
                ],
              ),
              trailing: Text(
                'Bp ${balanceCheckOutPut[i].name}',
                style: TextStyle(color: Colors.red[900], fontSize: 12),
              ),
            )));
  }
}
