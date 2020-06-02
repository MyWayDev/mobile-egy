import 'package:flutter/material.dart';
import 'package:mor_release/bottom_nav.dart';
import 'package:mor_release/models/lock.dart';
import '../../widgets/login/login_screen_banner.dart' as banner;
import '../../widgets/login/registration_button.dart' as registration_button;
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../../widgets/color_loader_2.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import '../../widgets/login/login_button.dart' as login_button;

class LoginScreen extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _LoginScreen();
  }
}

@override
class _LoginScreen extends State<LoginScreen> {
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();

  final Map<String, dynamic> _userFormData = {
    'id': null,
    'password': null,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _opacity = false;
  bool _isloading = false;

  void isloading(bool i) {
    setState(() {
      _isloading = i;
    });
  }

  void changeOpacity(bool o) {
    setState(() {
      _opacity = o;
    });
  }

  bool validateFormEntry() {
    final form = _userFormKey.currentState;
    if (form.validate()) {
      _userFormKey.currentState.save();
      return true;
    }
    return false;
  }

  TextEditingController loginController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        child: SingleChildScrollView(
          child: Container(child: buildLoginForm(context)),
        ),
        inAsyncCall: _isloading,
        opacity: 0.2,
        progressIndicator: ColorLoader2(),
      ),
    );
  }

  Widget buildLoginForm(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: Form(
          key: _userFormKey,
          child: ListView(children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                loginController.text.length == 0
                    ? FutureBuilder(
                        future: model.settingsData(),
                        builder: (context, AsyncSnapshot<Lock> snapshot) {
                          if (snapshot.hasData)
                            return banner.LoginBanner(snapshot.data.bannerUrl);
                          //!! switch back on admin Version!
                          /*Center(
                              child: Image.asset('assets/images/adbanner.png'),
                            ); */
                          else
                            return Center(
                                child: Image.asset(
                              'assets/images/myway.png',
                              scale: 2.5,
                            ));
                        })
                    : Container(),

                SizedBox(
                  height: 10.0,
                ),
                /*Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "code",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                  ),
                ),*/
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        child: Icon(
                          Icons.vpn_key,
                          color: Colors.pink,
                          size: 21.0,
                        ),
                      ),
                      Container(
                        height: 28.0,
                        width: 1.0,
                        color: Colors.grey.withOpacity(0.5),
                        margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                      ),
                      new Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'رقم العضويه',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          // controller: ,
                          //autocorrect: true,
                          autofocus: true,
                          // autovalidate: true,
                          // initialValue: '1',
                          keyboardType: TextInputType.number,
                          validator: (value) => value.isEmpty
                              ? 'رقم العضويه!!'
                              : RegExp('[0-9]').hasMatch(value)
                                  ? null
                                  : 'رقم العضويه!!',
                          onSaved: (String value) {
                            _userFormData['id'] = value; //.padLeft(8, '0');
                          },
                        ),
                      )
                    ],
                  ),
                ),
                /*Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    "Password",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                  ),
                ),*/
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 20.0),
                  child: Row(
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        child: Icon(
                          Icons.lock_open,
                          color: Colors.pink,
                        ),
                      ),
                      Container(
                        height: 30.0,
                        width: 1.0,
                        color: Colors.grey.withOpacity(0.5),
                        margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'كلمة المرور',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          // autovalidate: true,
                          // initialValue: 'sjmma225',
                          controller: loginController,
                          obscureText: true,
                          validator: (value) {
                            String _msg;
                            if (value.isEmpty) {
                              return 'خطأ فى البيانات';
                            }
                            if (value.length < 5) {
                              return 'خطأ فى البيانات';
                            }
                            return _msg;
                          },
                          onSaved: (String value) {
                            _userFormData['password'] = value;
                          },
                        ),
                      )
                    ],
                  ),
                ),
                AnimatedOpacity(
                    duration: Duration(milliseconds: 6),
                    opacity: _opacity ? 1.0 : 0.0,
                    child: Container(
                      child: Center(
                          child: Text(
                        "خطأ فى البيانات",
                        style: TextStyle(
                            color: Colors.pink[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0),
                      )),
                    )),

                Container(
                    margin: EdgeInsets.only(top: 3.0),
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Row(
                      children: <Widget>[
                        Expanded(child: ScopedModelDescendant<MainModel>(
                            builder: (BuildContext context, Widget child,
                                MainModel model) {
                          return FlatButton(
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              splashColor: Theme.of(context).primaryColor,
                              color: Theme.of(context).primaryColor,
                              child: Row(
                                children: <Widget>[
                                  new Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      "دخول",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                          color: Colors.white),
                                    ),
                                  ),
                                  new Expanded(
                                    child: Container(),
                                  ),
                                  new Transform.translate(
                                    offset: Offset(15.0, 0.0),
                                    child: new Container(
                                      padding: const EdgeInsets.all(1.0),
                                      child: FlatButton(
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      28.0)),
                                          splashColor: Colors.white,
                                          color: Colors.white,
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () {
                                            _loginPressed(model, context);
                                          }),
                                    ),
                                  )
                                ],
                              ),
                              onPressed: () {
                                _loginPressed(model, context);
                              });
                        })),
                      ],
                    )),
                //! registraion button here..
                //   registration_button.RegistrationButton(),

                /*  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(
                        child: Column(
                      children: <Widget>[
                        Text('Untuk bantuan aplikasi hubungi',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(GroovinMaterialIcons.whatsapp,
                                size: 28, color: Colors.greenAccent[400]),
                            SizedBox(width: 2.0),
                            Text('081-1186-245',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ],
                        )
                      ],
                    ))),*/
              ],
            ),
          ]),
        ),
      );
    });
  }

  void _loginPressed(MainModel model, BuildContext context) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    isloading(true);
    if (await model.formEntry(validateFormEntry(),
        model.logIn(_userFormData['id'], _userFormData['password'], context))) {
      print('userFormId:${_userFormData['id']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNav(_userFormData['id']),
        ),
      );
      print('isAllowedAccess:${model.access}');
      _userFormKey.currentState.reset();

      isloading(false);
      changeOpacity(false);
    } else {
      changeOpacity(true);
      isloading(false);
    }
  }
}
