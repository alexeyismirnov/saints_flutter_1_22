import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:async';
import 'dart:io';
import 'dart:core';

import 'package:html2md/html2md.dart' as html2md;
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' show join;

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
  FToast fToast;

  @override
  void initState() {
    super.initState();

    fToast = FToast();
    fToast.init(context);

    markdown = html2md
            .convert(widget.saint.zhitie)
            .trim()
            .replaceAll(RegExp(r'\n '), '\n')
            .replaceAll('\\', '')
            .replaceAll('\u00AD', '') +
        "\n";

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

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          SizedBox(
            width: 12.0,
          ),
          Text("Сохранено в Фотографиях"),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: 2),
    );
  }

  Future<File> getImageFileFromAssets(String path) async {
    ByteData byteData = await rootBundle.load(join("icons", path));

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<bool> saveIcon(String path) async {
    File f = await getImageFileFromAssets(path);
    return GallerySaver.saveImage(f.path);
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);

    if (_appBarHeight == 0.0) {
      _appBarHeight = widget.saint.has_icon ? 400.0 : 120.0;
      if (controller != null) _appBarHeight += 40.0;
    }

    final _textMinHeight = MediaQuery.of(context).size.height - _appBarHeight;

    final body1 = Theme.of(context)
        .textTheme
        .bodyText2
        .copyWith(fontSize: G.fontSize.val());
    // final String

    final mkText = SelectableText(markdown, style: body1);

    return Scrollbar(
        child: CustomScrollView(
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
                              if (widget.saint.has_icon)
                                GestureDetector(
                                    onTap: () {
                                      AlertDialog alert = AlertDialog(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 5.0, vertical: 10.0),
                                          titlePadding: EdgeInsets.all(5.0),
                                          title: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                  icon: Icon(Icons.clear,
                                                      size: 40.0),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  }),
                                              Expanded(
                                                  child: Text(widget.saint.name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                      ))),
                                              IconButton(
                                                  icon: Icon(Icons.save,
                                                      size: 40.0),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();

                                                    saveIcon(
                                                            "${widget.saint.id}.jpg")
                                                        .then((_) {
                                                      _showToast();
                                                    });
                                                  })
                                            ],
                                          ),
                                          content: Container(
                                              width: 500.0,
                                              height: 400.0,
                                              child: FittedBox(
                                                child: Image.asset(
                                                  "icons/${widget.saint.id}.jpg",
                                                ),
                                                fit: BoxFit.contain,
                                              )));
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              alert);
                                    },
                                    child: Material(
                                        elevation: 10.0,
                                        child: Container(
                                            height: 280.0,
                                            child: FittedBox(
                                              child: Image.asset(
                                                "icons/${widget.saint.id}.jpg",
                                              ),
                                              fit: BoxFit.contain,
                                            )))),
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
        ]));
  }
}
