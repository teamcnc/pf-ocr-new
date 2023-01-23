import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr/utils/file_operations/file_operations.dart';

enum ScreenMode { liveFeed, gallery }

class AllImagesView extends StatefulWidget {
  AllImagesView({Key key, @required this.onImage, this.incomingFiles})
      : super(key: key);

  final List<File> incomingFiles;
  final Function(List<File> inputImage) onImage;

  @override
  _AllImagesViewState createState() => _AllImagesViewState();
}

class _AllImagesViewState extends State<AllImagesView> {
  File _image;
  PickedFile dummyImage;
  ImagePicker _imagePicker;
  var decodedImage;
  List<File> images = [];
  FileOperations _fileOperations;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    _fileOperations = FileOperations();
    if (widget.incomingFiles != null) {
      images = widget.incomingFiles;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Images"),
        actions: [
          if (images.length > 0)
            IconButton(
                icon: Icon(Icons.crop_outlined),
                onPressed: () async {
                  var croppedImage = await _processPickedFile(images[0]);
                  if (croppedImage != null) images[0] = croppedImage;
                  setState(() {});
                }),
          if (images.length > 0)
            IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  if (images.length > 0) {
                    dummyImage = null;
                    widget.onImage(images);
                  } else
                    EasyLoading.showToast("Images not capture!");
                })
        ],
        // leading: IconButton(
        //     icon: Icon(
        //       Icons.close_rounded,
        //     ),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     }),
      ),
      body: _body(),
      // floatingActionButton: _floatingActionButton(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _body() {
    Widget body;
    body = _galleryBody();
    return body;
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      images.length > 0
          ? Container(
              padding: EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height - 80,
              width: MediaQuery.of(context).size.width,
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: List.generate(images.length, (index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, right: 10),
                        child: GestureDetector(
                          child: Image.file(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                          onTap: () async {
                            var croppedImage =
                                await _processPickedFile(images[index]);
                            if (croppedImage != null)
                              images[index] = croppedImage;
                            setState(() {});
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                images.removeAt(index);
                              });
                            },
                            child: Icon(
                              Icons.highlight_remove,
                              color: Colors.red,
                            )),
                      )
                    ],
                  );
                }),
              ))
          : Center(
              child: Text(""),
            )
    ]);
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      images.add(File(pickedFile.path));
      // _processPickedFile(pickedFile);
    } else {
      print('No image selected.');
      Navigator.pop(context);
    }
    setState(() {});
  }

  Future _processPickedFile(File pickedFile) async {
    // dummyImage = pickedFile;
    ImageCropper imageCropper = ImageCropper();
    // _image = await imageCropper.cropImage(
    //   sourcePath: pickedFile.path,
    //   aspectRatioPresets: [
    //     CropAspectRatioPreset.square,
    //     CropAspectRatioPreset.ratio3x2,
    //     CropAspectRatioPreset.original,
    //     CropAspectRatioPreset.ratio4x3,
    //     CropAspectRatioPreset.ratio16x9
    //   ],
    //   androidUiSettings: AndroidUiSettings(
    //       toolbarTitle: 'Cropper',
    //       toolbarColor: Colors.deepOrange,
    //       toolbarWidgetColor: Colors.white,
    //       initAspectRatio: CropAspectRatioPreset.original,
    //       lockAspectRatio: false),
    //   iosUiSettings: IOSUiSettings(
    //     minimumAspectRatio: 1.0,
    //   ),
    // );
    CroppedFile a = await imageCropper
        .cropImage(sourcePath: pickedFile.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ], uiSettings: [
      AndroidUiSettings(
          toolbarTitle: "Cropper",
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    ]);
    _image = File(a.path);
    if (_image == null) {
      // _getImage(ImageSource.camera);
      return null;
    } else {
      decodedImage = await decodeImageFromList(_image.readAsBytesSync());
      return _image;
      // setState(() {});
    }
  }
}
