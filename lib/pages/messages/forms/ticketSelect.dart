import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:mor_release/models/ticket.dart';
import 'package:mor_release/pages/messages/forms/ticketDoc.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:scoped_model/scoped_model.dart';

class TicketSelect extends StatefulWidget {
  final List<TicketType> types;
  final String distrId;
  TicketSelect(this.types, this.distrId, {Key key}) : super(key: key);

  _TicketSelectState createState() => _TicketSelectState();
}

class _TicketSelectState extends State<TicketSelect> {
  String type;
  bool isSelected = false;
  void _valueChanged(bool v) {
    setState(() {
      isSelected = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Directionality(
        child: Text('Tipe Dukungan'),
        textDirection: TextDirection.rtl,
      ),
      content: FormBuilder(
        autovalidate: true,
        child: FormBuilderCustomField(
          attribute: "type",
          validators: [
            FormBuilderValidators.required(),
          ],
          formField: FormField(
              // initialValue: [],
              //key: _formKey,
              enabled: true,
              builder: (FormFieldState<dynamic> field) {
                return ScopedModelDescendant<MainModel>(
                  builder:
                      (BuildContext context, Widget child, MainModel model) {
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: DropdownButton(
                        isExpanded: true,
                        items: widget.types.map((option) {
                          return DropdownMenuItem(
                              child: Text("${option.ticketType}"),
                              value: option.ticketType);
                        }).toList(),
                        value: field.value,
                        onChanged: (value) async {
                          field.didChange(value);
                          type = value;
                          _valueChanged(true);
                          print('dropDown value:$value');
                          // int x = types.indexOf(value);
                        },
                      ),
                    );
                  },
                );
              }),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.pink[900],
            size: 34,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        isSelected
            ? IconButton(
                icon: Icon(
                  Icons.done,
                  color: Colors.green,
                  size: 34,
                ),
                onPressed: () async {
                  // print(selectedValue);
                  Navigator.of(context).pop();

                  showDialog(
                      context: context,
                      builder: (_) => DocForm(type, widget.distrId,
                          getDocBase(type), getDocProblem(type)));
                },
              )
            : Container(),
      ],
    );
  }

  bool getDocBase(String value) {
    TicketType _types;
    _types = widget.types.firstWhere((v) => v.ticketType == value);
    int _typeIndex = widget.types.indexOf(_types);
    bool _docBase = widget.types.elementAt(_typeIndex).docBased;
    return _docBase;
  }

  String getDocProblem(String value) {
    print(value);
    TicketType _types;
    _types = widget.types.firstWhere((v) => v.ticketType == value);
    int _typeIndex = widget.types.indexOf(_types);
    String _docProblem = widget.types.elementAt(_typeIndex).docProblem;
    return _docProblem;
  }
}
