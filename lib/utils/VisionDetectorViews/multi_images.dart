import 'dart:io';
import 'dart:math';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:ocr/utils/file_operations/file_operations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum ScreenMode { liveFeed, gallery }

class AllImages extends StatefulWidget {
  AllImages(
      {Key key, @required this.title, @required this.onImage, this.incomingFile
      // this.initialDirection = CameraLensDirection.back
      })
      : super(key: key);

  final String title;
  final File incomingFile;
  final Function(List<File> inputImage) onImage;
  // final CameraLensDirection initialDirection;

  @override
  _AllImagesState createState() => _AllImagesState();
}

class _AllImagesState extends State<AllImages> {
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
    if (widget.incomingFile != null) {
      pdfToImage(widget.incomingFile);
    } else {
      _getImage(ImageSource.camera);
    }
  }

  pdfToImage(File incoming) async {
    final document = await PdfDocument.openFile(incoming.path);
    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage =
          await page.render(width: page.width, height: page.height);
      var rng = new Random();
      var isPermissionGranted = await _fileOperations.checkPermission();
      if (isPermissionGranted == PermissionStatus.granted) {
        images.add(
            await File((await findLocalPath() + "/${rng.nextInt(10000)}"))
                .writeAsBytes(pageImage.bytes));
      }

      await page.close();
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  Future<String> findLocalPath() async {
    var externalStorageDirectory;
    var path;
    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    }
    path = externalStorageDirectory.path;

    return path;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
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
        leading: IconButton(
            icon: Icon(
              Icons.close_rounded,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: _body(),
      floatingActionButton: _floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _getImage(ImageSource.camera),
      child: Icon(Icons.camera),
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
