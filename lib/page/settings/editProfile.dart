import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nextor/fnc/auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {

  AuthDBFNC authDBFNC = AuthDBFNC();
  FirebaseUser currentUser;
  String userName;
  String description;
  String email;

  //TODO 프로필 사진
  //TODO 커버 사진

  @override
  void initState() {
    super.initState();
    authDBFNC.getUser().then(
            (data) {
          currentUser = data;
          authDBFNC.getUserInfo(currentUser.uid).then(
                  (data) {
                setState(() {
                  userName = data.userName;
                  description = data.description;
                  email = data.email;
                });
              }
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("프로필 수정", style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold),),
              trailing: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Text("수정", style: TextStyle(color: Colors.indigoAccent),),
                onPressed: (){},
              )
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: Center(
                child: Text(userName??"불러오는 중...", style: TextStyle(color: Colors.grey[700]),),
              ),
            ),
            Divider(),
            ListTile(
                title: Text("한줄 소개", style: TextStyle(fontWeight: FontWeight.bold),),
                trailing: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Text("수정", style: TextStyle(color: Colors.indigoAccent),),
                  onPressed: (){},
                )
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: Center(
                child: Text(description??"불러오는 중...", style: TextStyle(color: Colors.grey[700]),),
              ),
            ),
            Divider(),

          ],
        ),
      ),
    );
  }
}