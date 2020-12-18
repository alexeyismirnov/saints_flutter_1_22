import 'package:flutter/material.dart';
import 'globals.dart' as G;
import 'saint_list.dart';

class FavsPage extends StatefulWidget {
  @override
  _FavsPageState createState() => new _FavsPageState();
}

class _FavsPageState extends State<FavsPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[SaintList(ids: G.favs.val())]);
  }
}
