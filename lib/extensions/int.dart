extension intExt on int {
  DateTime get toDateTime => DateTime.fromMillisecondsSinceEpoch(this * 1000);
}
