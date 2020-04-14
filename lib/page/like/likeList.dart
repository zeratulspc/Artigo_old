import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/page/like/likeLoading.dart';

class LikeList extends StatefulWidget {
  final String postKey;
  final FirebaseUser currentUser;

  LikeList({@required this.postKey, this.currentUser});
  @override
  LikeListState createState() => LikeListState();
}

class LikeListState extends State<LikeList> {
  PostDBFNC postDBFNC = PostDBFNC();
  AuthDBFNC authDBFNC = AuthDBFNC();

  bool isValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: screenSize.width,
      height: screenSize.height-50,
      child: Stack(
        children: <Widget>[
          Container(
            height: screenSize.height-105,
            child:FirebaseAnimatedList(
              query:  postDBFNC.postDBRef.child(widget.postKey).child("like"),
              sort: (a , b) => DateTime.parse(b.value["date"]).compareTo(DateTime.parse(a.value["date"])),
              itemBuilder: (context, snapshot, animation, index) {
                Like like = Like.fromSnapshot(snapshot);
                return FutureBuilder(
                  future: authDBFNC.getUserInfo(like.userUID),
                  builder: (context, asyncSnapshot) {
                    User uploader = asyncSnapshot.data;
                    DateTime date = DateTime.parse(like.date);
                    if(!asyncSnapshot.hasData) {
                      return LikeSkeleton(
                        animation: animation,
                      ); // loading
                    } else {
                      return ListTile(
                        contentPadding: EdgeInsets.only(top: 3.0, left: 10, right: 15),
                        title: Row(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.grey[400],
                                    )
                                ),
                                uploader.profileImageURL != null ?
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(80),
                                  child: Image.network(
                                    uploader.profileImageURL,
                                    height: 40.0,
                                    width: 40.0,
                                  ),
                                ) : ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.grey[400],
                                    )
                                ),
                              ],
                            ),
                            Container(
                              width: 160,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: InkWell(
                                child: Text(uploader.userName??"", maxLines: 1,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis,),
                                onTap: widget.currentUser.uid == uploader.key ? (){} : (){
                                  //TODO 유저 프로필 페이지로 네비게이트
                                },
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(DateTime.now().day == date.day && DateTime.now().month == date.month && DateTime.now().year == date.year ?
                        "${date.hour} : ${date.minute >= 10 ? date.minute : "0"+date.minute.toString() } 에 좋아요를 누름" : "${date.year}.${date.month}.${date.day} 에 좋아요를 누름",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[800],
                      width: 0.4,
                    ),)
              ),
              padding: EdgeInsets.symmetric(vertical: 5),
              width: screenSize.width,
              child: InkWell(
                child: Container(
                  margin: EdgeInsets.only(left: 15, right: 10, bottom: 10, top: 10),
                  child: Text("좋아요 표시 한 사람들",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                onTap: (){Navigator.pop(context);},
              ),
            ),
          ),
        ],
      ),
    );
  }

}