import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/invoice.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/custom_bar.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

class TrackInvoice extends StatefulWidget {
  final String userId;
  TrackInvoice(this.userId);
  @override
  State<StatefulWidget> createState() {
    return _TrackInvoice();
  }
}

@override
class _TrackInvoice extends State<TrackInvoice> {
  List<Invoice> firstInvoice;
  final formatter = new NumberFormat("#,###");
  double addPpnTax(int index) {
    print(firstInvoice[index].shipFee);
    return firstInvoice[index].invocieTotal +
        double.tryParse(firstInvoice[index].shipFee);
  }

  void _getInvoices(String userId) async {
    firstInvoice = [];
    final http.Response response = await http.get(
        'http://mywayegypt-api.azurewebsites.net/api/userinvoices/$userId'); // sample distrid =>$userId
    if (response.statusCode == 200 && firstInvoice.length == 0) {
      print('getInvoice ok');
      List<dynamic> invoiceList = json.decode(response.body);
      List<Invoice> invoices =
          invoiceList.map((i) => Invoice.fromJson(i)).toList();
      List<InvoiceItem> items =
          invoiceList.map((i) => InvoiceItem.fromJson(i)).toList();
//List<Invoice> firstInvoice = [];
//items.forEach((f)=>print('${f.itemId}..${f.docId}'));
      invoices.forEach((f) {
        if (f.counter == '0001' && f.flagType == 'CR') {
          firstInvoice.add(f);
        } else if (f.counter == '0001' && f.flagType == 'CA') {
          firstInvoice.add(f);
        }
      });

      for (var i = 0; i < firstInvoice.length; i++) {
        if (firstInvoice[i].invoiceItems == null) {
          firstInvoice[i].invoiceItems = [];
        }
      }
      for (InvoiceItem item in items) {
        for (var i = 0; i < firstInvoice.length; i++) {
          if (firstInvoice[i].docId == item.docId &&
              item.flagType == firstInvoice[i].flagType &&
              item.itemId != '90') {
            firstInvoice[i].invoiceItems.add(item);
          } else if (item.itemId == '90') {
            var _shipFee = double.tryParse(firstInvoice[i].shipFee) ?? 0.0;
            _shipFee = item.price;
            print(
                'Invoice shipFee: =>${firstInvoice[i].shipFee}:${item.itemId}');
          }
          /*else  {
            if (firstInvoice[i].docId == item.docId) {
              firstInvoice[i].invoiceItems.add(item);
            }
          }*/
        }
      }
//firstInvoice.forEach((f)=>f.invoiceItems.forEach((f)=>print('${f.itemId}=>${f.price} * ${f.qty} = ${f.total}/${f.itemBp}==${f.totalBp}')));
//firstInvoice.forEach((f)=>print({f.docId:f.invoiceItems.length}));
//firstInvoice.forEach((f)=>print({f.docId:f.invocieTotal}));
    }
    firstInvoice
        .sort((b, a) => a.addDate.toLocal().compareTo(b.addDate.toLocal()));
    //return firstInvoice;
  }

  @override
  void initState() {
    _getInvoices(widget.userId);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _statusColor(String status, String flagType) {
    Color _color = flagType == 'CA' ? Colors.limeAccent[700] : Colors.white;

    if (status == '0' || status == '1') {
      _color = Colors.yellow[400];
    } else if (status == '2') {
      _color = Colors.orange[400];
    } else if (status == '3' || status == '4') {
      _color = Colors.green[400];
    }

    return _color;
  }

  Color _statusColorHead(String status, String flagType) {
    Color _color = flagType == 'CA' ? Colors.limeAccent[400] : Colors.white;

    if (status == '0' || status == '1') {
      _color = Colors.lime[300];
    } else if (status == '2') {
      _color = Colors.orange[300];
    } else if (status == '3' || status == '4') {
      _color = Colors.lightGreen[300];
    }

    return _color;
  }

  Color _statusColorDetails(String status, String flagType) {
    Color _color = flagType == 'CA' ? Colors.limeAccent[400] : Colors.white;

    if (status == '0' || status == '1') {
      _color = Colors.lime[200];
    } else if (status == '2') {
      _color = Colors.orange[200];
    } else if (status == '3' || status == '4') {
      _color = Colors.lightGreen[200];
    }

    return _color;
  }

  Color _inlineColor(InvoiceItem item) {
    Color _color = Colors.white;

    if (item.price == 0 && item.itemBp == 0) {
      _color = Colors.pink[50];
    } else if (item.price > 0 && item.itemBp > 0) {
      _color = Colors.grey[100];
    }

    return _color;
  }

  Widget _buildItem(InvoiceItem item) {
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

  void _hideInvoiceDialog(String docId, String distrId, MainModel model,
      String storeId, String flagType) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Container(
          height: 80,
          child: AlertDialog(
            title: Text(
              "Nomor tagiha akan disembunyikan",
              textAlign: TextAlign.center,
            ),
            content: Text(
              "$docId",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              new IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                onPressed: () {
                  hideInvoice(docId, distrId, model, storeId, flagType);
                  Navigator.of(context).pop();
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

  Widget _buildOrder(List<Invoice> invoices, int index) {
    return ExpansionTile(
        backgroundColor: _statusColorDetails(
            invoices[index].status, invoices[index].flagType),
        key: PageStorageKey<Invoice>(invoices[index]),
        title: ListTile(
          title: Container(
              child: SizedBox(
            width: 200,
            child: Column(
              children: <Widget>[
                Text(invoices[index].docId, style: TextStyle(fontSize: 14)),
                Text(invoices[index].distrName, style: TextStyle(fontSize: 14)),
                Divider(
                  height: 3.0,
                  indent: 0,
                  color: Colors.blueGrey,
                )
              ],
            ),
          )),
        ),
        children: invoices[index].invoiceItems.map(_buildItem).toList()
        //root.invoiceItems.map(_buildTiles).toList(),
        );
  }

  void hideInvoice(String docId, String distrId, model, String storeId,
      String flagType) async {
    isLoading(true, model);
    firstInvoice.clear();

    final http.Response responseII = await http.post(
        'http://mywayegypt-api.azurewebsites.net/api/updatedoneinv/$docId/$distrId/$storeId/$flagType');
    if (responseII.statusCode == 200) {
      _getInvoices(widget.userId);
      isLoading(false, model);
    } else {
      isLoading(false, model);
      print('ERROR DELETE SO!');
    }
  }

  void isLoading(bool o, MainModel model) {
    setState(() {
      model.loadingSoPage = o;
    });
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
            onPressed: () {
              _getInvoices(widget.userId);
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
                CustomAppBar("الفواتير"),
                Container(),
                Expanded(
                  child: ListView.builder(
                      itemCount: firstInvoice.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                          onDismissed: (DismissDirection direction) {
                            if (direction == DismissDirection.endToStart) {
                              _hideInvoiceDialog(
                                  firstInvoice[index].docId,
                                  firstInvoice[index].distrId,
                                  model,
                                  firstInvoice[index].storeId,
                                  firstInvoice[index].flagType);
                              _getInvoices(widget.userId);
                            } else if (direction ==
                                DismissDirection.startToEnd) {
                              _hideInvoiceDialog(
                                  firstInvoice[index].docId,
                                  firstInvoice[index].distrId,
                                  model,
                                  firstInvoice[index].storeId,
                                  firstInvoice[index].flagType);
                              _getInvoices(widget.userId);
                            }
                          },
                          key: Key(firstInvoice[index].docId),
                          child: Card(
                              elevation: 8,
                              color: _statusColor(firstInvoice[index].status,
                                  firstInvoice[index].flagType),
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
                                            size: 19,
                                            color: Colors.blueGrey,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                          ),
                                          Text(
                                            firstInvoice[index].distrId,
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                // fontSize: 14,
                                                color: Colors.black),
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
                                            size: 19,
                                            color: Colors.blueGrey,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                          ),
                                          Text(
                                            firstInvoice[index].docDate,
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                //fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ExpansionTile(
                                      backgroundColor: _statusColorHead(
                                          firstInvoice[index].status,
                                          firstInvoice[index].flagType),
                                      key: PageStorageKey<Invoice>(
                                          firstInvoice[index]),
                                      title: ListTile(
                                        leading: Container(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 8),
                                                  child: Text(
                                                      firstInvoice[index]
                                                                  .flagType !=
                                                              'CA'
                                                          ? ''// 'Track # ${firstInvoice[index].refNo}'
                                                          : firstInvoice[index]
                                                              .flagType,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors
                                                              .brown[700]))),
                                              Text(firstInvoice[index].shipId,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[800])),
                                              Text(firstInvoice[index].shipper,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.grey[700])),
                                            ],
                                          ),
                                        ),
                                        /* title: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            firstInvoice[index].distrId,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                            ),
                                          ),
                                          firstInvoice[index].dlvDate ==
                                                  '0000-00-00'
                                              ? Container()
                                              : Text(
                                                  firstInvoice[index].dlvDate,
                                                  style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),*/
                                        trailing: Container(
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                'EGP ${formatter.format(addPpnTax(index))}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.pink[900],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'Bp ${firstInvoice[index].invocieBp.toString()}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue[900],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      children: [
                                        _buildOrder(firstInvoice, index)
                                      ]
                                      /* firstInvoice[index]
                        .invoiceItems
                        .map(_buildItem)
                        .toList()*/
                                      //root.invoiceItems.map(_buildTiles).toList(),
                                      )
                                ],
                              )),
                        );

                        // EntryItem(invoices[index]);
                      }),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
