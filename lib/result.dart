import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class Result extends StatefulWidget {
  final win;

  Result({this.win});
  @override
  ResultState createState() => new ResultState(win:win);
}

class ResultState extends State<Result> {
  final win ;

  ResultState({this.win});
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return new Scaffold(
      body: Container(
        padding: new EdgeInsets.fromLTRB(20, 170, 20, 20),
        child: Center(
          child: Column(
            children: <Widget>[
              win?
                Text(
                  'YOU \nWIN...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 100,
                    fontWeight: FontWeight.bold
                  ),
                )
              :
                Text(
                  'YOU \nLOSE...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 100,
                    fontWeight: FontWeight.bold
                  ),
                ),
              
              Image.asset(
                'images/wanko2.jpg',
                fit: BoxFit.cover,
                width: size.width,
              ),
            Material(
              color: Colors.brown[900],
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: (){
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                splashColor: Colors.brown[900],
                borderRadius: BorderRadius.circular(10),
                child: Text(
                  " Top ",
                  style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 35.0,
                  ),
                ),
              ),
            ),
            ],
          ),
        )
      )
    );
  }
}
