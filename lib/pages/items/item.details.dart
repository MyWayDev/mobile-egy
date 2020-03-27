import 'package:flutter/material.dart';
import '../../models/item.dart';

class ItemDetails extends StatelessWidget {
  final Item item;

  ItemDetails(this.item);

  _showWarningDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This action cannot be undone...'),
            actions: <Widget>[
              FlatButton(
                child: Text('Discard'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Continue'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, false);
          return Future.value(false);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(item.name),
            ),
            body: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.network(item.imageUrl ??
                        '' // 'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F${item.image[0].toString()}_${item.itemId}.png?alt=media&token=274fc65f-8295-43d5-909c-e2b174686439',
                    ),
                Container(
                    padding: EdgeInsets.all(10.0), child: Text(item.name)),

                ///here price tag
                /* Container(
                    padding: EdgeInsets.all(10.0),
                    child: RaisedButton(
                      child: Text('Delete'),
                      onPressed: () => _showWarningDialog(context),
                    ))*/
                Container(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(item.usage),
                    ),
                  ),
                )
              ],
            )));
  }
}
