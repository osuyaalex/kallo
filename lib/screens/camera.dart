import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as Img;
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'dart:math' as math;


class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera,}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool isFlashOff = true;
  Timer? _timer;
  int _start = 4;
  double _opacity = 1.0; // Initial opacity value
  // Future<File> _cropAndResizeImage(File imageFile) async {
  //   final originalImage = Img.decodeImage(imageFile.readAsBytesSync());
  //
  //   // Calculate the size of the square crop
  //   final cropSize = originalImage!.width > originalImage.height
  //       ? originalImage.height
  //       : originalImage.width;
  //
  //   // Calculate the coordinates for the center crop
  //   final left = (originalImage.width - cropSize) ~/ 2;
  //   final top = (originalImage.height - cropSize) ~/ 2;
  //
  //   // Crop the image to a square
  //   final squareImage = Img.copyCrop(
  //     originalImage,
  //     x: left,
  //     y: top,
  //     width: cropSize,
  //     height: cropSize,
  //   );
  //
  //   // Resize the image to 224 x 224
  //   final resizedImage = Img.copyResize(
  //     squareImage,
  //     width: 224,
  //     height: 224,
  //   );
  //
  //   // Save the resized image to a new file
  //   final resizedImageFile = File('${imageFile.path}_resized.jpg');
  //   resizedImageFile.writeAsBytesSync(Img.encodeJpg(resizedImage));
  //
  //   return resizedImageFile;
  // }

  Future<String> _cropAndResizeImage(File imageFile) async {
    final originalImage = Img.decodeImage(imageFile.readAsBytesSync());

    // Calculate the size of the square crop
    final cropSize = originalImage!.width > originalImage.height
        ? originalImage.height
        : originalImage.width;

    // Calculate the coordinates for the center crop
    final left = (originalImage.width - cropSize) ~/ 2;
    final top = (originalImage.height - cropSize) ~/ 2;

    // Crop the image to a square
    final squareImage = Img.copyCrop(
      originalImage,
      x: left,
      y: top,
      width: cropSize,
      height: cropSize,
    );

    // Resize the image to 224 x 224
    final resizedImage = Img.copyResize(
      squareImage,
      width: 224,
      height: 224,
    );

    // Encode the resized image to a base64-encoded string
    final resizedImageString = base64Encode(Img.encodeJpg(resizedImage));

    return resizedImageString;
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if(!mounted) return;
        if (_start == 0) {
          _timer?.cancel();
          setState(() {
            _opacity = 0.0;
          });
        }else {
          setState(() {
            _start--;
          });
        }

      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  Future<void> _toggleFlash() async {
    if (_controller.value.isInitialized) {
      if (isFlashOff) {
        await _controller.setFlashMode(FlashMode.off);
      } else {
        await _controller.setFlashMode(FlashMode.always);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                SizedBox(
                  height: double.infinity,
                    child: CameraPreview(_controller)
                ),
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.3,
                      ),
                      Stack(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.width*0.85,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: SizedBox(
                                width: 200,
                                child: AnimatedOpacity(
                                  opacity: _opacity,
                                  duration: Duration(milliseconds: 600),
                                  child: Text(AppLocalizations.of(context)!.position,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 25

                                    ),
                                  ),
                                ),
                              ),
                            )
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(math.pi),
                                child: SvgPicture.asset(
                                  'asset/xlarge-svg.svg',
                                  height: 60,
                                ),
                              )
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                              child:  SvgPicture.asset('asset/xlarge-svg.svg', height: 60,),
                            //Image.asset('asset/curve-arrow-svgrepo-com (2).png', height: 25, color: Colors.white,)

                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Transform(
                              transform: Matrix4.identity()..scale(-1.0, 1.0)..scale(1.0, -1.0),
                              alignment: Alignment.center,
                              child: SvgPicture.asset('asset/xlarge-svg.svg', height: 60),
                            )

                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child:Transform(
                              transform: Matrix4.identity()..scale(1.0, -1.0),
                              alignment: Alignment.center,
                              child: SvgPicture.asset('asset/xlarge-svg.svg', height: 60),
                            )
                          ),
                        ],
                      )

                    ],
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height*0.05,
                    left: 20,
                    child:IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close, color: Colors.white, size: 30,)
                    ),
                ),
                Positioned(
                    top: MediaQuery.of(context).size.height*0.05,
                    left: 100,
                    child: IconButton(
                        onPressed: (){
                          setState(() {
                            isFlashOff = !isFlashOff;
                          });
                        }, icon: isFlashOff ? Icon(Icons.flash_off, color: Colors.white,):Icon(Icons.flash_auto, color: Colors.white,)
                    )

                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: CircleAvatar(
          backgroundColor: Color(0xff7F78D8).withOpacity(0.4),
          radius: 35,
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.white,
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                await _toggleFlash();
                await Future.delayed(Duration(milliseconds: 200));
                final image = await _controller.takePicture();
                // Get the captured image as a File
               // final File capturedImageFile = File(image.path);

                // Create an instance of ImageCropper
                //final imageCropper = ImageCropper();

                // Crop the captured image to a square shape
                // final croppedImage = await imageCropper.cropImage(
                //   sourcePath: image.path,
                //   aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                //   compressFormat: ImageCompressFormat.png,
                //   compressQuality: 90,
                //   aspectRatioPresets: [
                //     CropAspectRatioPreset.square
                //   ],
                //   maxHeight: 224,
                //   maxWidth: 224,
                // );
                final _imageFile = File(image.path);
                final croppedImage = await _cropAndResizeImage(_imageFile);
                  // Resize the image to 224x224


                  // Convert the compressed image (Uint8List) to a base64-encoded string
                  //final String compressedImageString = croppedImage

                  // Pass the resized image path back to the previous screen
                  Navigator.pop(context, croppedImage);
              } catch (e) {
                print('Error capturing image: $e');
              }
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}