import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:async/async.dart';
import 'package:supercharged/supercharged.dart';

import 'dart:async';

import 'interval.dart' as Range;
import 'church_calendar.dart';
import 'globals.dart' as G;

class TheViewModel extends InheritedWidget {
  final SaintsModel theModel;

  const TheViewModel({Key key, @required this.theModel, @required Widget child})
      : assert(child != null),
        super(key: key, child: child);

  static SaintsModel of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(TheViewModel) as TheViewModel)
          .theModel;

  @override
  bool updateShouldNotify(TheViewModel oldWidget) => false;
}

class SaintsModel {

  void getFavedSaints({@required List<String> ids, @required StreamController<Saint> into}) {
    var sources = List<Observable<Saint>>();

    for (String idStr in ids) {
      final id = int.parse(idStr);

      final query = G.db.query('app_saint',
          columns: ['id', 'name', 'zhitie', 'has_icon'], where: 'id=$id');

      sources.add(Observable
          .fromFuture(query)
          .expand((e) => e)
          .map((Map data) => Saint.from(data)));
    }

    StreamGroup.merge(sources).pipe(into);
  }

  void getSaintsByName({@required String name, @required StreamController<Saint> into}) {
    var sources = List<Observable<Saint>>();

    var query = G.db.query('app_saint',
        columns: ['id', 'day', 'month', 'name', 'zhitie', 'has_icon'], where: 'name LIKE "%$name%"');

    sources.add(Observable
        .fromFuture(query)
        .expand((e) => e)
        .map((Map data) => Saint.from(data)));

    query = G.db.rawQuery('SELECT app_saint.id,link_saint.day,link_saint.month,link_saint.name,app_saint.zhitie,app_saint.has_icon '+
        'FROM app_saint JOIN link_saint ON ' +
        'app_saint.id = link_saint.id AND link_saint.name LIKE "%$name%"');

    sources.add(Observable
        .fromFuture(query)
        .expand((e) => e)
        .map((Map data) => Saint.from(data)));

    StreamGroup.merge(sources).pipe(into);

  }

  List<Observable<Saint>> _addSaints(DateTime date) {
    var sources = List<Observable<Saint>>();

    final day = date.day.toString();
    final month = date.month.toString();

    final query = G.db.query('app_saint',
        columns: ['id', 'name', 'zhitie', 'has_icon'],
        where: 'day=$day AND month=$month');

    sources.add(Observable
        .fromFuture(query)
        .expand((e) => e)
        .map((Map data) => Saint.from(data)));

    final query_link = G.db.rawQuery('SELECT app_saint.id,link_saint.name,app_saint.zhitie,app_saint.has_icon '+
        'FROM app_saint JOIN link_saint ON ' +
        'app_saint.id = link_saint.id AND link_saint.day=$day AND link_saint.month=$month');

    sources.add(Observable
        .fromFuture(query_link)
        .expand((e) => e)
        .map((Map data) => Saint.from(data)));

    return sources;
  }

  void getSaints (
      {@required DateTime date, @required StreamController<Saint> into}) async {

    var sources = List<Observable<Saint>>();

    ChurchCalendar.date = date;
    final codes = ChurchCalendar.feasts[date] ?? List<NameOfDay>();

    for (NameOfDay code in codes) {
      final id = code.toInt();
      final query = G.db.query('app_saint',
          columns: ['id', 'name', 'zhitie', 'has_icon'], where: 'id=$id');

      sources.add(Observable
          .fromFuture(query)
          .expand((e) => e)
          .map((Map data) => Saint.from(data)));
    }

    final isLeapYear = (date.year % 400) == 0 ||
        ((date.year % 4 == 0) && (date.year % 100 != 0));
    final leapStart = DateTime(date.year, 2, 29);
    final leapEnd = DateTime(date.year, 3, 13);

    if (isLeapYear) {
      final leap = Range.Interval<DateTime>.closedOpen(leapStart, leapEnd);

      if (leap.contains(date))
        sources.addAll(_addSaints(date + 1.days));
      else if (date == leapEnd)
        sources.addAll(_addSaints(leapStart));
      else
        sources.addAll(_addSaints(date));

    } else {
      sources.addAll(_addSaints(date));
      if (date == leapEnd) {
        sources.addAll(_addSaints(DateTime(2000, 2, 29)));
      }
    }

    StreamGroup.merge(sources).pipe(into);
  }
}

class Saint {
  int id;
  String name;
  int day;
  int month;
  String zhitie;
  int hasIcon;

  bool get has_icon => hasIcon == 1;

  Saint(
      {@required this.id,
      @required this.name,
      @required this.day,
      @required this.month,
      @required this.zhitie,
      @required this.hasIcon});

  Saint.from(Map s)
      : this(
            id: s['id'],
            name: s['name'],
            day: s['day'],
            month: s['month'],
            zhitie: s['zhitie'],
            hasIcon: s['has_icon']);
}
