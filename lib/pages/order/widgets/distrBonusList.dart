import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/user.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class DistrBonusList extends StatefulWidget {
  DistrBonusList({Key key}) : super(key: key);

  @override
  _DistrBonusListState createState() => _DistrBonusListState();
}

class _DistrBonusListState extends State<DistrBonusList> {
  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.distrBonusList.isNotEmpty
          ? ModalProgressHUD(
              color: Colors.black,
              inAsyncCall: _isloading,
              opacity: 0.6,
              progressIndicator: ColorLoader2(),
              child: Container(
                  height: MediaQuery.of(context).size.height / 1.6,
                  width: MediaQuery.of(context).size.width,
                  child: Column(children: <Widget>[
                    Expanded(
                        child: ListView.builder(
                      itemCount: model.distrBonusList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                            onDismissed: (DismissDirection direction) {
                              if (direction == DismissDirection.endToStart) {
                                model.deleteDistrBonus(index, context);
                              } else if (direction ==
                                  DismissDirection.startToEnd) {
                                model.deleteDistrBonus(index, context);
                              }
                            },
                            key: Key(model.distrBonusList[index].distrId),
                            child: Card(
                                color: Colors.green[300],
                                child: Column(children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text(
                                        ' طلب خصم المكافأة  ',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 12)
                                    ],
                                  ),
                                  _buildDistrBonus(
                                      model.distrBonusList, index, model),
                                ])));
                      },
                    ))
                  ])))
          : Container();
    }));
  }

  Widget _buildDistrBonus(
      List<DistrBonus> _distrBonusList, int index, MainModel model) {
    return ListTile(
      leading: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 50.0, maxWidth: 23.0),
        child: IconButton(
            disabledColor: Colors.transparent,
            icon: Icon(
              Icons.delete_forever,
              color: Colors.pink[900],
              size: 22,
            ),
            onPressed: () {
              model.deleteDistrBonus(index, context);
            }),
      ),
      title: Container(
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 45.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(
                    Icons.vpn_key,
                    color: Colors.pink[500],
                    size: 17,
                  ),
                  SizedBox(width: 2),
                  Text(
                    int.parse(model.distrBonusList[index].distrId).toString(),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                model.distrBonusList[index].name,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                model.distrBonusList[index].bonus.toString(),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
