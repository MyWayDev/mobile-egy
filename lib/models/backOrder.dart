import 'dart:convert';

class BackOrder {
  String docId;
  String itemId;
  String name;
  String giftType;
  bool release;
  var qty;

  BackOrder(
      {this.docId,
      this.itemId,
      this.name,
      this.giftType,
      this.release = false,
      this.qty});

  factory BackOrder.jsonParse(Map<dynamic, dynamic> json) {
    return BackOrder(
        docId: json['DOC_ID'],
        itemId: json['ITEM_ID'],
        name: json['ANAME'],
        giftType: json['GIFT_TYPE'],
        qty: json['FINALQTY']);
  }
  toJson() {
    return {
      "DOC_ID": docId,
      "ITEM_ID": itemId,
      "FINALQTY": qty,
      "GIFT_TYPE": giftType
    };
  }
}

class BackOrderRelease {
  String distrId;
  List<BackOrder> backOrder;

  BackOrderRelease({this.distrId, this.backOrder});

  toJson() {
    return backOrder;
  }

  String backOrderToJson(BackOrderRelease backOrder) {
    final dyn = backOrder.toJson();
    return json.encode(dyn);
  }
}
