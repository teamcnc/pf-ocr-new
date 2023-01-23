import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/image_slide.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen(
      {Key key, this.docNumber, this.fileName, this.type, this.incomingFile})
      : super(key: key);

  final String docNumber, type, fileName;
  final File incomingFile;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

List<File> images = [];

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  String filename = '';
  FlashMode flashMode = FlashMode.always;
  var selectedFilePickType;

  @override
  void initState() {
    super.initState();
    print('camera view init called');
    setCamera();
    if (widget.incomingFile != null) {
      pdfToImage(widget.incomingFile);
    }
    selectedFilePickType = "camera";
    // Future.delayed(Duration(seconds: 1), () => getFilePickType());
  }

  getFilePickType() async {
    await showModalBottomSheet(
        context: context,
        isDismissible: false,
        builder: (bottomContext) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Center(child: Text("Camera")),
                  onTap: () {
                    setState(() {
                      selectedFilePickType = "camera";
                    });
                    Navigator.pop(bottomContext);
                  },
                ),
                ListTile(
                  title: Center(child: Text("Gallery")),
                  onTap: () {
                    setState(() {
                      selectedFilePickType = "gallery";
                    });
                    Navigator.pop(bottomContext);
                  },
                )
              ],
            ));
    if (selectedFilePickType == "gallery") {
      _getImage();
    }
  }

  Future _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      images.add(File(pickedFile.path));
    } else {
      print('No image selected.');
      // Navigator.pop(context);
    }
    setState(() {});
  }

  setCamera() async {
    final cameras = await availableCameras();
    var selectedCamera;

    if (cameras.length > 1 &&
        _controller != null &&
        _controller.description.lensDirection == CameraLensDirection.back) {
      selectedCamera = cameras.last;
    } else {
      selectedCamera = cameras.first;
    }

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.ultraHigh,
    );
    print("_controller.cameraId=${_controller.description.lensDirection}");

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    setState(() {});
  }

  setFlash() async {
    try {
      await _controller.setFlashMode(FlashMode.off);
    } catch (e) {
      print("EEEEEEEEEEEEEEEEE+=>$e");
    }
  }

  pdfToImage(File incoming) async {
    EasyLoading.show();
    final document = await PdfDocument.openFile(incoming.path);
    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage =
          await page.render(width: page.width, height: page.height);
      var rng = new Random();
      var isPermissionGranted = await checkPermission();
      if (isPermissionGranted == PermissionStatus.granted) {
        images.add(
            await File((await findBasePath() + "/${rng.nextInt(10000)}.jpg"))
                .writeAsBytes(pageImage.bytes));
      }
      await page.close();
    }
    if (this.mounted) {
      setState(() {});
    }
    EasyLoading.dismiss();
  }

  Future<String> findBasePath() async {
    var externalStorageDirectory;
    var path;
    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getExternalStorageDirectory();
    }
    path = externalStorageDirectory.path;

    return path;
  }

  Future<String> findLocalPath() async {
    var externalStorageDirectory;
    var path;

    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getExternalStorageDirectory();
    }
    path = externalStorageDirectory.path;
    Directory _appDocDirFolderstart = Directory('${path}/Uploads/');
    if (await _appDocDirFolderstart.exists()) {
      //if folder already exists return path
    } else {
      //if folder not exists create folder and then return its path
      _appDocDirFolderstart =
          await _appDocDirFolderstart.create(recursive: true);
    }

    Directory _appDocDirFolder =
        Directory('${_appDocDirFolderstart.path}${widget.type}/');
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
    } else {
      //if folder not exists create folder and then return its path
      _appDocDirFolder = await _appDocDirFolder.create(recursive: true);
    }

    _appDocDirFolder =
        Directory('${_appDocDirFolder.path}${widget.docNumber}/');
    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      // filename = "${await _appDocDirFolder.list().length + 1}";
      await _appDocDirFolder.delete(recursive: true);
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      // filename = "${await _appDocDirFolder.list().length + 1}";
      return _appDocDirNewFolder.path;
    }
  }

  Future<PermissionStatus> checkPermission() async {
    var statuses = await Permission.storage.request();
    return statuses;
  }

  Future<void> deleteUnusedFiles(List<File> i) async {
    try {
      var isPermissionGranted = await checkPermission();
      if (isPermissionGranted == PermissionStatus.granted) {
        var uploadsPath = await findDirectoryPath();
        if (uploadsPath != null) {
          Directory docDir = Directory(uploadsPath);
          List<FileSystemEntity> uploadsEntities = await docDir.list().toList();
          final Iterable<Directory> uploadsDirectories =
              uploadsEntities.whereType<Directory>();
          for (int i = 0; i < uploadsEntities.length; i++) {
            if (await uploadsEntities[i].exists()) {
              uploadsDirectories.forEach(
                (element) async {
                  if (element.path != uploadsEntities[i].path) {
                    print('deleteUnusedFiles===>' + uploadsEntities[i].path);
                    if (await uploadsEntities[i].exists()) {
                      uploadsEntities[i].delete();
                    }
                  }
                },
              );
            }
          }
          await deleteCacheFile(i);
        }
      }
    } catch (e) {
      print("Error two====>" + e.toString());
    }
  }

  deleteCacheFile(List<File> i) {
    try {
      if (i.isNotEmpty) {
        i.forEach((element) async {
          if (await element.exists()) {
            await element.delete();
          }
        });
      }
    } catch (e) {
      print('deleteCacheFile===>' + e.toString());
    }
  }

  Future<String> findDirectoryPath() async {
    var externalStorageDirectory;
    var path;
    if (Platform.isIOS) {
      externalStorageDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalStorageDirectory = await getExternalStorageDirectory();
    }
    path = externalStorageDirectory.path;

    return path;
  }

  void storeFile(List<File> i) async {
    var isPermissionGranted = await checkPermission();
    if (isPermissionGranted == PermissionStatus.granted) {
      try {
        var path = await findLocalPath();
        var finalPdf = pdfConverter(i);
        var rng = new Random();
        filename = "${rng.nextInt(10000)}.pdf";
        final pdffile = File(path + filename);
        await pdffile.writeAsBytes(await finalPdf.save());
        await deleteUnusedFiles(i);
      } catch (e) {
        print("Error one=====>" + e.toString());
      } finally {
        EasyLoading.dismiss();
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
    } else {
      EasyLoading.showToast("No permission to access files");
    }
  }

  pw.Document pdfConverter(List<File> i) {
    print("pdfConverter=========>" + i.toString());
    final pdf = pw.Document();
    i.forEach((element) {
      final image = pw.MemoryImage(element.readAsBytesSync());
      pdf.addPage(
        pw.Page(
            margin: pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            clip: true,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image)); // Center
            }),
      ); // Page
    });
    return pdf;
  }

  @override
  void dispose() {
    print('camera view dispose called');
    // Dispose of the controller when the widget is disposed.
    imagesImageSlide.clear();
    croppedListImageSlide.clear();
    _controller.dispose();
    images.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.appTheame,
        title: const Text('Take a picture'),
      ),
      body: selectedFilePickType == "camera"
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    (snapshot.connectionState == ConnectionState.done)
                        ? Row(children: [
                            Expanded(child: CameraPreview(_controller))
                          ])
                        : const Center(child: CircularProgressIndicator()),
                    if (images.length > 0)
                      Positioned(
                        bottom: 20,
                        child: MaterialButton(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImageSliderView(
                                          images: images,
                                          onImage: (files) {
                                            if (files.length > 0) {
                                              storeFile(files);
                                            } else
                                              EasyLoading.showToast(
                                                  "Images not capture!");
                                          })));
                              if (this.mounted) {
                                setState(() {});
                              }
                            },
                            child: Image.file(
                              images.last,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            )),
                      )
                  ],
                );
              },
            )
          : Container(
              color: Colors.white,
              child: Center(
                child: ElevatedButton(
                  child: Text("Open Camera"),
                  onPressed: () {
                    setState(() {
                      selectedFilePickType = "camera";
                    });
                  },
                ),
              ),
            ),
      floatingActionButtonLocation: selectedFilePickType != null
          ? FloatingActionButtonLocation.centerDocked
          : null,
      floatingActionButton: selectedFilePickType != null
          ? FloatingActionButton(
              backgroundColor: AppColors.appTheame,
              onPressed: () async {
                if (selectedFilePickType == "camera") {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  try {
                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;

                    // Attempt to take a picture and get the file `image`
                    // where it was saved.
                    final image = await _controller.takePicture();

                    images.add(File(image.path));

                    // If the picture was taken, display it on a new screen.
                    // await Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => DisplayPictureScreen(
                    //       // Pass the automatically generated path to
                    //       // the DisplayPictureScreen widget.
                    //       imagePath: image.path,
                    //     ),
                    //   ),
                    // );
                    setState(() {});
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                } else if (selectedFilePickType == "gallery") {
                  _getImage();
                }
              },
              child: Icon(selectedFilePickType == "camera"
                  ? Icons.camera_alt
                  : Icons.image_rounded),
            )
          : null,
      bottomNavigationBar: selectedFilePickType != null
          ? BottomAppBar(
              // elevation: 10.0,
              color: AppColors.appTheame,
              shape: CircularNotchedRectangle(),
              notchMargin: 15,
              child: Container(
                // color: Colors.white,
                height: 65,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ///Gallery Icon
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: IconButton(
                        padding: EdgeInsets.all(2),
                        onPressed: () {
                          _getImage();
                        },
                        icon: Icon(
                          Icons.image_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                    ///Done Icon
                    if (images.length > 0)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MaterialButton(
                            minWidth: 40,
                            onPressed: () async {
                              setState(() {});
                            },
                            child: Container(
                                child: IconButton(
                                    icon: Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ImageSliderView(
                                                      images: images,
                                                      onImage: (files) {
                                                        if (files.length > 0) {
                                                          storeFile(files);
                                                        } else
                                                          EasyLoading.showToast(
                                                              "Images not capture!");
                                                      })));
                                      if (this.mounted) {
                                        setState(() {});
                                      }
                                    })),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, @required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Display the Picture',
        style: TextStyle(color: Colors.white),
      )),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
