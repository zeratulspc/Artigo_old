import 'package:flutter/material.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/preferencesData.dart';
import 'package:nextor/fnc/versionCheck.dart';
import 'package:nextor/page/auth/login.dart';
import 'package:nextor/page/basicDialogs.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  BasicDialogs basicDialogs = BasicDialogs();
  AuthDBFNC authDBFNC = AuthDBFNC();
  VersionCheck versionCheck = VersionCheck();
  
  @override
  void initState() {
    super.initState();
    versionCheck.checkVersion().then((isValidVersion){
      if(isValidVersion.isValid) {
        getAutoLogin().then((_isAutoLogin) {
          if(_isAutoLogin) {
            getEmail().then((_email) => getPassword().then((_password) =>
                authDBFNC.loginUser(email: _email, password: _password).then(
                        (user) {
                          authDBFNC.updateUserRecentLoginDate(uid: user.user.uid, recentLoginDate: DateTime.now().toIso8601String());
                          Navigator.of(context).pushReplacementNamed('/home');
                    }).catchError((e) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                })));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
          }
        });
      } else { //TODO 버전이 맞지 않을 경우
        basicDialogs.dialogWithYes(context, "버전이 올바르지 않습니다",
            "앱을 업데이트 해주세요, 현재 사용가능한 버전은 [${isValidVersion.versionName}] 입니다.");
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Image.asset(
          'assets/ver3.png',
          width: screenSize.width - 250,
        ),
      ),
    );
  }

}