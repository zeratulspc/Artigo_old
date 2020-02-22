import 'package:flutter/material.dart';

import 'package:nextor/page/home.dart';
import 'package:nextor/page/auth/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  bool _bigger = true;

  // 애니메이션 강좌 : https://youtu.be/KEUKRT9Xsls
  AnimationController buttonAnimationController;
  Animation<double> buttonAnimation;
  CurvedAnimation curvedAnimation;


  final loginKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, //TODO 계산기 앱에서 쓰던 그라디언트 그대로 적용할 것( 동적 그라디언트 )
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedContainer(
                width: _bigger ? 150 : 100, // 기본값 = 150, 에니메이션 실행시 100으로.
                child: Image.asset(
                  'assets/ver3.png',
                  width: screenSize.width - 250,
                ),
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut,
              ),
              AnimatedSwitcher(
                duration: Duration(seconds: 1),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(child: child, opacity: animation,);
                },
                child: _bigger ? selectButtons() : loginCard(screenSize),
              )
            ],
          ),
        )
    );
  }

  Widget loginCard(Size screenSize) {
    return Card(
      elevation: 10.0,
      child: Container(
        width: screenSize.width / 1.4,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(),
            TextField(),
            RaisedButton(
              elevation: 0,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(color: Theme.of(context).accentColor),
              ),
              child: Text("로그인", style: TextStyle(color: Colors.white, fontSize: 16),),
              onPressed: () {
                setState(() {
                  _bigger = !_bigger;
                  print(_bigger);
                });
              },
            ),
          ],
        ),
      )
    );
  }

  Widget selectButtons() {
    return Column(
      children: <Widget>[
        Container(
          width: 250,
          height: 35,
          child: RaisedButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Theme.of(context).accentColor),
            ),
            child: Text("로그인", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),),
            onPressed: () {
              setState(() {
                _bigger = !_bigger;
                print(_bigger);
              });
              //TODO 로그인 card 팝업
            },
          ),
        ),
        FlatButton(
          child: Text("회원가입", style: TextStyle(color: Colors.white, fontSize: 16)),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () {
            //TODO 회원가입 card 팝업
          },
        )
      ],
    );
  }
}
