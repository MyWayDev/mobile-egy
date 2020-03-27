import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:mor_release/scoped/connected.dart';
import 'package:mor_release/widgets/color_loader_2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';

class Cat extends StatefulWidget {
  final String pdfUrl;
  Cat({@required this.pdfUrl});
  @override
  _CatState createState() => new _CatState();
}

class _CatState extends State<Cat> {
  String pathPDF = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    /*
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f.path;

        print(pathPDF);
      });
    });*/
    downloadPdfFile(widget.pdfUrl).then((f) {
      pathPDF = f.path;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<File> downloadPdfFile(String pdfUrl) async {
    final url = pdfUrl;
    final filename = url.substring(url.lastIndexOf("/") + 1);
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/$filename');
    bool exist = false;
    try {
      await file.length().then((len) {
        exist = true;
      });
    } catch (e) {
      print(e);
    }
    if (!exist) {
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
    }
    setState(() => _isLoading = false);
    return file;
  }

  Future<File> createFileOfPdfUrl() async {
    final url = // "http://conorlastowka.com/book/CitationNeededBook-Sample.pdf";
        'https://firebasestorage.googleapis.com/v0/b/mobile-coco.appspot.com/o/Cat%2FMorocco72019-compressed.pdf?alt=media&token=e8990df3-f357-44c7-9c69-228d230235c3';
    final filename = url.substring(url.lastIndexOf("/") + 1);

    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;

    File file = new File('$dir/$filename');
    //print('directory:$dir =>filename:$filename =>file:$file');

    //if (file == baseName()) {}

    await file.writeAsBytes(bytes);
    setState(() => _isLoading = false);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: ColorLoader2(),
          )
        : ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
            return PDFViewerScaffold(
                primary: true,
                appBar: AppBar(
                  centerTitle: true,
                  title: Text("Katalog"),
                  actions: <Widget>[],
                ),
                path: pathPDF);
          });
  }
}
