import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:ocr/main.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView({
    Key key,
    @required this.title,
    @required this.customPaint,
    @required this.onImage,
    // this.initialDirection = CameraLensDirection.back
  }) : super(key: key);

  final String title;
  final CustomPaint customPaint;
  final Function(File inputImage) onImage;
  // final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  // CameraController _controller;
  File _image;
  PickedFile dummyImage;
  ImagePicker _imagePicker;
  int _cameraIndex = 0;
  var decodedImage;

  @override
  void initState() {
    super.initState();
    print("camera view init");
    _imagePicker = ImagePicker();
    // for (var i = 0; i < cameras.length; i++) {
    //   if (cameras[i].lensDirection == widget.initialDirection) {
    //     _cameraIndex = i;
    //   }
    // }
    // _startLiveFeed();
    _mode = ScreenMode.gallery;
    // _stopLiveFeed();
    _getImage(ImageSource.camera);
  }

  @override
  void dispose() {
    // _stopLiveFeed();
    print("camera view dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (dummyImage == null)
          return Future.value(true);
        else {
          _processPickedFile(dummyImage);
          return Future.value(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  dummyImage = null;
                  widget.onImage(_image);
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
      ),
    );
  }

  Widget _floatingActionButton() {
    if (_mode == ScreenMode.gallery) return null;
    // if (cameras.length == 1) return null;
    return Container(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: Icon(
            Platform.isIOS
                ? Icons.flip_camera_ios_outlined
                : Icons.flip_camera_android_outlined,
            size: 40,
          ),
          onPressed: _switchLiveCamera,
        ));
  }

  Widget _body() {
    Widget body;
    if (_mode == ScreenMode.liveFeed)
      body = _liveFeedBody();
    else
      body = _galleryBody();
    return body;
  }

  Widget _liveFeedBody() {
    // if (_controller?.value.isInitialized == false) {
    return Container();
    // }
    // return Container(
    //   color: Colors.black,
    //   child: Stack(
    //     fit: StackFit.expand,
    //     children: <Widget>[
    //       CameraPreview(_controller),
    //       if (widget.customPaint != null) widget.customPaint,
    //     ],
    //   ),
    // );
  }

  Widget _galleryBody() {
    // return _image != null
    //     ? Container(
    //         height: widget.customPaint != null
    //             ? widget.customPaint.size.height
    //             : null,
    //         width: widget.customPaint != null
    //             ? widget.customPaint.size.width
    //             : null,
    //         //     // MediaQuery.of(context).size.height - 80,
    //         //     // 400,
    //         //     double.tryParse(decodedImage.height.toString()),
    //         // width:
    //         //     // MediaQuery.of(context).size.width,
    //         //     // 300,
    //         //     double.tryParse(decodedImage.width.toString()),
    //         child: Stack(
    //           fit: StackFit.expand,
    //           children: <Widget>[
    //             Image.file(
    //               _image,
    //               fit: BoxFit.fill,
    //               // height: double.tryParse(decodedImage.height.toString()),
    //               // width: double.tryParse(decodedImage.width.toString()),
    //             ),
    //             if (widget.customPaint != null) widget.customPaint,
    //           ],
    //         ),
    //       )
    //     : Icon(
    //         Icons.image,
    //         size: 200,
    //       );

    return ListView(shrinkWrap: true, children: [
      _image != null
          ? Container(
              // height: widget.customPaint != null
              //     ? widget.customPaint.size.height
              //     : null,
              // width: widget.customPaint != null
              //     ? widget.customPaint.size.width
              //     : null,
              height: MediaQuery.of(context).size.height - 80,
              // 400,
              // double.tryParse(decodedImage.height.toString()),
              width: MediaQuery.of(context).size.width,
              // 300,
              // double.tryParse(decodedImage.width.toString()),
              child:
                  // Stack(
                  //   fit: StackFit.expand,
                  //   children: <Widget>[
                  Image.file(
                _image,
                fit: BoxFit.contain,
                // height: double.tryParse(decodedImage.height.toString()),
                // width: double.tryParse(decodedImage.width.toString()),
              ),
              //     if (widget.customPaint != null) widget.customPaint,
              //   ],
              // ),
            )
          : Icon(
              Icons.image,
              size: 200,
            ),
      // Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 16),
      //   child: ElevatedButton(
      //     child: Text('From Gallery'),
      //     onPressed: () => _getImage(ImageSource.gallery),
      //   ),
      // ),
      // Padding(
      //   padding: EdgeInsets.symmetric(horizontal: 16),
      //   child: ElevatedButton(
      //     child: Text('Take a picture'),
      //     onPressed: () => _getImage(ImageSource.camera),
      //   ),
      // ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.getImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    } else {
      print('No image selected.');
      Navigator.pop(context);
    }
    setState(() {});
  }

  void _switchScreenMode() async {
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      // await _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      // await _startLiveFeed();
    }
    setState(() {});
  }

  // Future _startLiveFeed() async {
  //   final camera = cameras[_cameraIndex];
  //   _controller = CameraController(
  //     camera,
  //     ResolutionPreset.low,
  //     enableAudio: false,
  //   );
  //   _controller?.initialize().then((_) {
  //     if (!mounted) {
  //       return;
  //     }
  //     _controller?.startImageStream(_processCameraImage);
  //     setState(() {});
  //   });
  // }

  // Future _stopLiveFeed() async {
  //   await _controller?.stopImageStream();
  //   await _controller?.dispose();
  //   _controller = null;
  // }

  Future _switchLiveCamera() async {
    if (_cameraIndex == 0)
      _cameraIndex = 1;
    else
      _cameraIndex = 0;
    // await _stopLiveFeed();
    // await _startLiveFeed();
  }

  Future _processPickedFile(PickedFile pickedFile) async {
    dummyImage = pickedFile;
    ImageCropper imageCropper = ImageCropper();
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
    // _image = await ImageCropper.cropImage(
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
    if (_image == null) {
      _getImage(ImageSource.camera);
    } else {
      decodedImage = await decodeImageFromList(_image.readAsBytesSync());
      setState(() {});
      // _image.readAsBytes().then((value) async {
      //   var decodedImage = await decodeImageFromList(_image.readAsBytesSync());
      // InputImage.fromBytes(bytes: value, inputImageData: InputImageData(imageRotation: InputImageRotation.Rotation_0deg,size: Size(double.tryParse(decodedImage.width.toString()), double.tryParse(decodedImage.height.toString())), inputImageFormat: InputImageFormat.BGRA8888));

      // });
      // final inputImage = InputImage.fromFilePath(_image.path);
      // widget.onImage(_image);
    }
    // _image = File(pickedFile.path);
  }

//   Future _processCameraImage(CameraImage image) async {
//     final WriteBuffer allBytes = WriteBuffer();
//     for (Plane plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();

//     final Size imageSize =
//         Size(image.width.toDouble(), image.height.toDouble());

//     final camera = cameras[_cameraIndex];
//     final imageRotation =
//         InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
//             InputImageRotation.Rotation_0deg;

//     final inputImageFormat =
//         InputImageFormatMethods.fromRawValue(image.format.raw) ??
//             InputImageFormat.NV21;

//     final planeData = image.planes.map(
//       (Plane plane) {
//         return InputImagePlaneMetadata(
//           bytesPerRow: plane.bytesPerRow,
//           height: plane.height,
//           width: plane.width,
//         );
//       },
//     ).toList();

//     final inputImageData = InputImageData(
//       size: imageSize,
//       imageRotation: imageRotation,
//       inputImageFormat: inputImageFormat,
//       planeData: planeData,
//     );

//     final inputImage =
//         InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

//     widget.onImage(inputImage);
//   }
}
