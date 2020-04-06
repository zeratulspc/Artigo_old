import 'package:flutter/material.dart';
import 'package:flutter/services.dart' ;
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/page/basicDialogs.dart';

class EditPost extends StatefulWidget {
  final int postCase; // 1: POST 2: EDIT
  final User uploader;
  final FirebaseUser currentUser;
  EditPost({this.postCase, this.uploader, this.currentUser}); // 1: POST 2: EDIT


  @override
  EditPostState createState() => EditPostState();
}

class EditPostState extends State<EditPost> {
  BasicDialogs basicDialogs = BasicDialogs();
  PostDBFNC postDBFNC = PostDBFNC();
  TextEditingController textEditingController = TextEditingController();
  List<Attach> initialPhoto = List(); // 업로드 되지 않은 사진
  List<Widget> photoItems = List();
  int maxLine = 8;
  bool showPostButton = false;
  bool notNull(Object o) => o != null;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
    if(this.mounted){
      textEditingController.addListener(() {
        if(this.mounted){ //TODO text field 길이 문제
          setState(() {
            if(textEditingController.text.length / 30 >= maxLine) { //TODO MaxLine 알고리즘 테스트
              print(maxLine);
              maxLine++; //TODO 사용자가 의미 없이 Line 을 늘릴 때 (엔터 칠 때) 는 maxLine 이 늘어나지 않음
            }
            if(textEditingController.text.length >= 1) {
              showPostButton = true;
            } else {
              showPostButton = false;
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
    super.dispose();
    textEditingController.dispose();
  }

  List<StaggeredTile> tileForm(int imageCount) {
    switch(imageCount){
      case 1:
        return [
          StaggeredTile.count(3, 2),
        ];
      break;
      case 2:
        return [
          StaggeredTile.count(3, 1),
          StaggeredTile.count(3, 1),
        ];
        break;
      case 3:
        return [
          StaggeredTile.count(2, 2),
          StaggeredTile.count(1, 1),
          StaggeredTile.count(1, 1),
        ];
        break;
      default:
        if(imageCount >= 3) {
          return [
            StaggeredTile.count(2, 2),
            StaggeredTile.count(1, 1),
            StaggeredTile.count(1, 1),
          ];
        } else {
          return [
            StaggeredTile.count(3, 2),
          ];
        }
        break;
    }
  }

  pickImage(BuildContext context) async {
    var tempImage = await ImagePicker.pickImage(
      source: ImageSource.gallery,);
    print(tempImage.path);
    if(await tempImage.exists()) {
      setState(() {
        initialPhoto.add(Attach(
          tempPhoto: tempImage,
          uploaderUID: widget.currentUser.uid,
          uploadDate: DateTime.now().toIso8601String(),
        ));
        photoItems.clear();
        generateItems(initialPhoto.length);
      });
    } else {
      basicDialogs.dialogWithYes(context, "불러오기 실패", "불러오기에 실패했습니다.");
    }
  }

  generateItems(int widgetLength) { //TODO 사진 삭제
    List<Widget> tempItems = List<Widget>.generate(widgetLength, (index){
      if(initialPhoto[index].tempPhoto != null) {
        return Container( //TODO 사진 디스크립션
          child: Image.file(
            initialPhoto[index].tempPhoto,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Container( //TODO 사진 디테일 페이지 만들기
          child: Image.network(
            initialPhoto[index].filePath,
            fit: BoxFit.cover,
          ),
        );
      }
    });
    setState(() {
      photoItems.addAll(tempItems);
    });
  }

  uploadPost() async {
    basicDialogs.showLoading(context, "게시글 업로드 중");
    String key = await postDBFNC.createPost(Post(
        body: textEditingController.text,
        uploaderUID: widget.currentUser.uid,
        uploadDate: DateTime.now().toIso8601String(),
        isEdited: false,
      )
    );
    if(key != null) { // post 가 정상적으로 업로드 되었는지 확인
      for(int i = 0;i < initialPhoto.length; i++) {
        await postDBFNC.addPhoto(initialPhoto[i], key, i);
      }
      Navigator.pop(context); // 로딩 다이알로그 pop
      Navigator.pop(context); // 페이지 pop
    } else {
      Navigator.pop(context);
      basicDialogs.dialogWithYes(context, "오류 발생", "게시글이 정상적으로 업로드 되지 않았습니다.");
    }

  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black87),
        backgroundColor: Colors.white,
        title: Text(
          "${widget.postCase == 1 ? "게시글 작성" : "게시글 수정"}",
          style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Center(
                child: Text("게시", style: TextStyle(
                    color: showPostButton ? Colors.black : Colors.grey[500]),),
              ),
              onTap: showPostButton ? uploadPost : null,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        focusColor: Colors.green[400],
        splashColor: Theme.of(context).accentColor,
        child: Icon(Icons.photo, color: Colors.white,),
        onPressed: (){
          pickImage(context);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.only(top: 3.0, left: 15, right: 15),
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
                      widget.uploader.profileImageURL != null ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Image.network(
                          widget.uploader.profileImageURL,
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.uploader.userName??"", maxLines: 1,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: screenSize.width,
              child: TextField(
                controller: textEditingController,
                maxLines: maxLine,
                cursorColor: Theme.of(context).primaryColor,
                style: TextStyle(
                    fontSize: 18
                ),
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "무슨 일이 일어나고 있나요?",
                  border: InputBorder.none,
                ),
              ),
            ),
            initialPhoto.length != 0 ? Container(
              width: screenSize.width,
              height: screenSize.height/2.75,
              margin: EdgeInsets.symmetric(vertical: 20),
              child: StaggeredGridView.count(
                padding: EdgeInsets.all(0),
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                staggeredTiles:tileForm(initialPhoto.length),
                children: photoItems,
              ),
            ) : null,
          ].where(notNull).toList(),
        )
      ),
    );
  }
}