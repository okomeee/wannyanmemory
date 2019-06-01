import "package:flutter/material.dart";
import "package:flutter/cupertino.dart";
import "dart:io";

// ---------
// サインイン画面＆サインアップ画面用のダイアログ
// ---------
// 失敗したときに描画される

enum _DialogActionType {
  cancel,
  ok,
}
 
void showBasicDialog(BuildContext context, String text, String btnName) {
  showDialog(
    context: context,
    builder: (context) {
      return Platform.isIOS ? _ios(context, text, btnName) : _android(context, text, btnName);
    }
  ).then<void>((value) {
    // ボタンタップ時の処理
    switch (value) {
      case _DialogActionType.cancel:
        debugPrint("cancel");
        break;
      case _DialogActionType.ok:
        debugPrint("ok");
        break;
      default:
        // debugPrint("default");
    }
  });
}

Widget _ios(context, text, btnName) {
  return CupertinoAlertDialog(
    title: new Text(
      text,
      style: TextStyle(color: Colors.redAccent),
    ),
    actions: <Widget>[
      new FlatButton(
        child: Text(
          btnName,
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          debugPrint("Failed!");
          Navigator.pop(context);
        }
      ),
    ],
  );
}

Widget _android(context, text, btnName) {
  return CupertinoAlertDialog(
    title: new Text(
      text,
      style: TextStyle(color: Colors.redAccent),
    ),
    actions: <Widget>[
      new FlatButton(
        child: Text(
          btnName,
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          debugPrint("Failed!");
          Navigator.pop(context);
        }
      ),
    ],
  );
}