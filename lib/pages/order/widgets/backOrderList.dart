import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/backOrder.dart';
import 'package:mor_release/pages/order/widgets/backOrderDialog.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class BackOrderList extends StatefulWidget {
  BackOrderList({Key key}) : super(key: key);

  @override
  _BackOrderListState createState() => _BackOrderListState();
}

class _BackOrderListState extends State<BackOrderList> {
  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.backOrdersList.isNotEmpty
          ? ModalProgressHUD(
              color: Colors.black,
              inAsyncCall: _isloading,
              opacity: 0.6,
              progressIndicator: ColorLoader2(),
              child: Container(
                  height: MediaQuery.of(context).size.height / 1.6,
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: <Widget>[
                    Expanded(
                        child: ListView.builder(
                      itemCount: model.backOrdersList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                            onDismissed: (DismissDirection direction) {
                              if (direction == DismissDirection.endToStart) {
                                model.deleteBackOrderItem(index, context);
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                model.deleteBackOrderItem(index, context);
                              }
                            },
                            key: Key(model.backOrdersList[index].distrId),
                            child: Card(
                                color: Colors.blue[300],
                                child: Column(children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(
                                        'طلب فك حجز',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      !model.userInfo.isleader
                                          ? IconButton(
                                              icon: Icon(
                                                  GroovinMaterialIcons
                                                      .arrow_right_thick,
                                                  size: 24,
                                                  color: Colors.pink[500]),
                                              onPressed: () async {
                                                isloading(true);
                                                List<BackOrder> _backOrders =
                                                    [];
                                                _backOrders = await model
                                                    .getBackOrderItems(
                                                        model.userInfo.distrId,
                                                        model.setStoreId);
                                                Navigator.of(context).pop();
                                                showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        BackOrderDialog(
                                                            _backOrders,
                                                            model.userInfo
                                                                .distrId,
                                                            model.userInfo
                                                                .name));
                                                isloading(false);
                                              })
                                          : SizedBox(width: 12)
                                    ],
                                  ),
                                  _buildBackOrderRelease(
                                      model.backOrdersList, index, model),
                                ])));
                      },
                    ))
                  ])))
          : Container();
    }));
  }

  Widget _buildBackOrderRelease(
      List<BackOrderRelease> _backOrderRelease, int index, MainModel model) {
    return ExpansionTile(

        // initiallyExpanded: true,
        backgroundColor: Colors.amber[300],
        key: PageStorageKey<BackOrderRelease>(_backOrderRelease[index]),
        title: ListTile(
          leading: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 50.0, maxWidth: 23.0),
            child: IconButton(
                disabledColor: Colors.transparent,
                icon: Icon(
                  Icons.delete_forever,
                  color: Colors.pink[900],
                  size: 22,
                ),
                onPressed: () {
                  model.deleteBackOrderItem(index, context);
                }),
          ),
          title: Container(
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 45.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.vpn_key,
                        color: Colors.pink[500],
                        size: 17,
                      ),
                      SizedBox(width: 2),
                      Text(
                        int.parse(_backOrderRelease[index].distrId).toString(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        children: _backOrderRelease[index].backOrder.isNotEmpty
            ? _backOrderRelease[index].backOrder.map(_buildItem).toList()
            : Container()
        //root.invoiceItems.map(_buildTiles).toList(),
        );
  }

  Widget _buildItem(BackOrder bO) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Card(
        color: Colors.amber,
        child: ListTile(
            leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    bO.docId,
                    style:
                        TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  Stack(
                    alignment: AlignmentDirectional.topCenter,
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      Positioned(
                        child: Icon(
                          Icons.shopping_cart,
                          size: 28,
                          color: Colors.blue[400],
                        ),
                      ),
                      Text(
                        '${bO.qty.round().toString()}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  )
                ]),
            title: Column(children: <Widget>[
              Text(
                bO.itemId,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ]),
            subtitle: Text(
              bO.name.length <= 24 ? bO.name : bO.name.substring(0, 24),
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 11.5),
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 21),
              child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.pink[900],
                    size: 18,
                  ),
                  onPressed: () {
                    model.deleteBackOrderDetails(bO, context);
                  }),
            )),
      );
    });
  }
}
