import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/comment.dart';
import 'package:nextor/fnc/like.dart';
import 'package:nextor/page/comment/commentItem.dart';
import 'package:nextor/page/comment/commentLoading.dart';
import 'package:nextor/page/basicDialogs.dart';

class CommentList extends StatefulWidget {
  final String postKey;
  final String commentKey;
  final FirebaseUser currentUser;

  CommentList({this.postKey, this.currentUser, this.commentKey});
  @override
  CommentListState createState() => CommentListState();
}

class CommentListState extends State<CommentList> {
  CommentDBFNC commentDBFNC;
  PostDBFNC postDBFNC = PostDBFNC();
  LikeDBFNC likeDBFNC = LikeDBFNC();
  AuthDBFNC authDBFNC = AuthDBFNC();
  BasicDialogs basicDialogs = BasicDialogs();

  TextEditingController commentUpdateController = TextEditingController();
  TextEditingController newCommentController = TextEditingController();

  bool isValid = false;

  @override
  void initState() {
    super.initState();
    if(widget.commentKey == null) {
      commentDBFNC = CommentDBFNC(postKey: widget.postKey);
    } else {
      commentDBFNC = CommentDBFNC(postKey: widget.postKey, commentKey: widget.commentKey);
    }
    newCommentController.addListener((){
      if(newCommentController.text == ""){
        if(this.mounted)
          setState(() {
            isValid = false;
          });
      } else {
        if(this.mounted)
          setState(() {
            isValid = true;
          });
      }
    });
  }

  void commentMoreOptionSheet(context, Comment comment) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _context){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('댓글 수정'),
                    onTap: () {
                      Navigator.pop(context);
                      commentUpdateController.text = comment.body;
                      commentUpdateSheet(context, comment);
                    } //TODO 게시글 수정
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("댓글 삭제"),
                  subtitle: Text("다시 되돌릴 수 없습니다!"),
                  onTap: () {
                    Navigator.pop(context);
                    basicDialogs.dialogWithFunction(
                        context, "댓글 삭제", "댓글을 삭제하시겠습니까?",
                            () {
                          Navigator.pop(context);
                          basicDialogs.showLoading(context, "댓글을 삭제하는 중입니다.");
                          commentDBFNC.deleteComment(comment.key).then((_) => Navigator.pop(context));
                        });
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  void commentUpdateSheet(context, Comment comment) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _context){
          return Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 330,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(),
                      child: TextField(
                        controller: commentUpdateController,
                        cursorColor: Theme.of(context).primaryColor,
                        style: TextStyle(
                            fontSize: 18
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "댓글을 수정합니다.",
                          border: InputBorder.none,
                        ),
                      ),
                    )
                ),
                RaisedButton(
                  elevation: 10,
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    basicDialogs.showLoading(context, "댓글 수정하는 중");
                    comment.body = commentUpdateController.text;
                    commentDBFNC.updateComment(comment).then((_){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 150,
                    child: Center(
                      child: Text("댓글 수정하기", style: TextStyle(color: Colors.white, ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }
    );
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
              query: widget.commentKey == null ?
              postDBFNC.postDBRef.child(widget.postKey).child("comment") :
              postDBFNC.postDBRef.child(widget.postKey).child("comment").child(widget.commentKey).child("reply"),
              sort: (a , b) => DateTime.parse(b.value["uploadDate"]).compareTo(DateTime.parse(a.value["uploadDate"])),
              itemBuilder: (context, snapshot, animation, index) {
                Comment comment = Comment.fromSnapShot(snapshot);
                return FutureBuilder(
                  future: authDBFNC.getUserInfo(comment.uploaderUID),
                  builder: (context, asyncSnapshot) {
                    if(!asyncSnapshot.hasData) {
                      return CommentSkeleton(
                        animation: animation,
                      );
                    } else {
                      return CommentItem(
                        animation: animation,
                        currentUser: widget.currentUser,
                        uploader: asyncSnapshot.data,
                        screenSize: screenSize,
                        moreOption: (){
                          if(widget.currentUser.uid == comment.uploaderUID)
                            commentMoreOptionSheet(context, comment);
                        },
                        likeToComment: (){
                            likeDBFNC.likeToComment(widget.postKey, widget.currentUser.uid, comment.key);
                        },
                        dislikeToComment: (){
                          likeDBFNC.dislikeToComment(widget.postKey, widget.currentUser.uid, comment.key);
                        },
                        replyComment: widget.commentKey == null ? ()=> showModalBottomSheet(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return CommentList(
                              postKey: widget.postKey,
                              commentKey: comment.key,
                              currentUser: widget.currentUser,
                            );
                          },
                        ) : null,
                        item: comment,
                      );
                    }
                  },
                );
              },
            ),
          ),
          KeyboardAvoider(
            child: Align(
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 150) ,
                  child: Row( //TODO 길이 재조정
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 10),
                        width: 50,
                        child: IconButton(
                          icon: Icon(Icons.add_a_photo, size: 24,),
                          onPressed: null,
                        ),
                      ),
                      Container(
                          width: screenSize.width - 140,
                          margin: EdgeInsets.only(right: 10),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(),
                            child: TextFormField(
                              maxLines: null,
                              controller: newCommentController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22.0),
                                    borderSide: BorderSide(color: Colors.transparent)
                                ),
                                fillColor: Colors.grey[300],
                                filled: true,
                                contentPadding: EdgeInsets.fromLTRB(20.0, 5.0, 5.0, 15.0),
                                hintText: "댓글 내용 입력",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22.0),
                                    borderSide: BorderSide(color: Colors.transparent, width: 0)
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22.0),
                                    borderSide: BorderSide(color: Colors.transparent, width: 0)
                                ),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22.0),
                                    borderSide: BorderSide(color: Colors.transparent, width: 0)
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22.0),
                                    borderSide: BorderSide(color: Colors.red, width: 1)
                                ),
                                errorStyle: TextStyle(height: 0, fontSize: 0,),
                              ),
                            ),
                          )
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                          onPressed: isValid ? () {
                            commentDBFNC.createComment(Comment(
                              body: newCommentController.text,
                              uploaderUID: widget.currentUser.uid,
                              uploadDate: DateTime.now().toIso8601String(),
                            )).then((_) => newCommentController.clear());
                          } : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}