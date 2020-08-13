import 'package:firebase_database/firebase_database.dart';

class Lock {
  String id; // ! changed here to display new non string id fb requirement.
  bool lockApp;
  bool lockCart;
  String catCode;
  String version;
  int safetyStock;
  int maxOrder;
  int adminFee;
  int backOrderFee;
  int memberBPLimit;
  String bannerUrl;
  int maxLimited;
  String pdfUrl;
  List limitedItem;
  List exItems;

  Lock({
    this.id,
    this.lockApp = false,
    this.catCode,
    this.version,
    this.adminFee,
    this.memberBPLimit,
    this.backOrderFee,
    this.safetyStock,
    this.maxOrder,
    this.pdfUrl,
    this.maxLimited,
    this.limitedItem,
    this.exItems,
  });

  Lock.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.value['id'],
        lockApp = snapshot.value['lockApp'],
        lockCart = snapshot.value['lockCart'],
        adminFee = snapshot.value['adminFee'],
        memberBPLimit = snapshot.value['memberBpLimit'] ?? 0,
        backOrderFee = snapshot.value['backOrderFee'] ?? 0,
        bannerUrl = snapshot.value['bannerUrl'],
        catCode = snapshot.value['catCode'] ?? '',
        version = snapshot.value['version'],
        safetyStock = snapshot.value['safetyStock'],
        maxOrder = snapshot.value['maxOrder'],
        maxLimited = snapshot.value['maxLimited'],
        pdfUrl = snapshot.value['pdfUrl'] ?? '',
        limitedItem = snapshot.value['limtedItem'] ?? [],
        exItems = snapshot.value['exclusiveList'] ?? [];
}
