import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin notifications;
NotificationDetails get _noSound {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'silent channel id',
    'silent channel name',
    'silent channel description',
    playSound: false,
  );
  final iOSChannelSpecifics = IOSNotificationDetails(presentSound: false);

  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showImageNotificaton(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  String image,
  int id = 0,
}) =>
    _showNotification(notifications,
        title: title, body: body, id: id, image: image, type: _image);

NotificationDetails get _image {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'your channel id', 'your channel name', 'your channel description',

    importance: Importance.Max,
    priority: Priority.Max,
    channelShowBadge: true,
    playSound: true,
    color: const Color(0xFF88124e),
    ongoing: false,
    autoCancel: false,
    ledColor: const Color(0xFFf2dee9),
    ledOnMs: 500,
    ledOffMs: 500,
    largeIcon: 'assets/images/myway.png',
    enableLights: true,
    style: AndroidNotificationStyle.BigText,

    //sound: 'point.mp3',
  );
  final iOSChannelSpecifics = IOSNotificationDetails(presentSound: true);
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showSilentNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  int id = 0,
}) =>
    _showNotification(notifications,
        title: title, body: body, id: id, type: _noSound);
NotificationDetails get _ongoing {
  final androidChannelSpecifics = AndroidNotificationDetails(
    'your channel id', 'your channel name', 'your channel description',
    importance: Importance.Max,
    priority: Priority.Max,
    channelShowBadge: true,
    playSound: true,
    //color: const Color(0xFF88124e),
    ongoing: true,
    autoCancel: false,
    ledColor: const Color(0xFFf2dee9),
    ledOnMs: 500,
    ledOffMs: 500,
    largeIcon: 'assets/images/myway.png',
    enableLights: true,
    style: AndroidNotificationStyle.BigText,
    //sound: 'point.mp3',
  );
  final iOSChannelSpecifics = IOSNotificationDetails(presentSound: true);
  return NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
}

Future showOngoingNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  int id = 0,
}) =>
    _showNotification(
      notifications,
      title: title,
      body: body,
      id: id,
      type: _ongoing,
    );

Future _showNotification(
  FlutterLocalNotificationsPlugin notifications, {
  @required String title,
  @required String body,
  @required NotificationDetails type,
  String image,
  int id = 0,
}) =>
    notifications.show(id, title, body, type);
/*
Future<String> _downloadAndSaveImage(String url, String fileName) async {
  var directory = await getApplicationDocumentsDirectory();
  var filePath = '${directory.path}/$fileName';

  var response = await http.get(url);
  var file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> showBigPictureNotificationHideExpandedLargeIcon() async {
  var largeIconPath = await _downloadAndSaveImage(
      'http://via.placeholder.com/48x48', 'largeIcon');
  var bigPicturePath = await _downloadAndSaveImage(
      'http://via.placeholder.com/400x800', 'bigPicture');

  var bigPictureStyleInformation = BigPictureStyleInformation(
      bigPicturePath, BitmapSource.FilePath,
      hideExpandedLargeIcon: true,
      contentTitle: 'overridden <b>big</b> content title',
      htmlFormatContentTitle: true,
      summaryText: 'summary <i>text</i>',
      htmlFormatSummaryText: true);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'big text channel id',
      'big text channel name',
      'big text channel description',
      importance: Importance.Max,
      priority: Priority.Max,
      channelShowBadge: true,
      playSound: true,
      color: const Color(0xFF88124e),
      ongoing: true,
      autoCancel: false,
      ledColor: const Color(0xFFf2dee9),
      ledOnMs: 500,
      ledOffMs: 500,
      largeIcon: largeIconPath,
      largeIconBitmapSource: BitmapSource.FilePath,
      style: AndroidNotificationStyle.BigPicture,
      styleInformation: bigPictureStyleInformation);

  final iOSChannelSpecifics = IOSNotificationDetails(presentSound: true);
  var platformChannelSpecifics =
      NotificationDetails(androidPlatformChannelSpecifics, iOSChannelSpecifics);

  await notifications.show(
      0, 'big text title', 'silent body', platformChannelSpecifics);
}*/
