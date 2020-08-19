import 'dart:collection';
import 'package:flutter/material.dart';

import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/user.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  PostDBFNC postDBFNC = PostDBFNC();
  UserDBFNC userDBFNC = UserDBFNC();

  List<Post> posts = List();
  List<User> users = List();
  List<Widget> frontWidgets = List();

  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    postDBFNC.postDBRef.once().then((snapshot) {
      LinkedHashMap<dynamic, dynamic>linkedHashMap = snapshot.value;
      linkedHashMap.forEach((key, value) async {
        Post post = Post().fromLinkedHashMap(value, key);
        User data = await userDBFNC.getUserInfo(post.uploaderUID);
        post.uploader = data;
        posts.add(post);
        setState(() {
          posts.sort((a, b){
            DateTime dateA = DateTime.parse(a.uploadDate);
            DateTime dateB = DateTime.parse(b.uploadDate);
            return dateB.compareTo(dateA);
          });
        });
      });
    });
    userDBFNC.userDBRef.once().then((snapshot){
      LinkedHashMap<dynamic, dynamic>linkedHashMap = snapshot.value;
      linkedHashMap.forEach((key, value) async{
        User user = User().fromLinkedHashMap(value, key); //
        users.add(user);
      });
    });
  }

  searchPost(String keyword) {
    if(posts.length != 0 && users.length != 0) {
      setState(() {

        // 유저 검색
        users.forEach((e) {
          if(e.userName == keyword) {
            // 이 오브젝트를 프론트 위젯에 추가
            // 형태 : TODO 새로 만들기....
            print(e.userName);
          }
        });
        // 게시글 검색
        posts.forEach((e) {
          if(e.body.contains(keyword)) {
            // 이 오브젝트를 프론트 위젯에 추가
            // 향테 : postCard()
            print(e.body);
          }
        });
      });
    } else {
      // 다시 시도해주세요! OR 게시글이 없습니다
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        title: TextField(
          controller: textController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: '궁금한 것을 검색해보세요',
            contentPadding: EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).accentColor),
              borderRadius: BorderRadius.circular(25.7),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(25.7),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(25.7),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.black87,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: (){
              String keyword = textController.value.text;
              if(keyword.length != 0) {
                //검색 진행
                searchPost(keyword);
              } else {
                // 인증실패 신호 보내기
              }
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: frontWidgets.length,
        itemBuilder: (context, index){
          return frontWidgets[index];
        },
      ),
    );
  }
}