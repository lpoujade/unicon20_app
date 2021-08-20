
import 'package:flutter/cupertino.dart';

class CalendarEvent {

  final String title;
  final String description;
  final int day;
  final int startHour;
  final int timeTaken;
  final Color backColor;

  CalendarEvent({
    required this.title,
    required this.description,
    required this.day,
    required this.startHour,
    required this.timeTaken,
    required this.backColor,
  }
      );


}