import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:image/image.dart';

void main(List<String> args) async {
  await new Directory('./icons-150px').create();

  final dir = new Directory('./icons');
  var files = dir.listSync();

  for (var file in files) {
    if (file is File && file.path.contains('jpg')) {
      String filename = basename(file.path);
      print(filename);

      Image image = decodeImage(file.readAsBytesSync());
      Image thumbnail = copyResize(image, height:150);

      new File('icons-150px/$filename').writeAsBytesSync(encodeJpg(thumbnail, quality:85));

    }
  }

}
