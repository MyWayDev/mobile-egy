import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:mor_release/account/new_member.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/items/items.tabs.dart';
import 'package:mor_release/pages/messages/tickets.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

import 'account/report.tabs.dart';

class BottomNav extends StatefulWidget {
  final String user;
  BottomNav(this.user);
  @override
  State<StatefulWidget> createState() {
    return _BottomNav();
  }
}

// SingleTickerProviderStateMixin is used for animation
class _BottomNav extends State<BottomNav> with SingleTickerProviderStateMixin {
  // Create a tab controller
  TabController tabController;
  Query query;
  var subAdd;
  var subChanged;
  var subDel;
  List<Ticket> _msgsList = List();
  String path = "flamelink/environments/egyProduction/content/support/en-US/";
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference databaseReference;

  int _msgCount = 0;
  @override
  void initState() {
    databaseReference = database.reference().child(path);
    int.parse(widget.user) >= 6
        ? query = databaseReference
            .child('/')
            .orderByChild('user')
            .equalTo(widget.user.toString())
        : query = databaseReference.child("/");

    subAdd = query.onChildAdded.listen(_onMessageEntryAdded);
    subChanged = query.onChildChanged.listen(_onItemEntryChanged);
    super.initState();

//! add admin conditions here for 1 to 5 users..

    // Initialize the Tab Controller
    tabController = new TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    subAdd?.cancel();
    subChanged?.cancel();
    subDel?.cancel();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        // Appbar
        /*appBar: new AppBar(
        // Title
        title: new Text("Using Bottom Navigation Bar"),
        // Set the background color of the App Bar
        backgroundColor: Colors.blue,
      ),*/
        // Set the TabBar view as the body of the Scaffold

        body: TabBarView(
          // Add tabs as widgets
          children: <Widget>[
            ItemsTabs(),
            NewMemberPage(),
            Tickets(
              distrId: int.parse(model.user.key),
            ),
            ReportTabs()
            //Report(model.user.distrId),
            //  Cat(pdfUrl: model.settings.pdfUrl)
          ],

          // set the controller
          controller: tabController,
        ),
        // Set the bottom navigation bar
        bottomNavigationBar: Material(
          // set the color of the bottom navigation bar
          color: Colors.transparent,
          elevation: 20,

          // set the tab bar as the child of bottom navigation bar
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 4,
            indicatorColor: Colors.pink[700],
            tabs: <Tab>[
              Tab(
                // set icon to the tab
                icon: Icon(
                  Icons.home,
                  size: 32,
                  color: Colors.pink[700],
                ),
              ),
              Tab(
                icon: Icon(GroovinMaterialIcons.account_plus,
                    size: 32, color: Colors.pink[700]),
              ),
              Tab(
                  child: BadgeIconButton(
                itemCount: _msgCount > 0 ? _msgCount : 0,
                badgeColor: Colors.deepPurple[300],
                badgeTextColor: Colors.white,
                icon: Icon(
                  Icons.forum,
                  size: 32.0,
                  color: Colors.pink[700],
                ),
              )),
              Tab(
                icon: Icon(GroovinMaterialIcons.book_open,
                    size: 32, color: Colors.pink[700]),
              ),
            ],
            // setup the controller
            controller: tabController,
          ),
        ),
      );
    });
  }

  void _onMessageEntryAdded(Event event) {
    _msgsList.add(Ticket.fromSnapshot(event.snapshot));

    setState(() {});
    _msgSnapshotCount(widget.user);
  }

  void _onItemEntryChanged(Event event) {
    var oldEntry = _msgsList.lastWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _msgsList[_msgsList.indexOf(oldEntry)] =
          Ticket.fromSnapshot(event.snapshot);
      _msgSnapshotCount(widget.user);
    });
  }

  void _msgSnapshotCount(String user) {
    _msgCount = 0;
    if (int.parse(user) > 6) {
      _msgsList.forEach((f) => _msgCount += f.fromSupport);
      print('msgs listener on:$_msgCount');
    } else {
      _msgsList.forEach((f) => _msgCount += f.fromClient);
      print('msgs listener on:$_msgCount');
    }
  }
}

class Msgs {
  String key;
  int fromClient;
  int fromSupport;
  Msgs({
    this.key,
    this.fromClient,
    this.fromSupport,
  });
  Msgs.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        fromClient = snapshot.value['fromClient'],
        fromSupport = snapshot.value['fromSupport'];
}
