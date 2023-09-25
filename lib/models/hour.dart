class CalendarHour {
  late bool isShift;
  late int hour;
  late String text;
  CalendarHour(this.hour) {
    text = "${hour.toString().padLeft(2, '0')}:00";
    isShift = hour < 8 || hour >= 18;
  }
}
