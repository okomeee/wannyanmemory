import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'dart:async';
import 'result.dart';

var _baseURL = "https://sumo-api.k-appdev.com";
var _baseURLws = "wss://sumo-api.k-appdev.com/cable";

class IDRequest {
  final int id;

  IDRequest({
    this.id,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
  };
}

class Join extends StatefulWidget {
  final int roomID;
  final bool flag;
  final int userID;
  Join({Key key, this.roomID, this.flag, this.userID}): super(key: key);

  @override
  _JoinState createState() => new _JoinState();
}

class _JoinState extends State<Join> {
  IOWebSocketChannel channel;
  Object identifier;
  Timer _timer;
  int _start = 5;
  int enemyPoint = 0;
  int myPoint = 0;
  int messageId;
  bool ternFlag = false;
  bool gameFlag = false;
  List alldata = [];
  int enemyUserID;

  int count=0;
  var b=null;

  List<int> ans=[];

  @override
  void initState() {
    super.initState();
    identifier = jsonEncode({
      "channel": "RoomChannel",
      "room": widget.roomID,
      "user": widget.userID
    });
    print(identifier);
    setState(() {
      ternFlag = widget.flag;
    });
    setupChannel();
  }

  List cList() {
    List cardlist = [];
    for(var i = 0; i < 5; i++) {
      cardlist.add(
        {
          "id": i,
          "user_id": widget.userID,
          "image":'spa${ i+ 1}.jpg',
          "isTapped": false
        }
      );
    }
    for(var i = 5; i < 10; i++) {
      cardlist.add(
        {
          "id": i,
          "user_id": widget.userID,
          "image":'spa${ i+ 1 - 5}.jpg',
          "isTapped": false
        }
      );
    }
    for(var i = 10; i < 15; i++) {
      cardlist.add(
        {
          "id": i,
          "user_id": enemyUserID==null?enemyUserID:0,
          "image":'spa${ i+ 1-10}.jpg',
          "isTapped": false
        }
      );
    }
    for(var i = 15; i < 20; i++) {
      cardlist.add(
        {
          "id": i,
          "user_id": enemyUserID==null?enemyUserID:0,
          "image":'spa${ i+ 1 - 15}.jpg',
          "isTapped": false
        }
      );
    }
    return cardlist;
  }

  @override
  void dispose() {
    if(_timer != null){
      _timer.cancel();
    }
    channel.sink.add(
      jsonEncode({
        "command": "unsubscribe",
        "identifier": identifier
      })
    );
    super.dispose();
  }

  void setupChannel() {
    // Doesn't work on localhost
    channel = IOWebSocketChannel.connect(_baseURLws);

    // Connet to Rails Server with WebSocket Session
    channel.sink.add(
      jsonEncode({
        "command": "subscribe",
        "identifier": identifier
      })
    );

    channel.stream.listen(onData);
  }

  void onData(_data) {
    var data = jsonDecode(_data);
    switch (data["type"]) {
      case "ping":
        break;
      case "welcome":
        print("Welcome!");
        break;
      case "confirm_subscription":
        print("Connected!");
        if (widget.flag) {
          channel.sink.add(
            jsonEncode({
              "command": "message",
              "identifier": identifier,
              "data": jsonEncode({"action": "join"})
            })
          );
        }
        initPost();
        break;
      default:
        // print(data.toString());
    }

    if (data["identifier"] == identifier &&
        !data.containsKey("type") ) {

      var d = data["message"];
      print(d);
      if (d["data"] == "START"){
        // ゲーム開始前
        setState(() {
          gameFlag = true;
        });
        startTimer();
      } else {
        // ゲーム開始後
        if (d["data"]["message"]=="Saved!" && d["data"]["obj"]["user_id"] == widget.userID){
          setState(() {
            messageId = d["data"]["obj"]["id"];
          });
        }else if(d["data"]["message"]=="Saved!" && d["data"]["obj"]["user_id"] != widget.userID){
          enemyUserID = d["data"]["obj"]["user_id"];
        }
        if(alldata.length==0){
          setState(() {
            alldata = cList();
          });
        }
        if (d["data"]["message"]=="Update!" && d["data"]["obj"]["user_id"] == widget.userID) {
          setState(() {
            ternFlag = !ternFlag;
            myPoint = d["data"]["obj"]["message"];
          });
        } else if (d["data"]["message"]=="Update!" && d["data"]["obj"]["user_id"] != widget.userID) {
          setState(() {
            ternFlag = !ternFlag;
            enemyPoint = d["data"]["obj"]["message"];
          });
        }
        if(d["data"]["message"]=="YEAH!"){
          List<int> v=[];
          var a = d["data"]["data"].split('+');
          for(var i=0; i<(a.length-1);i++){
            v.add(int.parse(a[i]));
          }
          setState(() {
            ans = v;
          });
        }
      }
    }
    print("MyPOINT: $myPoint");
    print("EnemyyPOINT: $enemyPoint");
    if(enemyPoint >3){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Result(win:false);
          },
        ),
      );
    }
    if(myPoint>3){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return Result(win:true);
          },
        ),
      );
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  Future<void> deleteRoom() async {
    var request = new IDRequest(id: widget.roomID);
    var url = "$_baseURL/v1/rooms/delete";
    final response = await http.post(url,
      body: jsonEncode(request.toJson()),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 204) {
      print('RoomDeleteOK');
    } else {
      print('RoomDeleteMISS');
    }
  }

  void initPost() {
    var data = jsonEncode({
      "action": "initpost",
      "data": myPoint,
    });

    channel.sink.add(
      jsonEncode({
        "command": "message",
        "identifier": identifier,
        "data": data
      })
    );
  }

  void post(flag) {
    if(flag){
      setState(() {
        myPoint = myPoint + 1;
      });
    }
    var data = jsonEncode({
      "action": "post",
      "data": myPoint,
      "id": messageId
    });

    channel.sink.add(
      jsonEncode({
        "command": "message",
        "identifier": identifier,
        "data": data
      })
    );
  }

  void postAns() {
    var a="";
    for(var i = 0;i<ans.length;i++){
      a+="${ans[i]}+";
    }
    var data = jsonEncode({
      "action": "postans",
      "data": myPoint,
      "ids": a
    });

    channel.sink.add(
      jsonEncode({
        "command": "message",
        "identifier": identifier,
        "data": data
      })
    );
  }

  Widget backbtn(Size size) {
    return Center(
      child: FlatButton(
        color: Colors.limeAccent[700],
        child: Container(
          width: size.width*0.8,
          padding: EdgeInsets.all(10),
          child: Center(
            child: Text(
              "戻る",
              style: TextStyle(
                fontFamily: '',
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
        ),
        onPressed: (){
          deleteRoom().then(
            (_) => Navigator.popUntil(context, ModalRoute.withName('/'))
          );
        },
      ),
    );
  }

  Widget waiting(size) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                'マッチング中…',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(10),),
          Center( child: const CircularProgressIndicator() ),
          Padding(padding: EdgeInsets.all(10),),
          backbtn(size)
        ],
      )
    );
  }

  Widget countdown() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            "始まるよー",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold
            ),
          ),
          Text(
            '$_start',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget game() {
    return GridView.extent(
      maxCrossAxisExtent: 120.0,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: alldata.length>0?wList():[],
    );
  }

  Widget gamewait() {
    return GridView.extent(
      maxCrossAxisExtent: 120.0,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: alldata.length>0?wList():[],
    );
  }

  Widget main(size) {
    if(gameFlag){
      if(_start < 1){
        // Game画面
        if(ternFlag){
          print("GAME!");
          return game();
        }else{
          print("WAIT!");
          return gamewait();
        }
      } else {
        // カウントダウン画面
        return countdown();
      }
    }else{
      // マッチング待機画面
      return  waiting(size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return new Scaffold(
      body: Stack(
        children:<Widget>[
          Positioned.fill(
            child: Image.asset(
              'wanko1.jpg',
              fit: BoxFit.fitWidth,
              width: size.width,
              alignment: Alignment.bottomLeft,
            ),
          ),
          main(size),
          // gameFlag&&_start<1&&!ternFlag?Center( child: const CircularProgressIndicator() ):Container(),
          gameFlag&&_start<1&&!ternFlag?Center( child: Container(color: Colors.white,child: Text("相手の番です",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),)  ):Container(),
        ]
      )
    );
  }

  void check() {
    for(var i=0;i<alldata.length;i++){
      if(alldata[i]["isTapped"]){
        if(b==null){
          setState(() {
            b=alldata[i];
          });
        }else{
          print(b);
          print(alldata[i]);
          if(b["user_id"]==alldata[i]["user_id"]&&b["image"]==alldata[i]["image"]){
            print('あってる');
            post(true);
            setState(() {
              ans.add(b["id"]);
              ans.add(alldata[i]["id"]);
            });
          }else{
            post(false);
          }
          postAns();
          setState(() {
            b=null;
            for(var j=0; j<alldata.length;j++){
              for(var k=0; k<ans.length;k++){
                if(j==ans[k]){
                  alldata[j]["isTapped"]=true;
                }else{
                  // alldata[j]["isTapped"]=false;
                }
              }
            }
          });
          return;
        }
      }
    }
  }

  List<Widget> wList() {
    List<Widget> _buffer = [];
    for(var i = 0; i < 20; i++) {
      if(alldata[i]["isTapped"]){
        _buffer.add(
          GestureDetector(
            child:Container(
              margin: const EdgeInsets.all(5.0),
              color: Colors.teal,
              child: Card(
                child:new Image.asset(
                  alldata[i]["image"],
                  fit:BoxFit.cover
                ),
              ),
            ),
            onTap: (){
              // setState(() {
              //   alldata[i]["isTapped"]=false;
              // });
            },
          ),
        );
      }else{
        _buffer.add(
          GestureDetector(
            child:Container(
              margin: const EdgeInsets.all(5.0),
              color: Colors.teal,
              child: Card(
                child:new Image.asset(
                  'card2.jpg',
                  fit:BoxFit.cover
                ),
              ),
            ),
            onTap: (){
              if(ternFlag){
                setState(() {
                  alldata[i]["isTapped"]=true;
                });
                count+=1;
                if(count>1){
                  check();
                  count=0;
                }
              }
            },
          ),
        );
      }
    }
    return _buffer;
  }
}