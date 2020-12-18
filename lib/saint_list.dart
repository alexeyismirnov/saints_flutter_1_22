import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'db.dart';
import 'saint_details.dart';
import 'globals.dart' as G;
import 'church_calendar.dart';
import "package:intl/intl.dart";

class SaintList extends StatefulWidget {
  DateTime date;
  List<String> ids;
  String search;

  SaintList({Key key, this.date, this.ids, this.search}) : super(key: key);

  @override
  SaintListState createState() => SaintListState();
}

class SaintListState extends State<SaintList> {
  var saintData;
  StreamController<Saint> streamController;
  StreamSubscription fontSizeChanged, favsChanged, searchChanged, dataStream;

  @override
  void initState() {
    super.initState();

    _initData();

    G.SubscriptionHandler<double> handler = (double _) => setState(() {});
    fontSizeChanged = G.fontSize.onChange(handler);

    if (widget.ids != null) {
      G.SubscriptionHandler<List<String>> handler = ((List<String> _) {
        widget.ids = G.favs.val();
        setState(() => _initData());
      });

      favsChanged = G.favs.onChange(handler);
    }

    if (widget.search != null) {
      G.SubscriptionHandler<String> handler = ((String _) {
        widget.search = G.search.val();
        setState(() => _initData());
      });

      searchChanged = G.search.onChange(handler);
    }
  }

  @override
  void dispose() {
    fontSizeChanged?.cancel();
    favsChanged?.cancel();
    searchChanged?.cancel();

    dataStream?.cancel();
    streamController = null;

    super.dispose();
  }

  void _initData() {
    dataStream?.cancel();
    saintData = List<Saint>();

    streamController = StreamController.broadcast();
    dataStream = streamController.stream.listen((s) => setState(() => saintData.add(s)));
  }

  Widget buildRow(BuildContext context, int index) {
    final Saint s = saintData[index];
    var day = s.day;
    var month = s.month;
    Widget name;

    var style =
        Theme.of(context).textTheme.body1.copyWith(fontSize: G.fontSize.val());

    if (day != null && day != 0) {
      if (day == 29 && month == 2) {
        day = 13;
        month = 3;
      }

      final dt = DateTime(ChurchCalendar.currentYear, month, day);
      final format = DateFormat.MMMMd('ru');

      name = RichText(
          text: TextSpan(text: '', style: style, children: [
        TextSpan(text: format.format(dt), style: style.copyWith(color: Colors.red)),
        TextSpan(text: '   '),
        TextSpan(text: s.name)
      ]));

    } else {
      name = Text(s.name, style: style);
    }

    return new GestureDetector(
      child: new Container(
          decoration: BoxDecoration(color: Colors.transparent),
          padding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              s.has_icon
                  ? Image.asset(
                      'icons/${s.id}.jpg',
                      width: 100.0,
                      height: 100.0,
                    )
                  : Container(),
              new Expanded(
                  child: new Container(
                      padding: EdgeInsets.only(left: 10.0), child: name))
            ],
          )),
      onTap: () {
        if (widget.ids != null || widget.search != null)
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SaintDetail([s], 0)));
        else
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      SaintDetail(saintData, index)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (saintData.length == 0 && !streamController.isClosed) {
      if (widget.date != null)
        TheViewModel
            .of(context)
            .getSaints(date: widget.date, into: streamController);
      else if (widget.ids != null)
        TheViewModel
            .of(context)
            .getFavedSaints(ids: widget.ids, into: streamController);
      else if (widget.search != null && widget.search.length > 2)
        TheViewModel
            .of(context)
            .getSaintsByName(name: widget.search, into: streamController);
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => buildRow(context, index),
            childCount: min(saintData.length, 100)));
  }
}
