import 'package:flutter/material.dart';

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
    return MaterialApp(
      routes: routes,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: RemoveGrow(),
          child: child,
        );
      },
      title: 'Nextor Community',
      theme: ThemeData(
        primaryColor: Colors.orange[700],
        primarySwatch: Colors.orange,
        accentColor: Colors.orangeAccent,
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
