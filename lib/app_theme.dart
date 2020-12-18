import 'package:flutter/material.dart';
import 'globals.dart' as G;

class AppTheme {
  static ThemeData getThemeData() {
    var theme = G.bgcolor.val();

    switch (theme) {
      case G.ThemeType.parchment:
        return ThemeData(
            brightness: Brightness.light,
            cardColor: Colors.orange.shade50,
            dialogBackgroundColor: Colors.orange.shade50,
            primaryColor: const Color(0xffe9c79a),
            accentColor: Colors.black54);
        break;

      case G.ThemeType.bright:
        return ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xffe9c79a),
            accentColor: Colors.black54);
        break;

      case G.ThemeType.dark:
        return ThemeData(brightness: Brightness.dark);
        break;
    }
  }

  static Decoration bg_decor_1() => G.bgcolor.val() == G.ThemeType.parchment
      ? BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.jpg"),
            fit: BoxFit.fill,
          ),
        )
      : null;

  static Decoration bg_decor_2() => G.bgcolor.val() == G.ThemeType.parchment
      ? BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/bg2.jpg"),
              fit: BoxFit.contain,
              repeat: ImageRepeat.repeat),
        )
      : null;

  static Decoration bg_decor_3() => G.bgcolor.val() == G.ThemeType.parchment
      ? BoxDecoration(
          image: DecorationImage(
          image: AssetImage("images/bg3.jpg"),
          fit: BoxFit.cover,
        ))
      : null;
}
