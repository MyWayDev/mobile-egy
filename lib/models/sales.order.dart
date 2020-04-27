class Sorder {
  String docId;
  String distrId;
  String distrName;
  String counter;
  String docDate;
  String addTime;
  String soType;
  String coureirFee;
  String storeId;
  List<SoItem> soItems;

  String get soTotal {
    double _totalPrice = 0;
    for (SoItem s in soItems) {
      // s.itemId != '90' ?     //: '0';
      _totalPrice += s.total;
    }
    return _totalPrice.toString();
  }

  String get soBp {
    double _soBp = 0;
    for (SoItem s in soItems) {
      _soBp += s.totalBp;
    }
    return _soBp.toString();
  }

  DateTime get addDate {
    DateTime _addDate = DateTime.parse(docDate + " " + addTime);
    return _addDate;
  }

  Sorder({
    this.docId,
    this.docDate,
    this.addTime,
    this.distrId,
    this.distrName,
    this.counter,
    this.soType,
    this.coureirFee,
    this.storeId,
    this.soItems,
  });
  factory Sorder.fromJson(Map<String, dynamic> json) {
    return Sorder(
        docId: json['DOC_ID'],
        docDate: json['DOC_DATE'],
        distrId: json['DISTR_ID'],
        distrName: json['DISTRNAME'],
        addTime: json['ADD_TIME'],
        counter: json['COUNTER'],
        coureirFee: json['AREMARKS'],
        storeId: json['STORE_ID'],
        soType: json['SO_INV_TYPE']);
  }
}

class SoItem {
  String docId;
  String itemId;
  String itemName;
  String soType;
  var qty;
  var price;
  var total;
  var itemBp;
  var totalBp;

  SoItem({
    this.docId,
    this.itemId,
    this.itemName,
    this.soType,
    this.qty,
    this.price,
    this.total,
    this.itemBp,
    this.totalBp,
  });

  factory SoItem.fromJson(Map<String, dynamic> json) {
    return SoItem(
        docId: json['DOC_ID'],
        itemId: json['ITEM_ID'],
        itemName: json['ITEMNAME'],
        qty: json['QTY_REQ'] ?? 0,
        price: json['UNIT_PRICE'] ?? 0.0,
        total: json['TOT_PRICE'] ?? 0.0,
        itemBp: json['ITEM_BP'] ?? 0,
        totalBp: json['TOTAL_BP'] ?? 0,
        soType: json['SO_INV_TYPE']);
  }
}
