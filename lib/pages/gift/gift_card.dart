import 'package:flutter/material.dart';
import 'package:mor_release/models/gift_pack.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class GiftCard extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _GiftCard();
  }

  final List<GiftPack> giftData;
  final int index;

  GiftCard(this.giftData, this.index);
}

@override
class _GiftCard extends State<GiftCard> {
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
      return Stack(
        children: <Widget>[
          Positioned(
            child: Opacity(
              opacity: 1,
              child: CircleAvatar(
                radius: 22.0,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  widget.giftData[widget.index].imageUrl,
                ),
                child: IconButton(
                  splashColor: Colors.purple,
                  icon: Icon(Icons.card_giftcard, size: 0.0),
                  onPressed: () {
                    model.loadGift(widget.giftData, widget.index);

                    /*
                    model.addGiftOrder(giftData[index]);
                    await model.checkGift(model.orderBp(), model.giftBp());
                    model.getGiftPack();*/
                  },
                ), //
              ),
            ),
          ),
          Text(
            widget.giftData[widget.index].bp.toString(),
            style: TextStyle(
                decorationColor: Colors.black,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Colors.red),
          ),
        ],
      );
    });
  }
}
