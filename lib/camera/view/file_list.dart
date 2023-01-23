import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ocr/utils/VisionDetectorViews/text_detector_view.dart';
import 'package:ocr/utils/file_operations/file_operations.dart';
import 'package:ocr/utils/navigation.dart';

class CameraFileList extends StatefulWidget {
  final String docNumber;
  CameraFileList({Key key, this.docNumber}) : super(key: key);

  @override
  _CameraFileListState createState() => _CameraFileListState();
}

class _CameraFileListState extends State<CameraFileList> {
  FileOperations _fileOperations = FileOperations();
  List<File> allImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Files"),
      ),
      body: Center(
        // child: ,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add_a_photo,
          size: 30,
        ),
        onPressed: () {
          NavigationActions.navigate(
              context,
              TextDetectorView(
                docNumber: widget.docNumber,
              ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
