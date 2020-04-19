import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/stock_dialog.dart';
import 'package:scoped_model/scoped_model.dart';
import 'clipper.dart';
import 'gredients.dart';

Widget _appbar(BuildContext context, MainModel model, String itemId) {
  Align appbar = Align(
    heightFactor: 0.40,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              splashColor: Colors.black,
            )),
        Expanded(
          child: Container(),
        ),
        Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: _buildIconButton(context, model, itemId))
      ],
    ),
  );
  return appbar;
}

Widget _buildIconButton(BuildContext context, MainModel model, String itemId) {
  return !model.cartLocked
      ? Stack(children: <Widget>[
          BadgeIconButton(
            itemCount: model.iCount(model.getIndex(itemId), item: itemId),
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.pink[900],
              size: 32.0,
            ),
            // required
            badgeColor: !model.iheld(model.getIndex(itemId))
                ? Colors.red
                : Colors.amber[400],
            badgeTextColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                  context: context,
                  builder: (_) => StockDialog(
                        model.itemData,
                        model.getIndex(itemId),
                        model.iCount(model.getIndex(itemId), item: itemId),
                        pop: false,
                      ));
            },
          ),
          Positioned(
            right: 21,
            bottom: 33,
            child: model.iheld(model.getIndex(itemId))
                ? Icon(
                    GroovinMaterialIcons.arrow_down_bold,
                    color: Colors.blue,
                  )
                : Container(),
          ),
        ])
      : BadgeIconButton(
          itemCount: model.iCount(model.getIndex(itemId), item: itemId),
          icon: Icon(
            Icons.remove_shopping_cart,
            color: Colors.grey,
            size: 32.0,
          ),
          badgeTextColor: Colors.white,
          onPressed: () {});
}

Widget _content(Item item, BuildContext context) {
  var content = Container(
    margin: EdgeInsets.only(top: 8.0),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Stack(
              fit: StackFit.loose,
              children: <Widget>[
                Image(
                  width: MediaQuery.of(context).devicePixelRatio <= 1.5
                      ? 160
                      : 180,
                  height: MediaQuery.of(context).devicePixelRatio <= 1.5
                      ? 155
                      : 160,
                  image: NetworkImage(item.imageUrl ?? ''),
                ),
                Positioned(
                  right: 40,
                  child: Opacity(
                    opacity: 0.60,
                    child: Image(
                      image: NetworkImage(item.promoImageUrl ?? '', scale: 1.2),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 0,
                  child: Text(
                    item.itemId,
                    style: TextStyle(
                        color: Colors.pink[900],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                    width: 70.0,
                    height: 49.0,
                    decoration: BoxDecoration(
                        gradient: btnGradientII,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              blurRadius: 10.0,
                              color: Colors.black12,
                              offset: Offset(0.0, 10.0))
                        ]),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'BV',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${item.bv.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ))),
                Container(
                  width: 170,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: item.name,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  height: 0.8)),
                          softWrap: true,
                          overflow: TextOverflow.fade,
                          maxLines: 3,
                        ),
                        Center(
                          child: Text(item.size.toString() + ' ' + item.unit,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Container(
                              width: 80.0,
                              height: 35.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: new BorderRadius.all(
                                      new Radius.circular(30.0)),
                                  boxShadow: <BoxShadow>[
                                    new BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10.0,
                                        offset: new Offset(0.0, 10.0))
                                  ]),
                              child: Center(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  /*Text(
                                  "\EGP ",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),*/
                                  Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Text(
                                        'EGP ${item.priceFormat}',
                                        style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.pink[900]),
                                      ))
                                ],
                              )) /*Text(
                              'DH ${item.price.toString()}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),*/
                              ),
                        )
                      ]),
                ),
                Container(
                  width: 70.0,
                  height: 49.0,
                  decoration: BoxDecoration(
                      gradient: btnGradient,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            blurRadius: 10.0,
                            color: Colors.black12,
                            offset: Offset(0.0, 10.0))
                      ]),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'BP',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${item.bp.toString()}',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          )
        ]),
  );
  return content;
}

class Header extends StatelessWidget {
  final Item item;
  //final int i;
  Header(this.item);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        height: 290.0,
        child: Stack(
          children: <Widget>[
            ClipPath(
              clipper: ArcClipper(),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(gradient: bgGradient),
              ),
            ),
            Align(
              alignment: FractionalOffset.center,
              heightFactor: 3.5,
              child: _content(item, context),
            ),
            _appbar(context, model, item.itemId)
          ],
        ),
      );
    });
  }
}
