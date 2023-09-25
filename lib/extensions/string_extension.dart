import 'package:moment_dart/moment_dart.dart';

extension StringExtension on String {
  String get doubleLength => (length == 1 ? "0$this" : this);
  DateTime? parseDateTimeWithTimeString(String time) {
    if (isEmpty) {
      return null;
    } else {
      if (time.isEmpty) {
        return DateTime.parse(this);
      } else {
        return DateTime.parse("$this $time");
      }
    }
  }

  String format([String? format]) => Moment.tryParse(this)?.format(format ?? "DD.MM.YY HH:mm") ?? "Tanımsız";

  List<String> get secondsToTime {
    int seconds = int.parse(this);
    var hour = seconds ~/ 3600;
    var minute = (seconds % 3600) ~/ 60;
    var second = (seconds % 3600) % 60;
    return [hour.toString(), minute.toString(), second.toString()];
  }

  String get timeIsZeroString {
    return this == "00:00:00" ? "" : this;
  }

  String get getMySqlTime {
    var now = DateTime.now();
    return "${now.year.toString().doubleLength}-${now.month.toString().doubleLength}-${now.day.toString().doubleLength} ${now.hour.toString().doubleLength}:${now.minute.toString().doubleLength}:${now.second.toString().doubleLength}";
  }
}

extension NullableStringExtension on String? {
  bool get isNotNullOrEmpty {
    if (this == null) return false;
    if (this == "") return false;
    if (this == " ") return false;
    if (this == "  ") return false;
    return true;
  }

  bool isContains(String other) {
    return this?.toLowerCase().contains(other.toLowerCase()) ?? false;
  }

  String format([String? format]) => Moment.tryParse(this ?? '')?.toLocal().format(format ?? "DD.MM.YY HH:mm") ?? "";

  String dateTimeFormat() => Moment.tryParse(this ?? '')?.toLocal().format("DD.MM.YY HH:mm") ?? "";
  String dateTimeLongYearFormat() => Moment.tryParse(this ?? '')?.toLocal().format("DD.MM.YY HH:mm") ?? "";
  String timeFormat() => Moment.tryParse(this ?? '')?.toLocal().format("HH:mm") ?? "";
  String dateFormat() => Moment.tryParse(this ?? '')?.toLocal().format("DD.MM.YY") ?? "";
  String dateFormatLong() => Moment.tryParse(this ?? '')?.toLocal().format("DD.MM.YYYY") ?? "";
  String dateFormatLongWithDayName() => Moment.tryParse(this ?? '')?.toLocal().format("DD.MM.YYYY dddd") ?? "";
  String mySqlFormat() => Moment.tryParse(this ?? '')?.format("YYYY-MM-DD HH:mm") ?? "";
}
