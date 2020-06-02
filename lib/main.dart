import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import 'package:nextor/page/auth/login.dart';
import 'package:nextor/page/home.dart';
import 'package:nextor/page/splash.dart';
import 'package:nextor/page/settings/settings.dart';
import 'package:nextor/page/settings/editProfile.dart';


void main() => runApp(MyApp());

final routes = {
  '/login': (BuildContext context) => LoginPage(),
  '/home': (BuildContext context) => HomePage(),
  '/settings' : (BuildContext context) => Settings(),
  '/editProfile' : (BuildContext context) => EditProfilePage(),
};

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //FlutterStatusbarcolor.setStatusBarColor(Colors.white);
    //FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: routes,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: RemoveGrow(),
          child: child,
        );
      },
      title: 'Artigo Community',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[300],
        primaryColor: Colors.green,
        primarySwatch: Colors.green,
        accentColor: Colors.greenAccent,
      ),
      home: SplashScreen(),
    );
  }
}



class RemoveGrow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
