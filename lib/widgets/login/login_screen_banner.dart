import 'package:flutter/material.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginBanner extends StatelessWidget {
  final String bannerUrl;
  //Map<String, String> title = {('title' 'dafd'): ('header' 'adfad')};
  LoginBanner(this.bannerUrl);
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return new ClipPath(
        clipper: MyClipper(),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: model.appLocked
                  ? NetworkImage(
                      'https://pngimage.net/wp-content/uploads/' +
                          '2018/06/locked-png-3.png',
                      scale: 3,
                    )
                  : NetworkImage(this.bannerUrl,
                      scale:
                          0.5), //AssetImage("assets/images/adbanner.png"), //!! need to change it to networkImagae & make it dynamic
              // fit: BoxFit.cover,
              /* */
            ),
          ),
          alignment: Alignment.bottomRight,
          padding: EdgeInsets.only(bottom: 100.0),
          child: Column(
            children: <Widget>[
              Text(
                "beta3.20r ",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
              Text(
                "",
                style: TextStyle(
                    fontSize: 70.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.90);
    p.arcToPoint(
      Offset(0.0, size.height * 0.85),
      radius: const Radius.elliptical(100.0, 100.0),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
/* */
