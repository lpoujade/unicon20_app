/// Main app bar

import 'package:flutter/material.dart';

import '../config.dart' as config;

/// Top bar
var appBar = AppBar(
    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  Image.asset('res/topLogo.png', width: 75, height: 75, color: Colors.black),
  const Text(config.Strings.DrawTitle,
      style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontFamily: 'Futura',
          fontWeight: FontWeight.bold)),
  const SizedBox(width: 75)
]));
