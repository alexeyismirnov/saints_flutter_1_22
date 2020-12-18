import 'package:flutter/material.dart';
import 'restart_widget.dart';
import 'globals.dart' as G;

class AppThemeDialog extends StatelessWidget {
  final labels = ['Пергамент', 'Светлый', 'Темный'];

  Widget _getListItem(BuildContext context, int index) {
    Widget content;
    final theme = G.ThemeType.values[index];

    if (G.bgcolor.val() == theme)
      content = CheckboxListTile(title: Text(labels[index]), value: true);
    else
      content = ListTile(title: Text(labels[index]));

    return GestureDetector(
        child: content,
        onTap: () {
          G.bgcolor.set(theme);
          RestartWidget.restartApp(context);
        });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      contentPadding: EdgeInsets.all(0.0),
      content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding: EdgeInsets.all(10.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(bottom: 20.0, top: 10.0),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('Фон', style: Theme.of(context).textTheme.title)
                        ])),
                _getListItem(context, 0),
                _getListItem(context, 1),
                _getListItem(context, 2),
              ])));
}
