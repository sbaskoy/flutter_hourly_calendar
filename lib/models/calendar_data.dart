import 'package:flutter/material.dart';

class CalendarData<T> {
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String title;
  final String id;
  final T data;

  CalendarData(
      {required this.startTime,
      required this.endTime,
      required this.data,
      required this.color,
      required this.title,
      required this.id});
}
