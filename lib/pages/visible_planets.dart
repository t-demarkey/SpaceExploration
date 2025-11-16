import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getVisiblePlanets(double lat, double lon) async {
  const appId = '97f7d0fd-575f-4776-8efa-a931dc814716';
  const appSecret =
      'a839420998002d4fbf2423c35ba247c2c921fbe2c5ad3d9226a6893dfdd0db348bcf13b4224dd8c0bfda1d6dfb00ff2283bc18cc72b01eeea6be67d53df4b442dbbc29318749187b14aa320da3277146eebba50cda361c5cf66557fef5398e7aaff2ee4ebec5397a69bb35d90675c08a';
  final credentials = base64Encode(utf8.encode('$appId:$appSecret'));

  final today = DateTime.now().toIso8601String().split('T').first;

  final url = Uri.parse(
    'https://api.astronomyapi.com/api/v2/bodies/positions'
    '?latitude=$lat'
    '&longitude=$lon'
    '&elevation=0'
    '&from_date=$today'
    '&to_date=$today'
    '&time=22:00:00',
  );

  final headers = {
    'Authorization': 'Basic $credentials',
    'Content-Type': 'application/json',
  };

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final visible = <String>[];

    for (var entry in data['data']['table']['rows']) {
      var altitudeRaw =
          entry['cells'][0]['position']['horizontal']['altitude']['degrees'];
      var altitude =
          altitudeRaw is double
              ? altitudeRaw
              : double.parse(altitudeRaw.toString());

      if (altitude > 0) {
        visible.add(entry['entry']['name']);
      }
    }

    return visible;
  } else {
    throw Exception('Failed to load visible planets: ${response.body}');
  }
}
