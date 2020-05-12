import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/pages/items/itemDetails/details.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/stock_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class IconBar extends StatefulWidget {
  final List<Item> itemData;
  final int index;
  IconBar(this.itemData, this.index);
  @override
  State<StatefulWidget> createState() {
    return _IconBar();
  }
}

@override
class _IconBar extends State<IconBar> {
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
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              !model.cartLocked
                  ? Stack(
                      children: <Widget>[
                        !model.iheld(widget.index)
                            ? BadgeIconButton(
                                itemCount: model.iCount(widget.index),
                                icon: Icon(
                                  Icons.shopping_cart,
                                  color: Colors.pink[900],
                                  size: 32.0,
                                ),
                                badgeColor: !model.iheld(widget.index)
                                    ? Colors.red
                                    : Colors.amber[400],
                                badgeTextColor: Colors.white,
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (_) => StockDialog(
                                      widget.itemData,
                                      widget.index,
                                      model.iCount(widget.index),
                                    ),
                                  );
                                },
                              )
                            : Stack(
                                children: <Widget>[
                                  BadgeIconButton(
                                    itemCount: model.iCount(widget.index),
                                    icon: Icon(
                                      Icons.shopping_cart,
                                      color: Colors.pink[900],
                                      size: 32.0,
                                    ),
                                    badgeColor: Colors.amber[400],
                                    badgeTextColor: Colors.white,
                                    onPressed: () async {
                                      showDialog(
                                          context: context,
                                          builder: (_) => StockDialog(
                                              widget.itemData,
                                              widget.index,
                                              model.iCount(widget.index)));
                                    },
                                  ),
                                  Positioned(
                                      right: 21,
                                      bottom: 33,
                                      child: Icon(
                                        GroovinMaterialIcons.arrow_down_bold,
                                        color: Colors.blue,
                                      )),
                                ],
                              )
                      ],
                    )
                  : BadgeIconButton(
                      itemCount: model.iCount(widget.index),
                      icon: Icon(
                        Icons.remove_shopping_cart,
                        color: Colors.grey,
                        size: 30.0,
                      ),
                      // required
                      //badgeColor: Colors.pink[900],
                      badgeTextColor: Colors.white,
                      onPressed: () {}),
              Padding(
                padding: EdgeInsets.only(left: 6.0, right: 6.0),
              ),
              IconButton(
                  icon: Icon(Icons.info_outline),
                  iconSize: 30.0,
                  color: Colors.blueAccent,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                          widget.itemData[widget.index],
                          model.getCaouselItems(widget.itemData[widget.index]),
                        ),
                      ),
                    );
                  }),
            ],
          )
        ],
      );
    });
  }
}
