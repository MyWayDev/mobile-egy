import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/item.dart';

import 'package:mor_release/models/sales.order.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/custom_bar.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

class TrackOrder extends StatefulWidget {
  final String userId;

  TrackOrder(this.userId);
  @override
  State<StatefulWidget> createState() {
    return _TrackOrder();
  }
}

@override
class _TrackOrder extends State<TrackOrder> {
  List<Sorder> firstSorder = [];
  final formatter = new NumberFormat("#,###");
  double addPpnTax(int index) {
    double cf = double.tryParse(firstSorder[index].coureirFee) ?? 0.0;
    return double.tryParse(firstSorder[index].soTotal) + cf;
  }

  void isLoading(bool o, MainModel model) {
    setState(() {
      model.loadingSoPage = o;
    });
  }

  void _deleteSo(String docId, String distrId, MainModel model, String storeId,
      String soType) async {
    model.distrIdDel = distrId;
    model.docIdDel = docId;
    isLoading(true, model);
    final http.Response responseI = await http.post(
        'http://mywayegypt-api.azurewebsites.net/api/updatedelap/$docId/$distrId/$storeId/$soType');

    if (responseI.statusCode == 200) {
      final http.Response responseII = await http.post(
          'http://mywayegypt-api.azurewebsites.net/api/editvou/$docId/$distrId/$storeId/$soType');
      if (responseII.statusCode == 200) {
        model.checkSoDupl(_getSorders, widget.userId);
      } else {
        isLoading(false, model);
        print('ERROR DELETE SO!');
      }
    } else {
      isLoading(false, model);
      print('ERROR UPDATE SO!');
    }
    isLoading(false, model);
    _getSorders(widget.userId);
  }

  void _getSorders(String userId) async {
    firstSorder = [];

    final http.Response response = await http
        .get('http://mywayegypt-api.azurewebsites.net/api/userpending/$userId');
    if (response.statusCode == 200 && firstSorder.length == 0) {
      print('getSorder ok');
      List<dynamic> soList = json.decode(response.body);
      List<Sorder> sos = [];
      sos = soList.map((i) => Sorder.fromJson(i)).toList();
      List<SoItem> items = [];
      items = soList.map((i) => SoItem.fromJson(i)).toList();
//List<Invoice> firstInvoice = [];
//items.forEach((f)=>print('${f.itemId}..${f.docId}'));
      sos.forEach((f) {
        if (f.counter == '0001' && f.soType == 'CR') {
          firstSorder.add(f);
        } else if (f.counter == '0001' && f.soType == 'CA') {
          firstSorder.add(f);
        }
      });

      for (var i = 0; i < firstSorder.length; i++) {
        if (firstSorder[i].soItems == null) {
          firstSorder[i].soItems = [];
        }
      }
      for (SoItem item in items) {
        for (var i = 0; i < firstSorder.length; i++) {
          if (firstSorder[i].docId == item.docId &&
              firstSorder[i].soType == item.soType) {
            firstSorder[i].soItems.add(item);
          } else {
            if (firstSorder[i].docId == item.docId &&
                firstSorder[i].soType == item.soType) {
              firstSorder[i].soItems.add(item);
            }
          }
        }
      }
    }
    firstSorder
        .sort((b, a) => a.addDate.toLocal().compareTo(b.addDate.toLocal()));
  }

  @override
  void initState() {
    _getSorders(widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _inlineColor(SoItem item) {
    Color _color = Colors.white;

    if (item.price == 0 && item.itemBp == 0) {
      _color = Colors.pink[50];
    } else if (item.price > 0 && item.itemBp > 0) {
      _color = Colors.grey[100];
    }

    return _color;
  }

  Future<int> getTimeDiff(MainModel model, int index) async {
    isLoading(true, model);
    DateTime orderTime = firstSorder[index].addDate;
    DateTime timeNow = await model.serverTimeNow();

    print('$orderTime=>$timeNow');
    Duration diff = timeNow.difference(orderTime);
    int timelapsed = diff.inMinutes;
    isLoading(false, model);
    return timelapsed;
  }

  void reBuildOrderFromLegacy(List<SoItem> items, MainModel model) {
    isLoading(true, model);
    model.giftorderList.clear();
    model.promoOrderList.clear();
    model.itemorderlist.clear();

    for (var i = 0; i < model.itemData.length; i++) {
      for (var d = 0; d < items.length; d++) {
        if (model.itemData[i].itemId == items[d].itemId && items[d].price > 0) {
          Item item = Item(
            itemId: items[d].itemId,
            price: model.itemData[i].price,
            bp: int.parse(model.itemData[i].bp.toString()),
            bv: model.itemData[i].bv,
            name: model.itemData[i].name,
            imageUrl: model.itemData[i].imageUrl,
          );
          model.addItemOrder(item, items[d].qty.toInt());
          //vitems.add(item);
        }
      }
    }
    print(model.itemorderlist.length);
    isLoading(false, model);
  }

  void _bottomSheetAlert(MainModel model, int wait) {
    showModalBottomSheet(
        context: context,
        builder: (buider) {
          return new Container(
            height: 80.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: new Center(
                  child: new Text(
                      " harap menunggu ${(5 - wait)} menit untuk melanjutkan "),
                )),
          );
        });
  }

  Widget _buildItem(SoItem item) {
    return item.price > 0 && item.totalBp == 0
        ? Container()
        : Card(
            color: _inlineColor(item),
            child: ListTile(
              leading: Text(
                item.itemId,
              ),
              title: Text(
                item.itemName,
              ),
              trailing: Text(item.qty.round().toString()),
            ),
          );
  }

  void _deleteSoDialog(List<SoItem> sOrder, String docId, String distrId,
      MainModel model, String title, bool edit, String storeId, String soType) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Container(
          height: 80,
          child: AlertDialog(
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content: Text(
              "$docId",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                onPressed: () {
                  if (!edit) {
                    _deleteSo(docId, distrId, model, storeId, soType);

                    Navigator.of(context).pop();
                  } else {
                    reBuildOrderFromLegacy(sOrder, model);
                    _deleteSo(docId, distrId, model, storeId, soType);
                    Navigator.of(context).pop();
                  }
                },
              ),
              // usually buttons at the bottom of the dialog
              new IconButton(
                icon: Icon(
                  Icons.cancel,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSorder(List<Sorder> sos, int index, MainModel model) {
    return ExpansionTile(
        backgroundColor:
            Colors.pink[300], // _statusColorDetails(sos[index].status),
        key: PageStorageKey<Sorder>(sos[index]),
        title: ListTile(
          leading: IconButton(
              disabledColor: Colors.transparent,
              icon: Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 32,
              ),
              onPressed: () async {
                int wait = await getTimeDiff(model, index);
                if (wait > 5) {
                  _deleteSoDialog(
                      firstSorder[index].soItems,
                      sos[index].docId,
                      sos[index].distrId,
                      model,
                      "Barang yang sudah dipesan akan dibatalkan dan order akan dihapus",
                      false,
                      sos[index].storeId,
                      sos[index].soType);
                } else {
                  _bottomSheetAlert(model, wait);
                }
              }),
          title: Container(
            child: Column(
              children: <Widget>[
                // Text(sos[index].docId, style: TextStyle(fontSize: 14)),
                Text(
                  sos[index].distrName,
                  style: TextStyle(fontSize: 14),
                ),
                Divider(
                  height: 3.0,
                  indent: 0,
                  color: Colors.white,
                )
              ],
            ),
          ),
          /* trailing: !model.cartLocked
                ? IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () async {
                      int wait = await getTimeDiff(model, index);

                      if (wait > 5) {
                        _deleteSoDialog(
                            firstSorder[index].soItems,
                            sos[index].docId,
                            sos[index].distrId,
                            model,
                            "Semua barang yang sudah dipesan akan dibatalkan dan dikembalikan ke keranjang belanja",
                            true);
                      } else {
                        _bottomSheetAlert(model, wait);
                      }
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.block,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  )*/
        ),
        children: sos[index].soItems.map(_buildItem).toList()
        //root.invoiceItems.map(_buildTiles).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            elevation: 21.5,
            backgroundColor: Colors.transparent,
            //foregroundColor: Colors.transparent,
            onPressed: () {
              _getSorders(widget.userId);
            },
            child: Icon(
              Icons.refresh,
              size: 32,
              color: Colors.black38,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          body: ModalProgressHUD(
            inAsyncCall: model.loadingSoPage,
            opacity: 0.6,
            progressIndicator: LinearProgressIndicator(),
            child: Column(
              children: <Widget>[
                CustomAppBar("Pelacakan order tertunda"),
                Container(),
                Expanded(
                  child: ListView.builder(
                      itemCount: firstSorder.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 8,
                          color: firstSorder[index].soType == 'CA' &&
                                  firstSorder[index].soItems.first.itemId !=
                                      '99m'
                              ? Colors.pink[900]
                              : firstSorder[index].soType == 'CR' &&
                                      firstSorder[index].soItems.first.itemId !=
                                          '99m'
                                  ? Colors.pink[700]
                                  : firstSorder[index].soType == 'CA' &&
                                          firstSorder[index]
                                                  .soItems
                                                  .first
                                                  .itemId ==
                                              '99m'
                                      ? Colors.redAccent[400]
                                      : Colors.redAccent,
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(2),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                //mainAxisSize: MainAxisSize.min,
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Icon(
                                        Icons.vpn_key,
                                        color: Colors.grey[400],
                                        size: 19,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                      ),
                                      Text(
                                        firstSorder[index].distrId,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            // fontSize: 14,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey[400],
                                        size: 19,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                      ),
                                      Text(
                                        firstSorder[index].docDate,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            //fontSize: 14,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              /* Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[],
                              ),*/
                              ExpansionTile(
                                  backgroundColor: Colors.pink[400],
                                  key: PageStorageKey<Sorder>(
                                      firstSorder[index]),
                                  title: ListTile(
                                    leading: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Text(firstSorder[index].docId,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.yellow[100])),
                                          firstSorder[index]
                                                          .soItems
                                                          .first
                                                          .itemId ==
                                                      '99m' &&
                                                  firstSorder[index].soType ==
                                                      'CA'
                                              ? Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Icon(
                                                      GroovinMaterialIcons
                                                          .account_plus,
                                                    ),
                                                    SizedBox(width: 5),
                                                    Icon(
                                                      GroovinMaterialIcons
                                                          .cash_multiple,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                )
                                              : firstSorder[index].soType ==
                                                          'CA' &&
                                                      firstSorder[index]
                                                              .soItems
                                                              .first
                                                              .itemId !=
                                                          '99m'
                                                  ? Icon(
                                                      GroovinMaterialIcons
                                                          .cash_multiple,
                                                      color: Colors.white,
                                                    )
                                                  : firstSorder[index].soType ==
                                                              'CR' &&
                                                          firstSorder[index]
                                                                  .soItems
                                                                  .first
                                                                  .itemId !=
                                                              '99m'
                                                      ? Icon(
                                                          Icons.local_shipping,
                                                        )
                                                      : firstSorder[index]
                                                                      .soItems
                                                                      .first
                                                                      .itemId ==
                                                                  '99m' &&
                                                              firstSorder[index]
                                                                      .soType ==
                                                                  'CR'
                                                          ? Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Icon(
                                                                  GroovinMaterialIcons
                                                                      .account_plus,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                SizedBox(
                                                                    width: 5),
                                                                Icon(
                                                                  Icons
                                                                      .local_shipping,
                                                                ),
                                                              ],
                                                            )
                                                          : Container()
                                        ],
                                      ),
                                    ),
                                    trailing: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            'EGP ${(formatter.format(double.tryParse(firstSorder[index].soTotal)))}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red[100],
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            'Bp ${firstSorder[index].soBp}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[100],
                                              fontSize: 15,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  children: [
                                    _buildSorder(firstSorder, index, model)
                                  ]
                                  /* firstInvoice[index]
                        .invoiceItems
                        .map(_buildItem)
                        .toList()*/
                                  //root.invoiceItems.map(_buildTiles).toList(),
                                  ),
                            ],
                          ),
                        );
                        // EntryItem(invoices[index]);
                      }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
