import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mor_release/pages/items/items.dart';
import 'package:mor_release/pages/items/items.tabs.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/messages/local_note.dart';
import 'package:mor_release/pages/order/bulkOrder.dart';
import 'package:mor_release/pages/order/end_order.dart';
import 'package:mor_release/pages/order/order.dart';
import 'package:mor_release/pages/user/phoneAuth.dart';
import 'package:mor_release/scoped/connected.dart';
import './pages/user/registration_page.dart';
import './pages/user/login_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mor_release/scoped/note_helper.dart' as note;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  final MainModel model = MainModel();

  Random random = Random();
  final String pathLink = 'egyDb/tokens/';
  static final FirebaseDatabase database = FirebaseDatabase.instance;
  final DatabaseReference databaseReference = database.reference();
  final firebaseMessaging = new FirebaseMessaging();
  final notify = FlutterLocalNotificationsPlugin();
  List<Notify> noteList = List();
  var subAdd;
  var subDel;
  var subChanged;
  String getPlatform() {
    String platform;

    Platform.isIOS ? platform = 'Ios' : platform = 'Android';
    return platform;
  }

  @override
  void initState() {
    super.initState();

    String _token = '';
    initTokenListen();
    Future onSelectNotification(String payload) async => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LocalNotification(
                    token: _token,
                  )),
        );
    var android = new AndroidInitializationSettings('icon');

    var ios = new IOSInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) =>
            onSelectNotification(payload));

    notify.initialize(InitializationSettings(android, ios),
        onSelectNotification: onSelectNotification);

    int _random = random.nextInt(10000);
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async {
        note.showOngoingNotification(
          notify,
          title: msg['notification']['title'],
          body: msg['notification']['body'],
          id: _random,
        );

        print(" onMessage called ${(msg)}");
      },
      onLaunch: (Map<String, dynamic> msg) async {
        note.showOngoingNotification(
          notify,
          title: msg['notification']['title'],
          body: msg['notification']['body'],
          id: _random,
        );

        // print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) async {
        note.showOngoingNotification(
          notify,
          title: msg['notification']['title'],
          body: msg['notification']['body'],
          id: _random,
        );
        //print(" onResume called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      //print('IOS Setting Registed');
    });
    // firebaseMessaging.getToken().then((token) {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initTokenListen() {
    firebaseMessaging.getToken().then((_token) {
      final String path = pathLink + 'tokens-list/$_token';
      subAdd =
          databaseReference.child(path).onChildAdded.listen(_onItemEntryAdded);

      subDel = databaseReference
          .child(path)
          .onChildRemoved
          .listen(_onItemEntryDeleted);
      model.token = _token;

      subChanged = databaseReference
          .child(path)
          .onChildChanged
          .listen(_onItemEntryChanged);

      update(_token);
    });
  }

  void _onItemEntryAdded(Event event) {
    noteList.add(Notify.fromSnapshot(event.snapshot));
    //  print('noteLenght:${noteList.length} snapshot key:${event.snapshot.key}');
    _noteSnapshotCount();
    setState(() {});
  }

  void _onItemEntryDeleted(Event event) {
    Notify note = noteList.firstWhere((f) => f.key == event.snapshot.key);
    setState(() {
      noteList.remove(noteList[noteList.indexOf(note)]);
      _noteSnapshotCount();
    });
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = noteList.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      noteList[noteList.indexOf(oldEntry)] =
          Notify.fromSnapshot(event.snapshot);
      _noteSnapshotCount();
    });
  }

  void _noteSnapshotCount() {
    model.noteCount = noteList.where((n) => !n.seen).length;
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNLE NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await notify.show(0, "This is title", "this is demo", platform);
  }

  /*updateMsg(Map<String, dynamic> msg) {
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference
        .child('tokens-list/$_token/${DateTime.now().millisecondsSinceEpoch}')
        .set({"Title": msg['notification']['title']});
  }*/

  update(String token) {
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child(pathLink + 'tokens-list/$token').update({
      "z": {"body": '', "image": '', "seen": true, "title": 'hide'}
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    model.settingsData();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        title: 'MyWay',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          //  const Locale('ar', 'MR'),
          const Locale('en', 'US'),
          const Locale('fr', 'FR'),
          // const Locale('ar', 'EG'),
        ],
        theme: ThemeData(
          primarySwatch: Colors.pink,
          brightness: Brightness.light,
          primaryColor: Colors.pink[900],
          accentColor: Colors.pinkAccent[700],
          backgroundColor: Colors.white70,
          buttonColor: Colors.pink[900],
        ),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          //  '/':home,
          // '/bottomnav': (BuildContext context) =>
          //  BottomNav(model.userInfo.distrId),
          '/login': (BuildContext context) => LoginScreen(),
          '/registration': (BuildContext context) => RegistrationPage(),
          '/bulkOrder': (BuildContext context) =>
              BulkOrder(model, model.shipmentArea, model.distrPoint),
          //'/welcome': (BuildContext context) => Welcome(),
          '/itemstabs': (BuildContext context) => ItemsTabs(),
          '/itemspage': (BuildContext context) => ItemsPage(model),
          '/endorder': (BuildContext context) => EndOrder(model),
          '/order': (BuildContext context) => OrderPage(model),
          '/phoneAuth': (BuildContext context) => PhoneAuth(title: 'Reg'),

          // '/savedialog':(BuildContext context) => SaveDialog(),
          //'/lockpage': (BuildContext context) => LockScreen(),
          // '/ordertabs': (BuildContext context) => OrderTabs(),
          // '/item':(BuildContext context) => ItemPage(),
        },
        /*
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');

          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'item') {
            final int index = int.parse(pathElements[2]);

            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => ItemPage(index),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => ItemsPage());
        },*/
      ),
    );
  }
}

//!old messaging code .

/*FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    firebaseMessaging.autoInitEnabled();
    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        print(" onMessage called ${(msg)}");

        final snackbar = SnackBar(
          content: Text("body"),
          action: SnackBarAction(
            label: 'Go',
            onPressed: () => null,
          ),
        );
        Scaffold.of(context).showSnackBar(snackbar);
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: ListTile(
                  title: Text(msg['title']),
                  subtitle: Text(msg['body']),
                ),
                actions: <Widget>[
                  FlatButton(
                    color: Colors.amber,
                    child: Text('Ok'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
        );
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));

    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });

    firebaseMessaging.getToken().then((token) {
      update(token);
      print('tokenUpdate:$token');
    });
  }

  showNotification(Map<String, dynamic> msg) async {}
  update(String token) {
    print(token);
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm-token/$token').set({"token": token});

    setState(() {});*/
