import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final loginKey = GlobalKey<FormState>();
//TODO Home Design
//TODO Home FNC
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      drawer: Drawer(
        child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
      ),
      appBar: AppBar(
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {

            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: WaveClipperOne(),
                    child: Container(color: Theme.of(context).primaryColor,
                      width: screenSize.width,
                      height: 200,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("안녕하세요,",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.0,
                          ),
                        ),
                        Text("김민재!", //TODO USERNAME
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32.0,
                          ),
                        ),
                      ],
                    ),

                  )
                ],
              )
            ],
        ),
      )
    );
  }
}
