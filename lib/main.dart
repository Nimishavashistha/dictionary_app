import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url = "https://owlbot.info/api/v4/dictionary/";
  String _token = "6b1d93b8ee00a69dd8c0284a5f581cf309a0de79";

  TextEditingController _controller = TextEditingController();

  StreamController _streamController;
  Stream _stream;

  Timer _debounce;

  @override
  void initState() {
    // TODO: implement initState
    _streamController = StreamController();
    _stream = _streamController.stream;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffd2d1dd),

        appBar: AppBar(
          backgroundColor: Color(0xff545273),
          title: Text("Dictionary",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28.0,
            ),),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(200.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: Image.asset("images/dict.png",
                  height: 150.0,
                  width: 200.0,
                  ),
                ),
                Row(
                  children:<Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 16.0, bottom: 14.0, right: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: TextFormField(
                          onChanged: (String text) {
                            if (_debounce?.isActive ?? false) _debounce.cancel();
                            _debounce =
                                Timer(const Duration(milliseconds: 1000), () {
                                  _search();
                                });
                          },
                          controller: _controller,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: Color(0xff545273),
                              ),
                              onPressed: () {
                                _search();
                              },
                            ),
                            hintText: "Search for a word",
                            contentPadding: const EdgeInsets.only(
                                left: 24.0, top: 14.0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ]
                ),

              ],
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(8.0),
          child: StreamBuilder(
            stream: _stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: Text("Type a word to get its meaning 🤔",
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3f3d56),
                    ),),
                );
              }

              if (snapshot.data == "waiting") {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                  itemCount: snapshot.data["definitions"].length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListBody(
                      children: <Widget>[
                        Container(
                          height: 80.0,
                          width: 80.0,
                          child: Card(
                            child: Container(
                              color: Color(0xff545273),
                              child: ListTile(
                                leading: snapshot
                                    .data["definitions"][index]["image_url"] ==
                                    null ? null : CircleAvatar(
                                  backgroundImage: NetworkImage(snapshot
                                      .data["definitions"][index]["image_url"]),
                                ),
                                title: Text(_controller.text.trim() + "(" +
                                    snapshot
                                        .data["definitions"][index]["type"] +
                                    ")",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.white,
                                  ),),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Meaning->  ${snapshot
                              .data["definitions"][index]["definition"]}",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                              color: Color(0xff545273),
                            ),),
                        )
                      ],
                    );
                  }
              );
            },
          ),
        )
    );
  }

  _search() async {
    if (_controller.text == null || _controller.text.length == 0) {
      _streamController.add(null);
      return;
    }
    _streamController.add("waiting");
    Response response = await get(
        _url + _controller.text.trim(), headers: {"Authorization":
    "Token " + _token});
    _streamController.add(json.decode(response.body));
  }



}
