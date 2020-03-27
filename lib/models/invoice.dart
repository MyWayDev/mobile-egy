class InvoiceItem {
  String docId;
  String itemId;
  String itemName;
  String flagType;
  var total;
  var itemBp;
  var totalBp;
  var price;
  var qty;

  InvoiceItem(
      {this.docId,
      this.itemId,
      this.itemName,
      this.total,
      this.itemBp,
      this.totalBp,
      this.price,
      this.flagType,
      this.qty});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
        docId: json['DOC_ID'],
        itemId: json['ITEM_ID'],
        itemName: json['ITEM_NAME'] ?? "",
        total: json['NET_TOTAL'] ?? 0.0,
        itemBp: json['ITEM_BP'] ?? 0.0,
        totalBp: json['TOTAL_BP'] ?? 0.0,
        price: json['PRICE'] ?? 0.0,
        flagType: json['FLAG_TYPE'] ?? 'CR',
        qty: json['QTY'] ?? 0.0);
  }
}

class Invoice {
  String docId;
  String docDate;
  String distrId;
  String distrName;
  String shipId;
  String shipFee;
  String status;
  String dlvDate;
  String shipper;
  String counter;
  String refNo;
  String storeId;
  String flagType;
  List<InvoiceItem> invoiceItems;

  DateTime get addDate {
    DateTime _addDate = DateTime.parse(docDate);
    return _addDate;
  }

  double get invocieTotal {
    double _totalPrice = 0;
    for (InvoiceItem i in invoiceItems ?? []) {
      _totalPrice += i.total ?? 0.0;
    }
    return _totalPrice;
  }

  double get invocieBp {
    double _totalBp = 0;
    for (InvoiceItem i in invoiceItems ?? []) {
      _totalBp += i.totalBp ?? 0.0;
    }
    return _totalBp;
  }

  Invoice(
      {this.docId,
      this.docDate,
      this.distrId,
      this.distrName,
      this.shipId,
      this.shipFee = '0.0',
      this.status,
      this.dlvDate,
      this.shipper,
      this.counter,
      this.refNo,
      this.flagType,
      this.storeId,
      this.invoiceItems});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
        docId: json['DOC_ID'],
        docDate: json['DOC_DATE'] ?? '',
        distrId: json['DISTR'] ?? '',
        distrName: json['DISTR_NAME'] ?? '',
        shipId: json['DS_SHIPMENT'] ?? '',
        status: json['SHIPMENT_STATUS'] ?? '',
        shipper: json['COMP_NAME'] ?? '',
        dlvDate: json['DLV_DATE'] ?? '',
        counter: json['COUNTER'] ?? '',
        flagType: json['FLAG_TYPE'] ?? '',
        storeId: json['STORE_ID'] ?? '',
        refNo: json['REF_NO'] ?? '');
  }
}
