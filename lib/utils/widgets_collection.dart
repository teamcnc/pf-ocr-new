import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AppColors.dart';
import 'close_dialouge.dart';

class WidgetsCollection {
  BuildContext context;

  WidgetsCollection(BuildContext sentContext) {
    context = sentContext;
  }

  Widget getRaisedButton(String text, VoidCallback voidCallback) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
      child: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: voidCallback,
    );
  }

  List<Color> colors = [AppColors.appTheame];

  showAcceptedDialog({String message}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext buildContext) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(buildContext).pop();
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          content: Container(
            width: 311,
            // height: 190,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'assets/images/correct.png',
                  height: 96,
                  width: 96,
                  // color: penzylColor,
                ),
                SizedBox(
                  height: 32,
                ),
                Text(
                  "Success",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 34,
                      color: AppColors.appTheame),
                ),
                if (message != null)
                  SizedBox(
                    height: 16,
                  ),
                if (message != null)
                  Text(
                    "$message",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Colors.black),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  showSnackBar(String text) {
    final snackBar = SnackBar(content: Text('$text'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showDeleteDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 20.0, minWidth: 200),
              child: CloseDialog(
                message: '',
                no: 'Cancel',
                yes: 'Delete',
                title: 'Are you sure you want to Delete',
                onnPressed: () {},
              ));
        });
  }

  static var inputBorder = OutlineInputBorder(
    borderSide: BorderSide(
        color: AppColors.appTheame, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
  );
}
