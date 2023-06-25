import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCupertinoSnackBar({
  required BuildContext context,
  required String message,
  int durationMillis = 3000,
}) {
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).size.height*0.1,
      left: 8.0,
      right: 8.0,
      child: CupertinoPopupSurface(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 15.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
  Future.delayed(
    Duration(milliseconds: durationMillis),
    overlayEntry.remove,
  );
  Overlay.of(Navigator.of(context).context).insert(overlayEntry);
}