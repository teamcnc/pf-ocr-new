import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ocr/utils/AppColors.dart';
import 'package:ocr/utils/camera_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_corner_detection/edge_detection.dart' as edge;

class ImageSliderView extends StatefulWidget {
  List<File> images;
  final Function(List<File> inputImage) onImage;
  ImageSliderView({Key key, this.images, this.onImage}) : super(key: key);

  @override
  _ImageSliderViewState createState() => _ImageSliderViewState();
}

List<File> imagesImageSlide = [];
List<Map<File, List<Offset>>> croppedListImageSlide = [];

class _ImageSliderViewState extends State<ImageSliderView> {
  PageController _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);
  Directory temporaryDirectory;

  @override
  void initState() {
    super.initState();
    copyImageToCroppingList().then((value) {
      setState(() {});
    });
  }

  Future<void> copyImageToCroppingList() async {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom]);
    if (widget.images != null) {
      temporaryDirectory = await getApplicationDocumentsDirectory();
      if (widget.images.length > imagesImageSlide.length) {
        for (int i = imagesImageSlide.isEmpty ? 0 : imagesImageSlide.length;
            i < widget.images.length;
            i++) {
          imagesImageSlide.add(widget.images[i]);
          File file =
              await widget.images[i].copy(temporaryDirectory.path + "/$i.jpg");
          print("image Slide===>" + file.path);
          Map<File, List<Offset>> d = {file: null};
          croppedListImageSlide.add(d);
        }
      }
    }
    return;
  }

  @override
  void dispose() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          ///Delete Icon
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                int index = _currentPageNotifier.value;
                imagesImageSlide.removeAt(index);
                croppedListImageSlide.removeAt(index);
                images.removeAt(index);
                if (imagesImageSlide.isEmpty) {
                  imagesImageSlide.clear();
                  croppedListImageSlide.clear();
                  Navigator.pop(context);
                } else {
                  _currentPageNotifier.value = imagesImageSlide.length - 1;
                  _pageController.jumpToPage(index);
                  setState(() {});
                }
              }),

          ///Crop icon
          if (imagesImageSlide.length > 0)
            IconButton(
                icon: Icon(Icons.crop_outlined),
                onPressed: () async {
                  int index = _currentPageNotifier.value;
                  Map<File, List<Offset>> d = croppedListImageSlide[index];

                  String fileName =
                      imagesImageSlide[index].path.split("/").last;
                  Directory directory =
                      await getApplicationDocumentsDirectory();
                  File tempFile = await d.keys
                      .elementAt(0)
                      .copy(directory.path + "/" + "abc" + fileName);

                  List<Offset> result =
                      await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ImageCropper(
                        file: tempFile, offsets: d.values.elementAt(0)),
                  ));
                  if (result != null) {
                    croppedListImageSlide[index]
                        .update(d.keys.elementAt(0), (value) => result);
                    imagesImageSlide[index] = tempFile;
                    print('Crop icon========>' + tempFile.path);
                    setState(() {});
                  }
                }),

          ///Done icon
          if (imagesImageSlide.length > 0)
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                if (imagesImageSlide.length > 0) {
                  widget.onImage(imagesImageSlide);
                } else {
                  EasyLoading.showToast("Images not capture!");
                }
              },
            )
        ],
      ),
      body: Stack(
        children: [
          ///This is the widget show full screen images
          Container(
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
                itemCount: imagesImageSlide.length,
                controller: _pageController,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.black,
                    child: Image.file(
                      imagesImageSlide[index],
                      fit: BoxFit.contain,
                    ),
                  );
                },
                onPageChanged: (int index) {
                  _currentPageNotifier.value = index;
                  setState(() {});
                }),
          ),

          ///this widget show all images in small box on the bottom left hand side
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 75,
              padding: const EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width * 0.8,
              color: Color(0x1A000000),
              child: ReorderableListView(
                scrollDirection: Axis.horizontal,
                onReorder: (int oldIndex, int newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  final item = imagesImageSlide.removeAt(oldIndex);
                  imagesImageSlide.insert(newIndex, item);
                  final item2 = croppedListImageSlide.removeAt(oldIndex);
                  croppedListImageSlide.insert(newIndex, item2);

                  _currentPageNotifier.value = newIndex;
                  _pageController.jumpToPage(newIndex);
                  // if (imagesImageSlide.length > 0) {
                  //   widget.onImage(imagesImageSlide);
                  // }
                  setState(() {});
                },
                children: List.generate(
                  imagesImageSlide.length,
                  (index) {
                    return GestureDetector(
                      key: ValueKey('Hey$index'),
                      onTap: () {
                        _pageController.jumpToPage(index);
                        _currentPageNotifier.value = index;
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: index == _currentPageNotifier.value
                                  ? AppColors.appTheame
                                  : Colors.transparent,
                              width: 2.0),
                        ),
                        width: 70,
                        height: 70,
                        child: Image.file(imagesImageSlide[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Container(
            // height: 50,
            // child: ListView.builder(
            //   itemCount: images.length,
            //   shrinkWrap: true,
            //   scrollDirection: Axis.horizontal,
            //   itemBuilder: (listContext, index) {
            //     return GestureDetector(
            //       onTap: () {
            //         _pageController.jumpToPage(index);
            //         _currentPageNotifier.value = index;
            //         setState(() {});
            //       },
            //       ///it give red color on the border
            //       child: Container(
            //         padding: EdgeInsets.only(right: 10),
            //         decoration: BoxDecoration(
            //             border: Border.all(
            //                 color: index == _currentPageNotifier.value
            //                     ? AppColors.appTheame
            //                     : Colors.transparent)),
            //         ///it will show the image
            //         child: Image.file(
            //           images[index],
            //           fit: BoxFit.cover,
            //           height: 50,
            //           width: 50,
            //         ),
            //       ),
            //     );
            //   },
            // ),
            // ),
          ),
        ],
      ),
    );
  }
}

class ImageCropper extends StatefulWidget {
  final File file;
  final List<Offset> offsets;

  const ImageCropper({Key key, this.file, this.offsets}) : super(key: key);

  @override
  State<ImageCropper> createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  List<Offset> pointsList = [];
  bool cropedImage = false, isImageLoaded = false;
  int touched = 1, rotation = 0;
  ui.Image image;

  @override
  void initState() {
    initImage().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    if (image != null) {
      image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appTheame,
        title: const Text("Cropper"),
        actions: [_iconDecider()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (isImageLoaded) {
      return Center(
        child: RotatedBox(
          quarterTurns: rotation,
          child: FittedBox(
            child: SizedBox(
              width: image.width.toDouble(),
              height: image.height.toDouble(),
              child: CustomPaint(
                painter: MyImagePainter(
                  image,
                  MediaQuery.of(context).size.height.toInt(),
                  cropedImage,
                  context,
                  pointsList,
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    touched = closeOffset(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    Offset click = Offset(
                        details.localPosition.dx, details.localPosition.dy);
                    setState(() {
                      if (touched != -1) {
                        if (touched % 2 != 0) {
                          Offset diff = (pointsList[touched] - click);
                          Offset back = (pointsList[(touched - 1) % 8] - diff);
                          Offset forward =
                              (pointsList[(touched + 1) % 8] - diff);
                          Offset dBack =
                              (pointsList[(touched - 3) % 8] + back) / 2;
                          Offset fForward =
                              (pointsList[(touched + 3) % 8] + forward) / 2;

                          if (back.dx > 0 &&
                              back.dx < image.width &&
                              back.dy > 0 &&
                              back.dy < image.height &&
                              click.dx > 0 &&
                              click.dx < image.width &&
                              click.dy > 0 &&
                              click.dy < image.height) {
                            pointsList.removeAt((touched - 1) % 8);
                            pointsList.insert((touched - 1) % 8, back);
                          }
                          if (forward.dx > 0 &&
                              forward.dx < image.width &&
                              forward.dy > 0 &&
                              forward.dy < image.height &&
                              click.dx > 0 &&
                              click.dx < image.width &&
                              click.dy > 0 &&
                              click.dy < image.height) {
                            pointsList.removeAt((touched + 1) % 8);
                            pointsList.insert((touched + 1) % 8, forward);
                          }

                          if (dBack.dx > 0 &&
                              dBack.dx < image.width &&
                              dBack.dy > 0 &&
                              dBack.dy < image.height &&
                              click.dx > 0 &&
                              click.dx < image.width &&
                              click.dy > 0 &&
                              click.dy < image.height) {
                            pointsList.removeAt((touched - 2) % 8);
                            pointsList.insert((touched - 2) % 8, dBack);
                          }
                          if (fForward.dx > 0 &&
                              fForward.dx < image.width &&
                              fForward.dy > 0 &&
                              fForward.dy < image.height &&
                              click.dx > 0 &&
                              click.dx < image.width &&
                              click.dy > 0 &&
                              click.dy < image.height) {
                            pointsList.removeAt((touched + 2) % 8);
                            pointsList.insert((touched + 2) % 8, fForward);
                          }
                        } else {
                          Offset back =
                              (pointsList[(touched + 6) % 8] + click) / 2;
                          Offset forward =
                              (pointsList[(touched + 2) % 8] + click) / 2;

                          if (back.dx > 0 &&
                              back.dx < image.width &&
                              back.dy > 0 &&
                              back.dy < image.height &&
                              click.dx > 0 &&
                              click.dx < image.width &&
                              click.dy > 0 &&
                              click.dy < image.height) {
                            pointsList.removeAt((touched + 7) % 8);
                            pointsList.insert((touched + 7) % 8, back);
                          }
                          if (forward.dx > 0 &&
                              forward.dx < image.width &&
                              forward.dy > 0 &&
                              forward.dy < image.height &&
                              click.dx > 0 &&
                              click.dx < image.width &&
                              click.dy > 0 &&
                              click.dy < image.height) {
                            pointsList.removeAt((touched + 1) % 8);
                            pointsList.insert((touched + 1) % 8, forward);
                          }
                        }
                        if (click.dx > 0 &&
                            click.dx < image.width &&
                            click.dy > 0 &&
                            click.dy < image.height) {
                          pointsList.removeAt(touched);
                          pointsList.insert(touched, click);
                        }
                      }
                    });
                  },
                  onPanEnd: (details) {
                    touched = -1;
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _iconDecider() {
    return IconButton(
        onPressed: () {
          cropedImage = true;
          setState(() {});
          proccessPop();
        },
        icon: const Icon(Icons.check));
  }

  void proccessPop() async {
    List<Offset> temp = [];
    temp.addAll(pointsList);
    for (int i = 0; i < 4; i++) {
      int index = i * 2;
      pointsList[index] = Offset(pointsList[index].dx / image.width,
          pointsList[index].dy / image.height);
    }
    edge.EdgeDetectionResult edgeDetectionResult = edge.EdgeDetectionResult(
      topLeft: pointsList[0],
      topRight: pointsList[2],
      bottomLeft: pointsList[6],
      bottomRight: pointsList[4],
    );
    edge.EdgeDetector()
        .processImage(
      widget.file.path,
      edgeDetectionResult,
      (rotation * 90.0 - 1),
    )
        .then((value) {
      imageCache?.clearLiveImages();
      imageCache?.clear();
      isImageLoaded = false;
      setState(() {});
      Navigator.pop(context, temp);
    });
  }

  int closeOffset(Offset click) {
    for (int i = 0; i < pointsList.length; i++) {
      if ((pointsList[i] - click).distance <
          (20.0 *
              (image.width.toDouble() / MediaQuery.of(context).size.width))) {
        return i;
      }
    }
    return -1;
  }

  Future<void> initImage() async {
    image = await loadImage(File(widget.file.path).readAsBytesSync());
    if (widget.offsets != null) {
      pointsList.addAll(widget.offsets);
    } else if (pointsList.isEmpty) {
      await _openCropper();
    }
  }

  loadImage(Uint8List img) {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (img2) {
      isImageLoaded = true;
      return completer.complete(img2);
    });
    return completer.future;
  }

  _openCropper() async {
    List<Offset> list = await points();
    Offset tl, tr, br, bl;
    setState(() {
      tl = list[0];
      tr = list[1];
      br = list[2];
      bl = list[3];
      pointsList.add(tl);
      pointsList.add((tl + tr) / 2);
      pointsList.add(tr);
      pointsList.add((tr + br) / 2);
      pointsList.add(br);
      pointsList.add((br + bl) / 2);
      pointsList.add(bl);
      pointsList.add((bl + tl) / 2);
    });
  }

  Future<List<Offset>> points() async {
    List<Offset> list = [];
    list.add(
      Offset(
        10 * (image.height / MediaQuery.of(context).size.width),
        10 * (image.height / MediaQuery.of(context).size.width),
      ),
    );
    list.add(
      Offset(
        image.width.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width)),
        10 * (image.height / MediaQuery.of(context).size.width),
      ),
    );
    list.add(
      Offset(
        image.width.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width)),
        image.height.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width)),
      ),
    );
    list.add(
      Offset(
        10 * (image.height / MediaQuery.of(context).size.width),
        image.height.toDouble() -
            (10 * (image.height / MediaQuery.of(context).size.width)),
      ),
    );
    // edge.EdgeDetectionResult result = await edge.EdgeDetector().detectEdges(widget.file.path);

    // print("================>Top Left ${result.topLeft} Top Right ${result.topRight} Bottom Left ${result.bottomLeft} Bottom Right ${result.bottomRight}");
    // list.clear();
    // list.add(result.topLeft);
    // list.add(result.topRight);
    // list.add(result.bottomLeft);
    // list.add(result.bottomRight);
    return list;
  }
}

class MyImagePainter extends CustomPainter {
  final ui.Image image;
  final int height;
  final bool crop;
  final BuildContext context;
  double angel = 1.5686;
  final List<Offset> offsetList;

  MyImagePainter(
    this.image,
    this.height,
    this.crop,
    this.context,
    this.offsetList,
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset(0.0, 0.0), Paint());
    if (offsetList.isNotEmpty && !crop) {
      Paint paint = Paint()
        ..strokeMiterLimit = 3.0
        ..color = Colors.white
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(ui.PointMode.polygon, offsetList, paint);

      canvas.drawLine(offsetList[0], offsetList[offsetList.length - 1], paint);

      canvas.drawPoints(
          ui.PointMode.points,
          offsetList,
          Paint()
            ..strokeWidth = 20 * (image.height / height)
            ..strokeCap = StrokeCap.round
            ..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
