import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/messages/chat.dart';

import '../const.dart';

class LocalNotification extends StatefulWidget {
  final String token;
  LocalNotification({@required this.token});
  @override
  _LocalNotificationState createState() => _LocalNotificationState();
}

class _LocalNotificationState extends State<LocalNotification> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  List<Notify> notifyData = List();
  List<Notify> filteredNotify = [];
  String path = 'flamelink/environments/egyProduction/content/tokens/en-US/';
  FirebaseDatabase database = FirebaseDatabase.instance;

  DatabaseReference databaseReference;
  var subAdd;
  var subChanged;
  var subDel;
  var subSelect;

  @override
  void initState() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _cancelAllNotifications();
    databaseReference =
        database.reference().child(path + "tokens-list/${widget.token}");
    Query query = databaseReference.orderByKey();
    subAdd = query.onChildAdded.listen(_onItemEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);
    subDel = query.onChildRemoved.listen(_onItemEntryDeleted);
    super.initState();
  }

  @override
  void dispose() {
    _cancelAllNotifications();
    notifyData
        .forEach((n) => databaseReference.child(n.key).update({'seen': true}));
    subAdd?.cancel();
    subChanged?.cancel();
    subDel?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    filteredNotify = notifyData.reversed.toList();
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              child: ListView.builder(
                  itemCount: filteredNotify.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                        onDismissed: (DismissDirection direction) {
                          if (direction == DismissDirection.endToStart) {
                            _removeNote(filteredNotify[index].key);
                            reloadDismissed();
                          } else if (direction == DismissDirection.startToEnd) {
                            _removeNote(filteredNotify[index].key);
                            reloadDismissed();
                          }
                        },
                        key: Key(filteredNotify[index].key),
                        child: filteredNotify[index].image.isNotEmpty
                            ? Card(
                                color: !filteredNotify[index].seen
                                    ? Colors.blue[50]
                                    : Colors.blueGrey[50],
                                child: ExpansionTile(
                                  backgroundColor: !filteredNotify[index].seen
                                      ? Colors.blue[50]
                                      : Colors.blueGrey[50],
                                  key: PageStorageKey<Notify>(
                                      filteredNotify[index]),
                                  title:
                                      buildItem(context, filteredNotify[index]),
                                  children: <Widget>[
                                    filteredNotify[index].image != null ||
                                            filteredNotify[index].image != ''
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (_) {
                                                return ImageDetails(
                                                  image: filteredNotify[index]
                                                      .image,
                                                );
                                              }));
                                            },
                                            child: Container(
                                              child: Material(
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              themeColor),
                                                    ),
                                                    width: 200.0,
                                                    height: 200.0,
                                                    padding:
                                                        EdgeInsets.all(70.0),
                                                    decoration: BoxDecoration(
                                                      color: greyColor2,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(8.0),
                                                      ),
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Material(
                                                    child: Image.asset(
                                                      'assets/images/img_not_available.jpeg',
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(8.0),
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                                  imageUrl:
                                                      filteredNotify[index]
                                                          .image,
                                                  fit: BoxFit.scaleDown,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                            ))
                                        : Container(),
                                  ],
                                ))
                            : Card(
                                color: !filteredNotify[index].seen
                                    ? Colors.blue[50]
                                    : Colors.blueGrey[50],
                                child:
                                    buildItem(context, filteredNotify[index]),
                              ));
                  })),
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)),
                    ),
                    color: Colors.white.withOpacity(0.95),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  bool isLoading = false;
  Widget buildItem(BuildContext context, Notify note) {
    return note.title != 'hide'
        ? Container(
            color: !note.seen ? Colors.blue[50] : Colors.blueGrey[50],
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Center(
                            child: Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                note.title,
                                style: TextStyle(
                                    color: Colors.pink[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                              alignment: Alignment.center,
                              // margin:
                              //   EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 5),
                            ),
                            Text(
                              note.body,
                              // textDirection: TextDirection.rtl,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            )
                          ],
                        )),
                      ],
                    ),
                    //  margin: EdgeInsets.only(left: 10.0),
                  ),
                )
              ],
            ),
            // onPressed: () {},
            // padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
            // shape: RoundedRectangleBorder(
            //  borderRadius: BorderRadius.circular(10.0)),

            // margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
          )
        : Container();
  }

  void _removeNote(String key) {
    databaseReference.child(key).remove();
  }

  void _onItemEntryAdded(Event event) {
    notifyData.add(Notify.fromSnapshot(event.snapshot));
    setState(() {});
  }

  void _onItemEntryDeleted(Event event) {
    Notify note = notifyData.firstWhere((f) => f.key == event.snapshot.key);
    setState(() {
      notifyData.remove(notifyData[notifyData.indexOf(note)]);
    });
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = notifyData.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      notifyData[notifyData.indexOf(oldEntry)] =
          Notify.fromSnapshot(event.snapshot);
    });
  }

  void reloadDismissed() {
    isLoading = true;
    Duration wait = Duration(milliseconds: 800);
    Timer(wait, () async {
      isLoading = false;
    });
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
