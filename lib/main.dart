import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'globals.dart' as G;
import 'restart_widget.dart';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  G.prefs = await SharedPreferences.getInstance();

  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "saints.sqlite");

  await deleteDatabase(path);

  try {
    await Directory(dirname(path)).create(recursive: true);
  } catch (_) {}

  ByteData data = await rootBundle.load(join("assets", "saints.sqlite"));
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  await new File(path).writeAsBytes(bytes, flush: true);

  G.db = await openDatabase(path, readOnly: true);

  if (!G.prefs.getKeys().contains('bgcolor')) {
    G.prefs.setInt('bgcolor', 0);
  }

  if (!G.prefs.getKeys().contains('fontSize')) {
    G.prefs.setDouble('fontSize', 20.0);
  }

  if (!G.prefs.getKeys().contains('favs')) {
    G.prefs.setStringList('favs', []);
  }

  if (!G.prefs.getKeys().contains('search')) {
    G.prefs.setString('search', '');
  }

  runApp(RestartWidget());
}
