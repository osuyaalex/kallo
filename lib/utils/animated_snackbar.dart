import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAnimatedCupertinoSnackBar({
  required BuildContext context,
  required String message,
  int durationMillis = 3000,
}) {
  const animationDurationMillis = 200;
  final overlayEntry = OverlayEntry(
    builder: (context) => _CupertinoSnackBar(
      message: message,
      animationDurationMillis: animationDurationMillis,
      waitDurationMillis: durationMillis,
    ),
  );
  Future.delayed(
    Duration(milliseconds: durationMillis + 2 * animationDurationMillis),
    overlayEntry.remove,
  );
  Overlay.of(Navigator.of(context).context).insert(overlayEntry);
}

class _CupertinoSnackBar extends StatefulWidget {
  final String message;
  final int animationDurationMillis;
  final int waitDurationMillis;

  const _CupertinoSnackBar({
    Key? key,
    required this.message,
    required this.animationDurationMillis,
    required this.waitDurationMillis,
  }) : super(key: key);

  @override
  State<_CupertinoSnackBar> createState() => _CupertinoSnackBarState();
}

class _CupertinoSnackBarState extends State<_CupertinoSnackBar> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => setState(() => _show = true));
    Future.delayed(
      Duration(
        milliseconds: widget.waitDurationMillis,
      ),
          () {
        if (mounted) {
          setState(() => _show = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      bottom: _show ? MediaQuery.of(context).size.height*0.1 : MediaQuery.of(context).size.height*0.06,
      left: 8.0,
      right: 8.0,
      curve: _show ? Curves.linearToEaseOut : Curves.easeInToLinear,
      duration: Duration(milliseconds: widget.animationDurationMillis),
      child: CupertinoPopupSurface(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 8.0,
          ),
          child: Text(
            widget.message,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.purple,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}