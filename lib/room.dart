import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:random_string/random_string.dart';
import 'package:wannyanmemory/join.dart';

var _baseURL = "https://sumo-api.k-appdev.com";

class Request {
  final String name;

  Request({
    this.name,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
  };
}

class RoomResponse {
  final int id;
  final String name;

  RoomResponse({
    this.id,
    this.name
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    return RoomResponse(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Room extends StatefulWidget {
  final int userID;
  Room({Key key, this.userID}): super(key: key);
  @override
  _RoomState createState() => new _RoomState();
}

class _RoomState extends State<Room> {

  @override
  void initState(){
    super.initState();
    _getRoomList().then((List<RoomResponse> r){
      if(r.length > 0 ){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Join(roomID: r[0].id, flag: true, userID: widget.userID);
            },
          ),
        );
      }else{
        createRoom().then((RoomResponse r){
          if(r.id != null){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return Join(roomID: r.id, flag: false, userID: widget.userID);
                },
              ),
            );
          }else{
            print('CreateRoomResponseMISS');
          }
        });
      }
    });
  }

  Future<List<RoomResponse>> _getRoomList() async {
    var rList = new List<RoomResponse>();
    var url = "$_baseURL/v1/rooms";
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      var data = jsonDecode(responseBody)['data'];
      data.forEach((json){
        rList.add(RoomResponse.fromJson(json));
      });
      print('GetRoomListOK');
      return rList;
    } else {
      print('GetRoomListMISS');
      return [];
    }
  }

  Future<RoomResponse> createRoom() async {
    var request = new Request(name: randomAlpha(5));
    var url = "$_baseURL/v1/rooms";
    final response = await http.post(url,
      body: jsonEncode(request.toJson()),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 201) {
      print('CreateRoomOK');
      var data = jsonDecode(response.body)['data'];
      print(RoomResponse.fromJson(data));
      return RoomResponse.fromJson(data);
    } else {
      print('CreateRoomMISS');
      return RoomResponse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(
        children:<Widget>[
          // Center(
          //   child: Image.asset(
          //     'assets/images/bg.jpg',
          //     fit: BoxFit.fitWidth,
          //     width: size.width,
          //   ),
          // ),
          Container(
            padding: EdgeInsets.fromLTRB(100, 10, 100, 10),
            child: Center( child: const CircularProgressIndicator() ),
          )
        ]
      )
    );
  }
}