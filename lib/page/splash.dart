import 'package:flutter/material.dart';

import 'package:nextor/fnc/auth.dart';
import 'package:nextor/fnc/preferencesData.dart';
import 'package:nextor/page/auth/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  AuthDBFNC authDBFNC = AuthDBFNC();

  @override
  void initState() {
    super.initState();
    getAutoLogin().then((_isAutoLogin) {
      if(_isAutoLogin) {
        getEmail().then((_email) => getPassword().then((_password) =>
            authDBFNC.loginUser(email: _email, password: _password).then(
                (_) => Navigator.of(context).pushReplacementNamed('/home')).catchError((e) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
            })));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }

}