import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as Img;
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

import '../classes/frame_clipper.dart';


class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera,}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;


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


  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                            width: MediaQuery.of(context).size.width*0.85,
                            child: Center(
                              child: Text(AppLocalizations.of(context)!.position,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                 // fontWeight: FontWeight.w700,
                                  fontSize: 17

                                ),
                              ),
                            )
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                              child: Image.asset('asset/curve-arrow-svgrepo-com (1).png', height: 25, color: Colors.white,)
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                              child: Image.asset('asset/curve-arrow-svgrepo-com (2).png', height: 25, color: Colors.white,)

                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Image.asset('asset/curve-arrow-svgrepo-com (3).png', height: 25, color: Colors.white,)
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Image.asset('asset/curve-arrow-svgrepo-com (4).png', height: 25, color: Colors.white,)
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
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white,)
                    ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(Icons.camera, color: Colors.black,),
          onPressed: () async {
            try {
              await _initializeControllerFuture;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}