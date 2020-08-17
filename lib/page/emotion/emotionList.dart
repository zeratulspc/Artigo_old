import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/fnc/postDB.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/fnc/dateTimeParser.dart';
import 'package:Artigo/page/profile/userProfile.dart';

class EmotionList extends StatefulWidget {
  final VoidCallback navigateToMyProfile;
  final String postKey;
  final FirebaseUser currentUser;
  final String attachKey;
  final String commentKey;
  final String replyKey;

  EmotionList({@required this.postKey, @required this.navigateToMyProfile, this.currentUser, this.attachKey, this.commentKey, this.replyKey,});
  @override
  EmotionListState createState() => EmotionListState();
}

class EmotionListState extends State<EmotionList> {
  PostDBFNC postDBFNC = PostDBFNC();
  UserDBFNC authDBFNC = UserDBFNC();

  bool isValid = false;

  DatabaseReference query;

  List<Emotion> emotionList = List();

  @override
  void initState() {
    if(widget.attachKey == null) {
      if(widget.commentKey == null) {
        query = postDBFNC.postDBRef
            .child(widget.postKey)
            .child("emotion"); // Post 좋아요 목록
      } else {
        if(widget.replyKey == null) {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("comment")
              .child(widget.commentKey)
              .child("emotion"); // Post 댓글 좋아요 목록
        } else {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("comment")
              .child(widget.commentKey)
              .child("reply")
              .child(widget.replyKey)
              .child("emotion"); // Post 댓글 답글 좋아요 목록
        }
      }
    } else {
      if(widget.commentKey == null) {
        query = postDBFNC.postDBRef
            .child(widget.postKey)
            .child("attach")
            .child(widget.attachKey)
            .child("emotion"); //Attach 좋아요 목록
      } else {
        if(widget.replyKey == null) {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("attach")
              .child(widget.attachKey)
              .child("comment")
              .child(widget.commentKey)
              .child("emotion"); //Attach 댓글 좋아요 목록
        } else {
          query = postDBFNC.postDBRef
              .child(widget.postKey)
              .child("attach")
              .child(widget.attachKey)
              .child("comment")
              .child(widget.commentKey)
              .child("reply")
              .child(widget.replyKey)
              .child("emotion"); //Attach 댓글 답글 좋아요 목록
        }
      }
    }
    if(query != null) {
      query.onChildAdded.listen(_onEntryAdded);
      query.onChildChanged.listen(_onEntryChanged);
      query.onChildRemoved.listen(_onEntryRemoved);

    }
    super.initState();
  }

  _onEntryAdded(Event event) async {
    if(this.mounted){
      Emotion comment = Emotion.fromSnapshot(event.snapshot);
      comment.uploaderInfo = await UserDBFNC().getUserInfo(comment.userUID);
      setState(() {
        emotionList.insert(0, comment);
        emotionList.sort((a, b){
          DateTime dateA = DateTime.parse(a.date);
          DateTime dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA);
        });
      });
    }
  }

  _onEntryChanged(Event event) async {
    if(this.mounted){
      Emotion comment = Emotion.fromSnapshot(event.snapshot);
      comment.uploaderInfo = await UserDBFNC().getUserInfo(comment.userUID);
      var oldEntry = emotionList.singleWhere((entry) {
        return entry.key == comment.key;
      });
      setState(() {
        emotionList[emotionList.indexOf(oldEntry)] = comment;
      });
    }
  }

  _onEntryRemoved(Event event) {
    if(this.mounted){
      Emotion emotion = Emotion.fromSnapshot(event.snapshot);
      setState(() {
        emotionList.removeWhere((element) =>
        element.key == emotion.key,
        );
      });
    }
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
            child:ListView.builder(
              itemCount: emotionList.length,
              itemBuilder: (context, index) {
                Emotion _emotion = emotionList[index];
                DateTime date = DateTime.parse( _emotion.date);
                return Container(
                  child: InkWell(
                    onTap: widget.currentUser.uid == _emotion.userUID ? (){
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
                            child: UserProfilePage(targetUserUid: _emotion.userUID, navigateToMyProfile: widget.navigateToMyProfile,),
                          );
                        },
                      );
                    },
                    child: ListTile(
                      contentPadding: EdgeInsets.only(top: 3.0, left: 10, right: 15),
                      leading: Stack(
                        children: <Widget>[
                          ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Container(
                                height: 40,
                                width: 40,
                                color: Colors.grey[400],
                              )
                          ),
                          _emotion.uploaderInfo.profileImageURL != null ?
                          ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: Image.network(
                              _emotion.uploaderInfo.profileImageURL,
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
                      title: Container(
                        width: 160,
                        child: Text(_emotion.uploaderInfo.userName??"", maxLines: 1,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis,),
                      ),
                      subtitle: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(_emotion.emotionCode,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                      ),
                      trailing: Text("${DateTimeParser().defaultParse(date)}에 공감",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ),
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
                  child: Text("공감한 사람들",
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