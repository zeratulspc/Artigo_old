import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:Artigo/fnc/emotion.dart';

class EmotionInput extends StatelessWidget {
  final VoidCallback refreshPost;
  final String userUid;
  final String targetUserUid;
  final DatabaseReference emotionRef;

  EmotionInput(this.emotionRef, this.userUid, this.targetUserUid, this.refreshPost);

  void showEmotionPicker (BuildContext context,) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return EmotionInput(emotionRef, userUid, targetUserUid, refreshPost);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double fontSize = 24;
    return Container(
      width: screenSize.width,
      height: screenSize.height/3,
      child: Stack(
        children: <Widget>[
          GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7
              ),
              itemCount: emotion.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    await EmotionDBFNC(emotionDBRef: emotionRef).like(userUid, targetUserUid, emotion[index]);
                    if(refreshPost != null) {
                      refreshPost();
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    child: Center(
                      child: Text(emotion[index],style: TextStyle(fontSize: fontSize),),
                    ),
                  ),
                );
              }
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
                  child: Text("공감하기",
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