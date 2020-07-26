import 'dart:io';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' ;

import 'package:image_picker/image_picker.dart';

import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/page/basicDialogs.dart';

class EditPostAttach extends StatefulWidget {
  final int imageUploadQuality;
  final List<Attach> attach;
  final String uploaderUID;
  EditPostAttach({this.attach, this.uploaderUID, this.imageUploadQuality}); // 1: POST 2: EDIT


  @override
  EditPostAttachState createState() => EditPostAttachState();
}

class EditPostAttachState extends State<EditPostAttach> {
  BasicDialogs basicDialogs = BasicDialogs();
  PostDBFNC postDBFNC = PostDBFNC();

  List<TextEditingController> controllers = List();
  List<Attach> attach = List(); // 업로드 되지 않은 사진
  Queue<int> deleteQueue = Queue();
  bool notNull(Object o) => o != null;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
    if(this.mounted){
      setState(() {
        attach.addAll(widget.attach);
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
    super.dispose();
    attach.clear();
  }

  void pickImageSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext _context){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('사진 찍기'),
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(context, ImageSource.camera);
                    }
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("갤러리에서 가져오기"),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  pickImage(BuildContext context, ImageSource source) async {
    File tempImage;
    PickedFile pickedFile;
    pickedFile = await ImagePicker().getImage(source: source, imageQuality: widget.imageUploadQuality);
    tempImage = File(pickedFile.path);
    if(tempImage != null) {
      if(await tempImage.exists()) {
        setState(() {
          attach.add(Attach(
            key: attach.length.toString(),
            tempPhoto: tempImage,
            uploaderUID: widget.uploaderUID,
            uploadDate: DateTime.now().toIso8601String(),
          ));
        });
      } else {
        basicDialogs.dialogWithYes(context, "불러오기 실패", "불러오기에 실패했습니다.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black87),
          backgroundColor: Colors.white,
          title: Text(
            "수정",
            style: TextStyle(color: Colors.black),),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Center(
                  child: Text("완료", style: TextStyle(color: Colors.black),),
                ),
                onTap: () => Navigator.pop(context, AttachEditInfo(attach: attach, deleteQueue: deleteQueue)),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[700],
          focusColor: Colors.green[400],
          splashColor: Theme.of(context).accentColor,
          child: Icon(Icons.photo, color: Colors.white,),
          onPressed: (){
            pickImageSheet(context);
          },
        ),
        body: ListView.builder(
          itemCount: attach.length,
          itemBuilder: (context, index) {
            return Container(
              width: screenSize.width,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      attach[index].filePath != null ?
                      Container(
                        height: 300,
                        width: screenSize.width,
                        child: Image.network(
                          attach[index].filePath,
                          fit: BoxFit.cover,
                        ),
                      ) :
                      Container(
                        height: 300,
                        width: screenSize.width,
                        child: Image.file(
                          attach[index].tempPhoto,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Opacity(
                                opacity: 0.3,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      color: Colors.black,
                                    )
                                ),
                              ),
                              Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          onPressed: (){
                            setState(() {
                              if(attach[index].tempPhoto != null) {
                                attach.removeAt(index);
                              } else {
                                deleteQueue.add(index);
                                attach.removeAt(index);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(),
                        child: TextFormField(
                          initialValue: attach[index].description != null ? attach[index].description : null,
                          onChanged: (text) {
                            attach[index].description = text;
                          },
                          cursorColor: Theme.of(context).primaryColor,
                          style: TextStyle(
                              fontSize: 18
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: "설명 추가...",
                            border: InputBorder.none,
                          ),
                        ),
                      )
                  ),
                ],
              ),
            );
          },
        )
    );
  }
}

class AttachEditInfo {
  List<Attach> attach;
  Queue<int> deleteQueue;
  AttachEditInfo({this.attach, this.deleteQueue});
}