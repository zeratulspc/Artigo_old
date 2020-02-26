import 'package:flutter/material.dart';

import 'package:connectivity/connectivity.dart';

import 'package:nextor/fnc/preferencesData.dart';
import 'package:nextor/fnc/auth.dart';
import 'package:nextor/page/auth/register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {

  // 로그인 관련 변수
  final AuthDBFNC authDBFNC = AuthDBFNC();
  final loginKey = GlobalKey<FormState>();
  String email;
  String password;

  // 로그인 정보 기억 관련 변수, 함수
  bool isAutoLogin;


  void _autoLoginChanged(bool value) {
    setState(() {
      isAutoLogin = value;
    });
    setAutoLogin(value);
  }

  // 로그인 함수
  login(BuildContext context) async {
    final form = loginKey.currentState;
    form.save();
    if(form.validate()) {
      showLoading(context);
      var connectivityResult = await (Connectivity().checkConnectivity()); // 인터넷 연결상태 확인
      if(connectivityResult != ConnectivityResult.none) { // 만약 인터넷 연결상태가 양호하면
        authDBFNC.loginUser(email: email, password: password).then((user) {
          authDBFNC.updateUserRecentLoginDate(uid: user.user.uid, recentLoginDate: DateTime.now().toIso8601String());
              if(isAutoLogin) {
                setEmail(email);
                setPassword(password);
              }
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/home');
            }
        ).catchError((e) {
          Navigator.pop(context);
          _errorDialog(context, e.message, e.code);
        });
      } else { // 만약 인터넷이 연결되지 않으면
        Navigator.pop(context);
        showDialog(
          builder: (context) {
            return AlertDialog(
              title: Text("인터넷 오류"),
              content: Text("인터넷 연결을 확인해 주세요"),
              actions: <Widget>[
                FlatButton(
                    child: Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }
                )
              ],
            );
          },
          context: context,
        );
      }
    }
  }

  Future _errorDialog(BuildContext context, _message, code) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text("로그인 실패"),
          content: Text(authDBFNC.errorKr(code)),
          actions: <Widget>[
            FlatButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                }
            )
          ],
        );
      },
      context: context,
    );
  }

  // 로딩 다이알로그
  void showLoading(BuildContext context) {
    showDialog(context: context,
      barrierDismissible: false,
      builder: (context) => bodyProgress,
    );
  }
  var bodyProgress = Center(
    child: CircularProgressIndicator(),
  );

  // 애니메이션 관련 변수
  // 관련자료 : https://youtu.be/KEUKRT9Xsls
  //TODO 에니메이션 개선
  bool _bigger = true;

  // initState

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: screenSize.height/4,),
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
        )
    );
  }

  Widget loginCard(Size screenSize) {
    return Card(
      elevation: 10.0,
      child: Container(
        width: screenSize.width / 1.4,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Form(
          key: loginKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  autofocus: false,
                  style: TextStyle(color: Colors.grey[800]),
                  onSaved: (value) => email = value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: '이메일',
                    contentPadding:
                    const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).accentColor),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                  ),
                  validator: (String email) {
                    if(email.length == 0)
                      return '이메일 주소를 입력해주세요.';
                    else
                      return null;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  autofocus: false,
                  obscureText: true,
                  style: TextStyle(color: Colors.grey[800]),
                  onSaved: (value) => password = value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: '비밀번호',
                    contentPadding:
                    const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).accentColor),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                  ),
                  validator: (String password) {
                    if(password.length == 0)
                      return '비밀번호를 입력해주세요.';
                    else
                      return null;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    elevation: 0,
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.7),
                      side: BorderSide(color: Theme.of(context).accentColor),
                    ),
                    child: Text("로그인", style: TextStyle(color: Colors.white, fontSize: 16),),
                    onPressed: () {
                      login(context);
                    },
                  ),
                  FlatButton(
                    child: Text("돌아가기", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14)),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      setState(() {
                        _bigger = !_bigger;
                        print(_bigger);
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Checkbox(value: isAutoLogin??false, onChanged: _autoLoginChanged),
                  Text("자동 로그인", style: TextStyle(color: Colors.grey[800]),)
                ],
              )
            ],
          ),
        )
      )
    );
  }

  Widget selectButtons() {
    return Container(
      padding: EdgeInsets.only(top: 167),
      child: Column(
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
              },
            ),
          ),
          FlatButton(
            child: Text("회원가입", style: TextStyle(color: Colors.white, fontSize: 16)),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              //TODO 회원가입 페이지 팝업
            },
          )
        ],
      ),
    );
  }
}
