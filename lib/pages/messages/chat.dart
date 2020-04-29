import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';

class Chat extends StatelessWidget {
  final int peerId;
  final String peerAvatar;
  final int ticketId;
  final String type;
  final String content;
  final bool isOpen;
  final bool inUse;

  Chat(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.ticketId,
      this.content,
      this.isOpen,
      this.inUse = false,
      this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Flushbar flush = Flushbar(
      messageText: Text(content,
          style: TextStyle(fontSize: 15, color: Colors.limeAccent[100])),
      isDismissible: true,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      mainButton: FlatButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(
          Icons.close,
          color: Colors.red[400],
        ),
      ),
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      title: "Id: ${peerId.toString()}",
      message: content,
      icon: Icon(
        Icons.chat,
        color: Colors.greenAccent,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.red[800],
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
    );
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              type,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.chat),
                onPressed: () {
                  flush.dismiss(context);
                  flush.show(context);
                },
              ),
            ],
          ),
          body: ChatScreen(
            id: int.parse(model.user.key) >= 5 ? model.user.key : '1',
            peerId: peerId,
            supportId: model.user.key,
            peerAvatar: peerAvatar,
            ticketId: ticketId,
            type: type,
            isOpen: isOpen,
            inUse: inUse,
          ));
    });
  }
}

class ChatScreen extends StatefulWidget {
  final int peerId;
  final String supportId;
  final String peerAvatar;
  final String id;
  final int ticketId;
  final String type;
  final bool isOpen;
  final bool inUse;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.id,
    @required this.ticketId,
    @required this.type,
    @required this.isOpen,
    @required this.supportId,
    this.inUse = false,
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
      peerId: peerId,
      peerAvatar: peerAvatar,
      ticketId: ticketId,
      type: type,
      isOpen: isOpen,
      inUse: inUse);
}

class ChatScreenState extends State<ChatScreen> {
  bool isOpen;
  String type;
  int peerId;
  String peerAvatar;
  int ticketId;
  bool inUse;

  ChatScreenState(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.ticketId,
      @required this.type,
      @required this.isOpen,
      this.inUse = false});

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  String path = "flamelink/environments/egyStage/content/messages/en-US/";
  List<Message> _msgList = List();
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;

  var subAdd;
  var subChanged;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  int msgCount;
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal(widget.id);

    // updateSeenCount();
  }

  void updateInUse() {
    DatabaseReference dbUpdateref = FirebaseDatabase.instance.reference();
    dbUpdateref
        .child("flamelink/environments/egyStage/content/support/en-US/")
        .child(ticketId.toString())
        .update({'inUse': false});
  }

  @override
  void dispose() {
    _peerSeenUpdate(
      database.reference().child("$path/$groupChatId/${widget.ticketId}"),
    );

    updateInUse();
    subAdd?.cancel();
    subChanged?.cancel();
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  _peerSeenUpdate(DatabaseReference dbref) {
    _msgList.length != 0
        ? _msgList
            .where((m) => m.idTo == widget.id)
            .forEach((k) => dbref.child(k.key).update({"seen": true}))
        : null;

    updateSeenCount();
  }

  readLocal(String distrId) {
    // prefs = await SharedPreferences.getInstance();
    //prefs.getString('id') ?? '';
    if (widget.id.hashCode <= peerId.toString().hashCode) {
      groupChatId = '${widget.id}-$peerId';
    } else {
      groupChatId = '$peerId-${widget.id}';
    }

    databaseReference =
        database.reference().child("$path/$groupChatId/$ticketId/");
    //
    subAdd = databaseReference.onChildAdded.listen(_onMessageEntryAdded);
    subChanged =
        databaseReference.onChildChanged.listen(_onMessageEntryChanged);
    setState(() {});
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      DatabaseReference myRef = FirebaseDatabase.instance.reference().child(path +
          '/$groupChatId/${widget.ticketId}/${DateTime.now().millisecondsSinceEpoch.toString()}');
      myRef.set({
        'idSupport': widget.supportId,
        'idFrom': widget.id,
        'idTo': peerId.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content,
        'type': type,
        'seen': false
      }).then((f) => updateSeenCount());

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  updateSeenCount() {
    DatabaseReference sumRef = FirebaseDatabase.instance.reference().child(
        'flamelink/environments/egyStage/content/support/en-US/${widget.ticketId}');
    if (int.parse(widget.id) > 6) {
      sumRef.update({
        'fromClient': _nonseenToPeerMsgsCount(),
        'fromSupport': 0,
      });
    } else {
      sumRef.update({
        'fromClient': 0,
        'fromSupport': _nonseenToPeerMsgsCount(),
      });
    }
  }

  int _nonSeenToMeMsgsCount() {
    int count = 0;
    //count = _msgList.where((f) => !f.seen && f.idTo != widget.id).length;

    print(count);
    return count;
  }

  int _nonseenToPeerMsgsCount() {
    int count = 0;
    count = _msgList.where((f) => !f.seen && f.idFrom == widget.id).length;
    print(count);
    return count;
  }

  Widget buildItem(int index, Message msg) {
    if (msg.idFrom == widget.id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          msg.type == 0
              // Text
              ? Container(
                  child: Text(
                    msg.content,
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: greyColor2,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : msg.type == 1
                  // Image
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return ImageDetails(
                            image: msg.content,
                          );
                        }));
                      },
                      child: Container(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'assets/images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: msg.content,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      ),
                    )
                  // Sticker
                  : Container(
                      child: new Image.asset(
                        'assets/images/${msg.content}.gif',
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(themeColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: peerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                msg.type == 0
                    ? Container(
                        child: Text(
                          msg.content,
                          style: TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.pink[800],
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : msg.type == 1
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return ImageDetails(
                                  image: msg.content,
                                );
                              }));
                            },
                            child: Container(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: greyColor2,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'assets/images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: msg.content,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.fill,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              margin: EdgeInsets.only(left: 10.0),
                            ),
                          )
                        : Container(
                            child: Image.asset(
                              'assets/images/${msg.content}.gif',
                              width: 100.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(msg.timeStamp))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom == widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].idFrom != widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(isOpen),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildImage(String image) {
    return Container(
      child: PhotoView(
        imageProvider: NetworkImage(image),
      ),
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'assets/images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'assets/images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'assets/images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'assets/images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'assets/images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'assets/images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'assets/images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'assets/images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'assets/images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput(bool isOpen) {
    return isOpen
        ? Container(
            child: Row(
              children: <Widget>[
                // Button send image
                Material(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.image,
                        size: 28,
                      ),
                      onPressed: getImage,
                      color: Colors.pink[900],
                    ),
                  ),
                  color: Colors.white,
                ),
                /*  Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(
                  Icons.face,
                  size: 28,
                ),
                onPressed: getSticker,
                color: Colors.pink[900],
              ),
            ),
            color: Colors.white,
          ),*/

                // Edit text
                Flexible(
                  child: Container(
                    child: TextField(
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: greyColor),
                      ),
                      focusNode: focusNode,
                    ),
                  ),
                ),

                // Button send message
                Material(
                  child: new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 8.0),
                    child: new IconButton(
                      icon: new Icon(
                        Icons.send,
                        size: 28,
                      ),
                      onPressed: () =>
                          onSendMessage(textEditingController.text, 0),
                      color: Colors.pink[900],
                    ),
                  ),
                  color: Colors.white,
                ),
              ],
            ),
            width: double.infinity,
            height: 50.0,
            decoration: new BoxDecoration(
                border: new Border(
                    top: new BorderSide(color: greyColor2, width: 0.5)),
                color: Colors.white),
          )
        : Container();
  }

  Widget buildListMessage() {
    //TODO: USE ONE LIST IF U CAN;
    listMessage = _msgList;

    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, revereMsgList(_msgList)[index]),
              itemCount: _msgList.length,
              reverse: true,
              controller: listScrollController,
            ),

      /* */
    );
  }

  List<Message> revereMsgList(List<Message> msgs) {
    List<Message> _msgs = [];
    msgs.reversed.forEach((f) => _msgs.add(f));
    // _msgs.forEach((f) => print(f.timeStamp));
    return _msgs;
  }

  void _onMessageEntryAdded(Event event) {
    _msgList.add(Message.fromSnapshot(event.snapshot));

    setState(() {});
    // msgCount = _msgList.where((t) => !t.seen).length;
  }

  void _onMessageEntryChanged(Event event) {
    var oldEntry = _msgList.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _msgList[_msgList.indexOf(oldEntry)] =
          Message.fromSnapshot(event.snapshot);
    });
  }
}

class Message {
  String key;

  String content;
  String idFrom;
  String idTo;
  String timeStamp;
  bool seen;
  int type;

  Message({
    this.key,
    this.content,
    this.idFrom,
    this.idTo,
    this.timeStamp,
    this.seen,
    this.type,
  });

  Message.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        content = snapshot.value['content'],
        idFrom = snapshot.value['idFrom'],
        idTo = snapshot.value['idTo'],
        timeStamp = snapshot.value['timestamp'],
        seen = snapshot.value['seen'],
        type = snapshot.value['type'];

  factory Message.fromList(Map<dynamic, dynamic> list) {
    return Message(
      content: list['content'],
      seen: list['seen'],
      idFrom: list['idFrom'],
      idTo: list['idTo'],
    );
  }

  // Map<dynamic,dynamic> msgsSnapshot =  snapshot.value;
  // List msgs = msgsSnapshot.values.toList();
  //List<Message> msgList = msgsSnapshot.map((m)=>Message.fromSnapShot(m)).toList();
}

class ImageDetails extends StatelessWidget {
  final String image;
  ImageDetails({@required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(image),
      ),
      body: Center(
        child: Hero(
            tag: "",
            child: PhotoView(
              imageProvider: NetworkImage(
                image,
              ),
            )),
      ),
    );
  }
}
