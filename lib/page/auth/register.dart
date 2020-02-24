import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';

import 'package:nextor/fnc/auth.dart';
// TODO 회원가입 구현.
// 별도의 관리자 개입이 없는이상 첫 role 은 GUEST 임.
// 회원가입 페이지는 설문조사 항목을 포함하고 있음.


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  AuthDBFNC authDBFNC = AuthDBFNC();

  //유저 정보 변수
  final registerFormKey = GlobalKey<FormState>();
  String email;
  String password;
  String userName;
  int memberType;

  // 오류 다이알로그
  Future _errorDialog(BuildContext context, _message, code) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text("회원가입 실패"),
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


//TODO 회원가입 Design
//TODO 회원가입 FNC
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: memberType != null ? FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text("      확인      ", style: TextStyle(color: Colors.white),),
        onPressed: () async {
          final form = registerFormKey.currentState;
          form.save();
          if(form.validate()) {
            showLoading(context);
            var connectivityResult = await (Connectivity().checkConnectivity()); // 인터넷 연결상태 확인
           if(connectivityResult != ConnectivityResult.none) {//TODO 이메일 인증 구현
             authDBFNC.createUser(email: email, password: password).then((user) async {
               await authDBFNC.createUserInfo(user: user.user, username: userName,
               description: "", registerDate: DateTime.now().toIso8601String(),
               role: memberType == 0 ? "MEMBER" : "GUEST");
               Navigator.pop(context);
               Navigator.pop(context);
             }).catchError((e) {
               Navigator.pop(context);
               _errorDialog(context, e.message, e.code);
             });
           } else {
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
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)
        ),
      ) : null,
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            firstQuestion(),
            AnimatedSwitcher(
              duration: Duration(seconds: 1),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(child: child, opacity: animation);},
              child: memberType != null ? secondQuestion() : Text(""),
            ),
          ],
        ),
      )
    );
  }

  // 첫번째 질문
  Widget firstQuestion() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text("1. 가입 유형을 선택해주세요.", style: Theme.of(context).textTheme.title),
          ),
          ListTile(
            title: Text('동아리 회원'),
            leading: Radio(
              value: 0,
              groupValue: memberType,
              onChanged: (int value) {
                setState(() { memberType = value; });
              },
            ),
          ),
          ListTile(
            title: Text('기타 회원'),
            leading: Radio(
              value: 1,
              groupValue: memberType,
              onChanged: (int value) {
                setState(() { memberType = value; });
              },
            ),
          ),
        ],
      )
    );
  }

  //두번째 질문
  Widget secondQuestion() {
    return Container(
        child: Form(
          key: registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: Text("2. 유저 정보를 입력해주세요", style: Theme
                    .of(context)
                    .textTheme
                    .title),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    10, 10, 10, 1
                ),
                height: 90,
                child: TextFormField(
                  onSaved: (value) => userName = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "닉네임",
                    fillColor: Colors.grey[300],
                    filled: true,),
                  validator: (String name) {
                    if (name.length == 0)
                      return '닉네임을 입력해주세요.';
                    else
                      return null;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    10, 10, 10, 1
                ),
                height: 90,
                child: TextFormField(
                  onSaved: (value) => email = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "이메일 주소",
                    fillColor: Colors.grey[300],
                    filled: true,),
                  validator: (String email) {
                    if (email.length == 0)
                      return '이메일 주소를 입력해주세요.';
                    else
                      return null;
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                    10, 1, 10, 10
                ),
                child: TextFormField(
                  onSaved: (value) => password = value,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "비밀번호",
                    fillColor: Colors.grey[300],
                    filled: true,),
                  validator: (String pass) {
                    if (pass.length == 0)
                      return '비밀번호를 입력해주세요.';
                    else
                      return null;
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
}
