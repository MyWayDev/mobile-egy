/*import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:mor_release/models/ticket.dart';

class FcmModel extends Model {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  DatabaseReference databaseReference;

  Future<String> sToken(Future<String> token) async {
    List _userToken = [];
    String _token = await token;
    DataSnapshot snapshot = await _db
        .reference()
        .child('flamelink/environments/production/content/users/en-US')
        .orderByChild('token')
        .equalTo('$_token')
        .once();
    _userToken = await snapshot.value;
    String id = _userToken.last['id'].toString();

    return id;
  }

  Future<Notify> _saveDeviceToken(message, Future<String> id) async {
    // String uid = model.userInfo.distrId;
    String fcmToken = await _fcm.getToken();
    String _id = await id;
    var msgJson = await message.values.first;

    // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    //String x = Platform.operatingSystemVersion;
    print('awaited id=>$_id');

    print("Token:$fcmToken");
    _db
        .reference()
        .child('flamelink/environments/production/content/users/en-US/$_id')
        .update({
      "token": fcmToken,
    });

    Notify notify = Notify.fromJson(msgJson);
    _saveNotify(notify, _id);
    print('notify body:${notify.title}');

    return notify;
  }

  void _saveNotify(Notify notify, String id) {
    _db
        .reference()
        .child('flamelink/environments/production/content/notify/en-US/' +
            id +
            new DateTime.now().millisecondsSinceEpoch.toString())
        .set({
      "title": notify.title,
      "body": notify.body,
      "image": notify.image,
      "user": id,
      "seen": false,
    }).catchError((e) => print('SaveNotifyError=>$e'));
  }

  void mainInitState() {
    _fcm.configure(
      onMessage: (Map<dynamic, dynamic> message) async {
        // print("onMessage: $message");
        _saveDeviceToken(message, sToken(_fcm.getToken()));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        //_saveDeviceToken(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _saveDeviceToken(message);
      },
    );

    _fcm.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
      //_saveDeviceToken();
    });
  }

  void printToken() async {
    String fcmToken = await _fcm.getToken();
    print("TokePrint:$fcmToken");
  }
}*/
