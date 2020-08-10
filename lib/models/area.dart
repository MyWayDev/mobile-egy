import 'package:firebase_database/firebase_database.dart';

class District {
  String districtId;
  String name;
  bool enable;

  District({this.districtId, this.name, this.enable});

  District.fromSnapshot(DataSnapshot snapshot)
      : districtId = snapshot.value['districtId'],
        name = snapshot.value['name'],
        enable = snapshot.value['enalble'];
  factory District.json(Map<dynamic, dynamic> json) {
    return District(
        districtId: json['districtId'],
        name: json['name'],
        enable: json['enalble']);
  }

  factory District.jsonParse(Map<dynamic, dynamic> json) {
    return District(
        districtId: json['districtId'],
        name: json['name'],
        enable: json['enlable']);
  }
  toJson() {
    return {
      "distictId": districtId,
      "name": name,
      "enable": enable,
    };
  }
}

class Area {
  String areaId;
  String name;
  int branch;

  Area({this.areaId, this.name, this.branch});

  Area.fromSnapshot(DataSnapshot snapshot)
      : areaId = snapshot.value['areaId'],
        name = snapshot.value['name'];

  factory Area.json(Map<dynamic, dynamic> json) {
    return Area(
        areaId: json['areaId'], name: json['name'], branch: json['branch']);
  }
  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(areaId: json['AREA_ID'], name: json['ANAME']);
  }
  toJson() {
    return {"areaId": areaId, "name": name, "id": areaId, "branch": branch};
  }
}

class AreaPlace {
  String shipmentPlace;
  String spName;
  String areaId;
  String areaName;

  AreaPlace({this.shipmentPlace, this.spName, this.areaId, this.areaName});

  factory AreaPlace.json(Map<dynamic, dynamic> json) {
    return AreaPlace(
        shipmentPlace: json['DS_SHIPMENT_PLACE'],
        spName: json['SPNAME'],
        areaId: json['AREA_ID'],
        areaName: json['AREA_NAME']);
  }
}

class Region {
  String regionId;
  String name;
  bool distrPoint;
  List storeId;
  int id;
  Region({this.regionId, this.name, this.id, this.distrPoint, this.storeId});
  Region.fromSnapshot(DataSnapshot snapshot)
      : regionId = snapshot.value['regionId'],
        name = snapshot.value['name'],
        id = snapshot.value['id'];

  factory Region.json(Map<dynamic, dynamic> json) {
    return Region(
        id: json['id'],
        regionId: json['regionId'],
        name: json['name'],
        storeId: json['storeId'],
        distrPoint: json['distrPoint'] ?? false);
  }
}

class Store {
  int id;
  String storeId;
  String name;
  String docType;
  int region;
  bool enabled;

  Store(
      {this.id,
      this.storeId,
      this.name,
      this.docType,
      this.region,
      this.enabled});
  Store.fromSnapshot(DataSnapshot snapshot)
      : storeId = snapshot.value['storeId'] ?? '',
        name = snapshot.value['name'] ?? '',
        region = snapshot.value['region'],
        enabled = snapshot.value['enabled'] ?? false,
        docType = snapshot.value['docType'] ?? 'CR';

  factory Store.json(Map<dynamic, dynamic> json) {
    return Store(
      id: json['id'],
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? '',
      docType: json['docType'] ?? 'CR',
      region: json['region'] ?? 1,
      enabled: json['enabled'] ?? false,
    );
  }
}
