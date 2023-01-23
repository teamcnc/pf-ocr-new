import 'package:flutter/material.dart';

class CloseDialog extends StatelessWidget {
  final title;
  final message;
  final yes;
  final no;
  @required
  final onnPressed;

  const CloseDialog({
    Key key,
    this.title,
    this.message,
    this.onnPressed,
    this.yes,
    this.no,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _screenWidth = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 20.0, minWidth: 200),
      child: AlertDialog(
        //  contentPadding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        title: Center(child: Text(title)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Text(message)),
          ],
        ),
        actions: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: _screenWidth / 2 - 40,
                padding: EdgeInsets.only(right: 50),
                child: ElevatedButton(
                  child: Text(
                    no ?? 'No',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
            ],
          ),
          Container(
            width: _screenWidth / 2 - 70,
            padding: EdgeInsets.only(right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                backgroundColor: Colors.red,
              ),
              child: Center(
                child: Text(
                  yes ?? 'Yes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: onnPressed,
            ),
          ),
        ],
      ),
    );
  }
}
