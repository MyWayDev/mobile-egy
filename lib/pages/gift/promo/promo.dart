import 'package:badges/badges.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class PromoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PromoPage();
  }
}

void giftState(MainModel model) async {
  await model.checkPromo(model.orderBp(), model.promoBp());
  model.getPromoPack();
}

@override
class _PromoPage extends State<PromoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        body: model.promoOrderList.length > 0
            ? Column(children: <Widget>[
                Expanded(
                    child: ListView.builder(
                  itemCount: model.promoOrderList.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Dismissible(
                      onDismissed: (DismissDirection direction) {
                        if (direction == DismissDirection.endToStart) {
                          model.deletePromoOrder(i);
                          setState(() {
                            giftState(model);
                          });
                          //model.giftpackorderlist.length;
                        } else if (direction == DismissDirection.startToEnd) {
                          model.deletePromoOrder(i);
                          setState(() {
                            giftState(model);
                          });
                          // model.giftpackorderlist.length;
                        }
                      },
                      background: Container(
                        color: Color(0xFFFFFFF1),
                      ),
                      key: Key(model.promoOrderList[i].bp.toString()),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                              trailing: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: NetworkImage(
                                  model.promoOrderList[i].imageUrl,
                                ),
                              ),
                              leading: BadgeIconButton(
                                itemCount: model.promoCount(i),
                                icon: Icon(
                                  Icons.shopping_cart,
                                  color: Colors.pink[900],
                                  size: 0.0,
                                ), // required
                                //badgeColor: Colors.pink[900],
                                badgeTextColor: Colors.white,
                              ),
                              title: model.giftorderList.length == 0
                                  ? Text(
                                      model.promoOrderList[i].desc,
                                      textAlign: TextAlign.right,
                                      textScaleFactor: 0.875,
                                    )
                                  : Container()

                              //    Text(model.giftorderList[i].qty.toString()),
                              ),
                        ],
                      ),
                    );
                  },
                ))
              ])
            : Container(),
      );
    });
  }
}
