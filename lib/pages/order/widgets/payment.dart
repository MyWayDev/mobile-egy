import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/scoped/connected.dart';

class PaymentInfo extends StatelessWidget {
  final MainModel model;
  final String msg;
  PaymentInfo(this.model, this.msg);
  Flushbar flushAction(BuildContext context) {
    Flushbar flush = Flushbar(
      isDismissible: true,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      mainButton: FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(
          GroovinMaterialIcons.close_circle_outline,
          size: 30,
          color: Colors.pink[500],
        ),
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      titleText: Text('', style: TextStyle(fontSize: 15, color: Colors.white)),
      messageText: Text(msg,
          textDirection: TextDirection.ltr,
          style: TextStyle(fontSize: 16, color: Colors.white)),
      icon: Icon(
        GroovinMaterialIcons.alert_circle,
        size: 36,
        color: Colors.red,
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
}
