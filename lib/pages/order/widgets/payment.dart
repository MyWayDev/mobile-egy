import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/scoped/connected.dart';

class PaymentInfo extends StatelessWidget {
  final MainModel model;
  PaymentInfo(this.model);
  Flushbar flushAction(BuildContext context) {
    Flushbar flush = Flushbar(
      isDismissible: true,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      mainButton: FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(
          GroovinMaterialIcons.close_circle_outline,
          color: Colors.red,
        ),
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      titleText:
          Text('...', style: TextStyle(fontSize: 12, color: Colors.white)),
      messageText: Text('${model.settings.bankInfo}',
          style: TextStyle(fontSize: 14, color: Colors.white)),
      icon: Icon(
        GroovinMaterialIcons.bank,
        color: Colors.greenAccent,
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
