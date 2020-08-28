import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:iot_app/data/settings_data.dart';

const int MS_DAY = 86400000;

int secondsSinceMonday() {
  DateTime now = DateTime.now();
  DateTime mon1 = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - ((now.weekday - 1) * MS_DAY));
  DateTime mon2 = DateTime(mon1.year, mon1.month, mon1.day, 0, 0, 1);
  return now.difference(mon2).inSeconds;
}

class Remote {
  final String hostIp;
  final int hostPort;

  Remote(this.hostIp, this.hostPort);

  Future<Map> get(final String path) async {
    final url = "$hostIp:$hostPort/$path?sync=${secondsSinceMonday()}";
    var response;
    try {
      response = await http.get(url).timeout(Duration(seconds: 3));
    } on Exception catch (e) {
      throw Exception(SettingsData.log('Failed to GET data from device. ${e.toString()}. URL[$url]'));
    }
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } on Exception catch (e) {
        throw Exception(SettingsData.log('Failed to parse data from device. ${e.toString()}. Json[${response.body}]'));
      }
    } else {
      throw Exception(SettingsData.log('Failed to get data from device. Code ${response.statusCode} : ${response.reasonPhrase}. URL[$url]'));
    }
  }
}
