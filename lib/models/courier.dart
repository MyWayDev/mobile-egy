import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class Courier {
  var key;
  var id;
  String courierId;
  String name;
  bool disabled;
  List service;

  Courier({this.courierId, this.name, this.disabled, this.service, this.id});

  Courier.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.value['id'],
        courierId = snapshot.value['courierId'],
        name = snapshot.value['name'],
        disabled = snapshot.value['disabled'] ?? false,
        service = snapshot.value['service'];

  factory Courier.fromJson(Map<String, dynamic> json) {
    return Courier(courierId: json['DS_SHIPMENT_COMP'], name: json['ANAME']);
  }
  factory Courier.fromList(Map<dynamic, dynamic> list) {
    return Courier(
        courierId: list['courierId'],
        name: list['name'],
        id: list['id'],
        disabled: list['disabled'] ?? false);
  }
  toJson() {
    return {
      "courierId": courierId,
      "name": name + '1',
      "id": courierId,
    };
  }
}

class Service {
  String id;
  var fees;
  var freeBp;
  var minWeight;
  var rate;
  List areas;
  Service(
      {this.id, this.fees, this.freeBp, this.areas, this.minWeight, this.rate});

  factory Service.fromJson(Map<dynamic, dynamic> json) {
    return Service(
        id: json['uniqueKey'],
        fees: json['fees'],
        freeBp: json['freeBp'],
        areas: json['areas'],
        minWeight: json['minWeight'],
        rate: json['rate']);
  }
  toJson() {
    return {
      "fees": fees,
      "freeBP": freeBp,
      "areas": areas,
    };
  }

  Service.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.value['uniqueKey'],
        fees = snapshot.value['fees'],
        freeBp = snapshot.value['freeBp'],
        areas = snapshot.value['areas'];
}

class CourierDiscount {
  int discount;
  int onBp;
  int toBp;
  bool enabled;

  CourierDiscount({this.discount, this.onBp, this.toBp, this.enabled});

  factory CourierDiscount.json(Map<dynamic, dynamic> json) {
    return CourierDiscount(
      discount: json['discount'],
      onBp: json['onBp'],
      toBp: json['toBp'],
      enabled: json['enabled'],
    );
  }
}

class ShipmentArea {
  int shipmentId;
  String shipmentDistrId;
  String shipmentArea;
  String shipmentName;
  String shipmentAddress;
  ShipmentArea(
      {this.shipmentId,
      this.shipmentDistrId,
      this.shipmentArea,
      this.shipmentName,
      this.shipmentAddress});

  factory ShipmentArea.fromJson(Map<String, dynamic> json) {
    return ShipmentArea(
        shipmentId: json['ID'],
        shipmentDistrId: json['DISTR_ID'],
        shipmentArea: json['DS_SHIPMENT_PLACE'],
        shipmentName: json['SPNAME'],
        shipmentAddress: json['ADDRESS_NOTES']);
  }
  Map<String, dynamic> toJson() => {
        "DISTR_ID": shipmentDistrId,
        "DS_SHIPMENT_PLACE": shipmentArea,
        "SPNAME": shipmentName,
        "ADDRESS_NOTES": shipmentAddress,
      };

  String postAddressToJson(ShipmentArea address) {
    final dyn = address.toJson();
    return json.encode(dyn);
  }

  Future<http.Response> createPost(ShipmentArea address, storeId) async {
    final response = await http.put(
        'https://mywaytest.mywayapienviroment.p.azurewebsites.net/api/add_new_distr_shipment_place/$storeId',
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          //HttpHeaders.authorizationHeader: ''
        },
        body: postAddressToJson(address));

    return response;
  }
}
