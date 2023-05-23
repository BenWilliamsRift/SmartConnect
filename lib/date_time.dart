import 'string_consts.dart';
import 'settings.dart';

class Delay {
  DateTimeManager dateTimeManager = DateTimeManager();
  late int months, weeks, days, hours, minutes, seconds;

  Delay({this.months=0, this.weeks=0, this.days=0, this.hours=0, this.minutes=0, this.seconds=0});

  // convert seconds to   hours : minutes : seconds
  static Delay fromSecs(double secs) {
      List<int> totalTime = DateTimeManager().fromSeconds(totalSeconds: secs);

      int months = totalTime.elementAt(0);
      int weeks = totalTime.elementAt(1);
      int days = totalTime.elementAt(2);
      int hours = totalTime.elementAt(3);
      int minutes = totalTime.elementAt(4);
      int seconds = totalTime.elementAt(5);

    return Delay(months: months, weeks: weeks, days: days, hours: hours, minutes: minutes, seconds: seconds);
  }

  static Delay copyFrom(Delay delay) {
    return Delay(months: delay.months, weeks: delay.weeks, days: delay.days, hours: delay.hours, minutes: delay.minutes, seconds: delay.seconds);
  }

  // get total number of seconds for delay
  get totalSeconds => dateTimeManager.toSeconds(months: months, weeks: weeks, days: days, hours: hours, minutes: minutes, seconds: seconds);

  @override
  String toString() {
    return dateTimeManager.convertTime(totalSeconds: totalSeconds);
  }

  String all() {
    return dateTimeManager.convertTime(totalSeconds: totalSeconds, all: true);
  }
}

class DateTimeManager {
  String convertTime({required int totalSeconds, bool all=false}) {
      List<int> totalTime = fromSeconds(totalSeconds: totalSeconds);

      int months = totalTime.elementAt(0);
      int weeks = totalTime.elementAt(1);
      int days = totalTime.elementAt(2);
      int hours = totalTime.elementAt(3);
      int minutes = totalTime.elementAt(4);
      int seconds = totalTime.elementAt(5);

      if (all) {
        return "${months.toString().padLeft(2, "0")} : ${weeks.toString().padLeft(2, "0")} : ${days.toString().padLeft(2, "0")} : ${hours.toString().padLeft(2, "0")} : ${minutes.toString().padLeft(2, "0")}: ${seconds.toString().padLeft(2, "0")}";
      }

      String time = "Error";

      switch(Settings.selectedTimeUnits) {
        case Settings.hoursMinutesSeconds:
          time = "${hours.toString().padLeft(2, "0")} : ${minutes.toString().padLeft(2, "0")}: ${seconds.toString().padLeft(2, "0")}";
          break;
        case Settings.monthsWeekDays:
          time = "${months.toString().padLeft(2, "0")} : ${weeks.toString().padLeft(2, "0")} : ${days.toString().padLeft(2, "0")}";
          break;
        case Settings.seconds:
          time = '${seconds.toString().padLeft(2, "0")} ${StringConsts.seconds}';
          break;
        case Settings.minutes:
          time = '${minutes.toString().padLeft(2, "0")} ${StringConsts.minutes}';
          break;
        case Settings.hours:
          time = '${hours.toString().padLeft(1, "0")} ${StringConsts.hours}';
          break;
        case Settings.days:
          time = '${days.toString().padLeft(1, "0")} ${StringConsts.days}';
          break;
        case Settings.weeks:
          time = '${weeks.toString().padLeft(1, "0")} ${StringConsts.weeks}';
          break;
      }

      return time;
    }

    int toSeconds({int months=0, int weeks=0, int days=0, int hours=0, int minutes=0, int seconds=0}) {
      return months * 2419200 + weeks * 604800 + days * 86400 + hours * 3600 + minutes * 60 + seconds;
    }

    List<int> fromSeconds({required totalSeconds}) {
      int months = ((totalSeconds / 2419200)).floor();
      int weeks = ((totalSeconds % 2419200) / 604800).floor();
      int days = (((totalSeconds % 2419200) % 604800) / 86400).floor();
      int hours = (((((totalSeconds % 2419200) % 604800) % 86400) / 3600)).floor();
      int minutes = ((((((totalSeconds % 2419200) % 604800) % 86400) % 3600) / 60)).floor();
      int seconds = (((((totalSeconds % 2419200) % 604800) % 86400) % 60)).floor();

      return [months, weeks, days, hours, minutes, seconds];
    }
}
