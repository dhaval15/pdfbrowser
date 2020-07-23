import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'entries.dart' as Data;
import 'welcome_screen.dart';

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
      home: WelcomeScreen(),
      theme: ThemeData(
        primaryColor: Color(0xFFF38270),
        floatingActionButtonTheme:
            FloatingActionButtonThemeData(backgroundColor: Color(0xFFF38270)),
        appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: Colors.white)),
      ),
    );
  }
}

class PdfList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Indian Patent Act',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  '1',
                  style: Theme.of(context).textTheme.headline6,
                ),
                backgroundColor: Colors.black.withAlpha(72),
              ),
              title: Text(
                Data.titles[0],
                style: Theme.of(context).textTheme.headline5,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PdfPage(
                      entries: Data.entries[0],
                      pdfFile: Data.pdfs[0],
                      offset: Data.offsets[0],
                      title: Data.titles[0],
                    ),
                  ),
                );
              },
            ),
            Divider(height: 24),
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  '2',
                  style: Theme.of(context).textTheme.headline6,
                ),
                backgroundColor: Colors.black.withAlpha(72),
              ),
              title: Text(
                Data.titles[1],
                style: Theme.of(context).textTheme.headline5,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => PdfPage(
                      entries: Data.entries[1],
                      pdfFile: Data.pdfs[1],
                      offset: Data.offsets[1],
                      title: Data.titles[1],
                    ),
                  ),
                );
              },
            ),
          ],
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
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
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
        title: Text(
          'Index',
          style: TextStyle(color: Colors.white),
        ),
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
