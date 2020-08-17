import 'dart:io';
import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:Artigo/fnc/user.dart';
import 'package:Artigo/page/basicDialogs.dart';
// 별도의 관리자 개입이 없는이상 첫 role 은 GUEST 임.
// 회원가입 페이지는 설문조사 항목을 포함하고 있음.


class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserDBFNC authDBFNC = UserDBFNC();
  BasicDialogs basicDialogs = BasicDialogs();

  //유저 정보 변수
  final registerFormKey = GlobalKey<FormState>();
  File defaultUserImage;
  String email;
  String password;
  String userName;
  int memberType;

  @override
  void initState() {
    super.initState();
    getImageFileFromAssets("user.png").then((data) {
      defaultUserImage = data;
    });
  }

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

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text("      확인      ", style: TextStyle(color: Colors.white),),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
        ),
        onPressed: () async {
          final form = registerFormKey.currentState;
          form.save();
          String _email = email;
          String _password = password;
          if(form.validate()) {
            showLoading(context);
            var connectivityResult = await (Connectivity().checkConnectivity()); // 인터넷 연결상태 확인
           if(connectivityResult != ConnectivityResult.none) {
             authDBFNC.createUser(email: _email, password: _password).then((user) async {
               await authDBFNC.createUserInfo(user: user.user, username: userName,
               description: "", registerDate: DateTime.now().toIso8601String(),
               role: "MEMBER");
               await authDBFNC.uploadUserProfileImage(uid: user.user.uid, profileImage: defaultUserImage);
               authDBFNC.loginUser(email: _email, password: _password).then((user) {
                 authDBFNC.updateUserRecentLoginDate(uid: user.user.uid, recentLoginDate: DateTime.now().toIso8601String());
                 Navigator.pop(context);
                 Navigator.pop(context);
                 Navigator.of(context).pushReplacementNamed('/home');
               }
               ).catchError((error) {
                 Navigator.pop(context);
                 _errorDialog(context, error.message, error.code);
               });
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
      ),
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Form(
                key: registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      ListTile(
                        title: Text("유저 정보를 입력해주세요", style: Theme
                            .of(context)
                            .textTheme
                            .headline6),
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
              ),
            ),
          ],
        ),
      )
    );
  }
}

