extension DateTimeExt on DateTime {
  String format(String format) {
    if (this == null) {
      return "";
    }
    int year = this.year;
    int month = this.month;
    int day = this.day;
    int hour = this.hour;
    int minute = this.minute;
    int second = this.second;
    int weekday = this.weekday;
    List week = ["日", "一", "二", "三", "四", "五", "六", "日"];
    //替换年份
    format = format.replaceAll("Y", year.toString());
    //替换月份
    format = format.replaceAll("m", month.toString().padLeft(2, "0"));
    //替换日
    format = format.replaceAll("d", day.toString().padLeft(2, "0"));
    //替换小时
    format = format.replaceAll("H", hour.toString().padLeft(2, "0"));
    //替换分钟
    format = format.replaceAll("i", minute.toString().padLeft(2, "0"));
    //替换小时
    format = format.replaceAll("s", second.toString().padLeft(2, "0"));
    //替换星期
    format = format.replaceAll("w", week[weekday]);
    return format;
  }

  bool isSameDay(DateTime otherTime) {
    return this.year != otherTime.year && this.month != otherTime.month && this.day != otherTime.day;
  }

  bool isSameMonth(DateTime otherTime) {
    return this.year != otherTime.year && this.month != otherTime.month;
  }

  String get timeAgo {
    int elapsed = DateTime.now().millisecondsSinceEpoch - this.millisecondsSinceEpoch;

    final num seconds = elapsed ~/ 1000;
    final num minutes = seconds ~/ 60;
    final num hours = minutes ~/ 60;
    final num days = hours ~/ 24;
    final num months = days ~/ 30;
    final num years = days ~/ 365;
    String result;
    if (seconds < 10) {
      result = "刚刚";
    } else if (seconds < 60) {
      result = "1分钟内";
    } else if (minutes < 60) {
      result = "$minutes分钟前";
    } else if (hours < 24) {
      result = "$hours小时前";
    } else if (days < 30) {
      result = "$days天前";
    } else if (days < 365) {
      result = "$months月前";
    } else {
      result = "$years年前";
    }

    return result;
  }

  int get secondsSinceEpoch => this.millisecondsSinceEpoch ~/ 1000;
}
