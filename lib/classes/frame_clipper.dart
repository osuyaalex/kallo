import 'package:flutter/cupertino.dart';

class FrameClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final borderWidth = 4.0; // Replace with your desired border width

    path.addRect(Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    ));

    return path;
  }

  @override
  bool shouldReclip(FrameClipper oldClipper) => false;
}
