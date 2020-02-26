import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info/package_info.dart';

import 'package:nextor/fnc/preferencesData.dart';
import 'package:nextor/fnc/auth.dart';

import 'package:nextor/page/settings/editProfile.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  AuthDBFNC authDBFNC = AuthDBFNC();
  FirebaseUser currentUser;
  String userName;
  String description;
  String email;
  String userRole;
  String version;

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
                      userRole = data.role;
                      email = data.email;
                    });
                  }
              );
        }
    );
    getVersion().then((data) {
      setState(() {
        version = data;
      });
    });
  }

  Future<String> getVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }

  _logOut(BuildContext context) {
    showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('정말 로그아웃 하시겠습니까?'),
          actions: <Widget>[
            FlatButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
                child: Text('네'),
                onPressed: () {
                  Navigator.of(context).pop();
                  authDBFNC.logout().then((_) {
                    setAutoLogin(false);
                    if(Navigator.canPop(context)) {
                      Navigator.popUntil(
                          context, ModalRoute.withName("/home"));
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  });

                }),
          ],
        );
      },
      context: context,
    );
  }

  removeAccount() {
    showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('정말 계정을 삭제하시겠습니까?'),
          actions: <Widget>[
            FlatButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
                child: Text('네'),
                onPressed: () {
                  Navigator.of(context).pop();
                  authDBFNC.deleteUser(currentUser: currentUser);
                  setAutoLogin(false);
                  if(Navigator.canPop(context)) {
                    Navigator.popUntil(
                        context, ModalRoute.withName("/home"));
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }),
          ],
        );
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: Text("설정", style: TextStyle(color: Colors.black),),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: Text("${userName??"불러오는 중..."} 님의 정보",
              style: TextStyle(fontSize: 18.0,
                  color: Colors.black),),
          ),
          ListTile(
            title: Text("닉네임"),
            trailing: Text("${userName??"없음"}"),
          ),
          ListTile(
            title: Text("한줄소개"),
            trailing: Text("${description??"없음"}"),
          ),
          ListTile(
            title: Text("이메일 주소"),
            trailing: Text("${email??"없음"}"),
          ),
          ListTile(
            title: Text("회원 정보 수정"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
          Divider(color: Colors.grey,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: Text("상태 설정",
              style: TextStyle(fontSize: 18.0,
                  color: Colors.black),),
          ),
          ListTile(
            title: Text("로그아웃"),
            onTap: () {_logOut(context);},
          ),
          ListTile(
            title: Text("탈퇴하기",style: TextStyle(color: Colors.red),),
            subtitle: Text("개인 정보가 모두 삭제됩니다"),
            onTap: () {removeAccount();},
          ),
          Divider(color: Colors.grey,),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: Text("앱 정보",
              style: TextStyle(fontSize: 18.0,
                  color: Colors.black),),
          ),
          ListTile(
            title: Text("버전"),
            trailing: Text("${version??"없음"}"),
          ),
          ListTile(
            title: Text("권한"),
            trailing: Text("${userRole??"없음"}"),
          ),
        ],
      ),
    );
  }
}
