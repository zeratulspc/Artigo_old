import 'package:flutter/material.dart';

// TODO 회원가입 구현.
// 별도의 관리자 개입이 없는이상 첫 role 은 GUEST 임.
// 회원가입 페이지는 설문조사 항목을 포함하고 있음.

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final loginKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      body: null,
    );
  }
}
