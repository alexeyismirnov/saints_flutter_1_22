import 'package:supercharged/supercharged.dart';

class NameOfDay {
  final _value;
  const NameOfDay._internal(this._value);

  int toInt() => _value as int;
}

const pascha = const NameOfDay._internal(100000);
const palmSunday = const NameOfDay._internal(100001);
const ascension = const NameOfDay._internal(100002);
const pentecost = const NameOfDay._internal(100003);

const theotokosIveron = const NameOfDay._internal(2250);
const theotokosLiveGiving = const NameOfDay._internal(100100);
const theotokosDubenskaya = const NameOfDay._internal(100101);
const theotokosChelnskaya = const NameOfDay._internal(100103);
const theotokosWall = const NameOfDay._internal(100105);
const theotokosSevenArrows = const NameOfDay._internal(100106);
const firstCouncil = const NameOfDay._internal(100107);
const theotokosTabynsk = const NameOfDay._internal(100108);
const newMartyrsOfRussia = const NameOfDay._internal(100109);
const holyFathersSixCouncils = const NameOfDay._internal(100110);
const allRussianSaints = const NameOfDay._internal(100111);

class ChurchCalendar {
  static DateTime currentDate;
  static int currentYear;

  static Map<DateTime, List<NameOfDay>> feasts;

  static DateTime paschaDay(int year) {
    final a = (19 * (year % 19) + 15) % 30;
    final b = (2 * (year % 4) + 4 * (year % 7) + 6 * a + 6) % 7;

    return ((a + b > 10)
            ? DateTime(year, 4, a + b - 9)
            : DateTime(year, 3, 22 + a + b)) +
        13.days;
  }

  static DateTime nearestSundayBefore(DateTime d) => d - d.weekday.days;
  static DateTime nearestSundayAfter(DateTime d) => d + (7 - d.weekday).days;

  static DateTime nearestSunday(DateTime d) {
    switch (d.weekday) {
      case DateTime.sunday:
        return d;

      case DateTime.monday:
      case DateTime.tuesday:
      case DateTime.wednesday:
        return nearestSundayBefore(d);

      default:
        return nearestSundayAfter(d);
    }
  }

  static set date(DateTime date) {
    currentDate = date;

    if (currentYear != date.year) {
      currentYear = date.year;

      final P = paschaDay(currentYear);

      feasts = {
        P - 7.days: [palmSunday],
        P: [pascha],
        P + 2.days: [theotokosIveron],
        P + 39.days: [ascension],
        P + 49.days: [pentecost],
        P + 5.days: [theotokosLiveGiving],
        P + 24.days: [theotokosDubenskaya],
        P + 42.days: [theotokosChelnskaya, firstCouncil],
        P + 56.days: [theotokosWall, theotokosSevenArrows],
        P + 61.days: [theotokosTabynsk],
        P + 63.days: [allRussianSaints],
        nearestSunday(DateTime(currentYear, 2, 7)): [newMartyrsOfRussia],
        nearestSunday(DateTime(currentYear, 7, 29)): [holyFathersSixCouncils]
      };
    }
  }
}
