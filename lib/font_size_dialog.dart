import 'package:flutter/material.dart';
import 'globals.dart' as G;

class FontSizeDialog extends StatefulWidget {
  @override
  FontSizeDialogState createState() => new FontSizeDialogState();
}

class FontSizeDialogState extends State<FontSizeDialog> {
  double fontSize = G.fontSize.val();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                        Text('Размер шрифта',
                            style: Theme.of(context).textTheme.title)
                      ])),
              Slider(
                value: fontSize,
                min: 18.0,
                max: 24.0,
                divisions: 6,
                label: '${fontSize.round()}',
                onChanged: (double value) {
                  setState(() {
                    fontSize = value;
                    G.fontSize.set(fontSize);
                  });
                },
              ),
              Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: new Text('ОК'),
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                    )
                  ])
            ]),
      ),
    );
  }
}
