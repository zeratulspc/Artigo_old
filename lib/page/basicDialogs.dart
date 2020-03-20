import 'package:flutter/material.dart';

class BasicDialogs {

  void showLoading(BuildContext context, String text) {
    showDialog(context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("잠시만 기다려주세요..."),
          content: Row(
            children: <Widget>[
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
              SizedBox(width: 25,),
              Text(text, style: TextStyle(color: Colors.grey[700]),)
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        );
      },
    );
  }

}