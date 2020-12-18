import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';

import 'homepage.dart';
import 'favs_page.dart';
import 'search_page.dart';
import 'custom_bottom_bar.dart';
import 'font_size_dialog.dart';
import 'app_theme.dart';
import 'app_theme_dialog.dart';
import 'globals.dart' as G;

class _AnimatedContent {
  _AnimatedContent({
    this.icon,
    this.title,
    this.content,
    TickerProvider vsync,
  })  : item = BottomNavigationBarItem(
          icon: icon,
          title: Text(title),
        ),
        controller = AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final Widget icon;
  final String title;
  final Widget content;

  final BottomNavigationBarItem item;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.02), // Slightly down.
            end: Offset.zero,
          ).animate(_animation),
          child: content),
    );
  }
}

class ContainerPage extends StatefulWidget {
  @override
  _ContainerPageState createState() => _ContainerPageState();
}

class _ContainerPageState extends State<ContainerPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final _type = CustomBottomNavigationBarType.fixed;

  List<_AnimatedContent> _navigationViews;

  @override
  void initState() {
    super.initState();

    _navigationViews = <_AnimatedContent>[
      _AnimatedContent(
        icon: const Icon(Icons.wb_sunny),
        title: 'Жития',
        content: HomePage(),
        vsync: this,
      ),
      _AnimatedContent(
        icon: const Icon(Icons.favorite),
        title: 'Закладки',
        content: ClipRect(child: FavsPage()),
        vsync: this,
      ),
      _AnimatedContent(
        icon: const Icon(Icons.search),
        title: 'Поиск',
        content: SearchPage(),
        vsync: this,
      ),
    ];

    for (_AnimatedContent view in _navigationViews)
      view.controller.addListener(_rebuild);

    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (_AnimatedContent view in _navigationViews) view.controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }

  Widget _buildTransitionsStack() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (_AnimatedContent view in _navigationViews)
      transitions.add(view.transition(context));

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return Stack(children: transitions);
  }

  Widget _getActionsMenu() {
    var contextMenu = List<PopupMenuEntry<String>>();

    contextMenu.add(PopupMenuItem(
        value: 'font_size',
        child: Container(
            child: ListTile(
                leading: const Icon(Icons.format_size, size: 30.0),
                title: Text('Шрифт')))));

    contextMenu.add(PopupMenuItem(
        value: 'bg_color',
        child: Container(
            child: ListTile(
                leading: const Icon(Icons.color_lens, size: 30.0),
                title: Text('Фон')))));

    return PopupMenuButton<String>(
        itemBuilder: (_) => contextMenu,
        onSelected: (action) {
          switch (action) {
            case 'font_size':
              {
                showDialog(context: context, builder: (_) => FontSizeDialog())
                    .then((_) => setState(() {}));
              }
              break;

            case 'bg_color':
              {
                showDialog(context: context, builder: (_) => AppThemeDialog());
              }
              break;
            default:
              break;
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final botNavBar = Container(
        color: Colors.transparent,
        child: CustomBottomNavigationBar(
          items: _navigationViews
              .map((_AnimatedContent navigationView) => navigationView.item)
              .toList(),
          currentIndex: _currentIndex,
          type: _type,
          onTap: (int index) {
            setState(() {
              _navigationViews[_currentIndex].controller.reverse();
              _currentIndex = index;
              _navigationViews[_currentIndex].controller.forward();
            });
          },
        ));

    return Container(
      decoration: AppTheme.bg_decor_1() ??
          BoxDecoration(color: Theme.of(context).canvasColor),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              elevation: 0.0,
              title: Text("Жития святых",
                  style: Theme.of(context).textTheme.title),
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                    icon: Icon(Icons.rate_review, size: 30.0),
                    onPressed: () {
                      LaunchReview.launch(
                          androidAppId: "com.alexey.test",
                          iOSAppId: "1343569925");
                    }),
                _getActionsMenu()
              ]),
          body: Center(child: _buildTransitionsStack()),
          bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
              ),
              child: botNavBar)),
    );
  }
}
