import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:mor_release/models/courier.dart';
import 'package:mor_release/pages/gift/gift.dart';
import 'package:mor_release/pages/gift/gift_list.dart';
import 'package:mor_release/pages/gift/promo/promo.dart';
import 'package:mor_release/pages/gift/promo/promo_list.dart';
import 'package:mor_release/pages/order/widgets/order_save.dart';
import 'package:mor_release/pages/order/widgets/order_summary.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class CourierOrder extends StatefulWidget {
  final List<dynamic> couriers;
  final String areaId;
  final String distrId;
  final String userId;

  CourierOrder(this.couriers, this.areaId, this.distrId, this.userId);

  @override
  State<StatefulWidget> createState() {
    return _CourierOrder();
  }
}

@override
class _CourierOrder extends State<CourierOrder> {
  List<Courier> shipment = [];
  String areaId;
  Courier _chosenValue;
  Courier stateValue;
  double courierFee;
  double courierDiscount;
  bool _loading = false;
  isloading(bool l) {
    setState(() {
      _loading = l;
    });
  }

  @override
  void initState() {
    getinit();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getinit() async {
    shipment = widget.couriers;
    areaId = widget.areaId;
  }

  TextEditingController controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        child: !model.loading
            ? Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 38,
                      child: TextField(
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                        controller: controller,
                        decoration: InputDecoration(
                          fillColor: Colors.lightBlue,
                          hintText: 'ملاحظات',
                        ),
                        // style: TextStyle(fontSize: 18.0),
                        // onChanged: onSearchTextChanged,
                      ),
                    ),

                    model.giftorderList.length > 0
                        //|| model.giftPacks.length > 0
                        ? Text(
                            'هدايا النقاط',
                            style: TextStyle(
                                color: Colors.grey,
                                //fontWeight: FontWeight.bold,
                                fontSize: 12.0),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.end,
                          )
                        : Container(),
                    model.giftPacks.length > 0 || model.promoPacks.length > 0
                        ? Row(
                            children: <Widget>[
                              Flexible(
                                child: SizedBox(
                                  height: 60.0,
                                  child: GiftList(),
                                ),
                              ),
                              model.promoPacks.length > 0
                                  ? Flexible(
                                      child: SizedBox(
                                        height: 60.0,
                                        child: PromoList(),
                                      ),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                    model.giftorderList.length > 0 ||
                            model.promoOrderList.length > 0
                        ? Row(
                            children: <Widget>[
                              model.giftorderList.length > 0
                                  ? Expanded(
                                      child: SizedBox(
                                          height: 120, child: GiftPage()),
                                    )
                                  : Container(),
                              model.promoOrderList.length > 0
                                  ? Expanded(
                                      child: SizedBox(
                                          height: 120, child: PromoPage()),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                    model.giftPacks.length == 0 &&
                            model.promoPacks.length == 0 &&
                            !model.isBulk
                        ? Container(
                            height: 62,
                            child: FormField<Courier>(
                              initialValue: _chosenValue = null,
                              onSaved: (val) => _chosenValue = val,
                              validator: (val) => (val == null)
                                  ? 'Please choose a Courier'
                                  : null,
                              builder: (FormFieldState<Courier> state) {
                                return InputDecorator(
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.local_shipping),
                                    labelText: stateValue == null
                                        ? 'شركة الشحن / ${model.shipmentName}'
                                        : '',
                                    errorText:
                                        state.hasError ? state.errorText : null,
                                  ),
                                  isEmpty: state.value == null,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Courier>(
                                      // iconSize: 25.0,
                                      // elevation: 5,
                                      value: stateValue,
                                      isDense: true,
                                      onChanged: (Courier newValue) async {
                                        if (newValue.courierId == '') {
                                          newValue = null;
                                        }
                                        setState(() {
                                          stateValue = newValue;
                                          _loading = true;
                                        });
                                        state.didChange(newValue);
                                        courierFee =
                                            await model.courierServiceFee(
                                                newValue.id.toString(),
                                                areaId,
                                                model.orderWeight());
                                        courierDiscount = 0.0;
                                        var cd = await model.getCourierDiscount(
                                            model.orderBp(), courierFee);
                                        courierDiscount = cd;
                                        isloading(false);
                                        // print(newValue.id.toString());
                                      },
                                      items: shipment.map((Courier courier) {
                                        return DropdownMenuItem<Courier>(
                                          value: courier,
                                          child: Text(
                                            "${courier.name} / ${model.shipmentName}",
                                            softWrap: true,
                                            style: TextStyle(
                                                color: Colors.pink[900],
                                                fontSize: 12.6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(),

                    courierFee != null && !model.isBulk && stateValue != null
                        ? Container(
                            height: 225,
                            child: ModalProgressHUD(
                                inAsyncCall:
                                    _loading, //courierFee == null ? true : false,
                                opacity: 0.6,
                                progressIndicator: LinearProgressIndicator(),
                                child: ListView(
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  children: <Widget>[
                                    stateValue != null &&
                                            model.giftPacks.length == 0 &&
                                            model.promoPacks.length == 0
                                        ? OrderSummary(
                                            stateValue.courierId,
                                            courierFee,
                                            model.userInfo.distrId,
                                            controller.text,
                                            courierDiscount)
                                        : Container(),
                                    stateValue != null &&
                                            courierFee != null &&
                                            // model.orderBp() > 0 &&
                                            model.giftPacks.length == 0 &&
                                            model.promoPacks.length == 0
                                        ? OrderSave(
                                            stateValue.courierId,
                                            courierFee,
                                            courierDiscount,
                                            widget.distrId,
                                            controller.text,
                                            widget.areaId,
                                            widget.userId)
                                        : Container(),
                                  ],
                                )))
                        : Container(),
                    model.giftPacks.length == 0 &&
                            model.promoPacks.length == 0 &&
                            model.isBulk
                        ? Container(
                            height: 62,
                            child: FormField<Courier>(
                              initialValue: _chosenValue = null,
                              onSaved: (val) => _chosenValue = val,
                              validator: (val) => (val == null)
                                  ? 'Please choose a Courier'
                                  : null,
                              builder: (FormFieldState<Courier> state) {
                                return InputDecorator(
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.local_shipping),
                                    labelText: stateValue == null
                                        ? '${model.shipmentName}'
                                        : '',
                                    errorText:
                                        state.hasError ? state.errorText : null,
                                  ),
                                  isEmpty: state.value == null,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<Courier>(
                                      // iconSize: 25.0,
                                      // elevation: 5,
                                      value: stateValue,
                                      isDense: true,
                                      onChanged: (Courier newValue) async {
                                        if (newValue.courierId == '') {
                                          newValue = null;
                                        }
                                        setState(() {
                                          stateValue = newValue;
                                          _loading = true;
                                        });
                                        state.didChange(newValue);
                                        courierFee =
                                            await model.courierServiceFee(
                                                newValue.id.toString(),
                                                areaId,
                                                model.bulkOrderWeight());
                                        courierDiscount = 0.0;
                                        var cd = await model.getCourierDiscount(
                                            model.bulkOrderBp().toInt(),
                                            courierFee);
                                        courierDiscount = cd;
                                        isloading(false);
                                        // print(newValue.id.toString());
                                      },
                                      items: shipment.map((Courier courier) {
                                        return DropdownMenuItem<Courier>(
                                          value: courier,
                                          child: Text(
                                            "${courier.name} / ${model.shipmentName}",
                                            softWrap: true,
                                            style: TextStyle(
                                                color: Colors.pink[900],
                                                fontSize: 12.6,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(),
                    courierFee != null && model.isBulk && stateValue != null
                        ? Container(
                            height: 180,
                            child: ModalProgressHUD(
                                inAsyncCall:
                                    _loading, //courierFee == null ? true : false,
                                opacity: 0.6,
                                progressIndicator: LinearProgressIndicator(),
                                child: ListView(
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  children: <Widget>[
                                    stateValue != null &&
                                            model.giftPacks.length == 0 &&
                                            model.promoPacks.length == 0
                                        ? OrderSummary(
                                            stateValue.courierId,
                                            courierFee,
                                            model.userInfo.distrId,
                                            controller.text,
                                            courierDiscount)
                                        : Container(),
                                    courierFee != null &&
                                            stateValue != null &&
                                            model.bulkOrderBp() > 0 &&
                                            model.giftPacks.length == 0 &&
                                            model.promoPacks.length == 0
                                        ? OrderSave(
                                            stateValue.courierId,
                                            courierFee,
                                            courierDiscount,
                                            widget.distrId,
                                            controller.text,
                                            widget.areaId,
                                            widget.userId)
                                        : Container(),
                                  ],
                                )))
                        : Container()

                    //! missing widgets goes here;
                  ],
                ),
              )
            : Container(),
      );
    });
  }
}

/*     courierFee != null
                                      ? SingleChildScrollView(
                                          child: OrderSave(
                                              stateValue.courierId,
                                              courierFee,
                                              widget.distrId,
                                              controller.text,
                                              widget.areaId),
                                        )
                                      : Container(),*/
