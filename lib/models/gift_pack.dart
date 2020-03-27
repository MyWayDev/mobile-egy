import 'package:mor_release/models/item.dart';

class GiftPack {
  String key;
  int bp;
  String desc;
  String imageUrl;
  List<Item> pack;

  int get qty {
    int _q;
    _q = 1;
    return _q;
  }

  GiftPack({this.key, this.bp, this.desc, this.imageUrl, this.pack});
}

class PromoPack {
  String key;
  int bp;
  String desc;
  String imageUrl;
  List<Item> promoPack;

  int get qty {
    int _q;
    _q = 1;
    return _q;
  }

  PromoPack({
    this.key,
    this.bp,
    this.desc,
    this.imageUrl,
    this.promoPack,
  });
}
