import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:masonry_grid/masonry_grid.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(swap: false),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool swap;

  MyHomePage({Key key, this.swap}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _uri = TextEditingController();
  bool flag = false;
  bool swap = false;
  String x = "Nothing To show";
  String y = "Try Entering Valid URL";
  List articles = [];
  int pointer=0;
  Future result(String url, _count) async {
    print(url);
    final http.Response response = await http.post(
      'https://finalyearnlp.herokuapp.com',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'url': url, 'count': _count}),
    );
    if (response.statusCode == 200) {
      setState(() {
        print(json.decode(response.body));
        articles.addAll(json.decode(response.body));

      });
    } else {
      print('beep boop');
    }
  }

  @override
  void initState() {
    swap = widget.swap;
    super.initState();
  }

  int pages = 2;
  @override
  Widget build(BuildContext context) {
    Widget swapWidget;
    if (swap) {
      if (pointer>=articles.length) {
        swapWidget=Center(
            child:SizedBox(

            height: 300.0,
            width: 300.0,
            child:
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue),
                strokeWidth: 5.0)
        ));
      }
      else{
      swapWidget = PageView.builder(
        itemCount: pages,
        onPageChanged: _onPageViewChange,
        controller: PageController(viewportFraction: 0.95),
        itemBuilder: (_, i) {
          return Transform.scale(
              scale: 1,
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Card(
                    shadowColor: Color(0xff58a6ff),
                    color: Color(0xff212121),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(children: <Widget>[
                      Text(
                        articles[pointer]['Title'],
                        style: TextStyle(
                            color: Color(0xff58a6ff),
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                      new Expanded(
                        // flex:2,
                        child: new SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Text(
                              articles[pointer]['Summary'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            )),
                      ),
                    ])),
              ));
        },
      );}
    } else {
      swapWidget = Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: MasonryGrid(
                      column: 2,
                      children: List.generate(10, (i) =>
                          SizedBox(width: 100, height: 100, child: Text("hello")),
                      )))
            ],
          ));
    }

    return new Scaffold(
        backgroundColor: Color(0xff181818),
        appBar: AppBar(
          backgroundColor: Color(0xff212121),
          title: TextField(
            controller: _uri,
            decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.white),
                fillColor: Color(0xff212121),
                hintText: 'Enter URL',
                ),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                // test();
                setState(() {
                  if (!flag) {
                    swap = !swap;
                    flag = true;
                  }
                  articles.clear();
                  pointer=0;
                  result(_uri.text, 'yes');
                  _uri.text="";
                });
              },
              child: Icon(Icons.search),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ),
        body: SafeArea(
          child: swapWidget,
        ));
  }

  void _onPageViewChange(int page) {
    // print("Current Page: " + page.toString());
    int previousPage = page;
    setState(() {
      pointer=page;
    });
    if (page != 0)
      previousPage--;
    else
      previousPage = 2;
    if (pages - 1 == page) {
      setState(() {
        pages++;
      });

      result(articles[page]['nextpage'], '');

    }
    // print("Previous page: $previousPage");
  }
}
