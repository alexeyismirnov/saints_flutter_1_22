import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:html2md/html2md.dart' as html2md;
import 'package:esys_flutter_share/esys_flutter_share.dart';

import 'app_theme.dart';
import 'db.dart';
import 'globals.dart' as G;

class SaintDetailPage extends StatefulWidget {
  Saint saint;
  SaintDetailPage(this.saint);

  @override
  _SaintDetailPageState createState() => _SaintDetailPageState();
}

class _SaintDetailPageState extends State<SaintDetailPage> {
  ScrollController _scrollController;
  double _appBarHeight = 0.0;

  String markdown;

  @override
  void initState() {
    super.initState();

    markdown = html2md
        .convert(widget.saint.zhitie)
        .replaceAll('\\', '')
        .replaceAll('\u00AD', '');

    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  bool get _showTitle {
    return _scrollController.hasClients &&
        _scrollController.offset + 10.0 > _appBarHeight - kToolbarHeight;
  }

  bool get _showDots {
    return !_scrollController.hasClients ||
        _scrollController.hasClients && _scrollController.offset < 30.0;
  }

  Widget _getActions() {
    List<String> favs = G.favs.val();
    bool isFaved = favs.contains(widget.saint.id.toString());

    var contextMenu = List<PopupMenuEntry<String>>();

    contextMenu.add(PopupMenuItem(
      value: 'bookmark',
      child: Container(
          child: ListTile(
        leading: isFaved
            ? const Icon(Icons.bookmark, size: 30.0)
            : const Icon(Icons.bookmark_border, size: 30.0),
        title: Text('Закладка'),
      )),
    ));

    contextMenu.add(PopupMenuItem(
        value: 'share',
        child: Container(
            child: ListTile(
                leading: const Icon(Icons.share, size: 30.0),
                title: Text('Поделиться')))));

    return PopupMenuButton<String>(
        itemBuilder: (_) => contextMenu,
        onSelected: (action) {
          switch (action) {
            case 'bookmark':
              {
                if (isFaved)
                  favs.removeWhere(
                      (String id) => id == widget.saint.id.toString());
                else
                  favs.add(widget.saint.id.toString());

                setState(() => G.favs.set(favs));
              }
              break;

            case 'share':
              {
                if (widget.saint.has_icon)
                  rootBundle
                      .load('icons/${widget.saint.id}.jpg')
                      .then((ByteData bytes) {
                    Share.file('icon', 'saint.jpg', bytes.buffer.asUint8List(),
                        'image/jpg',
                        text: markdown);
                  });
                else
                  Share.text(widget.saint.name, markdown, 'text/plain');
              }
              break;
            default:
              break;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);

    if (_appBarHeight == 0.0) {
      _appBarHeight = widget.saint.has_icon ? 400.0 : 120.0;
      if (controller != null) _appBarHeight += 40.0;
    }

    final _textMinHeight = MediaQuery.of(context).size.height - _appBarHeight;

    final body1 =
        Theme.of(context).textTheme.body1.copyWith(fontSize: G.fontSize.val());
    // final String
    final mkText = Text(markdown, style: body1);

    return CustomScrollView(
        controller: _scrollController,
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
              elevation: 0.0,
              expandedHeight: _appBarHeight,
              pinned: true,
              title: _showTitle ? Text(widget.saint.name) : null,
              actions: [_getActions()],
              bottom: controller != null && _showDots
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(48.0),
                      child: Container(
                          height: 48.0,
                          alignment: Alignment.center,
                          child: TabPageSelector(controller: controller)))
                  : null,
              flexibleSpace: _showTitle
                  ? null
                  : FlexibleSpaceBar(
                      title: null,
                      background: Container(
                        decoration: AppTheme.bg_decor_3() ??
                            BoxDecoration(
                                color: Theme.of(context).primaryColor),
                        padding: EdgeInsets.fromLTRB(
                            10.0, kToolbarHeight, 10.0, 0.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              widget.saint.has_icon
                                  ? Material(
                                      elevation: 10.0,
                                      child: Image.asset(
                                          "icons/${widget.saint.id}.jpg",
                                          height: 280.0))
                                  : Container(),
                              Container(
                                  padding: EdgeInsets.only(top: 10.0),
                                  constraints: BoxConstraints(
                                    maxHeight: 80.0,
                                  ),
                                  child: Center(
                                      child: Text(widget.saint.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            //color: Colors.white
                                          ))))
                            ]),
                      ))),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) => Container(
                      padding: EdgeInsets.all(10.0),
                      constraints: BoxConstraints(minHeight: _textMinHeight),
                      decoration: AppTheme.bg_decor_2() ??
                          BoxDecoration(color: Theme.of(context).canvasColor),
                      child: SafeArea(top: false, child: mkText)),
                  childCount: 1))
        ]);
  }
}
