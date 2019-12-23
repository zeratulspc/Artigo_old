import 'package:flutter/material.dart';


class PostList extends StatefulWidget {
  final String boardName;
  PostList({this.boardName});

  @override
  _PostListState createState() => _PostListState(boardName: boardName);
}

class _PostListState extends State<PostList> {
//TODO postList Design
//TODO postList FNC
  final String boardName;
  _PostListState({this.boardName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(boardName),
      ),
      body: ListView.builder(
        
        itemBuilder: ,),
    );
  }
}
