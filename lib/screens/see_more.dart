import 'package:flutter/material.dart';

class SeeMore extends StatelessWidget {
  const SeeMore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.add)),
      ),
    );
  }
}
