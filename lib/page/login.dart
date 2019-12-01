import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Form(
              key: loginKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //TODO 텍스트필드 디자인
                    TextFormField(),
                    TextFormField(),
                    //TODO 로그인, 회원가입 FNC
                    RaisedButton(
                      child: Text("로그인"),
                      onPressed: null,
                    ),
                    RaisedButton(
                      child: Text("회원가입"),
                      onPressed: null,
                    )
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}
