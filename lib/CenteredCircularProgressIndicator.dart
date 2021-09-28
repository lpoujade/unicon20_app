import 'package:flutter/material.dart';

class CenteredCircularProgressIndicator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            margin: const EdgeInsets.all(10.0),
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator()
        ),
    );
  }
}
