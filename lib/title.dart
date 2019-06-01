import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:random_string/random_string.dart';
import 'package:wannyanmemory/room.dart';
import 'package:image_picker/image_picker.dart';
import 'dialog/dialog.dart';

var _baseURL = "https://sumo-api.k-appdev.com";

class ImageRequest {
  final int id;
  final String img;

  ImageRequest({
    this.id,
    this.img,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'img': img,
  };
}

class ImageResponse {
  final int id;
  final String img;

  ImageResponse({
    this.id,
    this.img,
  });

  factory ImageResponse.fromJson(Map<String, dynamic> json) {
    return ImageResponse(
      id: json["id"],
      img: json["img"],
    );
  }
}

class Request {
  final String name;

  Request({
    this.name,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
  };
}

class UserResponse {
  final int id;

  UserResponse({
    this.id
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json["id"],
    );
  }
}

class TitlePage extends StatefulWidget {
  @override
  _TitleState createState() => new _TitleState();
}

class _TitleState extends State<TitlePage> {
  int _userID;
  File _image;
  String _base64;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
      print(_image.readAsBytesSync().length);
      _base64 = base64.encode(_image.readAsBytesSync());
      _postImage(_base64);
    });
  }

  @override
  void initState(){
    super.initState();
    createUser();
  }

  Future<ImageResponse> _postImage(String base64) async {
    var url = "$_baseURL/v1/images";
    print(_userID);
    var request = new ImageRequest(id: _userID, img: base64);
    final response = await http.post(url,
      body: jsonEncode(request.toJson()),
      headers: {
        "Content-Type": "application/json",
      }
    );
    print(response.body);
    if (response.statusCode == 200) {
      showBasicDialog(
        context,
        "画像を登録しました",
        "了解",
      );
      return ImageResponse.fromJson(jsonDecode(response.body));
    } else {
      return ImageResponse();
    }
  }

  Future<void> createUser() async {
    var request = new Request(name: randomAlpha(5));
    var url = "$_baseURL/v1/users";
    final response = await http.post(url,
      body: jsonEncode(request.toJson()),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      _userID = UserResponse.fromJson(data).id;
      print("CreateUserOK");
      print(_userID);
    } else {
      print("CreateUserMISS");
    }
  }

  Widget btn(String title, Size size) {
    return Center(
      child: FlatButton(
        color: Colors.limeAccent[700],
        child: Container(
          width: size.width*0.8,
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: '',
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ),
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return Room(userID: _userID);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Uint8List bytes = base64.decode(_base64);
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'wanko2.jpg',
              fit: BoxFit.fitWidth,
              width: size.width,
              alignment: Alignment.bottomLeft,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'title_logo.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomLeft,
                  ),
                ),
                Padding(padding: EdgeInsets.all(20),),
                Material(
                  color: Colors.brown[300],
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return Room(userID: _userID);
                          },
                        ),
                      );
                    },
                    splashColor: Colors.brown[600],
                    borderRadius: BorderRadius.circular(10),
                    child: Text(
                      " Start ",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "RockSalt",
                        fontSize: 35.0,
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(100),),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     getImage();
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
