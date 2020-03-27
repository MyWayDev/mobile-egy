import 'package:flutter/material.dart';
import 'package:mor_release/models/gift_pack.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class PromoCard extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _PromoCard();
  }

  final List<PromoPack> promoData;
  final int index;

  PromoCard(this.promoData, this.index);
}

@override
class _PromoCard extends State<PromoCard> {
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
                  widget.promoData[widget.index].imageUrl,
                ),
                child: IconButton(
                  splashColor: Colors.purple,
                  icon: Icon(Icons.card_giftcard, size: 0.0),
                  onPressed: () {
                    model.loadPromo(widget.promoData, widget.index);

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
            widget.promoData[widget.index].bp.toString(),
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
