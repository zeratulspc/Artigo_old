import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

import 'package:nextor/fnc/user.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/fnc/dateTimeParser.dart';
import 'package:nextor/page/like/likeLoading.dart';
import 'package:nextor/page/profile/userProfile.dart';

class LikeList extends StatefulWidget {
  final VoidCallback navigateToMyProfile;
  final String postKey;
  final FirebaseUser currentUser;
  final String attachKey;
  final String commentKey;
  final String replyKey;

  LikeList({@required this.postKey, @required this.navigateToMyProfile, this.currentUser, this.attachKey, this.commentKey, this.replyKey,});
  @override
  LikeListState createState() => LikeListState();
}

class LikeListState extends State<LikeList> {
  PostDBFNC postDBFNC = PostDBFNC();
  UserDBFNC authDBFNC = UserDBFNC();

  bool isValid = false;

  DatabaseReference query;

  @override
  void initState() {
    if(widget.attachKey == null) {
      if(widget.commentKey == null) {
        query = postDBFNC.postDBRef
            .child(widget.postKey)
            .child("like"); // Post 좋아요 목록
      } else {
        if(widget.replyKey == null) {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("comment")
              .child(widget.commentKey)
              .child("like"); // Post 댓글 좋아요 목록
        } else {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("comment")
              .child(widget.commentKey)
              .child("reply")
              .child(widget.replyKey)
              .child("like"); // Post 댓글 답글 좋아요 목록
        }
      }
    } else {
      if(widget.commentKey == null) {
        query = postDBFNC.postDBRef
            .child(widget.postKey)
            .child("attach")
            .child(widget.attachKey)
            .child("like"); //Attach 좋아요 목록
      } else {
        if(widget.replyKey == null) {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("attach")
              .child(widget.attachKey)
              .child("comment")
              .child(widget.commentKey)
              .child("like"); //Attach 댓글 좋아요 목록
        } else {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("attach")
              .child(widget.attachKey)
              .child("comment")
              .child(widget.commentKey)
              .child("reply")
              .child(widget.replyKey)
              .child("like"); //Attach 댓글 답글 좋아요 목록
        }
      }
    }
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
              query:  query,
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
                      return Container(
                        child: InkWell(
                          onTap: widget.currentUser.uid == uploader.key ? (){
                            Navigator.popUntil(context, ModalRoute.withName('/home'));
                          } : (){
                            Navigator.popUntil(context, ModalRoute.withName('/home'));
                            showModalBottomSheet(
                              backgroundColor: Colors.grey[300],
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: screenSize.height-50,
                                  child: UserProfilePage(targetUserUid: uploader.key, navigateToMyProfile: widget.navigateToMyProfile,),
                                );
                              },
                            );
                          },
                          child: ListTile(
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
                                  child: Text(uploader.userName??"", maxLines: 1,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis,),
                                ),
                              ],
                            ),
                            trailing: Text("${DateTimeParser().defaultParse(date)}에 좋아요를 누름",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
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