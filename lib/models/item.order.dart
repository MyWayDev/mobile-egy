import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:mor_release/models/backOrder.dart';
import 'dart:convert';
import 'dart:io';

import 'package:mor_release/models/gift.order.dart';
import 'package:mor_release/models/user.dart';

class ItemOrder {
  String itemId;
  double price;
  int bp;
  double bv;
  double weight;
  int qty;
  bool held;
  String name;
  String img;

  double get totalWeight {
    double _totalWeight = qty * weight;
    return _totalWeight;
  }

  double get totalPrice {
    double _totalPrice = qty * price;
    return _totalPrice;
  }

  int get totalBp {
    int _totalBp = qty * bp;
    return _totalBp;
  }

  bool get orderSatus {
    bool _held = false;

    held == null || held == false ? _held = false : _held = true;

    return _held;
  }

  ItemOrder({
    this.itemId,
    this.price,
    this.qty,
    this.held,
    this.bp,
    this.bv,
    this.name,
    this.weight,
    this.img,
  });

  Map<String, dynamic> toJson() => {
        "ITEM_ID": itemId,
        "QTY": orderSatus ? qty * -1 : qty,
        "QTY_REQ": qty,
        "UNIT_PRICE": price,
        "NET_PRICE": totalPrice,
        "TOT_PRICE": totalPrice,
        "ITEM_BP": bp,
        "ITEM_BV": bv,
      };

  String postToJson(ItemOrder itemOrder) {
    final dyn = itemOrder.toJson();
    return json.encode(dyn);
  }

  factory ItemOrder.fromJson(Map<String, dynamic> json) {
    return ItemOrder(itemId: json['itemId'], qty: json['qty']);
  }

  //  this.bv, });
}

class OrderMsg {
  String soid;
  double amt;
  String docDate;
  String addTime;
  String error;

  DateTime get addDate {
    DateTime _addDate = DateTime.parse(docDate + " " + addTime);
    return _addDate;
  }

  OrderMsg({this.soid, this.amt, this.docDate, this.addTime, this.error});
  factory OrderMsg.fromJson(Map<String, dynamic> msg) {
    return OrderMsg(
      soid: msg['id'],
      amt: msg['amt'],
      docDate: msg['docDate'],
      addTime: msg['addTime'],
    );
  }
}

class OrderBulkMsg {
  List<dynamic> ids = [];
  String error;

  OrderBulkMsg({this.ids, this.error});
  factory OrderBulkMsg.fromJson(Map<String, dynamic> msg) {
    return OrderBulkMsg(
      ids: msg['ids'] ?? [],
      error: msg['error'] ?? '',
    );
  }
}

class SalesOrder {
  String distrId;
  String userId;
  String courierId;
  String areaId;
  double total;
  int totalBp;
  double weight;
  String note;
  String address;
  String amt;
  String so;
  String storeId;
  String branchId;
  String soType;
  String projId;
  String courierFee;
  String bonusDeduc;
  String backOrder;
  List<BackOrder> bckOrdrs;
  List<BackOrderRelease> backOrders;
  List<DistrBonus> distrBonues;
  List<ItemOrder> order;
  List<GiftOrder> gifts;
  List<PromoOrder> promos;

  SalesOrder(
      {this.distrId,
      this.userId,
      this.total,
      this.totalBp,
      this.order,
      this.backOrders,
      this.bckOrdrs,
      this.distrBonues,
      this.weight,
      this.courierId,
      this.areaId,
      this.note,
      this.address,
      this.amt,
      this.so,
      this.storeId,
      this.branchId,
      this.soType,
      this.projId,
      this.courierFee,
      this.bonusDeduc,
      this.backOrder,
      this.gifts,
      this.promos});

  Map<String, dynamic> toJson() => {
        "ap3": distrBonues,
        "backorder": bckOrdrs,
        "a9master": {
          "STORE_ID": storeId, //!new
          "BRANCH_ID": branchId, //!new
          "CUS_VEN_ID": distrId,
          "USER_ID": userId,
        },
        "apmaster": {
          "STORE_ID": storeId, //!new
          "SO_INV_TYPE": soType, //!new
          "GROSS_TOTAL": total,
          "NET_TOTAL": total,
          "PRJ_ID": projId,
          "DS_SHIPMENT_COMP": courierId,
          "DS_SHIPMENT_PLACE": areaId,
          "AREMARKS": note, //!egyupdate AREMARKS FROM LREMARKS
          "SHIPMTHD_L": bonusDeduc,
          // "SHIPMTHD_A": backOrder,
          //"LREMARKS": courierFee ?? '0',
          "DISC_NOTES": address,
        },
        "aadetail": order,
        "aqdetail": order,
      };

  String postOrderToJson(SalesOrder salesOrder) {
    final dyn = salesOrder.toJson();
    return json.encode(dyn);
  }

  Future<http.Response> createPost(SalesOrder salesOrder) async {
    final response = await http.put(
        'https://mywaytest.mywayapienviroment.p.azurewebsites.net/api/invoice',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.authorizationHeader: ''
        },
        body: postOrderToJson(salesOrder));
    return response;
  }
}

class BulkSalesOrder {
  List<SalesOrder> bulkSalesOrder;

  BulkSalesOrder({
    this.bulkSalesOrder,
  });

  Map<String, dynamic> toJson() => {"batch": bulkSalesOrder};

  String postBulkOrderToJson(BulkSalesOrder bulkOrder) {
    final dyn = bulkOrder.toJson();
    return json.encode(dyn);
  }

  Future<http.Response> createBulkPost(BulkSalesOrder batch) async {
    final response = await http.put(
        'https://mywaytest.mywayapienviroment.p.azurewebsites.net/api/insert_batch_sales_orders',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.authorizationHeader: ''
        },
        body: postBulkOrderToJson(batch));
    return response;
  }
}
