import 'dart:io';
import 'package:image/image.dart';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  if (args.length < 2) {
    throw('Usage: <icon_add> url icon_id');
  }

  final url = args[0];
  final id = args[1];
  final bytes = await http.readBytes(url);

  Image image = decodeImage(bytes);
  Image thumbnail = copyResize(image, width: -1, height: 300);

  final icon = File('icons/$id.jpg')..writeAsBytesSync(encodeJpg(thumbnail, quality:85));
  await icon.copy("/Users/alexey/pCloud Drive/Public Folder/icons/$id.jpg");

}
