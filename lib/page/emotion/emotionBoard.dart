import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:Artigo/page/comment/commentList.dart';
import 'package:Artigo/fnc/emotion.dart';
import 'package:Artigo/fnc/comment.dart';

class EmotionBoard extends StatelessWidget {
  final String postKey;
  final String attachKey;
  final FirebaseUser currentUser;
  final VoidCallback navigateToMyProfile;
  final VoidCallback likeToPost;
  final VoidCallback dislikeToPost;
  final List<Emotion> emotion;
  final List<Comment> comment;

  EmotionBoard({
    this.currentUser,
    this.navigateToMyProfile,
    this.postKey,
    this.attachKey,
    this.emotion,
    this.comment,
    this.dislikeToPost,
    this.likeToPost
  });

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: screenSize.width/2,
          child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(emotion != null ?
                emotion.singleWhere((e) => e.userUID == currentUser.uid, orElse: ()=> null) != null ?//
                Icons.favorite : // 좋아요가 존재할 때
                Icons.insert_emoticon : // 좋아요 목록에 현재 유저 아이디가 없을 때
                Icons.insert_emoticon, // 좋아요 목록이 존재하지 않을 때
                  color: emotion != null ?
                  emotion.singleWhere((e) => e.userUID == currentUser.uid, orElse: ()=> null) != null ?
                  Colors.transparent: // 좋아요가 존재할 때
                  Colors.grey[600] : // 좋아요 목록에 현재 유저 아이디가 없을 때
                  Colors.grey[600], // 좋아요 목록이 존재하지 않을 때
                ),
                SizedBox(width: 5,),
                Text("${
                    emotion != null ?
                    emotion.singleWhere((e) => e.userUID == currentUser.uid, orElse: ()=> null) != null ?
                    emotion[emotion.indexOf(emotion.singleWhere((e) => e.userUID == currentUser.uid, orElse: ()=> null))].emotionCode :
                    "공감하기" :
                    "공감하기"}",
                  style: emotion != null ?
                  emotion.singleWhere((e) => e.userUID == currentUser.uid, orElse: ()=> null) != null ?
                  Theme.of(context).textTheme.headline5 :
                  Theme.of(context).textTheme.subtitle2 :
                  Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
            onPressed: emotion != null ?
            emotion.singleWhere((e) => e.userUID == currentUser.uid, orElse: ()=> null) != null ?
            dislikeToPost : // 좋아요가 존재할 때
            likeToPost : // 좋아요 목록에 현재 유저 아이디가 없을 때
            likeToPost, // 좋아요 목록이 존재하지 않을 때
          ),
        ),
        Container(
          width: screenSize.width/2,
          child: FlatButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.comment, color: Colors.grey[600],),
                SizedBox(width: 5,),
                Text("댓글 달기",style: Theme.of(context).textTheme.subtitle2,)
              ],
            ),
            onPressed: (){
              showModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return CommentList(
                    postKey: postKey,
                    attachKey: attachKey, //TODO Attach comment 가 아닌상황 테스트
                    currentUser: currentUser,
                    navigateToMyProfile: navigateToMyProfile,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}