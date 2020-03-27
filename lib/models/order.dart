//import 'package:http/http.dart' as http;
//import 'dart:convert';
class SalesOrder {
  String itemId;
  double price;
  SalesOrder({this.itemId, this.price});
}

class Order {
  A9Master a9Master;
  ApMaster apMaster;
  List<AaDetail> aaDetails;
  List<AqDetail> aqDetails;

  Order({this.a9Master, this.apMaster, this.aaDetails, this.aqDetails});

  Map<String, dynamic> toJson() => {
        'a9master': a9Master,
        'apmaster': apMaster,
        'aadetail': aaDetails,
        'aqdetail': aqDetails,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    var aalist = json['aaDetails'] as List;
    var aqlist = json['aqDetails'] as List;

    List<AaDetail> aadetailList =
        aalist.map((i) => AaDetail.fromJson(i)).toList();
    List<AqDetail> aqdetailList =
        aqlist.map((i) => AqDetail.fromJson(i)).toList();
    return new Order(
      a9Master: A9Master.fromJson(json['a9Master']),
      apMaster: ApMaster.fromJson(json['apMaster']),
      aaDetails: aadetailList,
      aqDetails: aqdetailList,
    );
  }
}

class A9Master {
  String distrId;
  A9Master({this.distrId});
  Map<String, dynamic> toJson() => {'CUS_VEN_ID': distrId};

  factory A9Master.fromJson(Map<String, dynamic> json) {
    return A9Master(distrId: json['CUS_VEN_ID']);
  }
}

class ApMaster {
  double grossTotal;
  double netTotal;
  ApMaster({this.grossTotal, this.netTotal});

  factory ApMaster.fromJson(Map<String, dynamic> json) {
    return ApMaster(
        grossTotal: json['GROSS_TOTAL'], netTotal: json['NET_TOTAL']);
  }
}

class AaDetail {
  String itemId;
  int qty;

  AaDetail({this.itemId, this.qty});
  factory AaDetail.fromJson(Map<String, dynamic> json) {
    return AaDetail(itemId: json['ITEM_ID'], qty: json['QTY']);
  }
}

class AqDetail {
  String itemId;
  int qtyRec;
  double unitPrice;
  double netPrice;
  double totalprice;
  String itemBp;
  String itemBv;

  AqDetail(
      {this.itemId,
      this.qtyRec,
      this.unitPrice,
      this.netPrice,
      this.totalprice,
      this.itemBp,
      this.itemBv});

  factory AqDetail.fromJson(Map<String, dynamic> json) {
    return AqDetail(
        itemId: json['ITEM_ID'],
        qtyRec: json['QTY_REQ'],
        unitPrice: json['UNIT_PRICE'],
        netPrice: json['NET_PRICE'],
        totalprice: json['TOT_PRICE'],
        itemBp: json['ITEM_BP'],
        itemBv: json['ITEM_BV']);
  }
}
/*
 ApMaster apMaster;
  List<AaDetail> aaDetails;
  List<AqDetail> aqDetails;

  A9Master({this.distrId, this.apMaster, this.aaDetails, this.aqDetails});

  Map<String, dynamic> toJson() => {
        'CUS_VEN_ID': distrId,
        'apmaster': apMaster,
        'aadetail': aaDetails,
        'aqdetail': aqDetails,
      };

  factory A9Master.fromJson(Map<String, dynamic> json) {
    var aalist = json['aaDetails'] as List;
    var aqlist = json['aqDetails'] as List;

    List<AaDetail> aadetailList =
        aalist.map((i) => AaDetail.fromJson(i)).toList();
    List<AqDetail> aqdetailList =
        aqlist.map((i) => AqDetail.fromJson(i)).toList();
    return new A9Master(
      distrId: json['CUS_VEN_ID'],
      apMaster: ApMaster.fromJson(json['apMaster']),
      aaDetails: aadetailList,
      aqDetails: aqdetailList,
    );
  }
*/
