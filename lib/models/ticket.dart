import 'package:firebase_database/firebase_database.dart';

class Ticket {
  String key;
  var id;
  String ticketId;
  String type;
  var user;
  bool open;
  bool inUse;
  String member;
  String openDate;
  String closeDate;
  String docId;
  String content;
  int fromClient;
  int fromSupport;
  List items;

  Ticket(
      {this.id,
      this.ticketId,
      this.type,
      this.user,
      this.open,
      this.inUse,
      this.member,
      this.openDate,
      this.closeDate,
      this.docId,
      this.content,
      this.fromClient,
      this.fromSupport,
      this.items});

  Ticket.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        id = snapshot.value['id'],
        ticketId = snapshot.value['ticketId'],
        type = snapshot.value['type'],
        user = snapshot.value['user'],
        open = snapshot.value['open'],
        inUse = snapshot.value['inUse'] ?? false,
        fromClient = snapshot.value['fromClient'] ?? 0,
        fromSupport = snapshot.value['fromSupport'] ?? 0,
        member = snapshot.value['member'],
        openDate = snapshot.value['openDate'],
        closeDate = snapshot.value['closeDate'],
        docId = snapshot.value['docId'] ?? "",
        content = snapshot.value['content'] ?? "",
        items = snapshot.value['items'] ?? [];

  factory Ticket.fromJson(Map<dynamic, dynamic> json) {
    return Ticket(
      id: json['id'],
      ticketId: json['ticketId'],
      type: json['type'],
      user: json['user'],
      open: json['open'],
      inUse: json['inUse'] ?? false,
      fromClient: json['fromClient'] ?? 0,
      fromSupport: json['fromSupport'] ?? 0,
      member: json['member'],
      openDate: json['openDate'],
      closeDate: json['closeDate'],
      docId: json['docId'] ?? "",
      content: json['content'] ?? "",
      items: json['items'] ?? [],
    );
  }
}

class Notify {
  String key;
  String title;
  String image;
  String body;
  bool seen;

  Notify({this.key, this.body, this.image, this.title, this.seen});

  Notify.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        body = snapshot.value['body'],
        image = snapshot.value['image'],
        title = snapshot.value['title'],
        seen = snapshot.value['seen'];

  factory Notify.fromJson(Map<dynamic, dynamic> json) {
    return Notify(
        body: json['body'],
        image: json['image'],
        seen: json['seen'],
        title: json['title']);
  }
  toJson() {
    return {
      "body": body,
      "title": title,
      "image": image,
      "seen": seen,
    };
  }
}

class TicketType {
  String typeId;
  String ticketType;
  bool docBased;
  String docProblem;

  TicketType({this.typeId, this.ticketType, this.docBased, this.docProblem});

  factory TicketType.toJosn(Map<dynamic, dynamic> list) {
    return TicketType(
        ticketType: list['ticketType'],
        typeId: list['typeId'],
        docBased: list['docBased'],
        docProblem: list['docProblem']);
  }

  TicketType.fromSnapshot(DataSnapshot snapshot)
      : typeId = snapshot.value['typeId'],
        ticketType = snapshot.value['ticketType'];
}

class TicketDoc {
  String docId;
  String docDate;
  String retrunDoc;
  var totalVal;

  TicketDoc({this.docId, this.docDate, this.retrunDoc, this.totalVal});

  factory TicketDoc.toJson(Map<dynamic, dynamic> doc) {
    return TicketDoc(
        docId: doc['DOC_ID'],
        docDate: doc['DOC_DATE'],
        retrunDoc: doc['RETURNDOC'],
        totalVal: doc['TOTAL_VAL']);
  }
}

class TicketItem {
  String itemId;
  var qty;
  int dmQty;

  TicketItem({this.itemId, this.qty, this.dmQty = 1});

  factory TicketItem.toJson(Map<dynamic, dynamic> item) {
    return TicketItem(itemId: item['ITEM_ID'], qty: item['QTY']);
  }
}
