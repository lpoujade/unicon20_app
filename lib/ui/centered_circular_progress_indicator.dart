import 'package:flutter/material.dart';

class CenteredCircularProgressIndicator extends StatelessWidget {
  const CenteredCircularProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            margin: const EdgeInsets.all(10.0),
            width: 50.0,
            height: 50.0,
            child: const CircularProgressIndicator()));
  }
}
