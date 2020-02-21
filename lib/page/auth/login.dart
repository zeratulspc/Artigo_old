import 'package:flutter/material.dart';

import 'package:nextor/page/home.dart';
import 'package:nextor/page/auth/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, //TODO 계산기 앱에서 쓰던 그라디언트 그대로 적용할 것( 동적 그라디언트 )
        body: Form(
          key: loginKey,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/ver3.png',
                  width: screenSize.width - 250,
                ),
                SizedBox(height: screenSize.height / 5),
                Container(
                  width: 250,
                  child: RaisedButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: BorderSide(color: Theme.of(context).accentColor),
                    ),
                    child: Text("로그인", style: TextStyle(color: Theme.of(context).primaryColor),),
                    onPressed: () {
                      //TODO 로그인 card 팝업
                    },
                  ),
                ),
                 FlatButton(
                  child: Text("회원가입", style: TextStyle(color: Colors.white)),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    //TODO 회원가입 card 팝업
                  },
                )
              ],
            ),
          ),
        )
    );
  }
}
