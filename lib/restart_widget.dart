import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'container_page.dart';
import 'db.dart';
import 'app_theme.dart';

class RestartWidget extends StatefulWidget {
  static restartApp(BuildContext context) {
    final _RestartWidgetState state =
    context.ancestorStateOfType(const TypeMatcher<_RestartWidgetState>());
    state.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  Widget getApp() => TheViewModel(
    theModel: SaintsModel(),
    child: MaterialApp(
      title: 'Жития святых',
      home: ContainerPage(),
      theme: AppTheme.getThemeData(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru', 'RU'),
      ],
      debugShowCheckedModeBanner: false,
    ),
  );


  void restartApp() {
    this.setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: getApp(),
    );
  }
}

