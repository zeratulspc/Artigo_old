import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_crop/image_crop.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:nextor/fnc/auth.dart';

class EditProfilePage extends StatefulWidget {
  final Function() callback;
  EditProfilePage({this.callback});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {

  AuthDBFNC authDBFNC = AuthDBFNC();
  FirebaseUser currentUser;
  String userName;
  String description;
  String email;

  //TODO 프로필 사진
  //TODO 커버 사진
  File profileImage;
  File coverImage;

  @override
  void initState() {
    super.initState();
    authDBFNC.getUser().then(
            (data) {
          currentUser = data;
          authDBFNC.getUserInfo(currentUser.uid).then(
                  (data) {
                setState(() {
                  userName = data.userName;
                  description = data.description;
                  email = data.email;
                });
              }
          );
        }
    );
  }

  getImageFile(ImageSource source) async {
    //Clicking or Picking from Gallery
    var image = await ImagePicker.pickImage(source: source);
    //Cropping the image;
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      compressQuality: 50,
      maxWidth: 512,
      maxHeight: 512,
      compressFormat: ImageCompressFormat.jpg,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
      )
    );


    setState(() {
      profileImage = croppedFile;
      print(croppedFile.lengthSync());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("프로필 수정", style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
                title: Text("프로필 사진", style: TextStyle(fontWeight: FontWeight.bold),),
                trailing: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Text("수정", style: TextStyle(color: Colors.indigoAccent),),
                  onPressed: (){
                    getImageFile(ImageSource.gallery);
                  },
                )
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: profileImage == null ?
              Image.asset(
                'assets/user.png',
                width: 200,
                height: 200,
              ) : Image.file(
                profileImage,
                width: 200,
                height: 200,
              ),
            ),
            Divider(),
            ListTile(
              title: Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold),),
              trailing: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Text("수정", style: TextStyle(color: Colors.indigoAccent),),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => TextFieldPage(object: "userName", uid: currentUser.uid, item: userName,
                    callback: () { // Reload
                      authDBFNC.getUserInfo(currentUser.uid).then(
                              (data) {
                            setState(() {
                              userName = data.userName;
                              description = data.description;
                              email = data.email;
                            });
                          }
                      );
                      this.widget.callback();
                    },)
                  ));
                },
              )
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: Center(
                child: Text(userName??"불러오는 중...", style: TextStyle(color: Colors.grey[700]),),
              ),
            ),
            Divider(),
            ListTile(
                title: Text("한줄 소개", style: TextStyle(fontWeight: FontWeight.bold),),
                trailing: FlatButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Text("수정", style: TextStyle(color: Colors.indigoAccent),),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (_) => TextFieldPage(object: "description", uid: currentUser.uid, item: description,
                          callback: () { // Reload
                            authDBFNC.getUserInfo(currentUser.uid).then(
                                    (data) {
                                  setState(() {
                                    userName = data.userName;
                                    description = data.description;
                                    email = data.email;
                                  });
                                }
                            );
                            this.widget.callback();
                          },
                        )
                    ));
                  },
                )
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: Center(
                child: Text(description??"불러오는 중...", style: TextStyle(color: Colors.grey[700]),),
              ),
            ),
            Divider(),

          ],
        ),
      ),
    );
  }
}

class TextFieldPage extends StatefulWidget {
  final Function() callback;
  final String object;
  final String uid;
  final String item;
  TextFieldPage({this.object, this.uid, this.item, this.callback});

  @override
  TextFieldPageState createState() => TextFieldPageState(object: object, uid: uid, item: item);
}

class TextFieldPageState extends State<TextFieldPage> {
  final editProfileFormKey = GlobalKey<FormState>();
  AuthDBFNC authDBFNC = AuthDBFNC();

  final String object;
  final String uid;
  String item;
  TextFieldPageState({this.object, this.uid, this.item});

  String objectToInfo(String object) {
    switch(object) {
      case "userName":
        return "닉네임";
        break;
      case "description":
        return "한줄소개";
        break;
      default:
        return "정보";
        break;
    }
  }

  objectToFnc(String object) {
    switch(object) {
      case "userName":
        authDBFNC.updateUserName(uid: uid, userName: item);
        break;
      case "description":
        authDBFNC.updateUserDescription(uid: uid, description: item);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("${objectToInfo(object)} 수정", style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Text("저장", style: TextStyle(color: Colors.black),),
            onPressed: (){
              var form = editProfileFormKey.currentState;
              form.save();
              if(form.validate()) {
                objectToFnc(object);
                this.widget.callback();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: editProfileFormKey,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(
                    10, 10, 10, 1
                ),
                height: 90,
                child: TextFormField(
                  initialValue: item,
                  onSaved: (value) => item = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: objectToInfo(object),
                    fillColor: Colors.grey[300],
                    filled: true,),
                  validator: (String name) {
                    if (name.length == 0)
                      return '${objectToInfo(object)}을 입력해주세요.';
                    else
                      return null;
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}