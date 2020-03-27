import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:mor_release/pages/gift/gift.dart';
import 'package:mor_release/pages/gift/gift_list.dart';
import 'package:mor_release/pages/gift/promo/promo.dart';
import 'package:mor_release/pages/gift/promo/promo_list.dart';
import 'package:mor_release/pages/order/widgets/order_save.dart';
import 'package:mor_release/pages/order/widgets/order_summary.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class CashOrder extends StatefulWidget {
  final String distrId;
  final String userId;

  CashOrder(this.distrId, this.userId);

  @override
  State<StatefulWidget> createState() {
    return _CashOrder();
  }
}

@override
class _CashOrder extends State<CashOrder> {
  bool _loading = false;
  isloading(bool l) {
    setState(() {
      _loading = l;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                        controller: controller,
                        decoration: InputDecoration(
                          fillColor: Colors.lightBlue,
                          hintText: 'Komentar',
                        ),
                        // style: TextStyle(fontSize: 18.0),
                        // onChanged: onSearchTextChanged,
                      ),
                    ),
                    model.giftorderList.length > 0
                        //|| model.giftPacks.length > 0
                        ? Text(
                            'Poin Hadiah',
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
                    Container(
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
                                model.giftPacks.length == 0 &&
                                        model.promoPacks.length == 0
                                    ? OrderSummary(
                                        '',
                                        0,
                                        model.userInfo.distrId,
                                        controller.text,
                                        0)
                                    : Container(),
                                model.orderBp() > 0 &&
                                        model.giftPacks.length == 0 &&
                                        model.promoPacks.length == 0
                                    ? OrderSave('', 0, 0, widget.distrId,
                                        controller.text, '', widget.userId)
                                    : Container(),
                              ],
                            ))),
                  ],
                ),
              )
            : Container(),
      );
    });
  }
}
