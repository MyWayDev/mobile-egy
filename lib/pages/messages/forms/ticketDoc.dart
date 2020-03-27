import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:http/http.dart' as http;
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:scoped_model/scoped_model.dart';

class DocForm extends StatefulWidget {
  final String type;
  final String distrId;
  final bool docBase;
  final String docProblem;

  DocForm(this.type, this.distrId, this.docBase, this.docProblem, {Key key})
      : super(key: key);

  _DocFormState createState() => _DocFormState();
}

class _DocFormState extends State<DocForm> {
  final formatter = NumberFormat("#,###");

  bool isDocBased = false;
  bool isItemChips = false;
  bool isComment;
  bool isValid = false;
  bool _isAsync = false;

  List<TicketDoc> docs = [];
  var items = [];

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  // final GlobalKey<FormFieldState> _specifyTextFieldKey = GlobalKey<FormFieldState>();

  Ticket _newTicketData = Ticket(
      id: null,
      ticketId: null,
      type: null,
      user: null,
      member: null,
      open: null,
      openDate: null,
      closeDate: null,
      docId: null,
      content: null,
      items: []);

  @override
  void initState() {
    if (widget.docBase && widget.docProblem != null) {
      isloading(true);

      getTicketDocs(widget.distrId, widget.docProblem).then((d) {
        docs = d;
        setState(() {
          isDocBased = widget.docBase;
          isloading(false);
        });
      });
    }
    setState(() {
      isDocBased = widget.docBase;
      isDocBased ? isComment = false : isComment = true;
      openItemChips(false);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String errorText = 'Entri yang diperlukan';
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      child: SingleChildScrollView(
        primary: true,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          content: FormBuilder(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  Text("${widget.type}"),
                  isDocBased
                      ? FormBuilderCustomField(
                          attribute: "doc",
                          validators: [
                            FormBuilderValidators.required(
                                errorText: errorText),
                          ],
                          formField: FormField(
                              onSaved: (value) {
                                _newTicketData.docId = value;
                              },
                              //initialValue: docs[0].docId,
                              // key: _formKey,
                              enabled: true,
                              builder: (FormFieldState<dynamic> field) {
                                return ScopedModelDescendant<MainModel>(
                                  builder: (BuildContext context, Widget child,
                                      MainModel model) {
                                    return InputDecorator(
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(
                                            top: 2.0, bottom: 0.0),
                                        border: InputBorder.none,
                                        errorText: errorText,
                                      ),
                                      child: DropdownButton(
                                        hint: Center(
                                          child: Text(
                                            "Nomor tagihan",
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        isExpanded: true,
                                        items: docs.map((option) {
                                          return DropdownMenuItem(
                                              child: Center(
                                                child: Text(
                                                  "${option.docId}" +
                                                      "  ("
                                                          '${option.docDate}' +
                                                      ')  ' +
                                                      "${formatter.format(option.totalVal)}" +
                                                      " " +
                                                      "EGP",
                                                  style: TextStyle(
                                                      backgroundColor:
                                                          Colors.yellow[100],
                                                      fontSize: 12.6,
                                                      color: Colors.grey[800],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              value: option.docId);
                                        }).toList(),
                                        value: field.value,
                                        onChanged: (value) {
                                          field.didChange(value);

                                          openItemChips(false);
                                          isloading(true);
                                          widget.docProblem != 'l'
                                              ? getDocItems(value).then((i) {
                                                  items = i;
                                                  isloading(false);
                                                  openItemChips(true);
                                                  setState(() {
                                                    isValid = _formKey
                                                        .currentState
                                                        .validate();
                                                  });
                                                })
                                              : isloading(false);
                                          isComment = true;

                                          print("doc is valued = $isValid");

                                          _newTicketData.docId = value;
                                          // print('docId selected Value:$value');

                                          // int x = types.indexOf(value);
                                        },
                                      ),
                                    );
                                  },
                                );
                              }),
                        )
                      : Container(),
                  isItemChips && widget.docProblem != 'l'
                      ? FormBuilderChipsInput(
                          decoration: InputDecoration(labelText: "Barang"),
                          attribute: 'chips',
                          // readonly: true,
                          validators: [
                            FormBuilderValidators.required(
                                errorText: errorText),
                            //)
                            //FormBuilderValidators.max(150),
                          ],

                          //initialValue: [],
                          maxChips: items.length,

                          onChanged: (value) {
                            setState(() {
                              isValid = _formKey.currentState.validate();
                            });

                            print("chips is valued = $isValid");

                            _newTicketData.items = value;
                          },
                          findSuggestions: (String query) {
                            if (query.length != 0) {
                              var lowercaseQuery = query.toLowerCase();
                              return items.where((profile) {
                                return profile.itemId
                                        .toLowerCase()
                                        .contains(query.toLowerCase()) ||
                                    profile.itemId
                                        .toLowerCase()
                                        .contains(query.toLowerCase());
                              }).toList(growable: false)
                                ..sort((a, b) => a.itemId
                                    .toLowerCase()
                                    .indexOf(lowercaseQuery)
                                    .compareTo(b.itemId
                                        .toLowerCase()
                                        .indexOf(lowercaseQuery)));
                            } else {
                              return const <TicketItem>[];
                            }
                          },

                          chipBuilder: (context, state, profile) {
                            return SingleChildScrollView(
                              child: Flex(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                  Expanded(
                                      // fit: FlexFit.tight,
                                      flex: 1,
                                      child: Container(
                                          height: 45,
                                          width: 200,
                                          child: SizedBox(
                                            height: 200,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              children: <Widget>[
                                                Container(
                                                  width: 210,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      profile.dmQty != 1
                                                          ? GestureDetector(
                                                              child: Icon(
                                                                Icons.remove,
                                                                size: 28,
                                                                color: Colors
                                                                    .red[900],
                                                              ),
                                                              onTap: () => setState(
                                                                  () => profile
                                                                      .dmQty--),
                                                            )
                                                          : Icon(
                                                              Icons.remove,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                      InputChip(
                                                        key: ObjectKey(profile),
                                                        label: Text(
                                                          profile.itemId,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .pink[900],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        avatar: CircleAvatar(
                                                          backgroundColor:
                                                              Colors
                                                                  .yellow[100],
                                                          child: Text(
                                                            profile.dmQty
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        onDeleted: () =>
                                                            state.deleteChip(
                                                                profile),
                                                        materialTapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                      profile.dmQty <
                                                              profile.qty
                                                          ? GestureDetector(
                                                              child: Icon(
                                                                Icons.add,
                                                                size: 28,
                                                                color: Colors
                                                                    .green,
                                                              ),
                                                              onTap: () => setState(
                                                                  () => profile
                                                                      .dmQty++))
                                                          : Icon(
                                                              Icons.add,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )))
                                ],
                              ),
                            );
                          },
                          suggestionBuilder: (context, state, profile) {
                            return SingleChildScrollView(
                              child: ListTile(
                                key: ObjectKey(profile),
                                /* leading: CircleAvatar(
                          backgroundImage: NetworkImage(profile.ticketType),
                        ),*/
                                title: Text(
                                  profile.itemId,
                                  style: TextStyle(
                                      color: Colors.pink[900],
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Container(
                                  child: Text(
                                    "${profile.qty.toInt().toString()}" +
                                        ' ' +
                                        "Jumlah",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                ),
                                onTap: () => state.selectSuggestion(profile),
                              ),
                            );
                          },
                        )
                      : Container(),
                  isComment
                      ? FormBuilderTextField(
                          enableInteractiveSelection: true,
                          expands: false,
                          autocorrect: true,
                          autovalidate: true,
                          maxLengthEnforced: true,
                          maxLines: 4,
                          attribute: "comment",
                          decoration: InputDecoration(
                            labelText: "Komentar",
                            /*border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),*/
                          ),
                          onChanged: (value) {
                            setState(() {
                              isValid = _formKey.currentState.validate();
                            });
                            print("comment is valued = $isValid");
                            _newTicketData.content = value;
                          },

                          //  valueTransformer: (text) => num.tryParse(text),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: errorText),
                            FormBuilderValidators.minLength(3,
                                errorText: errorText),
                            FormBuilderValidators.maxLength(300,
                                errorText: 'Batas masuk tercapai'),
                          ],
                        )
                      : Container(),
                ],
              )),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.pink[900],
                size: 32,
              ),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                //_formKey.currentState.fields['chips'].currentState.reset();
                //openItemChips(false);
                //  _formKey.currentState.fields['chips'].currentState.reset();
                //  _formKey.currentState.fields['doc'].currentState.reset();
                // openItemChips(true);
              },
            ),
            isValid
                ? IconButton(
                    icon: Icon(
                      Icons.done,
                      color: Colors.green,
                      size: 32,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        addDefaultValues();
                        _formKey.currentState.save();

                        /*print("valid form = ${_newTicketData.openDate}}");
                        _newTicketData.items.forEach((i) =>
                            print('${i.qty} to => ${i.itemId}==${i.dmQty}'));*/
                        ticketPushToFirebase(_newTicketData);
                      }

                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  )
                : Container()
          ],
        ),
      ),
      inAsyncCall: _isAsync,
      opacity: 0.0,
      progressIndicator: ColorLoader2(),
    );
  }

  ValueChanged _onChanged = (val) {
    val.forEach((t) => print("${t.itemId} => ${t.dmQty}"));
  };

  void isloading(bool i) {
    setState(() {
      _isAsync = i;
    });
  }

  Future<List<TicketDoc>> getTicketDocs(
      String distrId, String docProblem) async {
    List<TicketDoc> docs = [];
    //List productlist;
    List<dynamic> docList;
    dynamic response;
    if (docProblem == 'm' || docProblem == 'd') {
      response = await http.get(
          'http://mywayegypt-api.azurewebsites.net/api/missingordamageditems/$distrId');
      print('running Missing or damaged invoice: $docProblem');
    } else {
      response = await http.get(
          'http://mywayegypt-api.azurewebsites.net/api/getlateinvoices/$distrId');
      print('running late invoice: $docProblem');
    }
    if (response.statusCode == 200) {
      docList = json.decode(response.body) as List;
    }
    docs = docList
        .map((i) => TicketDoc.toJson(i))
        .where((doc) => doc.retrunDoc == '0' && doc.totalVal > 0)
        .toList();
    //print('docs count :${docs.length}');
    return docs;
  }

  Future<List<TicketItem>> getDocItems(String docId) async {
    List<TicketItem> items = [];
    //List productlist;
    List<dynamic> itemsList;
    dynamic response;

    response = await http.get(
        'http://mywayegypt-api.azurewebsites.net/api/getinvoicedetails/$docId');

    if (response.statusCode == 200) {
      itemsList = json.decode(response.body) as List;
    }
    items = itemsList
        .map((i) => TicketItem.toJson(i))
        .where((i) => i.itemId.length == 4)
        .toList();
    print('items count :${items.length}');
    return items;
  }

  openItemChips(bool o) {
    setState(() {
      isItemChips = o;
      print("isItemChips:$o");
    });
  }

  void addDefaultValues() {
    _newTicketData.type = widget.type;

    _newTicketData.member = widget.distrId;
  }

  void ticketPushToFirebase(Ticket ticket) {
    DatabaseReference ref = FirebaseDatabase.instance
        .reference()
        .child('flamelink/environments/egyProduction/content/support/en-US');
    var myRef = ref.child(DateTime.now().millisecondsSinceEpoch.toString());
    myRef.set({
      "inUse": false,
      "open": true,
      "closeDate": DateTime.now().toString(),
      "content": _newTicketData.content,
      "docId": _newTicketData.docId,
      "id": int.parse(
        myRef.key,
      ),
      "member": _newTicketData.member,
      "openDate": DateTime.now().toString(),
      "ticketId": myRef.key,
      "type": _newTicketData.type,
      "user": int.parse(_newTicketData.member).toString(),
      "items": _newTicketData.items
          .map((f) => {"itemId": f.itemId, "qty": f.dmQty.toString()})
          .toList()
    });
  }
}
