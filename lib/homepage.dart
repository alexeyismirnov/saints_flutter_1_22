import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'globals.dart' as G;
import 'saint_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime initialDate;
  int initialPage;
  PageController _controller;

  @override
  void initState() {
    super.initState();

    initialPage = 100000;
    _controller = PageController(initialPage: initialPage);

    DateTime now =  DateTime.now();
    initialDate  =  DateTime(now.year, now.month, now.day);
  }

  Widget _buildPage(BuildContext context, int index) {
    GlobalKey<SaintListState> saintListKey = GlobalKey<SaintListState>();

    final currentDate = initialDate.add(Duration(days: index - initialPage));
    final currentDateOS = currentDate.subtract(Duration(days: 13));

    final df1 = DateFormat.yMMMMEEEEd('ru');
    final df2 = DateFormat.yMMMMd('ru');

    final w = MediaQuery.of(context).size.width;

    return NestedScrollView(
        key: PageStorageKey('homekey1'),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            [
              SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: false,
                  title: GestureDetector(
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.calendar_today, size: 30.0),
                            Container(
                                padding: EdgeInsets.only(left: 10.0),
                                width: w - 80.0,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                              G.capitalize(
                                                  df1.format(currentDate)),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .title)),
                                      Text(
                                          df2.format(currentDateOS) +
                                              ' (ст. ст.)',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead)
                                    ]))
                          ]),
                      onTap: () {
                        showDatePicker(
                                context: context,
                                initialDate: currentDate,
                                locale: const Locale('ru'),
                                firstDate: new DateTime(2000),
                                lastDate: new DateTime(2100))
                            .then((dt) {
                          if (dt != null) {
                            setState(() {
                              initialPage = index;
                              initialDate = dt;
                            });
                          }
                        });
                      })),
            ],
        body: CustomScrollView(slivers: <Widget>[
          SaintList(key: saintListKey, date: currentDate)
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      key: PageStorageKey('homekey3'),
      controller: _controller,
      itemBuilder: (BuildContext context, int index) {
        return _buildPage(context, index);
      },
    );
  }
}
