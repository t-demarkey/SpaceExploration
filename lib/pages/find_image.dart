import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

Future<String?> findImageElement(String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Document document = parser.parse(response.body);

    var element = document.querySelector("img");
    if (element != null) {
      String? imgSrc = element.attributes['src'];
      if (imgSrc != null) {
        return imgSrc.startsWith('http')
            ? imgSrc
            : 'https://apod.nasa.gov/apod/$imgSrc';
      }
    } else {}
  }
  return null;
}
