extension StringExtension on DateTime {
  bool isBetweenDaily(DateTime v1, DateTime v2) {
    return copyWith(hour: 1).isAfter(v1.copyWith(hour: 0)) && copyWith(hour: 0).isBefore(v2.copyWith(hour: 1));
  }

  DateTime getOnlyDate() {
    return copyWith(hour: 0, minute: 0, second: 0, microsecond: 0, millisecond: 0);
  }
}

// a 

// v1 - v2

// v1 after a , a before v2 
