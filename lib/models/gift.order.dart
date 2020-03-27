import 'package:mor_release/models/item.dart';

class GiftOrder {
  List<Item> pack;
  int bp;
  int qty;
  String imageUrl;
  String desc;

  GiftOrder({this.pack, this.bp, this.qty, this.imageUrl, this.desc});
}

class PromoOrder {
  List<Item> promoPack;
  int bp;
  int qty;
  String imageUrl;
  String desc;

  PromoOrder({this.promoPack, this.bp, this.qty, this.desc, this.imageUrl});
}
