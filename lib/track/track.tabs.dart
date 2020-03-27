import 'package:flutter/material.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/track/track.invoice.dart';
import 'package:mor_release/track/track.order.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';

class TrackTabs extends StatelessWidget {
  final AppBar _appBar = AppBar(
    leading: Container(),
    bottomOpacity: 0.0,
    backgroundColor: Colors.transparent,
    elevation: 20,
    ///////////////////////Top Tabs Navigation Widget//////////////////////////////
    title: TabBar(
      indicatorColor: Colors.pink[700],
      indicatorWeight: 2,
      indicatorSize: TabBarIndicatorSize.tab,
      tabs: <Widget>[
        Tab(
          icon: new Icon(
            GroovinMaterialIcons.file,
            size: 35.0,
            color: Colors.pink[700],
          ),
        ),
        Tab(
          icon: Icon(
            GroovinMaterialIcons.file_check,
            color: Colors.green[400],
            size: 35.0,
          ), // required
          //badgeColor: Colors.red, // default: Colors.red
          // default: Colors.white
          //hideZeroCount: true, // default: true

          /* icon: new Stack(children: <Widget>[
                        Icon(
                          Icons.shopping_cart,
                          size: 35.0,
                        ),
                        Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: )
                      ]),*/
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(45.0), child: _appBar),
          body: TabBarView(
            children: <Widget>[
              TrackOrder(model.userInfo.distrId),
              TrackInvoice(model.userInfo.distrId),
              // ExpansionTileSample() // SwitchPage(ItemsPage()),
              //OrderPage(), //SwitchPage(OrderPage()),
              //ProductList(),
            ],
          ),
          /* bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: [
              BottomNavigationBarItem(
                  title: new Text('Account'),
                  icon: new Icon(Icons.account_box)),
              BottomNavigationBarItem(
                  icon: new Icon(Icons.mail), title: new Text('Messages')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text('Profile'))
            ],
          ),*/
        ),
      );
    });
  }
/*new BottomNavigationBarItem(
        title: new Text('Home'),
        icon: new Stack(
          children: <Widget>[
            new Icon(Icons.home),
            new Positioned(  // draw a red marble
              top: 0.0,
              right: 0.0,
              child: new Icon(Icons.brightness_1, size: 8.0, 
                color: Colors.redAccent),
            )
          ]
        ),
      )*/

}
