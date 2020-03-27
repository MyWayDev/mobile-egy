import 'package:flutter/material.dart';
import 'package:mor_release/models/item.dart';
import 'package:mor_release/pages/items/itemDetails/footer.dart';
import 'package:mor_release/pages/items/itemDetails/gredients.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';
import 'header.dart';
import 'package:carousel_slider/carousel_slider.dart';

final Widget placeholder = Container(color: Colors.grey);

List _child(List<Item> imgList, BuildContext context, Item item) {
  final List child = map<Widget>(
    imgList,
    (index, i) {
      return ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          margin: EdgeInsets.all(1.0),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  // model.getIndex(imgList[index]);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details(
                            /*model.itemData[model.getIndex(imgList[index].itemId)],
                          model.getRecoItem(model
                              .itemData[model.getIndex(imgList[index].itemId)]),
                          model.getCaouselItems(model
                              .itemData[model.getIndex(imgList[index].itemId)]),*/
                            imgList[index],
                            model.getCaouselItems(imgList[index])),
                        // ItemDetails(widget.itemData[widget.index])
                      ));
                },
                child: Stack(children: <Widget>[
                  Image.network(
                    imgList[index].imageUrl ?? '',
                    scale: 2.0,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    right: 15,
                    child: Opacity(
                      opacity: 0.6,
                      child: imgList[index].catalogue == true ||
                              imgList[index].promoImageUrl != null ||
                              imgList[index].promoImageUrl != ''
                          ? Image.network(
                              imgList[index].promoImageUrl ??
                                  '', //  'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1540155801359_tag-50.png?alt=media',
                              scale: 1.9,
                            )
                          : Container(),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.pinkAccent[100],
                            Colors.pink[50],
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                      child: Center(
                        child: Text(
                          '${imgList[index].itemId}',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              )),
        );
      });
    },
  ).toList();
  return child;
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }
  return result;
}

class Details extends StatefulWidget {
  final Item item;
  //final int i;
  final List<Item> recoImage;

  Details(this.item, this.recoImage);

  List<String> _imgs(List<Item> items) {
    List<String> imgList = List();
    items.forEach((i) => imgList.add(i.imageUrl));

    return imgList;
  }

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> with TickerProviderStateMixin {
  int current = 0;
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
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        body: ListView(
          children: <Widget>[
            Header(model.getRecoItem(widget.item)),

            //favPrice(widget.item.price.toString()),
            //divider,
            Footer(widget.item.usage),
            Container(
              decoration: BoxDecoration(gradient: bgGradientII),
              child: Column(
                children: [
                  CarouselSlider(
                    enableInfiniteScroll: true,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    items: _child(widget.recoImage, context, widget.item),
                    autoPlay: true,
                    viewportFraction: 0.24,
                    enlargeCenterPage: true,
                    aspectRatio: 3.9,
                    onPageChanged: (index) {
                      setState(() {
                        current = index;
                      });
                    },
                  ),
                  /*  Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: map<Widget>(
                  widget.recoImage,
                  (index, url) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 1.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? Color.fromRGBO(0, 0, 0, 0.9)
                              : Color.fromRGBO(0, 0, 0, 0.4)),
                    );
                  },
                ),
              ),*/
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            )
          ],
        ),
      );
    });
  }
}
