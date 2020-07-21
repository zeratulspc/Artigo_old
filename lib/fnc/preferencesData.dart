import 'package:shared_preferences/shared_preferences.dart';


Future<bool> getAutoLogin() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isAutoLogin = prefs.getBool("isAutoLogin") ?? false;
  return isAutoLogin;
}

setAutoLogin(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool("isAutoLogin", value);
}

Future<String> getEmail() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString("email") ?? "null";
  return email;
}

setEmail(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("email", value);
}

Future<String> getPassword() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("password") ?? "null";
  return userId;
}

setPassword(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString("password", value);
}