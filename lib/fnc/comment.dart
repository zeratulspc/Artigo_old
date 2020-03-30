import 'package:nextor/fnc/postDB.dart';
import 'package:nextor/fnc/like.dart';

class Comment {
  String body;
  String uploaderUID;
  String uploadDate;
  Attach attach;
  List<Like> like;
  List<Comment> reply;
}