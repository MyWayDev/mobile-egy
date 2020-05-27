import 'dart:async';
import 'dart:math';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:mor_release/models/area.dart';
import 'package:mor_release/models/backOrder.dart';
import 'package:mor_release/models/courier.dart';
import 'package:mor_release/models/gift.dart';
import 'package:mor_release/models/gift.order.dart';
import 'package:mor_release/models/gift_pack.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/models/item.order.dart';
import 'package:mor_release/models/lock.dart';
import 'package:mor_release/models/sales.order.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class MainModel extends Model {
  // ** items //** */
  static String _version = '3.30r'; //!Modify for every release version./.
  static String firebaseDb = "egyProduction";
  static String stage = "egyProduction";
  static String updateDb = "egyProduction";
  final FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;
  final String path = 'flamelink/environments/$firebaseDb/content';
  final String httpath = 'http://mywayegypt-api.azurewebsites.net/api';
  final List<Item> _recoImage = List();

  String shipmentName = '';
  String shipmentArea = '';
  String shipmentAddress = '';
  String bulkDistrId;
  String shipmentCompanyId;
  int distrPoint = 1;
  String distrPointName = 'شحن القاهرة';
  String setStoreId = '01';
  String docType = 'CR';
  int noteCount;
  List<Item> itemData = List();
  List<Item> searchResult = [];
  List<ItemOrder> itemorderlist = [];
  //List<GiftPack> giftpacklist = [];
  List<GiftOrder> giftorderList = [];
  List<PromoOrder> promoOrderList = [];
  bool isBulk = false;
  String token = '';
  List<BackOrderRelease> backOrdersList = [];
  List<DistrBonus> distrBonusList = [];
  bool loading = false;
  bool bulkLoading = false;
  bool isBalanceChecked = true;
  bool isTypeing = false;

  String get distrPointNames {
    String _distrPointNames;
    _distrPointNames = distrPointName;
    notifyListeners();
    return _distrPointNames;
  }

  void itemDataUpdataProductToFB() async {
    List<Products> products = await getitemDetailsApi();
    if (products.isNotEmpty) {
      for (Products p in products)
        itemData.where((i) => i.itemId == p.itemId).forEach((f) {
          updateItemsCatFalse(f.key, p);
          print('${f.itemId}');
        });
    }
  }

  void addToBackOrderList(BackOrderRelease bOR) {
    bool v = false;
    for (final f in backOrdersList) {
      if (f.distrId.contains(bOR.distrId)) {
        v = true;
        break;
      }
    }
    if (v) {
      for (var bo in backOrdersList) {
        bo.distrId == bOR.distrId ? bo.backOrder.addAll(bOR.backOrder) : null;
      }
    } else {
      backOrdersList.add(bOR);
    }
  }

  List<BackOrderRelease> addToBulkBackOrderList(
      BackOrderRelease bOR, List<BackOrderRelease> _bulkBackOrderList) {
    bool v = false;
    for (final f in _bulkBackOrderList) {
      if (f.distrId.contains(bOR.distrId)) {
        v = true;
        break;
      }
    }
    if (v) {
      for (var bo in _bulkBackOrderList) {
        bo.distrId == bOR.distrId ? bo.backOrder.addAll(bOR.backOrder) : null;
      }
    } else {
      _bulkBackOrderList.add(bOR);
    }
    return _bulkBackOrderList;
  }

  bool getbulkBackOrderDistr(String distrId) {
    bool found = false;
    for (SalesOrder bo in bulkOrder) {
      for (final bbo in bo.backOrders) {
        if (bbo.distrId == distrId) {
          print('distrFound=>$found');
          found = true;
          break;
        }
      }
    }
    print('distrFound=>$found');
    return found;
  }

  Future<List<BackOrder>> getBulkBackOrderItems(
      String distrId, String storeId) async {
    List<BackOrder> _backOrder = [];
    List<BackOrder> checkedBO = [];
    List<BackOrderRelease> bulkBackOrderList = [];
    bool v = false;

    final response =
        await http.get('$httpath/getBackOrderItems/$distrId/$storeId');

    if (response.statusCode == 200) {
      final backOrderItems = json.decode(response.body) as List;

      _backOrder = backOrderItems.map((i) => BackOrder.jsonParse(i)).toList();
      backOrdersList
          .forEach((o) => addToBulkBackOrderList(o, bulkBackOrderList));
      bulkOrder.forEach((b) => b.backOrders
          .forEach((o) => addToBulkBackOrderList(o, bulkBackOrderList)));

      for (final f in bulkBackOrderList) {
        if (f.distrId.contains(distrId)) {
          v = true;
          break;
        }
      }

      if (v) {
        for (BackOrderRelease bol
            in bulkBackOrderList.where((f) => f.distrId == distrId)) {
          for (final bo in _backOrder) {
            bool found = false;

            for (final bl in bol.backOrder) {
              if (bo.docId == bl.docId && bo.itemId == bl.itemId) {
                found = true;
                print(bl.itemId);
                break;
              }
            }

            if (!found) {
              checkedBO.add(bo);
            }
          }
        }
      } else {
        checkedBO = _backOrder;
      }
    }
    return checkedBO;
  }

  Future<List<BackOrder>> getBackOrderItems(
      String distrId, String storeId) async {
    List<BackOrder> _backOrder = [];
    List<BackOrder> checkedBO = [];
    bool v = false;

    final response =
        await http.get('$httpath/getBackOrderItems/$distrId/$storeId');

    if (response.statusCode == 200) {
      final backOrderItems = json.decode(response.body) as List;

      _backOrder = backOrderItems.map((i) => BackOrder.jsonParse(i)).toList();

      for (final f in backOrdersList) {
        if (f.distrId.contains(distrId)) {
          v = true;
          break;
        }
      }

      if (v) {
        for (BackOrderRelease bol
            in backOrdersList.where((f) => f.distrId == distrId)) {
          for (final bo in _backOrder) {
            bool found = false;

            for (final bl in bol.backOrder) {
              if (bo.docId == bl.docId && bo.itemId == bl.itemId) {
                found = true;
                print(bl.itemId);
                break;
              }
            }

            if (!found) {
              checkedBO.add(bo);
            }
          }
        }
      } else {
        checkedBO = _backOrder;
      }
    }
    return checkedBO;
  }

  Future<List<Products>> getitemDetailsApi() async {
    List<Products> products;
    //List productlist;
    final response = await http.get('$httpath/allitemdetails');
    if (response.statusCode == 200) {
      final productlist = json.decode(response.body) as List;

      products = productlist.map((i) => Products.fromList(i)).toList();
    }
    return products;
  }

  bool getDistrBonus(String distrId) {
    bool found = false;
    for (var d in distrBonusList) {
      if (d.distrId == distrId) {
        found = true;
        break;
      }
    }

    return found;
  }

  Future<DistrBonus> distrBonus(String distrId) async {
    DistrBonus _distrBonus;

    final response = await http.get('$httpath/deserve_bonus/$distrId');
    if (response.statusCode == 200) {
      List _bonus = json.decode(response.body);
      _distrBonus = DistrBonus.fromJson(_bonus.first);
    } else {
      _distrBonus = null;
    }
    return _distrBonus;
  }

  updateItemsCatFalse(String itemId, Products p) {
    DatabaseReference catF = FirebaseDatabase.instance.reference().child(
        'flamelink/environments/egyProduction/content/items/en-US/$itemId');

    catF.update({
      'catalogue': p.catalog,
      'disable': false,
      'promo': p.promo,
      'price': p.price,
      'bp': p.bp,
      'bv': p.bv,
      'weigth': p.weight

      // 'fromSupport': 0,
    });
  }

  updateEnabledItems(String itemId) {
    database
        .reference()
        .child('$path/items/en-US/$itemId')
        .update({"disable": false});
  }

  Item getRecoItem(Item item) {
    var i = itemData.where((i) => i.itemId == item.itemId).first;
    notifyListeners();
    return i;
  }

  List<Item> getCaouselItems(Item item) {
    _recoImage.clear();
    itemData
        .where((i) =>
            i.itemId != item.itemId &&
            i.brand == item.brand &&
            i.disabled == false &&
            i.imageUrl.length > 10)
        .forEach((i) {
      _recoImage.add(i);
    });
    itemData
        .where((i) =>
            i.itemId != item.itemId &&
            i.grp != null &&
            item.grp != null &&
            i.grp.first == item.grp.first &&
            i.disabled == false &&
            i.imageUrl.length > 10)
        .forEach((i) {
      _recoImage.add(i);
    });
    itemData
        .where((i) =>
            i.itemId != item.itemId &&
            i.cat != null &&
            item.cat != null &&
            i.cat.first == item.cat.first &&
            i.disabled == false &&
            i.imageUrl.length > 10)
        .forEach((i) {
      _recoImage.add(i);
    });

    return _recoImage;
  }

  bool limited(int key) {
    bool islimited = false;
    if (settings.limitedItem != null) {
      for (var l in settings.limitedItem) {
        if (key == l) {
          islimited = true;
        }
      }
    }
    return islimited;
  }

  Future<List<User>> getContacts(String distrId) async {
    List<User> _contactList = await messageKeys(distrId);

    return _contactList;
  }

  Future<List<User>> messageKeys(String distrId) async {
    List<String> keys = [];
    List<User> _contactList = [];
    DataSnapshot snapshot =
        await database.reference().child('$path/messages/en-US/').once();
    Map<dynamic, dynamic> msg = snapshot.value;
    // print('mkeys:=>${msg.keys}');

    List mkeys = msg.keys.toList();

    for (var k in mkeys) {
      k.split('-')[0] == distrId
          ? keys.add(k.split('-')[1])
          : k.split('-')[1] == distrId ? keys.add(k.split('-')[0]) : print('');
    }
    keys.forEach((k) => k.toString() != null
        ? contact(k.toString()).then((c) {
            _contactList.add((c));
          })
        : null);
    return _contactList;
  }

  Future<User> contact(String key) async {
    User contactUser;
    DataSnapshot snapshot =
        await database.reference().child('$path/users/en-US/$key').once();
    if (snapshot.value != null) {
      contactUser = User.fromSnapshot(snapshot);
      print(
          'contactUser:${contactUser.key}--${contactUser.name}--${contactUser.photoUrl}');
    }

    return contactUser;
  }

  Lock settings;
//!--------*Settings*-----------//
  Future<Lock> settingsData() async {
    DataSnapshot snapshot =
        await database.reference().child('$path/lockScreen/en-US').once();
    settings = Lock.fromSnapshot(snapshot);
    notifyListeners();

    //print('Setting${settings.bannerUrl}');
    return settings;
  }

  Future<List<Item>> fbItemList() async {
    DataSnapshot snapshot =
        await database.reference().child('$path/items/en-US/').once();
    Map<dynamic, dynamic> fbitemsList = snapshot.value;
    List fblist = fbitemsList.values.toList();
    List<Item> fbItems = fblist.map((f) => Item.fromList(f)).toList();
    return fbItems;
  }

  Future<List<Item>> dbItemsList() async {
    List<Item> products;
    //List productlist;
    final response = await http.get('$httpath/allitemdetails');
    if (response.statusCode == 200) {
      final productlist = json.decode(response.body) as List;

      products = productlist.map((i) => Item.fromJson(i)).toList();
    }
    return products;
  }

  Future<List<Item>> fbItemsUpdateFromDb() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'mobile-coco',
      options: FirebaseOptions(
          googleAppID: '1:592280217867:android:7c1c6ad4297912c3',
          gcmSenderID: '592280217867',
          apiKey: 'AIzaSyDDMUXEZNsB-B2MCw6_xHUA9lirfuYW00w',
          projectID: 'mobile-coco'),
    );

    final List<Item> dbItems = await dbItemsList();
    final List<Item> fbItems = await fbItemList();
    final FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://mobile-coco.appspot.com/');

    final StorageReference storageRef = storage.ref().child('imgs');
    List<Item> items = [];
    for (var i = 0; i < fbItems.length; i++) {
      for (var x = 0; x < dbItems.length; x++) {
        if (fbItems[i].itemId == dbItems[x].itemId) {
          dbItems[x].id = int.parse(fbItems[i].id.toString());
          items.add(dbItems[x]);

          print('count:$i--fbId:${fbItems[i].id} => dbId:${dbItems[x].id}->}');
        }
      }
    }

    for (var i = 0; i < items.length; i++) {
      items[i].catalogue == true
          ? items[i].disabled = false
          : items[i].disabled = true;
      try {
        if (items[i].promo != '0' || items[i].promo != null) {
          var promoString =
              storageRef.child('tag-${items[i].promo}.png').getDownloadURL();
          items[i].promoImageUrl = await promoString;
        } else {
          items[i].promoImageUrl = '';
        }
      } catch (e) {
        // print(e.toString());
      }
      print(
          'count:$i#-fbId:${items[i].id}=>${items[i].itemId}+dbId:${items[i].promo}->PromoUrl:${items[i].promoImageUrl}');
    }

    void updateItemsToFirebase(int id, Item item) {
      databaseReference =
          database.reference().child('$path/items/en-US/${id.toString()}');
      databaseReference.update(item.toJsonUpdate());
    }

    for (Item item in items) {
      updateItemsToFirebase(item.id, item);
      print(
          '${item.id}..${item.itemId}..${item.price}..${item.bp}..${item.promo}..${item.promoImageUrl}');
    }
    return items;
  }

  void itemsAndImageAssembly() async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: 'mobile-coco',
      options: FirebaseOptions(
          googleAppID: '1:592280217867:android:7c1c6ad4297912c3',
          gcmSenderID: '592280217867',
          apiKey: 'AIzaSyDDMUXEZNsB-B2MCw6_xHUA9lirfuYW00w',
          projectID: 'mobile-coco'),
    );
    final FirebaseStorage storage = FirebaseStorage(
        app: app, storageBucket: 'gs://mobile-coco.appspot.com/');

    StorageReference storageRef;
    storageRef = storage.ref().child('imgs');
    //var spaceRef = storageRef.child('1092.png').getDownloadURL();
//String img = await spaceRef;

    List<Item> items;
    final response = await http
        .get('http://mywayegypt-api.azurewebsites.net/api/allitemdetails');
    if (response.statusCode == 200) {
      List<dynamic> itemlist = json.decode(response.body);
      items = itemlist.map((i) => Item.fromJson(i)).toList();
    }
    print('itemslist length${items.length}');
    for (Item i in items) {
      var imgString = storageRef.child('${i.itemId}.png').getDownloadURL();
      var promoString1 =
          storageRef.child('tag-${i.promo}0.png').getDownloadURL();
      var promoString = storageRef.child('tag-${i.promo}.png').getDownloadURL();

      try {
        i.imageUrl = await imgString;
        i.disabled = false;
        print('${i.itemId}..${i.imageUrl}');
        if (i.promo.length == 1 && i.promo != '0') {
          i.promoImageUrl = await promoString1;
        } else {
          if (i.promo.length == 2)
            i.promoImageUrl = await promoString;
          else {
            i.promoImageUrl = '';
          }
        }
      } catch (e) {
        i.promoImageUrl = '';
        i.imageUrl = '';
        i.disabled = true;
        print('ItemId not AVALABLE');
      }
    }
    /*
*/

    items.forEach((f) =>
        print('${f.itemId}..${f.imageUrl}..${f.disabled}..${f.promoImageUrl}'));
    print('itemslist length${items.length}');

    void pushItemsToFirebase(String itemId, Item item) {
      databaseReference = database.reference().child('$path/items/en-US');
      databaseReference.set(item.toJson());
    }

    for (Item item in items) {
      pushItemsToFirebase(item.itemId, item);
      print(
          '${item.itemId}..${item.imageUrl}..${item.disabled}..${item.promoImageUrl}');
    }
  }

  void stageToProduction() async {
    DataSnapshot stagesnapshot =
        await database.reference().child('$path/items/en-US/').once();

    Map<dynamic, dynamic> itemlist = stagesnapshot.value;
    List list = itemlist.values.toList();
    List<Item> items = list.map((f) => Item.fromList(f)).toList();

    print(items.first.itemId);
//items.forEach((f)=>print({f.itemId:f.key}));

//items.forEach((f)=>print(f.itemId));

    void pushItemsToFirebase(Item item, String key) {
      DatabaseReference ref =
          database.reference().child('$path/items/en-US/$key');
      //var push =ref.push();
      ref.update({item.id: key});
    }

    for (Item item in items) {
      pushItemsToFirebase(item, item.key);
      print(
          '${item.itemId}..${item.imageUrl}..${item.disabled}..${item.promoImageUrl}');
    }
  }

//!--------*Items*-----------//
  String idPadding(String input) {
    input = input.padLeft(8, '0');
    return input;
  }

//!--------*Orders*---------//

//!--------*

  void addToItemOrder(Item item, int qty) {
    if (item.bp != 0) {
      giftorderList.clear();
      promoOrderList.clear();
      addItemOrder(item, qty);
    } else {
      addItemOrder(item, qty);
    }
  }

  void addItemOrder(Item item, int qty, [bool _held = false]) {
    final ItemOrder itemorder = ItemOrder(
      itemId: item.itemId,
      price: double.parse(item.price.toString()),
      bp: item.bp,
      bv: double.parse(item.bv.toString()),
      qty: qty,
      held: _held,
      name: item.name,
      weight: double.parse(item.weight.toString()),
      img: item.imageUrl,
    );

    var x = itemorderlist.where((orderItem) => orderItem.itemId == item.itemId);
    int i;
    ItemOrder itemOrdered;
    if (x.isNotEmpty) {
      itemOrdered = itemorderlist.where((i) => i.itemId == item.itemId).first;
      i = itemorderlist.indexOf(itemOrdered);
      itemorderlist[i].qty += itemorder.qty;
      itemorderlist[i].held = itemorder.held;
      notifyListeners();
    } else {
      itemorderlist.add(itemorder);
      notifyListeners();
    }
  }

  void addGiftToBlukOrder(Item item, int qty, SalesOrder order) {
    final ItemOrder itemorder = ItemOrder(
      itemId: item.itemId,
      price: 0.0,
      bp: 0,
      bv: 0.0,
      qty: qty,
      name: item.name,
      weight: item.weight,
      img: item.imageUrl,
    );

    order.order.add(itemorder);
    notifyListeners();
  }

//!-------------------------------------------*
  bool iheld(int x, {String item}) {
    if (itemorderlist.isNotEmpty) {
      if (item != null) {
        var i = itemData.where((i) => i.itemId == item);
        int index = itemData.indexOf(i.first);

        try {
          var l =
              itemorderlist.where((o) => o.itemId == itemData[index].itemId);
          // int index = itemorderlist.indexOf(l.first);
          notifyListeners();
          return l.single.held; //use to be l.first.qty
        } catch (e) {
          notifyListeners();
          return false;
        }
      }
      if (itemorderlist.length > 0) {
        if (searchResult.length == 0) {
          try {
            var l = itemorderlist.where((o) => o.itemId == itemData[x].itemId);
            //int index = itemorderlist.indexOf(l.first);
            notifyListeners();
            return l.single.held; //use to be l.first.qty
          } catch (e) {
            notifyListeners();
            return false;
          }
        } else {
          try {
            var l =
                itemorderlist.where((o) => o.itemId == searchResult[x].itemId);
            // int index = itemorderlist.indexOf(l.first);
            notifyListeners();
            return l.single.held; //use to be l.first.qty
          } catch (e) {
            notifyListeners();

            return false;
          }
        }
      }
      return false;
    }

    return false;
  }

  int iCount(int x, {String item}) {
    if (item != null) {
      var i = itemData.where((i) => i.itemId == item);
      int index = itemData.indexOf(i.first);

      try {
        var l = itemorderlist.where((o) => o.itemId == itemData[index].itemId);
        // int index = itemorderlist.indexOf(l.first);
        notifyListeners();
        return l.single.qty; //use to be l.first.qty
      } catch (e) {
        notifyListeners();

        return 0;
      }
    }
    if (itemorderlist.length > 0) {
      if (searchResult.length == 0) {
        try {
          var l = itemorderlist.where((o) => o.itemId == itemData[x].itemId);
          //int index = itemorderlist.indexOf(l.first);
          notifyListeners();
          return l.single.qty; //use to be l.first.qty
        } catch (e) {
          notifyListeners();
          return 0;
        }
      } else {
        try {
          var l =
              itemorderlist.where((o) => o.itemId == searchResult[x].itemId);
          // int index = itemorderlist.indexOf(l.first);
          notifyListeners();
          return l.single.qty; //use to be l.first.qty
        } catch (e) {
          notifyListeners();

          return 0;
        }
      }
    }
    return 0;
  }

//!--------*

  int getItemIndex(int x) {
    var item = itemData.where((i) => i.itemId == itemorderlist[x].itemId);

    int index;
    item.isNotEmpty ? index = itemData.indexOf(item.first) : null;

    return index;
  }

  int getIndex(String i) {
    var item = itemData.where((t) => t.itemId == i);
    int index = itemData.indexOf(item.first);
    //print('getIndex:$index');
    //print('${itemData.length}');
    return index;
  }

//!--------*
  void deleteItemOrder(int i) {
    giftorderList.clear();
    promoOrderList.clear();
    itemorderlist.remove(itemorderlist[i]);
    notifyListeners();
  }

  void deleteDistrBonus(int i, BuildContext context) {
    distrBonusList.remove(distrBonusList[i]);
    distrBonusList.isEmpty ? Navigator.of(context).pop() : null;
    notifyListeners();
  }

  void deleteBackOrderItem(int i, BuildContext context) {
    backOrdersList.remove(backOrdersList[i]);
    backOrdersList.isEmpty ? Navigator.of(context).pop() : null;
    notifyListeners();
  }

  void deleteBackOrderDetails(BackOrder backOrder, BuildContext context) {
    bool v = false;
    for (final f in backOrdersList) {
      if (f.backOrder.contains(backOrder)) {
        v = true;
        break;
      }
    }
    if (v) {
      for (var bo in backOrdersList) {
        bo.backOrder.remove(backOrder);
        bo.backOrder.isEmpty ? backOrdersList.remove(bo) : null;
        bo.backOrder.isEmpty ? Navigator.of(context).pop() : null;
      }
    }
    notifyListeners();
  }

//!--------*
  void removeItemOrder(Item item, int qty, [bool _held = false]) {
    giftorderList.clear();
    promoOrderList.clear();
    final ItemOrder itemorder = ItemOrder(
        itemId: item.itemId,
        price: double.parse(item.price.toString()),
        bp: item.bp,
        bv: double.parse(item.bv.toString()),
        qty: qty);

    var x = itemorderlist.where((orderItem) => orderItem.itemId == item.itemId);
    int i;
    bool canRemove = false;
    x.forEach((f) => f.qty >= qty ? canRemove = true : canRemove = false);
    ItemOrder itemOrdered;

    if (x.isNotEmpty && canRemove) {
      itemOrdered = itemorderlist.where((i) => i.itemId == item.itemId).first;
      i = itemorderlist.indexOf(itemOrdered);
      if (itemOrdered.qty == itemorder.qty) {
        itemorderlist.remove(itemOrdered);
      } else {
        itemorderlist[i].qty -= itemorder.qty;
        itemorderlist[i].held = _held;
        print('removeItem Held:=>$_held');
        notifyListeners();
        print('olderIndex:$i');
        print('x not empty :${x.isNotEmpty}');
      }
    }
  }

//!--------*
  double distrBonusDeductTotal() {
    double x = 0;
    for (DistrBonus i in distrBonusList) {
      x += i.bonus;
    }
    notifyListeners();
    return x;
  }

  List<ItemOrder> get displayItemOrder {
    return List.from(itemorderlist);
  }

  /*List<GiftPack> get displayGiftOrder {
    return List.from(giftpacklist);
  }*/

  double giftWeight() {
    double w = 0;
    if (giftorderList.length > 0) {
      for (GiftOrder g in giftorderList) {
        for (var p in g.pack) {
          w += p.weight * g.qty;
        }
      }
    }
    return w;
  }

  double promoWeight() {
    double w = 0;
    if (promoOrderList.length > 0) {
      for (PromoOrder g in promoOrderList) {
        for (var p in g.promoPack) {
          w += p.weight * g.qty;
        }
      }
    }
    return w;
  }

  double orderWeight() {
    double x = 0;
    for (ItemOrder i in itemorderlist) {
      x += i.weight * i.qty;
    }
    notifyListeners();
    x += promoWeight() + giftWeight();
    return x;
  }

  double bulkOrderBp() {
    double x = 0;
    for (SalesOrder i in bulkOrder) {
      x += i.totalBp;
    }
    notifyListeners();
    return x;
  }

  double bulkOrderWeight() {
    double x = 0;
    for (SalesOrder o in bulkOrder) {
      x += o.weight;
    }

    notifyListeners();
    return x;
  }

  double bulkOrderSum() {
    double x = 0;
    for (SalesOrder i in bulkOrder) {
      x += i.total;
    }
    notifyListeners();
    return x;
  }

//!--------*
  double orderSum() {
    double x = 0;
    for (ItemOrder i in itemorderlist) {
      x += i.price * i.qty;
    }
    notifyListeners();
    return x;
  }

//!--------*
  int orderBp() {
    int x = 0;
    for (ItemOrder i in itemorderlist) {
      x += i.bp * i.qty;
    }
    notifyListeners();
    return x;
  }

//!--------*
  int itemCount() {
    int x = 0;
    for (ItemOrder i in itemorderlist) {
      x += i.qty;
    }
    // print('itemCount:$x');
    notifyListeners();
    return x;
  }

//!--------*legacy salesOrder*---------//

  String distrIdDel;
  String docIdDel;
  bool loadingSoPage = false;
  Future<List<Sorder>> checkSoDeletion(String userId) async {
    List<Sorder> sos;
    final http.Response response =
        await http.get('$httpath/userpending/$userId');
    if (response.statusCode == 200) {
      print('check deletion!!');
      List<dynamic> soList = json.decode(response.body);
      sos = soList.map((i) => Sorder.fromJson(i)).toList();
    }
    return sos;
  }

  void checkSoDupl(
    Function getSorders,
    String userId,
  ) async {
    List<Sorder> _check = await checkSoDeletion(userId);
    int _recheck = _check
        .where((f) => f.distrId == distrIdDel && f.docId == docIdDel)
        .length;
    if (_recheck == 0) {
      getSorders(userId);
      loadingSoPage = false;
    } else {
      checkSoDupl(getSorders, userId);
      //print(_recheck);
    }
  }

  Future<DateTime> serverTimeNow() async {
    DateTime _stn;
    final http.Response response = await http.get('$httpath/datetimenow');
    if (response.statusCode == 200) {
      String stn = json.encode(response.body);
      // print(stn);
      String subTime = stn.substring(3, 22);
      // print(subTime);
      _stn = DateTime.parse(subTime);
    }
    // print("serverTime:$_stn");
    return _stn;
  }

//!--------*Gift*---------//
  int gCount(int x) {
    var g = giftorderList[x].qty;
    return g;
  }

  int promoCount(int x) {
    var p = promoOrderList[x].qty;
    return p;
  }

  int giftBp() {
    int x = 0;
    for (GiftOrder i in giftorderList) {
      x += i.bp * i.qty;
    }
    notifyListeners();
    return x;
  }

  int promoBp() {
    int x = 0;
    for (PromoOrder i in promoOrderList) {
      x += i.bp * i.qty;
    }
    notifyListeners();
    return x;
  }

  void addGiftPackOrder(GiftPack pack) {
    final GiftOrder giftOrder = GiftOrder(
      pack: pack.pack,
      bp: pack.bp,
      qty: pack.qty,
      imageUrl: pack.imageUrl,
      desc: pack.desc,
    );
    var x = giftorderList.where((i) => i.bp == pack.bp);
    int i;
    GiftOrder giftOrdered;
    if (x.isNotEmpty) {
      giftOrdered = giftorderList.where((i) => i.bp == pack.bp).first;
      i = giftorderList.indexOf(giftOrdered);
      giftorderList[i].qty += giftOrder.qty;
      notifyListeners();
      print('giftorderlist:${giftorderList.length}');
    } else {
      giftorderList.add(giftOrder);
      notifyListeners();
      print('giftorderlist:${giftorderList.length}');
    }
  }

  void addPromoPackOrder(PromoPack pack) {
    final PromoOrder promoOrder = PromoOrder(
      promoPack: pack.promoPack,
      bp: pack.bp,
      qty: pack.qty,
      imageUrl: pack.imageUrl,
      desc: pack.desc,
    );
    var x = promoOrderList.where((i) => i.bp == pack.bp);
    int i;
    PromoOrder promoOrdered;
    if (x.isNotEmpty) {
      promoOrdered = promoOrderList.where((i) => i.bp == pack.bp).first;
      i = promoOrderList.indexOf(promoOrdered);
      promoOrderList[i].qty += promoOrder.qty;
      notifyListeners();
    } else {
      promoOrderList.add(promoOrder);
      notifyListeners();
    }
  }

  void deleteGiftOrder(int i) {
    giftorderList.remove(giftorderList[i]);
    notifyListeners();
  }

  void deletePromoOrder(int i) {
    promoOrderList.remove(promoOrderList[i]);
    notifyListeners();
  }

  Future<List<Gift>> giftList() async {
    DataSnapshot snapshot =
        await database.reference().child('$path/gifts/en-US/').once();

    Map<dynamic, dynamic> giftsList = snapshot.value;
    List list = giftsList.values.toList();
    List<Gift> gifts = list.map((f) => Gift.fbList(f)).toList();

    return gifts;
  }

  Future<List<Promo>> promoList() async {
    DataSnapshot snapshot =
        await database.reference().child('$path/timePromo/en-US/').once();

    Map<dynamic, dynamic> promosList = snapshot.value;
    List list = [];
    if (snapshot.value != null) {
      list = promosList.values.toList();
    } else {
      list = [];
    }

    List<Promo> promos = [];
    promos = list.map((f) => Promo.fbList(f)).toList();
    //bool activePromo = promoIsActive(promos);
    //print('Is Active Promo : => $activePromo');
    DateTime serverTime;
    Duration promoFrom;
    Duration promoTo;

    List<Promo> promosOngoing = [];
    serverTime = await serverTimeNow();

    for (var x in promos) {
      var serverT = DateFormat('yyyy-MM-dd').format(serverTime);

      var promoF = DateFormat('yyyy-MM-dd').format(DateTime.parse(x.fromDate));
      var promoT = DateFormat('yyyy-MM-dd').format(DateTime.parse(x.toDate));
      promoFrom = DateTime.parse(promoF).difference(DateTime.parse(serverT));
      promoTo = DateTime.parse(promoT).difference(DateTime.parse(serverT));
      if (promoFrom.inDays <= 0 && promoTo.inDays >= 0) {
        // print('Fromdays:${promoFrom.inDays}ToDays:${promoTo.inDays}');
        promosOngoing.add(x);
      }
      //  print('Fromdays:${promoFrom.inDays}ToDays:${promoTo.inDays}');
    }
    return promosOngoing ?? [];
  }

  List<Gift> giftQty;
  Future<void> checkGift(int orderbp, int giftbp) async {
    int _qualifyBp = orderbp - giftbp;
    List<Gift> gifts = [];
    gifts = await giftList();

    List<Gift> aprovedGift = [];
    giftQty = [];
    gifts.forEach((g) => _qualifyBp / g.bp >= 1 ? aprovedGift.add(g) : null);

//gifts.forEach((g)=>qualifyBp/g.bp>=1?aprovedGift.add(g):null);

    for (var i = 0; i < aprovedGift.length; i++) {
      double x = _qualifyBp / aprovedGift[i].bp;
      for (var e = 0; e < x.toInt(); e++) {
        giftQty.add(aprovedGift[i]);
      }
    }
  }

  bool promoIsActive(List<Promo> promos) {
    bool isActive = false;
    for (var p in promos) {
      DateTime _from = DateTime.parse(p.fromDate);
      DateTime _to = DateTime.parse(p.toDate);
      if (_from.isBefore(DateTime.now()) || _to.isAfter(DateTime.now())) {
        isActive = false;
      } else {
        isActive = true;
      }
    }
    return isActive;
  }

  List<Promo> promoQty;
  Future<void> checkPromo(int orderbp, int promobp) async {
    int _qualifyBp = orderbp - promobp;
    List<Promo> promos = [];
    promos = await promoList();

    List<Promo> aprovedPromo = [];
    promoQty = [];
    if (promos.length >= 1) {
      promos
          .forEach((p) => _qualifyBp / p.bp >= 1 ? aprovedPromo.add(p) : null);
      for (var i = 0; i < aprovedPromo.length; i++) {
        double x = _qualifyBp / aprovedPromo[i].bp;
        for (var e = 0; e < x.toInt(); e++) {
          promoQty.add(aprovedPromo[i]);
        }
      }
    }
    //print('promos length==>${promos.length}');
  }

  bool isloading = false;
  void loadGift(List<GiftPack> giftData, int index) {
    isloading = true;
    Duration wait = Duration(milliseconds: 800);
    Timer(wait, () async {
      addGiftPackOrder(giftData[index]);
      await checkGift(orderBp(), giftBp());
      getGiftPack();
      isloading = false;
    });
  }

  void loadPromo(List<PromoPack> promoData, int index) {
    isloading = true;
    Duration wait = Duration(milliseconds: 800);
    Timer(wait, () async {
      addPromoPackOrder(promoData[index]);
      await checkPromo(orderBp(), promoBp());
      getPromoPack();
      isloading = false;
    });
  }

  void rungiftState() {
    giftState();
    promoState();
    notifyListeners();
  }

  void giftState() async {
    await checkGift(orderBp(), giftBp());
    getGiftPack();
  }

  void promoState() async {
    await checkPromo(orderBp(), promoBp());
    getPromoPack();
  }

  List<GiftPack> giftPacks = [];
  void getGiftPack() {
    // List<Item> giftItems =List() ;
    Item item;
    giftPacks.clear();
    GiftPack giftPack;
//print('GiftPack:${giftQty.length}');
    for (var i = 0; i < giftQty.length; i++) {
      giftPack = GiftPack(
          key: i.toString(),
          bp: giftQty[i].bp,
          imageUrl: giftQty[i].imageUrl,
          desc: giftQty[i].desc);
      giftPack.pack = [];

      for (var p = 0; p < giftQty[i].items.length; p++) {
        item = itemData
            .where((item) => item.key == giftQty[i].items[p].toString())
            .first;
        //print('${item.itemId}');

        giftPack.pack.add(item);
        //giftPacks.add(giftPack);

      }
      giftPacks.add(giftPack);

      // giftItems.forEach((f)=>print(f.itemId));
    }
    //  giftPacks.forEach((f)=>print(f.bp));
    //  giftPacks.forEach((f)=>f.pack.forEach((p)=>print({p.itemId:p.image})));

    //*----------\\\\//////////////////////////***////////////////////////////\\\\-----------*//

    //print('PackKey:${giftPack.key} + PackKey:${giftPack.bp}'  );
    //print('${giftPack.pack.length}');
    //giftPack.pack.forEach((f)=>print({f.itemId:f.price}));
    //print('giftPacks Length:${giftPacks.length}');
    // return giftPacks;
  }

  List<PromoPack> promoPacks = [];
  void getPromoPack() {
    Item item;
    promoPacks.clear();
    PromoPack promoPack;
    for (var i = 0; i < promoQty.length; i++) {
      promoPack = PromoPack(
          key: i.toString(),
          bp: promoQty[i].bp,
          imageUrl: promoQty[i].imageUrl,
          desc: promoQty[i].desc);
      promoPack.promoPack = [];
      for (var p = 0; p < promoQty[i].items.length; p++) {
        item = itemData
            .where((item) => item.key == promoQty[i].items[p].toString())
            .first;
        promoPack.promoPack.add(item);
      }
      promoPacks.add(promoPack);
    }
  }

//!--------*Stock*---------//
  Future<int> getStock(String itemId) async {
    ItemOrder itemOrder;
    List stockData = [];
    http.Response response =
        await http.get('$httpath/stock/$itemId/$setStoreId');
    print(response.body);
    if (response.statusCode == 200) {
      stockData = json.decode(response.body);
      itemOrder = ItemOrder.fromJson(stockData.first);
    }
    return itemOrder == null ? 0 : itemOrder.qty;
  }

  int getItemOrderQty(Item item) {
    int x;
    bool y = itemorderlist.where((i) => i.itemId == item.itemId).isNotEmpty;
    if (y) {
      x = itemorderlist.where((i) => i.itemId == item.itemId).first.qty;
      print("itemId${item.itemId}: qty:$x");
    } else {
      x = 0;
    }
    return x;
  }

  void addCatToOrder(String itemid) {
    final Item item = Item(
      itemId: itemid,
      price: 0,
      bp: 0,
      bv: 0.0,
      name: 'Katalog bulan ini',
      imageUrl: '',
    );
    addToItemOrder(item, 2);
  }

  void addAdminToOrder(String itemid) {
    final Item item = Item(
      itemId: itemid,
      price: settings.adminFee,
      bp: 0,
      bv: 0.0,
      name: 'Biaya admin',
      imageUrl: '',
    );
    addToItemOrder(item, 1);
  }

  void addCourierToOrder(String itemid, double fee) {
    final ItemOrder itemorder = ItemOrder(
      itemId: itemid,
      price: fee,
      bp: 0,
      bv: 0,
      qty: 1,
      name: 'Courier',
      weight: 0,
      img: "",
    );
    itemorderlist.add(itemorder);
  }

  void mockOrder(Item item, int qty) {
    addItemOrder(item, qty);
  }

  int totalPromoBp(int bp) {
    int _bp;

    _bp += bp;
    return _bp;
  }

  Flushbar flush(BuildContext context, String _msg,
      {String subMsg = 'تم تخطي الحد الاقصي لنقاط'}) {
    Flushbar _flush = Flushbar(
      duration: Duration(seconds: 4),
      messageText: Center(
          child: Text(_msg,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15, color: Colors.limeAccent[100]))),
      isDismissible: true,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      mainButton: FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(
          Icons.warning,
          color: Colors.red,
        ),
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      title: subMsg,
      icon: Padding(
        padding: EdgeInsets.only(left: 18),
        child: Image.asset(
          'assets/images/myway.png',
          scale: 6,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.red[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        ),
      ],
    );
    return _flush;
  }

  Future<String> getOrderInvalidPerc(MainModel model) async {
    double _exPromo = getExPromo(orderBp());
    double _wPromo = await getWeeklyPromo(orderBp());
    double promoSum = _exPromo + _wPromo;
    String _msg = '';

    if (orderBp() > 100) {
      if (promoSum > 71 && _exPromo > 0 && _wPromo > 0) {
        _msg = '% ' + '${promoSum.toInt().toString()}' + ' ' + 'العرض و الشاور';
      } else if (_exPromo > 51 && _wPromo == 0) {
        promoSum = _exPromo;
        _msg = '% ' + '${_exPromo.toInt().toString()}' + ' ' + 'الشاور';
      } else if (_wPromo > 51 && _exPromo == 0) {
        promoSum = _wPromo;
        _msg = '% ' + '${_wPromo.toInt().toString()}' + ' ' + 'العرض';
      }
    }

    return _msg;
  }

  double getExPromo(int totalBp) {
    int exPromoItemBpTotal = 0;
    List<ItemOrder> exList = [];
    for (var i in settings.exItems) {
      itemorderlist
          .forEach((f) => i.toString() == f.itemId ? exList.add(f) : null);
    }
    for (ItemOrder i in exList) {
      exPromoItemBpTotal += i.bp * i.qty;
    }

    return exPromoItemBpTotal * 100 / totalBp;
  }

  Future<double> getWeeklyPromo(int totalBp) async {
    int promoItemBpTotal = 0;
    DataSnapshot snapshot =
        await database.reference().child('$path/gifts/en-US/').once();
    Map<dynamic, dynamic> giftsList = snapshot.value;
    List list = giftsList.values.toList();
    List<Gift> gifts = list.map((f) => Gift.fbList(f)).toList();
    String promoItem = gifts[0].items.first.toString();

    for (ItemOrder item in itemorderlist) {
      if (item.itemId == promoItem) {
        promoItemBpTotal = item.bp * item.qty;
      }
    }
    return promoItemBpTotal * 100 / totalBp;
  }

  Future<OrderMsg> orderBalanceCheck(String shipmentId, double courierfee,
      String distrId, String note, String areaId) async {
    OrderMsg msg;
    List<ItemOrder> orderOutList = List();

    //promoOrderList.forEach((p) => print('bp:${p.bp}Qty:${p.qty}'));
    for (ItemOrder item in itemorderlist) {
      await getStock(item.itemId).then((i) {
        if (i < item.qty && !item.held) {
          print('stock:$i');
          print('heldtree:${item.held}');
          orderOutList.add(item);
          orderOutList.last.qty = i;
          print('OutListBelow:');
          isBalanceChecked = false;
          print({orderOutList.last.itemId: orderOutList.last.qty});
        }
      });
    }
    if (orderOutList.length > 0) {
      for (ItemOrder item in orderOutList) {
        itemorderlist
            .where((i) => i.itemId == item.itemId)
            .forEach((f) => f.qty = item.qty);
      }
      orderOutList.clear();
      giftorderList.clear();
      promoOrderList.clear();
      itemorderlist.removeWhere((i) => i.qty <= 0);
      isBalanceChecked = false;
    } else {
      isBalanceChecked = true;
      msg = await saveOrder(shipmentId, courierfee, distrId, note, areaId);
    }
    return msg;
  }

  bool _isWaiting = true;
  bool wait() {
    Duration wait = Duration(minutes: 1);
    Timer(wait, () async {
      print('waiting...');
    });
    _isWaiting = false;
    return _isWaiting;
  }

//!-------------------------------------SaveOrder---------------------------------//
  List<SalesOrder> bulkOrder = [];

  void orderToBulk(String _distrId) {
    SalesOrder order = SalesOrder(
        distrId: _distrId,
        userId: userInfo.distrId,
        total: orderSum(),
        totalBp: orderBp(),
        note: '',
        address: shipmentAddress,
        courierId: '',
        storeId: setStoreId,
        branchId: setStoreId,
        soType: docType,
        areaId: shipmentArea,
        weight: orderWeight(),
        order: itemorderlist,
        gifts: giftorderList,
        backOrders: backOrdersList,
        distrBonues: distrBonusList,
        backOrder: txtBackOrderList(),
        bonusDeduc: txtdistrBonusList(),
        promos: promoOrderList);
    bulkOrder.add(order);
    distrBonusList = [];
    backOrdersList = [];
    itemorderlist = [];
    giftorderList = [];
    promoOrderList = [];
  }

  double reOrderWeight(List<ItemOrder> itemOrder) {
    double x = 0;
    for (ItemOrder i in itemOrder) {
      x += i.weight * i.qty;
    }
    return x;
  }

  double reOrderSum(List<ItemOrder> itemOrder) {
    double x = 0;
    for (ItemOrder i in itemOrder) {
      x += i.price * i.qty;
    }
    return x;
  }

  int reOrderBp(List<ItemOrder> itemOrder) {
    int x = 0;
    for (ItemOrder i in itemOrder) {
      x += i.bp * i.qty;
    }
    return x;
  }

  // List<AggrItem> bulkItemsjoin = List();

  List<AggrItem> itemOrderAggrList(List<ItemOrder> itemOrders) {
    List<AggrItem> bulkItemsjoin = [];

    for (var item in itemOrders) {
      AggrItem aggrItem =
          AggrItem(id: item.itemId, qty: item.qty, held: item.held);
      if (bulkItemsjoin.length == 0) {
        bulkItemsjoin.add(aggrItem);
      } else {
        if (bulkItemsjoin.where((i) => i.id == aggrItem.id).length > 0) {
          bulkItemsjoin.firstWhere((i) => i.id == item.itemId).qty += item.qty;
        } else {
          bulkItemsjoin.add(aggrItem);
        }
      }
    }
    bulkItemsjoin.forEach((i) => print('${i.id}:${i.qty}:${i.held}'));
    return bulkItemsjoin;
  }

  List<AggrItem> bulkItemsList(List<SalesOrder> orders) {
    List<ItemOrder> itemOrdersII = [];
    // orders.forEach((o) => print({o.distrId: o.total}));
    orders.forEach((so) => so.order.forEach((item) {
          print("held too:${item.held}");
          itemOrdersII.add(item);
        }));

    return itemOrderAggrList(itemOrdersII);
  }

  int getItemBulkQty(Item item) {
    List<AggrItem> itemBulkQty = bulkItemsList(bulkOrder);
    int x;
    bool y = itemBulkQty.where((i) => i.id == item.itemId).isNotEmpty;
    if (y) {
      x = itemBulkQty.where((i) => i.id == item.itemId).first.qty;
      print("ItemId${item.itemId}: BulkQty:$x");
    } else {
      x = 0;
    }
    return x;
  }

  Future<List<AggrItem>> mockBulkOrderBalanceCheck(
      List<SalesOrder> orders, List<AggrItem> aggrItem) async {
    // List<ItemOrder> orderOutList = List();
    List<AggrItem> itemOutList = List();
    loading = true;
    for (var item in aggrItem) {
      item.id != '90'
          ? await getStock(item.id).then((i) {
              if (i < item.qty && !item.held) {
                print('held one:${item.held}');
                itemOutList.add(item);
                itemOutList.last.qtyOut = i;
                print('BulkOutListBelow:');
                isBalanceChecked = false;
                print({itemOutList.last.id: itemOutList.last.qty});
              }
            })
          : null;
    }

    // for (var order in orders) {
    if (itemOutList.length > 0) {
      /* for (var item in itemOutList) {
          order.order
              .where((i) => i.itemId == item.id)
              .forEach((f) => f.qty = item.qty);
        }
        //  orderOutList.clear();
        order.gifts.clear();
        order.promos.clear();
        order.order.removeWhere((i) => i.qty <= 0 || i.bp <= 0);
        // bulkOrder.removeWhere((bulk) => bulk.order.length == 0);

        for (var sOrder in bulkOrder) {
          sOrder.total = reOrderSum(sOrder.order);
          sOrder.totalBp = reOrderBp(sOrder.order);
          sOrder.weight = reOrderWeight(sOrder.order);
        }*/
      isBalanceChecked = false;
    } else {
      isBalanceChecked = true;
      // msg = await saveOrder(shipmentId, courierfee, distrId, note, areaId);
    }
    //  }
    loading = false;
    return itemOutList;
  }

  Future<List<ItemOrder>> bulkOrderBalanceCheck(List<SalesOrder> orders) async {
    List<ItemOrder> orderOutList = List();
    loading = true;
    for (var order in orders) {
      for (ItemOrder item in order.order) {
        item.itemId != '90'
            ? await getStock(item.itemId).then((i) {
                if (i < item.qty) {
                  print('held also:${item.held}');
                  orderOutList.add(item);
                  orderOutList.last.qty = i;
                  print('BulkOutListBelow:');
                  isBalanceChecked = false;
                  print({orderOutList.last.itemId: orderOutList.last.qty});
                }
              })
            : null;
      }
    }

    for (var order in orders) {
      if (orderOutList.length > 0) {
        for (ItemOrder item in orderOutList) {
          order.order
              .where((i) => i.itemId == item.itemId)
              .forEach((f) => f.qty = item.qty);
        }
        //  orderOutList.clear();
        order.gifts.clear();
        order.promos.clear();
        order.order.removeWhere((i) => i.qty <= 0 || i.bp <= 0);
        //bulkOrder.removeWhere((bulk) => bulk.order.length == 0);
        isBalanceChecked = false;

        for (var sOrder in bulkOrder) {
          sOrder.total = reOrderSum(sOrder.order);
          sOrder.totalBp = reOrderBp(sOrder.order);
          sOrder.weight = reOrderWeight(sOrder.order);
        }
      } else {
        isBalanceChecked = true;
        // msg = await saveOrder(shipmentId, courierfee, distrId, note, areaId);
      }
    }
    loading = false;
    return orderOutList;
  }

  int getRandom() {
    Random random = Random();
    int _random = random.nextInt(9998);
    int projId;
    projId = _random.toString().length == 4 ? _random : getRandom();
    return projId;
  }

  List<SalesOrder> prepareBulkOrder(List<SalesOrder> bulkOrders,
      double courierFee, String note, String shipmentId, int ordersCount) {
    List<SalesOrder> finalBulkOrders = [];
    String bulkId = getRandom().toString();
    for (SalesOrder order in bulkOrders) {
      /*if (order.gifts.length > 0) {
        /* order.gifts.forEach((g) => g.pack.forEach((p) => {p.bp = 0: p.bv = 0.0}));
      order.gifts.forEach((g) => g.pack.forEach((p) => p.price = 0.0));*/

        order.gifts.forEach(
            (g) => g.pack.forEach((p) => addGiftToBlukOrder(p, g.qty, order)));
      }
      if (order.promos.length > 0) {
        /* order.promos
          .forEach((g) => g.promoPack.forEach((p) => {p.bp = 0: p.bv = 0.0}));
      order.promos.forEach((g) => g.promoPack.forEach((p) => p.price = 0.0));*/

        order.promos.forEach((p) =>
            p.promoPack.forEach((pp) => addGiftToBlukOrder(pp, p.qty, order)));
      }*/
      if (courierFee > 0) {
        double courierPerOrderFee =
            (order.weight / bulkOrderWeight()) * courierFee;

        final ItemOrder itemorder = ItemOrder(
          itemId: '90',
          price: courierPerOrderFee.roundToDouble(),
          bp: 0,
          bv: 0,
          qty: 1,
          name: 'Biaya Courier',
          weight: 0,
          img: "",
        );
        order.order.add(itemorder);
      }

      SalesOrder salesOrder = SalesOrder(
        distrId: order.distrId,
        userId: userInfo.distrId,
        total: order.total,
        totalBp: order.totalBp,
        courierFee: courierFee.toString(),
        note: bulkId +
            ' => ' +
            (bulkOrders.indexOf(order) + 1).toString() +
            '/' +
            ordersCount.toString() +
            ' => ' +
            order.address +
            ': ' +
            note, //?
        backOrder: order.backOrder,
        projId: bulkId,
        address: order.address,
        courierId: shipmentId, //?
        areaId: order.areaId,
        storeId: setStoreId,
        branchId: setStoreId,
        soType: docType,
        order: order.order,
      );
      finalBulkOrders.add(salesOrder);
    }

    return finalBulkOrders;
  }

  // int i = 0; //?  commented because not implementatio

  Future<List<ItemOrder>> putBulk(List<SalesOrder> orders) async {
    List<ItemOrder> listOfIO = await bulkOrderBalanceCheck(orders);

    if (listOfIO.length == 0) {
      BulkSalesOrder bulk = BulkSalesOrder(bulkSalesOrder: orders);
      print(bulk.postBulkOrderToJson(bulk));
      Response response = await bulk.createBulkPost(bulk);
      // List<String> idsList = [];
      if (response.statusCode == 201) {
        print('Order Msg:${response.body}!!');
        bulkOrder.clear();
        giftorderList.clear();
        promoOrderList.clear();
        isBulk = false;
        //var ids = json.decode(response.body);
        // idsList = ids.values;
        return listOfIO = [];
      } else {
        //OrderBulkMsg errorMsg = OrderBulkMsg(error: 'operation failed');
        // idsList.add(errorMsg.error);
        return listOfIO;
      }
    }
    return listOfIO;
  }

  Future<OrderBulkMsg> mockPutBulk(List<SalesOrder> orders) async {
    BulkSalesOrder bulk = BulkSalesOrder(bulkSalesOrder: orders);
    print(bulk.postBulkOrderToJson(bulk));
    Response response = await bulk.createBulkPost(bulk);
    if (response.statusCode == 201) {
      //print('Order Msg:${response.body}!!');

      bulkOrder.clear();
      giftorderList.clear();
      promoOrderList.clear();
      isBulk = false;

      OrderBulkMsg bulkMsg = OrderBulkMsg.fromJson(json.decode(response.body));
      bulkMsg.ids.forEach((id) => print(id.toString()));
      return bulkMsg;
    } else {
      OrderBulkMsg errorMsg = OrderBulkMsg(error: 'operation failed');
      return errorMsg;
    }
  }

  deleteEmptyOrders() {
    bulkOrder.removeWhere((o) => o.order.length == 0);
  }

  Future<OrderBulkMsg> mockSaveBulkOrders(
      //* mock balance check on putBulk function
      List<SalesOrder> bulkSalesOrder,
      double courierFee, // * mock function to test bulk order prepare
      String note,
      String shipmentId) async {
    OrderBulkMsg bulkOrderIds;

    bulkSalesOrder.removeWhere((o) => o.order.length == 0);

    bulkOrderIds = await mockPutBulk(prepareBulkOrder(
        bulkSalesOrder, courierFee, note, shipmentId, bulkOrder.length));

    return bulkOrderIds;
  }

  //Future<OrderMsg>
  Future<List<ItemOrder>> saveBulkOrders(List<SalesOrder> bulkSalesOrder,
      double courierFee, String note, String shipmentId) async {
    List<ItemOrder> listOfIO = [];
    listOfIO = await putBulk(prepareBulkOrder(
        bulkSalesOrder, courierFee, note, shipmentId, bulkOrder.length));
    return listOfIO;
  }

//!-----------------------orders starts here ----------------------

  List<ItemOrder> getHeld(List<ItemOrder> itemList) {
    List<ItemOrder> itemorderlistWithHeld = [];
    itemList.forEach((i) => itemorderlistWithHeld.add(i));
    for (var item in itemorderlistWithHeld) {
      if (item.held && item.qty > 0) {
        item.qty = item.qty * (-1);
        print("QTY${item.qty}" + '=>' + "${item.itemId}");
      }
    }
    return itemorderlistWithHeld;
  }

  String txtBackOrderList() {
    String body = '';
    backOrdersList.forEach((f) => body += f.backOrderToJson(f));
    return body;
  }

  String txtdistrBonusList() {
    String body = '';
    distrBonusList.forEach((f) => body += f.distrBonusToJson(f));
    return body;
  }

  Future<OrderMsg> saveOrder(String shipmentId, double courierfee,
      String distrId, String note, String areaId) async {
    itemorderlist.forEach((i) => print({i.itemId: i.qty}));
    giftorderList.forEach((p) => print(p.pack.map((g) => {g.itemId: p.qty})));
    print('OrderListLength:${itemorderlist.length}');
    //!! fix errors on bottom commentted block;

    //addCatToOrder(settings.catCode);
    //addAdminToOrder('91');
    //print("courier fee test=> :$courierfee");

    /* if (giftorderList.length > 0 || promoOrderList.length > 0) {
      giftorderList
          .forEach((g) => g.pack.forEach((p) => {p.bp = 0: p.bv = 0.0}));
      promoOrderList.forEach(
          (p) => p.promoPack.forEach((pp) => {pp.bp = 0: pp.bv = 0.0}));
      giftorderList.forEach((g) => g.pack.forEach((p) => p.price = 0.0));
      promoOrderList
          .forEach((p) => p.promoPack.forEach((pp) => pp.price = 0.0));

      giftorderList
          .forEach((g) => g.pack.forEach((p) => addToItemOrder(p, g.qty)));
      promoOrderList.forEach(
          (p) => p.promoPack.forEach((pp) => addToItemOrder(pp, p.qty)));
    }*/
    if (courierfee > 0) {
      addCourierToOrder('90', courierfee);
    }

    SalesOrder salesOrder = SalesOrder(
      distrId: distrId,
      userId: userInfo.distrId,
      total: orderSum(),
      totalBp: orderBp(),
      courierFee: courierfee.toString(),
      note: note,
      backOrder: txtBackOrderList(),
      bonusDeduc: txtdistrBonusList(),
      address: docType == 'CR' ? shipmentAddress : null,
      courierId: docType == 'CR' ? shipmentId : null,
      areaId: docType == 'CR' ? areaId : null,
      storeId: setStoreId,
      branchId: setStoreId,
      soType: docType,
      order: itemorderlist,
    );
    itemorderlist
        .forEach((i) => print('itemOrderList held : ${i.itemId}=>${i.held}'));

    print(salesOrder.postOrderToJson(salesOrder));

    Response response = await salesOrder.createPost(salesOrder);

    if (response.statusCode == 201) {
      print('Bulk Order Msg:${response.body}!!');
      itemorderlist.clear();
      giftorderList.clear();
      promoOrderList.clear();
      backOrdersList.clear();
      distrBonusList.clear();

      OrderMsg msg = OrderMsg.fromJson(json.decode(response.body));

      return msg;
    } else {
      OrderMsg errorMsg = OrderMsg(error: 'operation failed');
      return errorMsg;
    }
  }
//return salesOrder;
//itemorderlist.forEach((f)=>so.order.add(f))  ;
//itemorderlist.forEach((f)=>so.order.add(f));
//print('SalesOrderLength:${so.order.length}');
//salesOrder.order.forEach((o)=>print(postSalesOrderToJson(SSo)));
//!--------*Areas*---------////
//? Areaupdate to firebase..

  List<Area> areas;

  Future<List<Area>> getArea() async {
    final response = await http.get('$httpath/areas');

    if (response.statusCode == 200) {
      //Map<String,dynamic> jSON;
// List<Area> _areas = List();
      List<dynamic> responseList = json.decode(response.body);
      areas = responseList.map((l) => Area.fromJson(l)).toList();
      areas.forEach((f) => print({f.areaId: f.name}));
    }
    return areas;
/*
  void areaPushToFirebase(String areaId,Area area){
  DatabaseReference ref = FirebaseDatabase.instance.reference()
  .child('flamelink/environments/production/content/areas/en-US');
  ref.child(areaId).set(area.toJson());
}
for(var area in areas){
  areaPushToFirebase(area.areaId, area);
  print('setting...${area.areaId}..${area.name}');
}*/
  }

//!--------*Courier*----------//

  // List<Courier> couriers;
/*
  void getShipmentCompanies() async {
    final response = await http.get('$httpath/shipmentcompanies');
    void shipmentPushToFirebase(String courierId, Courier courier) {
      databaseReference = database
          .reference()
          .child('flamelink/environments/$firebaseDb/content/courier/en-US');
      databaseReference.child(courierId).update(courier.toJson());
    }
    if (response.statusCode == 200) {
      List<dynamic> responseList = json.decode(response.body);
      couriers = responseList.map((l) => Courier.fromJson(l)).toList();
    }
    for (var c in couriers) {
      shipmentPushToFirebase(c.courierId, c);
    }
//return couriers;
  }*/
  Future<List<AreaPlace>> getAreaPlace() async {
    List<AreaPlace> shipmentAreas = [];

    final response = await http.get('$httpath/get_all_shipment_places/');
    if (response.statusCode == 200) {
      final _shipmentArea = json.decode(response.body) as List;
      shipmentAreas = _shipmentArea.map((s) => AreaPlace.json(s)).toList();
      shipmentAreas.forEach((a) => print(a.spName));
    } else {
      shipmentAreas = [];
    }

    return shipmentAreas;
  }

  Future<List<ShipmentArea>> getShipmentAreas(String distrId, int point) async {
    List<ShipmentArea> shipmentAreas = [];
    List<ShipmentArea> validShipmentAreas = [];
    final response =
        await http.get('$httpath/get_shipment_places_by_distr_id/$distrId');
    if (response.statusCode == 200) {
      final _shipmentArea = json.decode(response.body) as List;
      shipmentAreas =
          _shipmentArea.map((s) => ShipmentArea.fromJson(s)).toList();
      shipmentAreas.forEach((a) => print(a.shipmentName));

      for (ShipmentArea s in shipmentAreas) {
        await couriersList(s.shipmentArea, point)
            .then((c) => c.length > 0 ? validShipmentAreas.add(s) : null);
        //c.length > 0 ? validShipmentAreas.add(s) : null
      }

      //  products = productlist.map((i) => Item.fromJson(i)).toList();
    } else {
      shipmentAreas = [];
      print('no shipment Areas for $distrId');
    }
    print('validShipmentAreas Count=>:${validShipmentAreas.length}');
    return validShipmentAreas;
  }

  List companies = [];
  Future<List> couriersList(String areaid, int distrPoint) async {
    DataSnapshot snapshot = await database
        .reference()
        .child('$path/courier/en-US') //!enviroments/$firebaseDb
        .once();

    var courierList = snapshot
        .value; //! changed list to var in this line for firebase key genrated

    List ships = [];
    for (var c in courierList.values) {
      //! add .values to courierlist to loop through values while firebase key is generated
      if (c != null) {
        if (c['region'] == distrPoint && c['disabled'] != true) {
          for (var s in c['service']) {
            for (var a in s['areas']) {
              if (a.toString() == areaid) {
                print('a.string:=>${a.toString()}:areaid=$areaid');
                print(c['courierId']);
                ships.add(c);
              }
            }
          }
        }
      }
    }
    courierList = [];
    List companies = ships.map((f) => Courier.fromList(f)).toList();
    // companies.forEach((c) => print(c));
//companies.forEach((f)=>print('${f.name} : ${f.courierId}'));
    ships.clear();

    return companies;
  }

  /*
  Future<List> courierList(String areaid) async {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child(
            'flamelink/environments/production/content/courier/en-US/') //!enviroments/$firebaseDb
        .once();
    Map<dynamic, dynamic> courier = snapshot.value;
    List courierList = courier.values.toList();

    List ships = [];
    for (var c in courierList) {
      for (var s in c['service']) {
        for (var a in s['areas']) {
          if (a.toString() == areaid) {
            // print(c['courierId']);
            ships.add(c);
          }
        }
      }
    }
    List companies = ships.map((f) => Courier.fromList(f)).toList();
    companies.forEach((c) => print(c));
//companies.forEach((f)=>print('${f.name} : ${f.courierId}'));

    return companies;
  }*/
  Future<double> getCourierDiscount(int totalBp, double courierFeez) async {
    double courierDiscount = 0.0;
    DataSnapshot snapshot =
        await database.reference().child('$path/courierDiscount/en-US/').once();
    if (snapshot.value != null) {
      Map<dynamic, dynamic> _courierDiscount = snapshot.value;
      List list = _courierDiscount.values.toList();
      bool _hasData = list
          .map((f) => CourierDiscount.json(f))
          .where((r) =>
              r.enabled == true && totalBp >= r.onBp && totalBp <= r.toBp)
          .isNotEmpty;

      if (_hasData) {
        courierDiscount = list
                .map((f) => CourierDiscount.json(f))
                .where((r) =>
                    r.enabled == true && totalBp >= r.onBp && totalBp <= r.toBp)
                .first
                .discount /
            100 *
            courierFeez;

        print('discount:${courierDiscount.abs()}');
      } else {
        print(courierFeez);
      }
    }

    return courierDiscount.abs();
  }

//!--------*

  List<Store> stores;
  Future<List<Store>> getStores() async {
    DataSnapshot snapshot =
        await database.reference().child('$path/stores/en-US/').once();

    Map<dynamic, dynamic> _stores = snapshot.value;
    List list = _stores.values.toList();
    stores =
        list.map((f) => Store.json(f)).where((s) => s.enabled == true).toList();

    return stores;
  }

  List<Region> distrPoints;
  Future<List<Region>> getPoints(int _regionId) async {
    distrPoints = [];

    DataSnapshot snapshot =
        await database.reference().child('$path/region/en-US/').once();
    print(snapshot.value);
    Map<dynamic, dynamic> _areas = snapshot.value;
    List list = _areas.values.toList();
    distrPoints = list
        .map((f) => Region.json(f))
        .where((r) =>
            r.distrPoint == true &&
            r.id ==
                _regionId) //? very important update //&& r.regionId == _regionId)
        .toList();
    print('distrPoints Count:${distrPoints.length}');
    return distrPoints;
  }

  Future<bool> courierService(String courierId, String areaId) async {
    DataSnapshot snapshot = await database
        .reference()
        .child(
            '$path/courier/en-US/$courierId/service') //!enviroments/production
        .once();
    List list = snapshot.value;
// print(list.length);
    List<Service> services = list.map((f) => Service.fromJson(f)).toList();
//print(services.map((f)=>f.areas.forEach((a)=>a == areaId))) ;
    bool x;
    for (var s in services) {
      for (var a in s.areas) {
        if (areaId == a.toString()) {
          x = true;
        } else {
          x = false;
        }
      }
    }
    return x;
  }

  Future<double> courierServiceFee(
      String courierId, String areaId, double orderWeight) async {
    DataSnapshot snapshot = await database
        .reference()
        .child(
            '$path/courier/en-US/$courierId/service') //!enviroments/production
        .once();
    List list = snapshot.value;
// print(list.length);
    List<Service> services = list.map((f) => Service.fromJson(f)).toList();
    // print(services.map((f) => f.areas.forEach((a) => a == areaId)));
    double x;
    for (var s in services) {
      for (var a in s.areas) {
        if (areaId == a.toString()) {
          x = (orderWeight.ceil().toDouble() * s.rate.toDouble()) + s.minWeight;
        }
      }
    }
    services.clear();
    return x;
  }

  //print(services.map((f)=> f.areas.map((a)=>a.toString() == areaId)));
//Service service = Service.fromJson(list.first);
//print(service.fees);
  //list.forEach((f)=>Service.fromJson(f));
//List<Service> service = Service.fromSnapshot(snapshot);
//print(service.fees);
  /*_list.length;
for( var i = 0 ; i < _list.length; i++){
}*/

//!--------*Users/Members*-----------//
  void userPushToFirebase(String id, User user) {
    String memberId = int.parse(id).toString();
    databaseReference = database.reference().child('$path/users/en-US');
    databaseReference.child(memberId).set(user.toJson());
  }

  User memberData;
  //!--------*
  Future<User> memberJson(String distrid) async {
    http.Response response = await http.get('$httpath/memberid/$distrid');

    if (response.body.length > 2) {
      List responseData = await json.decode(response.body);
      memberData = User.formJson(responseData[0]);
    } else {
      return memberData = null;
    }

    return memberData;
    /*
    (
      distrId: responseData[0]['DISTR_ID'],
      name: responseData[0]['ANAME'],
      distrIdent: responseData[0]['DISTR_IDENT'],
      email: responseData[0]['E_MAIL'],
      phone: responseData[0]['TELEPHONE'],
    );
    */
  }

  User nodeJsonData;
  Future<User> nodeJson(String nodeid) async {
    http.Response response = await http.get('$httpath/memberid/$nodeid');

    if (response.statusCode == 200) {
      List responseData = await json.decode(response.body);
      nodeJsonData = User.formJson(responseData[0]);
    } else {
      return nodeJsonData =
          new User(distrId: '00000000', name: 'NA', areaId: '');
    }

    return nodeJsonData;
  }

//!--------*
  Future<String> regUser(String email, String password) async {
    FirebaseUser user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }
//bool isLoggedIn;
  /// bool isValid;

//!------------*

  User user;
  Future<User> userData(String key) async {
    print('userData key:$key');
    final DataSnapshot snapshot =
        await database.reference().child('$path/users/en-US').child(key).once();
    user = User.fromSnapshot(snapshot);
    return user;
  }

//!--------*
  FirebaseUser _user;
  Future<bool> logIn(String key, String password, BuildContext context) async {
    print('key:$key');
    User _userInfo =
        await userData(key).catchError((e) => print('Erro:${e.toString()}'));
    if (_userInfo != null) {
      if (_userInfo.isAllowed) {
        // print('user is allowed ${_userInfo.isAllowed.toString()}');
        versionControl(context);
        locKCart(context); //! uncomment this before buildR
        locKApp(context); //! uncomment this before buildR
        userAccess(key, context);
        //userTest(key, context);
        //getAreagetAreauserTest(key, context);
        //getArea();
        try {
          _user = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _userInfo.email, password: password);
        } catch (e) {
          print('singin error caught:${e.toString()}');
          return false;
        }
        updateToke(key);
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  updateToke(String _key) {
    databaseReference = database.reference().child('$path/users/en-US/$_key');
    if (token != null) {
      databaseReference.update({"token": token});
    }
  }

  //!--------*
  bool access = true;
  bool tester = false;
  void userTest(key, BuildContext context) {
    databaseReference = database.reference().child('$path/users/en-US/$key/');
    databaseReference.onValue.listen((event) async {
      tester = await setIsTester(User.fromSnapshot(event.snapshot).tester);
      print('isTesterxx:$tester');
      if (!tester) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        signOut();
        Navigator.pushReplacementNamed(context, '/');
      }
    });

    // return _access;
  }

  void userAccess(key, BuildContext context) {
    databaseReference = database.reference().child('$path/users/en-US/$key/');
    databaseReference.onValue.listen((event) async {
      access = await setIsAllowed(User.fromSnapshot(event.snapshot).isAllowed);
      print('isAllowedxx:$access');
      if (!access) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        signOut();
        // Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        // exit(0);
        Navigator.pushReplacementNamed(context, '/');
        //  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        //   Navigator.pop(
        //   context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });

    // return _access;
  }

  bool cartLocked = false;
  void locKCart(BuildContext context) {
    databaseReference =
        database.reference().child('$path/lockScreen/en-US/lockCart');
    databaseReference.onValue.listen((event) async {
      cartLocked = await event.snapshot.value;
      //print('CARTLOCKED-XXXXX:$cartLocked');
      if (cartLocked) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        //signOut();
        //Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

        /* Navigator.pop(context,
                          MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen()));*/
      }
    });

    // return _access;
  }

  bool appLocked = false;
  void locKApp(BuildContext context) {
    databaseReference =
        database.reference().child('$path/lockScreen/en-US/lockApp');
    databaseReference.onValue.listen((event) async {
      appLocked = await event.snapshot.value;
      print('APPLOCKED-XXXXX:$appLocked');
      if (appLocked) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        signOut();
        //  SystemNavigator.pop();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        //Navigator.pushReplacementNamed(context, '/');
        // Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

        //  Navigator.pop(
        //   context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });

    // return _access;
  }

  void versionControl(BuildContext context) {
    databaseReference =
        database.reference().child('$path/lockScreen/en-US/version');
    databaseReference.onValue.listen((event) async {
      String version = await event.snapshot.value;
      //print('APPLOCKED-XXXXX:$appLocked');
      if (version != _version) {
        itemorderlist.clear();
        giftorderList.clear();
        promoOrderList.clear();
        print('$version CheckYour Version $_version :)');
        signOut();
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        flush(context, '     نرجو تحديث التطبيق', subMsg: '').show(context);
      }

      /* Navigator.pop(context,
                          MaterialPageRoute(
                          builder: (context) =>
                              LoginScreen()));*/
    });

    // return _access;
  }

  Future<bool> distrVerification(String distrId) async {
    http.Response response = await http.get('$httpath/memberid/$distrId');
    User _verDistr;
    String sBool;

    if (response.statusCode == 200 && response.contentLength > 0) {
      List _distr = await json.decode(response.body);

      _verDistr = User.formJson(_distr[0]);
      if (_verDistr.distrId.substring(1, 2) == '3' && _verDistr != null) {
        http.Response responseBool = await http.get(
            '$httpath/member_fees_verification/$distrId/${_verDistr.serviceCenter}');
        if (response.statusCode == 200) {
          List _distrVeri = json.decode(responseBool.body);
          sBool = _distrVeri[0];
          print('sbool:$sBool');
        }
      }
    }

    return sBool == '1' ? false : true;
  }

  //!--------*

  Future<bool> leaderVerification(String distrId) async {
    String v;
    http.Response response = await http
        .get('$httpath/leaderverification/${userInfo.distrId}/$distrId');

    if (response.statusCode == 200) {
      List vList = await json.decode(response.body);
      print('verList:${vList.length}');

      if (vList.length == 1) {
        v = vList[0].toString().toLowerCase();
      } else {
        v = 'false';
      }
    }
    bool b;
    v == 'true' ? b = true : b = false;
    print('verification:$b');
    return b;
  }

  //!--------*
  User userInfo;
  void userDetails() {
    database.reference().child('$path/users/en-US/${user.key}/');
    databaseReference.onValue.listen((event) async {
      userInfo = User.fromSnapshot(event.snapshot);
    });
  }

  //!--------*
  Future<bool> setIsAllowed(bool allowed) async {
    final User userAccess = User(isAllowed: allowed);
    return userAccess.isAllowed;
  }

  Future<bool> setIsTester(bool _tester) async {
    final User testUser = User(tester: _tester);
    return testUser.tester;
  }

  //!--------*
  Future<bool> formEntry(bool validate, Future<bool> signin) async {
    bool isLoggedIn = await signin;
    bool isValid = validate;

    if (isValid) {
      if (isLoggedIn && loggedUser() != null) {
        print('isLoggedIn:$isLoggedIn');
        print('isValidIn:$isValid');

        return true;
      } else {
        return false;
      }
    } else {
      print('isLoggedIn:$isLoggedIn');
      print('isValidIn:$isValid');
      return false;
    }
  }

//!--------*
  Future<bool> emailSignIn(String email, String password) async {
    try {
      _user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print(' Future signIn display ${_user.uid}');
    } catch (e) {
      print('singin error caught:${e.toString()}');
      return false;
    }
    return true;
  }

//!--------*
  Future<void> signOut() async {
    print('signing outttttttttt');

    return FirebaseAuth.instance.signOut();
  }

  Future<String> loggedUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.email;
  }
}

/* //! 
void main() async {
  List _data = await getJson();

  for (int i = 0; i < _data.length; i++) {}

  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('JSON PARSE'),
        centerTitle: true,
        backgroundColor: Colors.pink[900],
      ),
      body: ListView.builder(
        itemCount: _data.length,
        padding: EdgeInsets.all(15.0),
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(_data[index]['ITEM_ID']),
                  Text(_data[index]['ANAME']),
                ],
              )
            ],
          );
        },
      ),
    ),
  ));
}

Future<List> getJson() async {
  String apiUrl = 'http://mywayapi.azurewebsites.net/api/allitemdetails';

  http.Response response = await http.get(apiUrl);

  return json.decode(response.body);
}

*/
