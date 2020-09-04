import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:iot_app/data/settings_data.dart';





class Remote {
  final String hostIp;
  final int hostPort;

  Remote(this.hostIp, this.hostPort);

  Future<Map> get(final String path) async {
    final url = "$hostIp:$hostPort/$path";
    var response;
    try {
      response = await http.get(url).timeout(Duration(seconds: 10));
    } on Exception catch (e) {
      throw Exception(SettingsData.log('Failed to GET data from device. ${e.toString()}. URL[$url]'));
    }
    if (response.statusCode == 200) {
      try {
        print("--> $path <-- ${response.body}");
        return jsonDecode(response.body);
      } on Exception catch (e) {
        throw Exception(SettingsData.log('Failed to parse data from device. ${e.toString()}. Json[${response.body}]'));
      }
    } else {
      throw Exception(SettingsData.log('Failed to get data from device. Code ${response.statusCode} : ${response.reasonPhrase}. URL[$url]'));
    }
  }
}
