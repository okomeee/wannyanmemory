import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:wannyanmemory/title.dart';

var _baseURL = "https://sumo-api.k-appdev.com";

void main() {
  // SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState(){
    super.initState();
    _destroyAllRooms().then((_){
    });
  }

  Future<void> _destroyAllRooms() async {
    var url = "$_baseURL/v1/rooms";
    final response = await http.get(url);
    print('RoomALLDELETE!');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wannyanmemory',
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => new TitlePage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
    );
  }
}