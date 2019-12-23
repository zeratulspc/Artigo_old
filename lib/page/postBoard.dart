import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import 'package:nextor/page/postList.dart';

class PostBoard extends StatefulWidget {
  @override
  _PostBoardState createState() => _PostBoardState();
}

class _PostBoardState extends State<PostBoard> {
  //TODO postBoard Design
  //TODO postBoard FNC
  List<String> boardList = ["일반 게시판", "인기 게시판", "Flutter 게시판", "Arduino 게시판", "공지 게시판", "F&A게시판"];

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 20),
          itemCount: boardList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              child: Container(
                height: 200,
                child: FlatButton(
                  onPressed: () {
                    print(boardList[index]);
                    Navigator.push(
                      context,
                      PageTransition(type: PageTransitionType.leftToRight, child: PostList(
                      boardName: boardList[index],)) //TODO BOARD NAME),
                    );
                  },
                  child: Center(
                    child: Text(boardList[index]),
                  ),
                )
              ),
            );
          },
        ),
      )
    );
  }
}

