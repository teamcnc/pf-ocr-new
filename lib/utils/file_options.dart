import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocr/utils/camera_view.dart';
import 'package:ocr/utils/navigation.dart';

class FileOptions extends StatefulWidget {
  const FileOptions(
      {Key key, this.docNumber, this.fileName, this.incomingFile, this.type})
      : super(key: key);
  final String docNumber, type, fileName;
  final File incomingFile;

  @override
  _FileOptionsState createState() => _FileOptionsState();
}

class _FileOptionsState extends State<FileOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    // bool isDocSave = await 
                    NavigationActions.navigateReplacement(
                      context,
                      TakePictureScreen(
                        docNumber: widget.docNumber,
                        type: "sales",
                        fileName: widget.fileName,
                      ),
                    );
                  },
                  child: Text("Open Gallery")),
              SizedBox(height: 30),
              ElevatedButton(onPressed: () {}, child: Text("Open Camera"))
            ],
          ),
        ),
      ),
    );
  }
}
