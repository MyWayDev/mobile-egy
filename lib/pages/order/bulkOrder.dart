import 'package:flutter/material.dart';
import 'package:mor_release/models/courier.dart';
import 'package:mor_release/pages/order/widgets/order_courier.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class BulkOrder extends StatefulWidget {
  final MainModel model;
  final String areaId;
  final int distrPoint;
  BulkOrder(this.model, this.areaId, this.distrPoint, {Key key})
      : super(key: key);

  @override
  _BulkOrderState createState() => _BulkOrderState();
}

class _BulkOrderState extends State<BulkOrder> {
  List<Courier> shipment = [];
  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  @override
  void initState() {
    getinit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getinit() async {
    isloading(true);
    shipment =
        await widget.model.couriersList(widget.areaId, widget.distrPoint);
    isloading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.model.userInfo.name,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              Text(
                widget.model.distrPointName,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                ),
              )
            ]),
      ),
      body: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          return shipment.length > 0
              ? CourierOrder(shipment, widget.areaId, model.userInfo.distrId,
                  model.userInfo.distrId)
              : Container();
        },
      ),
    );
  }
}
