import 'package:firebase_database/firebase_database.dart';

class Gift {
  List items;
  String desc;
  int bp;
  String imageUrl;

  Gift({this.items, this.bp, this.imageUrl, this.desc});

  Gift.fromSnapshot(DataSnapshot snapshot)
      : items = snapshot.value['items'] ?? [],
        bp = snapshot.value['bp'] ?? 0;

  factory Gift.fbList(Map<dynamic, dynamic> list) {
    return Gift(
        bp: list['bp'] ?? 0,
        desc: list['desc'],
        items: list['items'] ?? [],
        imageUrl: list['imageUrl']);
  }
}

class Promo {
  int id;
  String desc;
  int bp;
  List items;
  List areas;
  String imageUrl;
  String fromDate;
  String toDate;
  bool oneOrder;

  Promo(
      {this.id,
      this.desc,
      this.bp,
      this.items,
      this.areas,
      this.imageUrl,
      this.fromDate,
      this.toDate,
      this.oneOrder});

  factory Promo.fbList(Map<dynamic, dynamic> fbList) {
    return Promo(
        id: fbList['id'],
        desc: fbList['desc'],
        bp: fbList['bp'],
        items: fbList['items'],
        areas: fbList['areas'],
        imageUrl: fbList['imageUrl'],
        fromDate: fbList['fromDate'],
        toDate: fbList['toDate'],
        oneOrder: fbList['oneOrder']);
  }
}
