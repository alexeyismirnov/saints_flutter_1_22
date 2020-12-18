import 'package:flutter/material.dart';
import 'globals.dart' as G;
import 'saint_list.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: G.search.val());
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
            [
              SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: false,
                  title: TextField(
                      controller: _controller,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: "Имя святого",
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .subhead
                          .copyWith(fontSize: G.fontSize.val()),
                      onChanged: (String name) => G.search.set(name)))
            ],
        body: CustomScrollView(
            slivers: <Widget>[SaintList(search: G.search.val())]));
  }
}
