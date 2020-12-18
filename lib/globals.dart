library saints_flutter.globals;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

SharedPreferences prefs;
Database db;

enum ThemeType { parchment, bright, dark }

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

typedef void SubscriptionHandler<T>(T val);

class ConfigParam<T> {
  String prefKey;
  final subject = new PublishSubject<T>();

  ConfigParam(this.prefKey);

  T val() {
    if (T == int)
      return prefs.getInt(prefKey) as T;
    else if (T == double)
      return prefs.getDouble(prefKey) as T;
    else if (T == String)
      return prefs.getString(prefKey) as T;
    else if (T == ThemeType)
      return ThemeType.values[prefs.getInt(prefKey)] as T;
    else
      return prefs.getStringList(prefKey) as T;
  }

  set(T val) {
    if (T == int)
      prefs.setInt(prefKey, val as int);
    else if (T == double)
      prefs.setDouble(prefKey, val as double);
    else if (T == String)
      prefs.setString(prefKey, val as String);
    else if (T == ThemeType)
      prefs.setInt(prefKey, (val as ThemeType).index);
    else
      prefs.setStringList(prefKey, val as List<String>);

    subject.add(val);
  }

  StreamSubscription onChange(SubscriptionHandler<T> handler) {
    return subject.stream.listen(handler);
  }
}

final fontSize = ConfigParam<double>('fontSize');
final favs = ConfigParam<List<String>>('favs');
final search = ConfigParam<String>('search');
final bgcolor = ConfigParam<ThemeType>('bgcolor');