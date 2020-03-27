import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'details_tabs/howto.dart';
import 'gredients.dart';

final formatter = new NumberFormat("#,###");

Widget favPrice(String price) {
  Padding _favprice = Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        /* Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
                size: 36,
              ),
            ),
          ],
        ),*/
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "\EGP",
                style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              formatter.format(price),
              style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[900]),
            )
          ],
        )
      ],
    ),
  );
  return _favprice;
}

double ration(BuildContext context) {
  var _ratio = MediaQuery.of(context).devicePixelRatio;
  var _height = MediaQuery.of(context).size.height;
  var _aspectRatio = MediaQuery.of(context).size.aspectRatio;
  var aspect =
      (((_ratio > 2.5 ? 2.2 : _ratio) * _height) / _aspectRatio / 100) * 10;

  return aspect.toDouble();
}

var divider = Divider();

var bottomBtns = Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Expanded(
        child: InkWell(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            child: Container(
              decoration: BoxDecoration(
                  gradient: btnGradient,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        blurRadius: 10.0,
                        color: Colors.black12,
                        offset: Offset(0.0, 10.0))
                  ]),
              height: 60.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Center(
                  child: Text(
                    "",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
              gradient: btnGradient,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 10.0,
                    color: Colors.black12,
                    offset: Offset(0.0, 10.0))
              ]),
          child: Icon(
            Icons.add_shopping_cart,
            size: 25.0,
            color: Colors.white,
          ),
        ),
      )
    ],
  ),
);

class Footer extends StatefulWidget {
  final String howToText;
  Footer(this.howToText);
  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> with SingleTickerProviderStateMixin {
  List<Tab> _tabs;
  List<Widget> _pages;
  static TabController _controller;
  @override
  void initState() {
    _tabs = [
      Tab(
        child: Text(
          "HowTo",
          style: TextStyle(color: Colors.black),
        ),
      ),
    ];
    _pages = [HowTo(widget.howToText)];
    _controller = TabController(
      length: _tabs.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /*TabBar(
          isScrollable: true,
          controller: _controller,
          tabs: _tabs,
          indicatorColor: Colors.white,
        ),*/
        // Text('How To'),
        Divider(
          height: 0.3,
        ),

        SizedBox.fromSize(
          size: Size.fromHeight(ration(context)),
          child: TabBarView(
            controller: _controller,
            children: _pages,
          ),
        ),
      ],
    );
  }
}
