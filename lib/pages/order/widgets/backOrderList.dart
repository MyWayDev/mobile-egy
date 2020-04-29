import 'package:flutter/material.dart';
import 'package:mor_release/models/backOrder.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class BackOrderList extends StatefulWidget {
  BackOrderList({Key key}) : super(key: key);

  @override
  _BackOrderListState createState() => _BackOrderListState();
}

class _BackOrderListState extends State<BackOrderList> {
  @override
  Widget build(BuildContext context) {
    return Dialog(child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.backOrdersList.isNotEmpty
          ? Container(
              height: MediaQuery.of(context).size.height / 1.45,
              width: MediaQuery.of(context).size.width,
              child: Column(children: <Widget>[
                Expanded(
                    child: ListView.builder(
                  itemCount: model.backOrdersList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                        onDismissed: (DismissDirection direction) {
                          if (direction == DismissDirection.endToStart) {
                            model.deleteBackOrderItem(index);
                          } else if (direction == DismissDirection.startToEnd) {
                            model.deleteBackOrderItem(index);
                          }
                        },
                        background: Container(),
                        key: Key(model.backOrdersList[index].distrId),
                        child: Card(
                            color: Colors.blue[300],
                            child: Column(children: <Widget>[
                              Center(child: Text('طلب فك حجز')),
                              _buildBackOrderRelease(
                                  model.backOrdersList, index, model),
                            ])));
                  },
                ))
              ]))
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
          leading: IconButton(
              disabledColor: Colors.transparent,
              icon: Icon(
                Icons.delete_forever,
                color: Colors.pink[900],
                size: 28,
              ),
              onPressed: () {
                model.deleteBackOrderItem(index);
              }),
          title: Container(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(
                      Icons.vpn_key,
                      color: Colors.pink[500],
                      size: 21,
                    ),
                    Text(
                      _backOrderRelease[index].distrId,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Divider(
                  height: 3.0,
                  indent: 0,
                  color: Colors.black,
                )
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
            leading: Column(children: <Widget>[
              Icon(
                Icons.insert_drive_file,
                color: Colors.blueGrey,
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                bO.docId,
              ),
            ]),
            title: Column(children: <Widget>[
              Text(
                bO.itemId,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                bO.name.length <= 22 ? bO.name : bO.name.substring(0, 22),
                style: TextStyle(fontSize: 12),
              ),
            ]),
            subtitle: Center(
              child: Text(
                bO.qty.round().toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.cancel,
                  color: Colors.pink[900],
                  size: 22,
                ),
                onPressed: () {
                  model.deleteBackOrderDetails(bO);
                })),
      );
    });
  }
}
