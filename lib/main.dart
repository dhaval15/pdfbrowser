import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'entries.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patent',
      debugShowCheckedModeBanner: false,
      home: PdfPage(),
    );
  }
}

class PdfPage extends StatefulWidget {
  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  PDFDocument document;
  PageController pageController = PageController();
  List<PDFPage> pages;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    try {
      document = await PDFDocument.fromAsset('assets/app.pdf');
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patent'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Go To',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final value = await showDialog(
                  context: context, builder: (context) => AskPage());
              pageController.jumpToPage(value);
            },
          ),
        ],
        elevation: 0,
      ),
      body: document != null
          ? PDFViewer(
              controller: pageController,
              scrollDirection: Axis.vertical,
              document: document,
              showNavigation: false,
              showPicker: false,
              lazyLoad: false,
              showIndicator: false,
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        child: Text('Index'),
        onPressed: () async {
          final value = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => IndexPage()));
          pageController.jumpToPage(value);
        },
      ),
    );
  }
}

class AskPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Page No'),
      contentPadding: EdgeInsets.all(16),
      children: <Widget>[
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
        ),
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop(int.parse(_controller.text) - 1);
          },
        )
      ],
    );
  }
}

class IndexPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Index'),
        elevation: 0,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) => Container(
            color: index % 2 == 0 ? Color(0xFFeeeeee) : null,
            child: ListTile(
              leading: Text(entries[index].number),
              title: Text(entries[index].title),
              onTap: () {
                Navigator.of(context).pop(entries[index].pageNo - 1);
              },
            ),
          ),
        ),
      ),
    );
  }
}

