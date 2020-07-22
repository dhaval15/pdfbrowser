import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'entries.dart' as Data;

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
      home: PdfList(),
    );
  }
}

class PdfList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents'),
      ),
      body: Container(
        child: ListView.separated(
          separatorBuilder: (context, _) => Divider(),
          itemBuilder: (context, index) => ListTile(
            title: Text(Data.titles[index]),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => PdfPage(
                    entries: Data.entries[index],
                    pdfFile: Data.pdfs[index],
                    offset: Data.offsets[index],
                    title: Data.titles[index],
                  ),
                ),
              );
            },
          ),
          itemCount: Data.titles.length,
        ),
      ),
    );
  }
}

class PdfPage extends StatefulWidget {
  final List<Data.Entry> entries;
  final String pdfFile;
  final int offset;
  final String title;

  const PdfPage({
    Key key,
    this.entries,
    this.pdfFile,
    this.offset,
    this.title,
  }) : super(key: key);
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
      document = await PDFDocument.fromAsset('assets/${widget.pdfFile}');
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Go To',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final value = await showDialog(
                  context: context, builder: (context) => AskPage());
              pageController.jumpToPage(value + widget.offset);
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
          final value = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => IndexPage(
                    entries: widget.entries,
                  )));
          pageController.jumpToPage(value + widget.offset);
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
  final List<Data.Entry> entries;

  const IndexPage({Key key, this.entries}) : super(key: key);
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
