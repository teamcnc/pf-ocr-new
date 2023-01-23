// import 'dart:io';
// import 'dart:typed_data';

// import 'package:custom_camera/my_cameranew.dart';
// import 'package:flutter/material.dart';

// class CustomCamera extends StatefulWidget {
//   const CustomCamera({Key key}) : super(key: key);

//   @override
//   _CustomCameraState createState() => _CustomCameraState();
// }

// class _CustomCameraState extends State<CustomCamera> {
//   List<String> pictureSizes = [];
//   String imagePath;
//   Uint8List bytes = Uint8List(0);
//   TextEditingController _inputController;
//   TextEditingController outputController;
//   MyCameraController cameraController;

//   @override
//   initState() {
//     super.initState();
//     this._inputController = new TextEditingController();
//     this.outputController = new TextEditingController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 Container(
//                   color: Colors.transparent,
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           Icons.flash_off_outlined,
//                           color: Colors.black,
//                         ),
//                         onPressed: () {
//                           cameraController.setFlashType(FlashType.off);
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.flash_on,
//                           color: Colors.black,
//                         ),
//                         onPressed: () {
//                           cameraController.setFlashType(FlashType.torch);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 TextField(
//                   controller: this.outputController,
//                   maxLines: 2,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.wrap_text),
//                     hintText:
//                         'The barcode or qrcode you scan will be displayed in this area.',
//                     hintStyle: TextStyle(fontSize: 15),
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 7, vertical: 15),
//                   ),
//                 ),
//                 Expanded(
//                     child: Container(
//                   child: MyCamera(
//                     onCameraCreated: _onCameraCreated,
//                     onImageCaptured: (String path) {
//                       print("onImageCaptured => " + path);
//                       if (this.mounted)
//                         setState(() {
//                           imagePath = path;
//                         });
//                     },
//                     cameraPreviewRatio: CameraPreviewRatio.r16_9,
//                   ),
//                 )),
//               ],
//             ),
//             Positioned(
//               bottom: 16.0,
//               left: 16.0,
//               child: imagePath != null
//                   ? Container(
//                       width: 100.0,
//                       height: 100.0,
//                       child: Image.file(File(imagePath)))
//                   : Icon(Icons.image),
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             FloatingActionButton(
//               heroTag: 1,
//               child: Icon(Icons.switch_camera),
//               onPressed: () async {
//                 await cameraController.switchCamera();
//                 List<FlashType> types = await cameraController.getFlashType();
//               },
//             ),
//             Container(height: 16.0),
//             FloatingActionButton(
//                 heroTag: 2,
//                 child: Icon(Icons.camera_alt),
//                 onPressed: () {
//                   cameraController.captureImage();
//                 }),
//             Container(height: 16.0),
//             FloatingActionButton(
//                 heroTag: 3,
//                 child: Icon(Icons.scanner),
//                 onPressed: () {
//                   _scan();
//                 }),
//           ]),
//     );
//   }

//   Future _scan() async {
//     String barcode = await cameraController.scan();

//     if (barcode == null) {
//       print('nothing return.');
//     } else {
//       this.outputController.text = barcode;
//       print(barcode);
//     }
//   }

//   _onCameraCreated(MyCameraController controller) {
//     this.cameraController = controller;

//     this.cameraController.getPictureSizes().then((pictureSizes) {
//       setState(() {
//         this.pictureSizes = pictureSizes;
//       });
//     });
//   }
// }

// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// // import 'package:tesseract_ocr/tesseract_ocr.dart';
// import 'dart:ui';

// // import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// // import 'package:flutter_camera_ml_vision/flutter_camera_ml_vision.dart';

// class CustomCamera extends StatefulWidget {
//   @override
//   _CustomCameraState createState() => _CustomCameraState();
// }

// class _CustomCameraState extends State<CustomCamera> {
//   bool _scanning = false;
//   String _extractText = '';
//   int _scanTime = 0;
//   List<String> data = [];

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('Tesseract OCR'),
//           ),
//           body: Container(
//             padding: EdgeInsets.all(16),
//             child: ListView(
//               children: <Widget>[
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     RaisedButton(
//                       child: Text('Select image'),
//                       onPressed: () async {
//                         // var results = await FilePicker.platform.pickFiles(
//                         //     type: FileType.image, allowMultiple: false);
//                         // // await FilePicker.getFilePath(type: FileType.image);
//                         // var file = results.paths[0];
//                         // _scanning = true;
//                         // setState(() {});

//                         // var watch = Stopwatch()..start();
//                         // // _extractText = await TesseractOcr.extractText(file);
//                         // _scanTime = watch.elapsedMilliseconds;

//                         // _scanning = false;
//                         // setState(() {});
//                         //           final barcode = await Navigator.of(context).push<Barcode>(
//                         //   MaterialPageRoute(
//                         //     builder: (c) {
//                         //       return ScanPage();
//                         //     },
//                         //   ),
//                         // );
//                         // if (barcode == null) {
//                         //   return;
//                         // }

//                         // setState(() {
//                         //   data.add(barcode.displayValue);
//                         // });
//                       },
//                     ),
//                     // It doesn't spin, because scanning hangs thread for now
//                     _scanning
//                         ? SpinKitCircle(
//                             color: Colors.black,
//                           )
//                         : Icon(Icons.done),
//                   ],
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 Text(
//                   'Scanning took $_scanTime ms',
//                   style: TextStyle(color: Colors.red),
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 Center(child: SelectableText(_extractText)),
//               ],
//             ),
//           )),
//     );
//   }
// }

// class ScanPage extends StatefulWidget {
//   @override
//   _ScanPageState createState() => _ScanPageState();
// }

// class _ScanPageState extends State<ScanPage> {
//   bool resultSent = false;
//   BarcodeDetector detector = FirebaseVision.instance.barcodeDetector();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           child: CameraMlVision<List<Barcode>>(
//             overlayBuilder: (c) {
//               return Container(
//                 decoration: ShapeDecoration(
//                   shape: _ScannerOverlayShape(
//                     borderColor: Theme.of(context).primaryColor,
//                     borderWidth: 3.0,
//                   ),
//                 ),
//               );
//             },
//             detector: detector.detectInImage,
//             onResult: (List<Barcode> barcodes) {
//               if (!mounted ||
//                   resultSent ||
//                   barcodes == null ||
//                   barcodes.isEmpty) {
//                 return;
//               }
//               resultSent = true;
//               Navigator.of(context).pop<Barcode>(barcodes.first);
//             },
//             onDispose: () {
//               detector.close();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ScannerOverlayShape extends ShapeBorder {
//   final Color borderColor;
//   final double borderWidth;
//   final Color overlayColor;

//   _ScannerOverlayShape({
//     this.borderColor = Colors.white,
//     this.borderWidth = 1.0,
//     this.overlayColor = const Color(0x88000000),
//   });

//   @override
//   EdgeInsetsGeometry get dimensions => EdgeInsets.all(10.0);

//   @override
//   Path getInnerPath(Rect rect, {TextDirection textDirection}) {
//     return Path()
//       ..fillType = PathFillType.evenOdd
//       ..addPath(getOuterPath(rect), Offset.zero);
//   }

//   @override
//   Path getOuterPath(Rect rect, {TextDirection textDirection}) {
//     Path _getLeftTopPath(Rect rect) {
//       return Path()
//         ..moveTo(rect.left, rect.bottom)
//         ..lineTo(rect.left, rect.top)
//         ..lineTo(rect.right, rect.top);
//     }

//     return _getLeftTopPath(rect)
//       ..lineTo(
//         rect.right,
//         rect.bottom,
//       )
//       ..lineTo(
//         rect.left,
//         rect.bottom,
//       )
//       ..lineTo(
//         rect.left,
//         rect.top,
//       );
//   }

//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
//     const lineSize = 30;

//     final width = rect.width;
//     final borderWidthSize = width * 10 / 100;
//     final height = rect.height;
//     final borderHeightSize = height - (width - borderWidthSize);
//     final borderSize = Size(borderWidthSize / 2, borderHeightSize / 2);

//     var paint = Paint()
//       ..color = overlayColor
//       ..style = PaintingStyle.fill;

//     canvas
//       ..drawRect(
//         Rect.fromLTRB(
//             rect.left, rect.top, rect.right, borderSize.height + rect.top),
//         paint,
//       )
//       ..drawRect(
//         Rect.fromLTRB(rect.left, rect.bottom - borderSize.height, rect.right,
//             rect.bottom),
//         paint,
//       )
//       ..drawRect(
//         Rect.fromLTRB(rect.left, rect.top + borderSize.height,
//             rect.left + borderSize.width, rect.bottom - borderSize.height),
//         paint,
//       )
//       ..drawRect(
//         Rect.fromLTRB(
//             rect.right - borderSize.width,
//             rect.top + borderSize.height,
//             rect.right,
//             rect.bottom - borderSize.height),
//         paint,
//       );

//     paint = Paint()
//       ..color = borderColor
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = borderWidth;

//     final borderOffset = borderWidth / 2;
//     final realReact = Rect.fromLTRB(
//         borderSize.width + borderOffset,
//         borderSize.height + borderOffset + rect.top,
//         width - borderSize.width - borderOffset,
//         height - borderSize.height - borderOffset + rect.top);

//     //Draw top right corner
//     canvas
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.right, realReact.top)
//             ..lineTo(realReact.right, realReact.top + lineSize),
//           paint)
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.right, realReact.top)
//             ..lineTo(realReact.right - lineSize, realReact.top),
//           paint)
//       ..drawPoints(
//         PointMode.points,
//         [Offset(realReact.right, realReact.top)],
//         paint,
//       )

//       //Draw top left corner
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.left, realReact.top)
//             ..lineTo(realReact.left, realReact.top + lineSize),
//           paint)
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.left, realReact.top)
//             ..lineTo(realReact.left + lineSize, realReact.top),
//           paint)
//       ..drawPoints(
//         PointMode.points,
//         [Offset(realReact.left, realReact.top)],
//         paint,
//       )

//       //Draw bottom right corner
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.right, realReact.bottom)
//             ..lineTo(realReact.right, realReact.bottom - lineSize),
//           paint)
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.right, realReact.bottom)
//             ..lineTo(realReact.right - lineSize, realReact.bottom),
//           paint)
//       ..drawPoints(
//         PointMode.points,
//         [Offset(realReact.right, realReact.bottom)],
//         paint,
//       )

//       //Draw bottom left corner
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.left, realReact.bottom)
//             ..lineTo(realReact.left, realReact.bottom - lineSize),
//           paint)
//       ..drawPath(
//           Path()
//             ..moveTo(realReact.left, realReact.bottom)
//             ..lineTo(realReact.left + lineSize, realReact.bottom),
//           paint)
//       ..drawPoints(
//         PointMode.points,
//         [Offset(realReact.left, realReact.bottom)],
//         paint,
//       );
//   }

//   @override
//   ShapeBorder scale(double t) {
//     return _ScannerOverlayShape(
//       borderColor: borderColor,
//       borderWidth: borderWidth,
//       overlayColor: overlayColor,
//     );
//   }
// }


import 'dart:io';

import 'package:flutter/material.dart';

import 'VisionDetectorViews/text_detector_view.dart';

class CustomCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google ML Kit Demo App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ExpansionTile(
                    title: const Text("Vision"),
                    children: [
                      // CustomCard(
                      //   'Image Label Detector',
                      //   ImageLabelView(),
                      //   featureCompleted: true,
                      // ),
                      // CustomCard(
                      //   'Face Detector',
                      //   FaceDetectorView(),
                      //   featureCompleted: true,
                      // ),
                      // CustomCard(
                      //   'Barcode Scanner',
                      //   BarcodeScannerView(),
                      //   featureCompleted: true,
                      // ),
                      // CustomCard(
                      //   'Pose Detector',
                      //   PoseDetectorView(),
                      //   featureCompleted: true,
                      // ),
                      // CustomCard(
                      //   'Digital Ink Recogniser',
                      //   DigitalInkView(),
                      //   featureCompleted: true,
                      // ),
                      CustomCard(
                        'Text Detector',
                        TextDetectorView(),
                        featureCompleted: true,
                      ),
                      // CustomCard(
                      //   'Object Detector',
                      //   ObjectDetectorView(),
                      // ),
                      // CustomCard(
                      //   'Remote Model Manager',
                      //   RemoteModelView(),
                      //   featureCompleted: true,
                      // )
                    ],
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // ExpansionTile(
                  //   title: const Text("Natural Language"),
                  //   children: [
                  //     CustomCard(
                  //         'Language Identifier', LanguageIdentifierView()),
                  //     CustomCard(
                  //         'Language Translator', LanguageTranslatorView()),
                  //     CustomCard('Entity Extractor', EntityExtractionView()),
                  //     CustomCard('Smart Reply', SmartReplyView())
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage,
      {this.featureCompleted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (Platform.isIOS && !featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'This feature has not been implemented for iOS yet')));
          } else
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _viewPage));
        },
      ),
    );
  }
}