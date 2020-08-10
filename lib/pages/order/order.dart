import 'package:draggable_floating_button/draggable_floating_button.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/models/backOrder.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/pages/gift/gift_card.dart';
import 'package:mor_release/pages/gift/promo/promo_card.dart';
import 'package:mor_release/pages/order/bulkOrder.dart';
import 'package:mor_release/pages/order/end_order.dart';
import 'package:mor_release/pages/order/widgets/backOrderDialog.dart';
import 'package:mor_release/pages/order/widgets/backOrderList.dart';
import 'package:mor_release/pages/order/widgets/bonus.deduct.dart';
import 'package:mor_release/pages/order/widgets/shipmentArea.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:mor_release/widgets/stock_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderPage extends StatefulWidget {
  final MainModel model;
  OrderPage(this.model);

  State<StatefulWidget> createState() {
    return _OrderPage();
  }
}

@override
class _OrderPage extends State<OrderPage> {
  final formatter = new NumberFormat("#,###");
  final formatWeight = new NumberFormat("#,###.##");
  List<BackOrder> _backOrders = [];
  bool _isloading = false;
  void isBulk(bool b, MainModel model) {
    setState(() {
      model.isBulk = b;
    });
  }

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();
  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <=
              scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {}
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isOnlyBackOrder(MainModel model) {
    bool isOBO = false;

    if (model.backOrdersList.isNotEmpty &&
        model.itemorderlist.isEmpty &&
        !model.isBulk) {
      isOBO = true;
    } else if (model.backOrdersList.isNotEmpty &&
        model.itemorderlist.isNotEmpty &&
        !model.isBulk) {
      isOBO = true;
    } else if (model.backOrdersList.isEmpty &&
        model.itemorderlist.isNotEmpty &&
        !model.isBulk) {
      isOBO = true;
    }
    return isOBO;
  }

  AppBar appBar;
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        elevation: 21,
        backgroundColor: Colors.deepPurple[50],
        context: context,
        builder: (BuildContext bc) {
          return ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget child, MainModel model) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned(
                    top: 1,
                    left: MediaQuery.of(context).size.width / 6,
                    right: MediaQuery.of(context).size.width / 6,
                    child: IconButton(
                      icon: Icon(
                        Icons.add_location,
                        size: 32,
                        color: Colors.pink[900],
                      ),
                      onPressed: () {
                        //Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (_) => ShipmentPlace(
                                  model: widget.model,
                                  memberId: model.userInfo.distrId,
                                  isEdit: true,
                                ));
                      },
                    )),
                Positioned(
                  top: 40,
                  left: MediaQuery.of(context).size.width / 10,
                  right: MediaQuery.of(context).size.width / 10,
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Flexible(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Flex(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      direction: Axis.horizontal,
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            // width: 113,
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              child: Text(
                                                '${model.shipmentAddress}/${model.shipmentName}',
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )),
                                      ]),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 68),
                  child: ListView.builder(
                    itemCount: model.bulkOrder.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        enabled: true,
                        selected: true,
                        onTap: () {
                          if (model.itemorderlist.length > 0) {
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'سيتم حذف المنتجات من السلة لتحميل',
                                        style:
                                            TextStyle(color: Colors.pink[900])),
                                    actions: <Widget>[
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          model.backOrdersList.clear();
                                          model.distrBonusList.clear();
                                          model.itemorderlist.clear();
                                          model.backOrdersList.addAll(model
                                              .bulkOrder[index].backOrders);
                                          model.distrBonusList.addAll(model
                                              .bulkOrder[index].distrBonues);
                                          model.itemorderlist.addAll(
                                              model.bulkOrder[index].order);
                                          model.bulkOrder
                                              .remove(model.bulkOrder[index]);
                                          model.bulkOrder.length == 0
                                              ? model.shipmentAddress = ''
                                              : null;
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            model.distrBonusList
                                .addAll(model.bulkOrder[index].distrBonues);
                            model.backOrdersList
                                .addAll(model.bulkOrder[index].backOrders);
                            model.itemorderlist
                                .addAll(model.bulkOrder[index].order);
                            model.giftorderList
                                .addAll(model.bulkOrder[index].gifts);
                            model.promoOrderList
                                .addAll(model.bulkOrder[index].promos);
                            model.bulkOrder.remove(model.bulkOrder[index]);
                            model.bulkOrder.length == 0
                                ? model.shipmentAddress = ''
                                : null;
                            print(model.shipmentArea);
                            Navigator.of(context).pop();
                          }
                        },
                        leading: Column(
                          children: <Widget>[
                            Icon(Icons.vpn_key, size: 18),
                            Text(model.bulkOrder[index].distrId,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                        title: Column(
                          children: <Widget>[
                            Text(
                              "EGP ${formatter.format(model.bulkOrder[index].total)}",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                            Text(
                              "Bp ${formatter.format(model.bulkOrder[index].totalBp)}",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                            Text(
                              "kg ${formatWeight.format(model.bulkOrder[index].weight)}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                            ),
                            Divider(height: 12, color: Colors.black)
                          ],
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            model.bulkOrder.remove(model.bulkOrder[index]);
                            if (model.bulkOrder.length == 0) {
                              isBulk(false, model);
                              model.shipmentAddress = '';
                              //model.shipmentArea = '';
                            }

                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.delete_forever),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ModalProgressHUD(
        color: Colors.black,
        inAsyncCall: _isloading,
        opacity: 0.6,
        progressIndicator: ColorLoader2(),
        child: Scaffold(
          floatingActionButton: model.isBulk
              ? FloatingActionButton(
                  backgroundColor: Colors.purple[800],
                  onPressed: () {
                    _settingModalBottomSheet(context);
                  },
                  child: BadgeIconButton(
                    badgeTextColor: Colors.white,
                    itemCount: model.bulkOrder.length,
                    icon: Icon(
                      Icons.format_list_numbered,
                      size: 28,
                      color: Colors.white,
                    ),
                  ))
              : Container(),
          resizeToAvoidBottomPadding: true,
          body: Stack(
            children: <Widget>[
              Column(children: <Widget>[
                model.bulkOrder.length != 0
                    ? Container(
                        height: 58,
                        child: Card(
                          color: Colors.grey[350],
                          elevation: 21,
                          child: ListTile(
                              leading: Container(
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(left: 20),
                                    ),
                                    Text(
                                      ' EGP ${formatter.format(model.bulkOrderSum())}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ' Bp ${formatter.format(model.bulkOrderBp())}',
                                      style: TextStyle(
                                        color: Colors.pink[800],
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      ' Kg ${formatWeight.format(model.bulkOrderWeight())}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              title: Icon(
                                GroovinMaterialIcons.format_list_checks,
                                color: Colors.grey,
                                size: 34,
                              ),
                              trailing: Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: model.itemorderlist.length == 0
                                      ? RawMaterialButton(
                                          child: Icon(
                                            Icons.send,
                                            size: 24.0,
                                            color: Colors.white,
                                          ),
                                          shape: CircleBorder(),
                                          highlightColor: Colors.pink[900],
                                          elevation: 21,
                                          fillColor: Colors.green,
                                          onPressed: () {
                                            model.loading = false;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) {
                                                return BulkOrder(
                                                    model,
                                                    model.shipmentArea,
                                                    model.distrPoint);
                                              }),
                                            );
                                          },
                                          splashColor: Colors.pink[900],
                                        )
                                      : RawMaterialButton(
                                          child: Icon(
                                            Icons.block,
                                            size: 24.0,
                                            color: Colors.white,
                                          ),
                                          shape: CircleBorder(),
                                          highlightColor: Colors.pink[900],
                                          elevation: 21,
                                          fillColor: Colors.red,
                                          onPressed: () {
                                            model.loading = false;
                                          },
                                          splashColor: Colors.pink[900],
                                        ))),
                        ),
                      )
                    : Container(),
                Container(
                    height: 58,
                    child: Card(
                        color: Colors.purple[50],
                        elevation: 21,
                        child: ListTile(
                          leading: Container(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                ),
                                Text(
                                  'EGP ${formatter.format(model.orderSum())}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' Bp ${formatter.format(model.orderBp())}',
                                  style: TextStyle(
                                    color: Colors.pink[800],
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' Kg ${formatWeight.format(model.orderWeight())}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: RawMaterialButton(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Stack(
                                          fit: StackFit.loose,
                                          overflow: Overflow.clip,
                                          children: <Widget>[
                                            BadgeIconButton(
                                              itemCount:
                                                  model.backOrdersList.length,
                                              icon: Icon(
                                                GroovinMaterialIcons
                                                    .arrow_down_bold,
                                                size: 25.0,
                                                color: Colors.blue,
                                              ),
                                              badgeTextColor: Colors.red[700],
                                              badgeColor: Colors.grey[100],
                                            ),
                                            Text(' فك الحجز',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700])),
                                          ],
                                        ),
                                      ]),
                                  constraints: const BoxConstraints(
                                      maxHeight: 48, maxWidth: 45),
                                  shape: CircleBorder(),
                                  highlightColor: Colors.pink[900],
                                  elevation: 21,
                                  fillColor: Colors.amber[400],
                                  onPressed: () async {
                                    if (!model.userInfo.isleader) {
                                      isloading(true);
                                      _backOrders = await widget.model
                                          .getBackOrderItems(
                                              widget.model.userInfo.distrId,
                                              widget.model.setStoreId);
                                    }

                                    showDialog(
                                        context: context,
                                        builder: (_) => model.userInfo.isleader
                                            ? NodeBODialoge(model)
                                            : model.backOrdersList.isEmpty
                                                ? BackOrderDialog(
                                                    _backOrders,
                                                    widget
                                                        .model.userInfo.distrId,
                                                    widget.model.userInfo.name)
                                                : BackOrderList());
                                    isloading(false);
                                  },
                                  splashColor: Colors.pink[900],
                                ),
                              ),
                              model.bulkOrder.length == 0 &&
                                      model.userInfo.isleader &&
                                      model.docType == 'CR' &&
                                      model.itemorderlist.isNotEmpty
                                  ? Transform.scale(
                                      scale: 1.55,
                                      child: Switch(
                                        inactiveTrackColor: Colors.white70,
                                        activeTrackColor: Colors.grey,
                                        activeColor: Colors.black12,
                                        value: model.isBulk,
                                        onChanged: (bool value) {
                                          setState(() {
                                            model.isBulk = value;
                                            model.shipmentAddress = '';
                                            model.shipmentArea = '';
                                          });
                                        },
                                        activeThumbImage: AssetImage(
                                            'assets/images/bulk.png'),
                                        inactiveThumbImage:
                                            AssetImage('assets/images/box.png'),
                                      ),
                                    )
                                  : Icon(
                                      GroovinMaterialIcons.cart_plus,
                                      color: Colors.grey,
                                      size: 31,
                                    ),
                            ],
                          ),
                          trailing: Padding(
                            padding: EdgeInsets.only(right: 0.1, left: 6),
                            child: Container(
                                width: 54,
                                child: isOnlyBackOrder(model)
                                    ? Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: RawMaterialButton(
                                          child: Icon(
                                            Icons.send,
                                            size: 24.0,
                                            color: Colors.white,
                                          ),
                                          shape: CircleBorder(),
                                          highlightColor: Colors.pink[900],
                                          elevation: 21,
                                          fillColor: Colors.green,
                                          onPressed: () async {
                                            model.loading = false;
                                            String validMsg = await model
                                                .getOrderInvalidPerc(model);
                                            model
                                                .flush(context, validMsg)
                                                .dismiss(context);
                                            validMsg != ''
                                                ? model
                                                    .flush(context, validMsg)
                                                    .show(context)
                                                : Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (_) {
                                                    return EndOrder(model);
                                                  }));
                                          },
                                          splashColor: Colors.pink[900],
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: model.giftPacks.length == 0 &&
                                                model.promoPacks.length == 0 &&
                                                model.backOrdersList.isNotEmpty
                                            ? RawMaterialButton(
                                                child: Icon(
                                                  Icons.add,
                                                  size: 24.0,
                                                  color: Colors.white,
                                                ),
                                                shape: CircleBorder(),
                                                highlightColor:
                                                    Colors.pink[900],
                                                elevation: 21,
                                                fillColor: Colors.purple[800],
                                                onPressed: () async {
                                                  //model.giftorderList.clear();
                                                  String validMsg = await model
                                                      .getOrderInvalidPerc(
                                                          model);
                                                  model
                                                      .flush(context, validMsg)
                                                      .dismiss(context);
                                                  validMsg != ''
                                                      ? model
                                                          .flush(
                                                              context, validMsg)
                                                          .show(context)
                                                      : showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              NodeDialoge(
                                                                  model));
                                                },
                                                splashColor: Colors.pink[900],
                                              )
                                            : RawMaterialButton(
                                                child: Icon(
                                                  Icons.block,
                                                  size: 24.0,
                                                  color: Colors.white,
                                                ),
                                                shape: CircleBorder(),
                                                highlightColor:
                                                    Colors.pink[900],
                                                elevation: 21,
                                                fillColor: Colors.red[800],
                                                onPressed: () {},
                                                splashColor: Colors.pink[900],
                                              ))),
                          ),
                        ))),

                model.itemorderlist.isNotEmpty
                    ? BonusDeduct(model)
                    : Container(),

                //  model.isBulk ? BulkGiftsAndPromos(model) : Container(),
                _orderExp(context, model, formatter, formatWeight),
              ]),
              /* DraggableFloatingActionButton(
                  data: 'dfab_demo',
                  offset: Offset(100, 205),
                  backgroundColor: Theme.of(context).accentColor,
                  child: Text(
                    'PerBP',
                  ),
                  onPressed: () => print('pressed'),
                  appContext: context,
                  appBar: appBar),*/
            ],
          ),
        ),
      );
    });
  }
}

Widget _orderExp(BuildContext context, MainModel model, NumberFormat formatter,
    NumberFormat formatWeight) {
  return Expanded(
      child: model.itemorderlist.length != 0
          ? ListView.builder(
              itemCount: model.itemorderlist.length,
              itemBuilder: (BuildContext context, int i) {
                return Dismissible(
                    onDismissed: (DismissDirection direction) {
                      if (direction == DismissDirection.endToStart) {
                        model.deleteItemOrder(i);
                        model.itemCount();
                      } else if (direction == DismissDirection.startToEnd) {
                        model.deleteItemOrder(i);
                        model.itemCount();
                      }
                    },
                    background: Container(
                      color: Colors.grey[50],
                    ),
                    key: Key(model.displayItemOrder[i].itemId),
                    child: Column(
                      children: <Widget>[
                        Card(
                          elevation: 21,
                          child: ListTile(
                            enabled: true,
                            selected: true,
                            //   trailing: _buildIconButton(context, i, model),
                            // contentPadding: EdgeInsets.only(top: 10.0),
                            leading: CircleAvatar(
                              minRadius: 36,
                              maxRadius: 36,
                              backgroundColor: Colors.purple[50],
                              backgroundImage: NetworkImage(
                                model.itemorderlist[i].img,
                              ),
                            ),
                            title: Row(children: <Widget>[
                              Container(
                                child: Flexible(
                                  flex: 1,
                                  child: Column(children: <Widget>[
                                    Flex(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        direction: Axis.horizontal,
                                        //  direction: Axis.horizontal,
                                        children: <Widget>[
                                          Container(
                                            width: 38,
                                            child: Text(
                                              model.itemorderlist[i].itemId,
                                              style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF8C00),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              // width: 113,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 8),
                                                child: Text(
                                                  model.itemorderlist[i].name,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )),
                                        ]),
                                    Center(
                                        child: Text(
                                      'إجمالي القطع',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          // fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    )),
                                    Divider(
                                      height: 3.0,
                                      indent: 0,
                                      color: Colors.blueGrey,
                                    ),
                                  ]),
                                ),
                              ),
                            ]),
                            subtitle: Row(
                              children: <Widget>[
                                Container(
                                  child: Flexible(
                                    flex: 1,
                                    child: Column(
                                      children: <Widget>[
                                        Flex(
                                            direction: Axis.horizontal,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                'EGP ${formatter.format(model.itemorderlist[i].totalPrice)}',
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[700],
                                                ),
                                              ),
                                              _buildIconButton(
                                                  context, i, model),
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    'Bp ${model.itemorderlist[i].totalBp.toString()}',
                                                    style: TextStyle(
                                                      fontSize: 13.0,
                                                      color: Colors.red[900],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Divider(
                                                    height: 2.0,
                                                    indent: 1,
                                                    color: Colors.black,
                                                  ),
                                                  Text(
                                                    'Kg ${formatWeight.format(model.itemorderlist[i].totalWeight)}',
                                                    style: TextStyle(
                                                      fontSize: 13.0,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ));
              },
            )
          : Center(
              child: Icon(
              Icons.remove_shopping_cart,
              size: 80.5,
              color: Colors.grey[300],
            )));
}
//double orderPlus(double orderSum, int courierFee, int bpLimit) {}

Widget _buildIconButton(BuildContext context, int i, MainModel model) {
  return !model.iheld(model.getItemIndex(i))
      ? BadgeIconButton(
          itemCount: model.itemorderlist[i].qty <= 0
              ? 0
              : model.itemorderlist[i].qty, // required

          icon: Icon(
            Icons.shopping_cart,
            color: Colors.grey[600],
            size: 28.0,
          ), // required
          badgeColor: Colors.red,
          badgeTextColor: Colors.white,
          onPressed: () async {
            showDialog(
                context: context,
                builder: (_) => StockDialog(model.itemData,
                    model.getItemIndex(i), model.itemorderlist[i].qty));
          },
        )
      : Stack(
          children: <Widget>[
            BadgeIconButton(
              itemCount: model.itemorderlist[i].qty <= 0
                  ? 0
                  : model.itemorderlist[i].qty, // required

              icon: Icon(
                Icons.shopping_cart,
                color: Colors.grey[600],
                size: 28.0,
              ), // required
              badgeColor: Colors.amber[400],
              badgeTextColor: Colors.white,
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (_) => StockDialog(model.itemData,
                        model.getItemIndex(i), model.itemorderlist[i].qty));
              },
            ),
            Positioned(
                top: -5,
                right: 23,
                child: Icon(GroovinMaterialIcons.arrow_down_bold,
                    color: Colors.blue, size: 21)),
          ],
        );
}

class BulkGiftsAndPromos extends StatefulWidget {
  final MainModel model;
  BulkGiftsAndPromos(this.model, {Key key}) : super(key: key);

  @override
  _BulkGiftsAndPromosState createState() => _BulkGiftsAndPromosState();
}

class _BulkGiftsAndPromosState extends State<BulkGiftsAndPromos> {
  void giftState(MainModel model) async {
    await model.checkGift(model.orderBp(), model.giftBp());
    model.getGiftPack();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // widget.model.rungiftState();
    return Row(
      children: <Widget>[
        widget.model.giftPacks.length > 0
            ? Flexible(
                child: SizedBox(
                    height: 45.0,
                    child: Card(
                      color: Color(0xFFFFFFF1),
                      elevation: 21,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ModalProgressHUD(
                                color: Colors.transparent,
                                inAsyncCall: widget.model.isloading,
                                opacity: 0.1,
                                progressIndicator: LinearProgressIndicator(
                                  backgroundColor: Colors.grey[200],
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.model.giftPacks.length,
                                  itemBuilder: (context, i) {
                                    return GiftCard(widget.model.giftPacks, i);
                                  },
                                )),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    )),
              )
            : Container(),
        widget.model.promoPacks.length > 0
            ? Flexible(
                child: SizedBox(
                    height: 45.0,
                    child: Card(
                      color: Color(0xFFFFFFF1),
                      elevation: 21,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ModalProgressHUD(
                                color: Colors.transparent,
                                inAsyncCall: widget.model.isloading,
                                opacity: 0.1,
                                progressIndicator: LinearProgressIndicator(
                                  backgroundColor: Colors.grey[200],
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.model.promoPacks.length,
                                  itemBuilder: (context, i) {
                                    return PromoCard(
                                        widget.model.promoPacks, i);
                                  },
                                )),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    )),
              )
            : Container(),
        widget.model.giftorderList.length > 0
            ? Flexible(
                child: SizedBox(
                    height: 45.0,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ListView.builder(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.model.giftorderList.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Stack(
                              children: <Widget>[
                                Positioned(
                                    child: Opacity(
                                  opacity: 0.9,
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: NetworkImage(
                                      widget.model.giftorderList[i].imageUrl,
                                    ),
                                    child: BadgeIconButton(
                                      itemCount: widget.model.gCount(i),
                                      icon: Icon(
                                        Icons.shopping_cart,
                                        color: Colors.pink[900],
                                        size: 0.0,
                                      ), // required
                                      //badgeColor: Colors.pink[900],
                                      badgeTextColor: Colors.white,
                                      onPressed: () {
                                        widget.model.deleteGiftOrder(i);
                                        setState(() {
                                          giftState(widget.model);
                                        });
                                      },
                                    ),
                                  ),
                                )),
                                /*Padding(
                                      padding: EdgeInsets.only(left: 40),
                                      child: Text(
                                        model.giftorderList[i].desc,
                                        textAlign: TextAlign.left,
                                        textScaleFactor: 0.8,
                                      )),*/
                              ],
                            );
                          },
                        ),
                      ],
                    )),
              )
            : Container(),
        widget.model.promoOrderList.length > 0
            ? Flexible(
                child: SizedBox(
                    height: 45,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        ListView.builder(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width / 15),
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.model.promoOrderList.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Stack(
                              children: <Widget>[
                                Positioned(
                                    child: Opacity(
                                  opacity: 0.9,
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: NetworkImage(
                                      widget.model.promoOrderList[i].imageUrl,
                                    ),
                                    child: BadgeIconButton(
                                      itemCount: widget.model.promoCount(i),
                                      icon: Icon(
                                        Icons.shopping_cart,
                                        color: Colors.pink[900],
                                        size: 0.0,
                                      ), // required
                                      //badgeColor: Colors.pink[900],
                                      badgeTextColor: Colors.white,
                                      onPressed: () {
                                        widget.model.deletePromoOrder(i);
                                        setState(() {
                                          giftState(widget.model);
                                        });
                                      },
                                    ),
                                  ),
                                )),
                                /*Padding(
                                      padding: EdgeInsets.only(left: 40),
                                      child: Text(
                                        model.giftorderList[i].desc,
                                        textAlign: TextAlign.left,
                                        textScaleFactor: 0.8,
                                      )),*/
                              ],
                            );
                          },
                        )
                      ],
                    )),
              )
            : Container()
      ],
    );
  }
}

class NodeDialoge extends StatefulWidget {
  final MainModel model;
  NodeDialoge(this.model, {Key key}) : super(key: key);

  @override
  _NodeDialogeState createState() => _NodeDialogeState();
}

class _NodeDialogeState extends State<NodeDialoge> {
  User _nodeData;
  bool isTyping;
  bool veri = false;
  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  void getTyping(MainModel model) {
    setState(() {
      model.isTypeing = isTyping;
    });
  }

  void resetVeri() {
    controller.clear();
    setState(() {
      veri = false;
      _isloading = false;
    });
  }

  final Map<String, dynamic> _orderFormData = {
    'id': null,
    'areaId': null,
    'name': null,
  };

  TextEditingController controller = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _isloading,
        opacity: 0.6,
        progressIndicator: LinearProgressIndicator(),
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child:

              // _orderExp(context, model, formatter, formatWeight),
              Container(
            width: 120,
            height: 60,
            child: ListTile(
              //  contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.vpn_key, size: 24.0, color: Colors.pink[500]),
              title: TextFormField(
                textAlign: TextAlign.center,
                controller: controller,
                enabled: !veri ? true : false,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل رقم العضو',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value.isEmpty
                    ? 'كود المنتج فارغ !!'
                    : RegExp('[0-9]').hasMatch(value)
                        ? null
                        : 'كود المنتج غير صحيح !!',
                onSaved: (String value) {
                  _orderFormData['id'] = value.padLeft(8, '0');
                },
              ),
              trailing: IconButton(
                icon: !veri //&& controller.text.length > 0
                    ? Icon(
                        Icons.check,
                        size: 26.0,
                        color: Colors.blue,
                      )
                    : controller.text.length > 0
                        ? Icon(
                            Icons.close,
                            size: 24.0,
                            color: Colors.grey,
                          )
                        : Container(),
                color: Colors.pink[900],
                onPressed: () async {
                  isloading(true);
                  if (!veri) {
                    veri = await widget.model
                        .leaderVerification(controller.text.padLeft(8, '0'));
                    if (veri) {
                      _nodeData = await widget.model
                          .nodeJson(controller.text.padLeft(8, '0'));
                      print('_nodeData.distrId:${_nodeData.distrId}');
                      _nodeData.distrId == '00000000'
                          ? resetVeri()
                          : controller.text =
                              _nodeData.distrId + '    ' + _nodeData.name;
                      if (_nodeData.distrId == '00000000') {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (_) => NodeDialoge(widget.model));
                      } else {
                        Navigator.of(context).pop();
                        setState(() {
                          widget.model.bulkDistrId = _nodeData.distrId;
                        });
                        widget.model.shipmentAddress == null ||
                                widget.model.shipmentAddress == ''
                            ? showDialog(
                                context: context,
                                builder: (_) => ShipmentPlace(
                                      model: widget.model,
                                      memberId: _nodeData.distrId,
                                    ))
                            : widget.model
                                .orderToBulk(widget.model.bulkDistrId);
                      }
                    } else {
                      resetVeri();
                    }
                  } else {
                    resetVeri();
                  }
                  isloading(false);
                },
                splashColor: Colors.pink,
              ),
            ),
          ),
        ));
  }
}

class NodeBODialoge extends StatefulWidget {
  final MainModel model;
  NodeBODialoge(this.model, {Key key}) : super(key: key);

  @override
  _NodeBODialogeState createState() => _NodeBODialogeState();
}

class _NodeBODialogeState extends State<NodeBODialoge> {
  User _nodeData;
  bool isTyping;
  bool veri = false;
  bool _isloading = false;
  List<BackOrder> _backOrders = [];

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  void getTyping(MainModel model) {
    setState(() {
      model.isTypeing = isTyping;
    });
  }

  void resetVeri() {
    controller.clear();
    setState(() {
      veri = false;
      _isloading = false;
    });
  }

  final Map<String, dynamic> _orderFormData = {
    'id': null,
    'areaId': null,
    'name': null,
  };

  TextEditingController controller = new TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
        inAsyncCall: _isloading,
        opacity: 0.6,
        progressIndicator: LinearProgressIndicator(),
        child: Flex(
          mainAxisSize: MainAxisSize.min,
          direction: Axis.vertical,
          children: <Widget>[
            Dialog(
              backgroundColor: Colors.amber[100],
              elevation: 21,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                width: 120,
                height: 60,
                child: ListTile(
                  //  contentPadding: EdgeInsets.all(0),
                  leading:
                      Icon(Icons.vpn_key, size: 24.0, color: Colors.pink[500]),
                  title: TextFormField(
                    textAlign: TextAlign.center,
                    controller: controller,
                    enabled: !veri ? true : false,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'أدخل رقم العضو',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value.isEmpty
                        ? 'كود المنتج فارغ !!'
                        : RegExp('[0-9]').hasMatch(value)
                            ? null
                            : 'كود المنتج غير صحيح !!',
                    onSaved: (String value) {
                      _orderFormData['id'] = value.padLeft(8, '0');
                    },
                  ),
                  trailing: IconButton(
                    icon: !veri //&& controller.text.length > 0
                        ? Icon(
                            Icons.check,
                            size: 30.0,
                            color: Colors.blue[600],
                          )
                        : controller.text.length > 0
                            ? Icon(
                                Icons.close,
                                size: 24.0,
                                color: Colors.grey,
                              )
                            : Container(),
                    color: Colors.pink[900],
                    onPressed: () async {
                      isloading(true);
                      if (!veri) {
                        veri = await widget.model.leaderVerification(
                            controller.text.padLeft(8, '0'));
                        if (veri) {
                          _nodeData = await widget.model
                              .nodeJson(controller.text.padLeft(8, '0'));
                          print('_nodeData.distrId:${_nodeData.distrId}');
                          _nodeData.distrId == '00000000'
                              ? resetVeri()
                              : controller.text =
                                  _nodeData.distrId + '    ' + _nodeData.name;
                          if (_nodeData.distrId == '00000000') {
                            Navigator.of(context).pop();
                            showDialog(
                                context: context,
                                builder: (_) => NodeBODialoge(widget.model));
                          } else {
                            _backOrders = await widget.model.getBackOrderItems(
                                _nodeData.distrId, widget.model.setStoreId);
                            Navigator.of(context).pop();
                            setState(() {
                              widget.model.bulkDistrId = _nodeData.distrId;
                            });

                            showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (_) => widget.model
                                      .getbulkBackOrderDistr(_nodeData.distrId)
                                  ? AlertDialog(
                                      title: Text(
                                        "تم طلب فك الحجز لهاذا العضو في طلبيه سابقه",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    )
                                  : BackOrderDialog(_backOrders,
                                      _nodeData.distrId, _nodeData.name),
                            );
                          }
                        } else {
                          resetVeri();
                        }
                      } else {
                        resetVeri();
                      }
                      isloading(false);
                    },
                    splashColor: Colors.pink,
                  ),
                ),
              ),
            ),
            BackOrderList(),
          ],
        ));
  }
}
