import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:intl/intl.dart' as prefix0;
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/const.dart';
import 'package:mor_release/pages/messages/chat.dart';
import 'package:mor_release/pages/messages/forms/ticketSelect.dart';

class Tickets extends StatefulWidget {
  final int distrId;
  Tickets({@required this.distrId});

  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  List<Ticket> ticketsData = List();
  List<Ticket> filteredTickets = [];
  List<TicketType> types = [];
  ChatScreen msgs;

  String path = "flamelink/environments/egyStage/content/support/en-US";

  FirebaseDatabase database = FirebaseDatabase.instance;

  DatabaseReference databaseReference;
  Query query;
  var subAdd;
  var subChanged;
  var subDel;
  //var subSelect;
  List<DropdownMenuItem> items = [];

  String selectedValue;
  bool isSwitched = true;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    getTicketTypes();

    databaseReference = database.reference().child(path);
    widget.distrId >= 5
        ? query = databaseReference
            .child('/')
            .orderByChild('user')
            .equalTo(widget.distrId.toString())
        : query = databaseReference.child("/");
    subAdd = query.onChildAdded.listen(_onItemEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);
    subDel = query.onChildRemoved.listen(_onItemEntryDeleted);

    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncInputDialog(context);
    });*/
    super.initState();
  }

  @override
  void dispose() {
    subAdd?.cancel();
    subChanged?.cancel();
    subDel?.cancel();
    // subSelect?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    filteredTickets = ticketsData.reversed
        .where((o) =>
            o.open == true ||
            closeDate(o.closeDate) == DateTime.now().month ||
            o.closeDate.toString() == '01/01/1900')
        .toList();
    // filteredTickets
    // ..sort((a, b) => a.open.toString().compareTo(b.open.toString()));

    return Scaffold(
      floatingActionButton: widget.distrId > 5
          ? FloatingActionButton(
              onPressed: () {
                _asyncInputDialog(context);
              },
              child: Icon(
                Icons.add_comment,
                size: 28,
              ),
              backgroundColor: Colors.pink[600],
            )
          : null,
      floatingActionButtonLocation:
          widget.distrId > 5 ? FloatingActionButtonLocation.endDocked : null,
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Stack(
          children: <Widget>[
            Container(
                child: ListView.builder(
              padding: EdgeInsets.all(5),
              itemBuilder: (context, index) {
                return Card(
                  color: !filteredTickets[index].open
                      ? Colors.greenAccent[100]
                      : Colors.pink[100],
                  child: Column(
                    children: <Widget>[
                      ListTile(
                          leading: Icon(
                            Icons.vpn_key,
                            size: 21,
                            color: Colors.pink[900],
                          ),
                          title: Text(
                            filteredTickets[index].member,
                            style: TextStyle(fontSize: 14),
                          ),
                          subtitle: Row(
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                size: 21,
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 5),
                              ),
                              Text(
                                prefix0.DateFormat("H:mm").format(
                                    DateTime.parse(
                                        filteredTickets[index].openDate)),
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 6),
                              ),
                              Text(
                                prefix0.DateFormat("dd-MM-yyy").format(
                                    DateTime.parse(
                                        filteredTickets[index].openDate)),
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          )),
                      ExpansionTile(
                        leading: widget.distrId <= 5
                            ? ConstrainedBox(
                                constraints: BoxConstraints.tight(Size(45, 40)),
                                child: Switch(
                                  value: filteredTickets[index].open,
                                  onChanged: (value) {
                                    _closeTicket(
                                        filteredTickets[index].key, value);
                                    /* setState(() {
                                  filteredTickets[index].open = value;
                                });*/
                                  },
                                  activeTrackColor: Colors.white,
                                  activeColor: Colors.pink[700],
                                  inactiveThumbColor: Colors.grey,
                                ),
                              )
                            : Icon(
                                Icons.add_comment,
                              ),
                        backgroundColor: !filteredTickets[index].open
                            ? Colors.greenAccent[100]
                            : Colors.pink[100],
                        key: PageStorageKey<Ticket>(filteredTickets[index]),
                        title: buildItem(context, filteredTickets[index]),
                        children: <Widget>[
                          buildTicketInfo(context, filteredTickets[index]),
                        ],
                      )
                    ],
                  ),
                );
              },
              itemCount: filteredTickets.length,
            )),
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(themeColor)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }

  bool isLoading = false;
  Widget buildItem(BuildContext context, Ticket ticket) {
    if (widget.distrId <= 6) {
      return !ticket.inUse
          ? Container(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(12.0)),
                splashColor: Colors.yellowAccent,
                color: !ticket.open ? Colors.green[50] : Colors.pink[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Column(
                                children: <Widget>[
                                  Text(
                                    ticket.id.toString(),
                                    softWrap: true,
                                    style: TextStyle(
                                        color: Colors.pink[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  Text(
                                    ticket.type,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  ticket.fromClient != 0
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.pink[900],
                                                    blurRadius: 10.0,
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                border: Border.all(
                                                  width: 3.0,
                                                  color: Colors.deepPurple[300],
                                                ),
                                                color: Colors.deepPurple[300],
                                                // shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                ticket.fromClient.toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // Text(ticket.fromSupport.toString())
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                        // margin: EdgeInsets.only(left: 18.0),
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  databaseReference
                      .child(ticket.ticketId)
                      .update({'inUse': true});
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                                inUse: true,
                                isOpen: ticket.open,
                                type: ticket.type,
                                content: ticket.content,
                                peerId: int.parse(ticket.member),
                                peerAvatar:
                                    "https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1568595588253_account-img.png?alt=media&token=3d4fa5c4-5099-49ac-b621-96b5ea4cd5bd",
                                ticketId: ticket.id,
                              )));
                },
                //padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                //  shape:
                //    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              //   margin: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
            )
          : Container(child: Center(child: MyBlinkingButton()));
    } else {
      return ticket.user == widget.distrId.toString()
          ? Container(
              child: RaisedButton(
                padding: EdgeInsets.all(7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                splashColor: Colors.yellowAccent,
                color: !ticket.open ? Colors.green[50] : Colors.pink[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Text(
                                '${ticket.id}',
                                style: TextStyle(
                                    color: Colors.pink[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                              //   alignment: Alignment.centerLeft,
                              //   margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                            ),
                            Text(ticket.type),
                            ticket.fromSupport != 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.pink[900],
                                              blurRadius: 10.0,
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          border: Border.all(
                                            width: 3.0,
                                            color: Colors.deepPurple[300],
                                          ),
                                          color: Colors.deepPurple[300],
                                          // shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          ticket.fromSupport.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Text(ticket.fromSupport.toString())
                                    ],
                                  )
                                : Container()
                          ],
                        ),
                        //  margin: EdgeInsets.only(left: 15.0),
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                                isOpen: ticket.open,
                                type: ticket.type,
                                content: ticket.content,
                                peerId: 1,
                                peerAvatar:
                                    "https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/flamelink%2Fmedia%2F1568468553357_myway.png?alt=media&token=bd51c423-9967-4075-bb8b-3f2fbee1e9dd",
                                ticketId: ticket.id,
                              )));
                },
                // padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                ////   borderRadius: BorderRadius.circular(10.0)),
              ),
              //  margin: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
            )
          : Container();
    }
  }

  int closeDate(String closeDate) {
    if (closeDate == '' || closeDate == null) {
      DateTime date = new DateTime(2000);
      closeDate = date.toString();
    }
    var date = DateTime.parse(closeDate);

    return date.month;
  }

  void _onItemEntryAdded(Event event) {
    ticketsData.add(Ticket.fromSnapshot(event.snapshot));

    setState(() {});
  }

  void _onItemEntryDeleted(Event event) {
    Ticket tick =
        ticketsData.firstWhere((f) => f.id == event.snapshot.value['id']);

    setState(() {
      ticketsData.remove(ticketsData[ticketsData.indexOf(tick)]);
    });
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = ticketsData.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      ticketsData[ticketsData.indexOf(oldEntry)] =
          Ticket.fromSnapshot(event.snapshot);
    });
  }

  getTicketTypes() async {
    DataSnapshot snapshot = await database
        .reference()
        .child('flamelink/environments/egyStage/content/ticketType/en-US/')
        .once();
    Map<dynamic, dynamic> typeList = snapshot.value;
    List list = typeList.values.toList();
    types = list.map((f) => TicketType.toJosn(f)).toList();
  }

  //void _onData(Event event) {}

  _asyncInputDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return TicketSelect(types, widget.distrId.toString().padLeft(8, '0'));
      },
    );
  }

  Widget buildTicketInfo(BuildContext context, Ticket ticket) {
    return ExpansionTile(
      key: PageStorageKey<Ticket>(ticket),
      backgroundColor:
          !ticket.open ? Colors.greenAccent[100] : Colors.pink[100],
      leading: Icon(GroovinMaterialIcons.file),
      title: Column(
        children: <Widget>[
          Text(
            ticket.docId ?? "",
            style: TextStyle(color: Colors.pink[900], fontSize: 14),
          ),
          Text(
            ticket.content,
            textDirection: TextDirection.ltr,
            softWrap: true,
            style: TextStyle(fontSize: 14, wordSpacing: 0.1),
          ),
          ticket.items.length != 0
              ? Divider(
                  color: Colors.black,
                )
              : Container(),
          ticket.items.length != 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_downward,
                      size: 18,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                    ),
                    Text(
                      "Daftar barang",
                      style: TextStyle(fontSize: 13),
                    )
                  ],
                )
              : Container()
        ],
      ),
      children: ticket.items.map(_buildTicketItems).toList(),
    );
  }

  Widget _buildTicketItems(item) {
    return ConstrainedBox(
        constraints: BoxConstraints.tight(Size(125, 48)),
        child: ListTile(
            title: Text(
              item['itemId'] ?? "",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            trailing: Container(
              width: 28,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.pink[900],
                shape: BoxShape.circle,
              ),
              child: Text(
                item['qty'] ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )));
  }

  _closeTicket(String key, bool value) {
    databaseReference.child(key).update({'open': value});
  }
}

class MyBlinkingButton extends StatefulWidget {
  @override
  _MyBlinkingButtonState createState() => _MyBlinkingButtonState();
}

class _MyBlinkingButtonState extends State<MyBlinkingButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: Icon(
        Icons.headset_mic,
        size: 40,
        color: Colors.pink[700],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
