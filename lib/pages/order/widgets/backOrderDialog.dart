import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/backOrder.dart';
import 'package:mor_release/models/item.order.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class BackOrderDialog extends StatefulWidget {
  List<BackOrder> backOrders;
  final String memberId;
  final String memberName;

  BackOrderDialog(this.backOrders, this.memberId, this.memberName);
  @override
  State<StatefulWidget> createState() {
    return _BackOrderDialog();
  }
}

@override
class _BackOrderDialog extends State<BackOrderDialog> {
  BackOrderRelease _backOrderRelease;
  bool isRelease = false;
  bool _isAll = false;

  @override
  void initState() {
    _backOrderRelease = BackOrderRelease(
      distrId: widget.memberId,
    );
    _backOrderRelease.backOrder = [];

    super.initState();
  }

  @override
  void dispose() {
    widget.backOrders = [];
    print(widget.backOrders.length);
    print('disposed backOrders');
    super.dispose();
  }

  void _value1Changed(bool value) {
    setState(() => _isAll = value);
    releaseAll(value);
  }

  void releaseAll(bool value) {
    if (widget.backOrders.isNotEmpty) {
      widget.backOrders.forEach((i) => i.release = value);
    }
  }

  void isLoading(bool o, MainModel model) {
    setState(() {
      model.loading = o;
    });
  }

  bool getRelease() {
    List<BackOrder> _backOrder = [];

    _backOrder = widget.backOrders.where((i) => i.release == true).toList();
    isRelease = _backOrder.isNotEmpty ? true : false;

    return isRelease;
  }

  List<ItemOrder> getOrderList(MainModel model) {
    return model.itemorderlist.where((test) => test.bp != 0).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _backOrderDialog(context);
  }

  Widget _backOrderDialog(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ModalProgressHUD(
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 600.0,
            width: 320.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.amber[50],
            ),
            child: Column(
              children: <Widget>[
                Card(
                  elevation: 21,
                  color: Colors.amber[50],
                  child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 1),
                          child: Text(
                            'الكمية',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Column(children: <Widget>[
                          Text(
                            widget.memberName.length <= 16
                                ? widget.memberName
                                : widget.memberName.substring(0, 16) + '..',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.memberId,
                            style: TextStyle(
                                color: Colors.orange[600],
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                        Row(
                          verticalDirection: VerticalDirection.down,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Checkbox(value: _isAll, onChanged: _value1Changed),
                          ],
                        ),
                        /*Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Text(
                            'الكود',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),*/
                      ]),
                ),
                Container(
                    color: Colors.grey[200],
                    height: MediaQuery.of(context).size.height / 1.9,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      itemCount: widget.backOrders.length,
                      itemBuilder: (context, i) {
                        return _orderCard(context, i, widget.backOrders);
                      },
                    )),
                //  SizedBox(height: 5.0),
                Container(
                    color: Colors.amber[50],
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                              elevation: 6,
                              fillColor: Colors.yellowAccent[700],
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              splashColor: Colors.pink[900],
                            ),
                            !model.loading && getRelease()
                                ? RawMaterialButton(
                                    child: Icon(
                                      Icons.done_all,
                                      size: 24.0,
                                      color: Colors.white,
                                    ),
                                    shape: CircleBorder(),
                                    highlightColor: Colors.pink[900],
                                    elevation: 6,
                                    fillColor: Colors.green,
                                    onPressed: () async {
                                      //_backOrderRelease.backOrder = [];
                                      isLoading(true, model);
                                      widget.backOrders.forEach((f) =>
                                          f.release == true
                                              ? _backOrderRelease.backOrder
                                                  .add(f)
                                              : null);
                                      model.addToBackOrderList(
                                          _backOrderRelease);
                                      isLoading(false, model);
                                      Navigator.of(context).pop();
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

  Widget _orderCard(BuildContext context, int i, List<BackOrder> backOrder) {
    return Container(
      height: 59,
      child: Card(
        color: backOrder[i].release ? Colors.green[100] : Colors.amber[100],
        elevation: 1,
        child: ListTile(
          onTap: () {
            backOrder[i].release == true
                ? backOrder[i].release = false
                : backOrder[i].release = true;
          },
          trailing: Padding(
            padding: EdgeInsets.only(left: 3),
            child: Text(
              backOrder[i].itemId,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600]),
            ),
          ),
          title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('${backOrder[i].docId}',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 10)),
                Text(
                  backOrder[i].name.length >= 21
                      ? backOrder[i].name.substring(0, 21) + '...'
                      : backOrder[i].name,
                  textDirection: TextDirection.rtl,
                  softWrap: true,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ]),
          leading: backOrder[i].release
              ? Column(
                  //  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(backOrder[i].qty.toInt().toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                            fontSize: 13.5)),
                    Icon(GroovinMaterialIcons.check,
                        size: 22, color: Colors.green),
                  ],
                )
              : Column(
                  //  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Icon(
                      GroovinMaterialIcons.arrow_down_bold,
                      size: 19,
                      color: Colors.blue[200],
                    ),
                    Text(backOrder[i].qty.toInt().toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ],
                ),
        ),
      ),
    );
  }
}
