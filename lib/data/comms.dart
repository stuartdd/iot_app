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

  Remote(this.hostIp, [this.hostPort]);

  Future<Map> get(final String path) async {
    final url = "$hostIp${hostPort == null ? "" : ":${hostPort.toString()}"}/$path?sync=${secondsSinceMonday()}";
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

//class RemoteDeviceStatus {
//  final Map map;
//  final String id;
//  final int ra;
//  final int rb;
//  final double t0;
//  final double t1;
//  final double v0;
//  final double v1;
//
//
//  RemoteDeviceStatus(final this.map, final this.id, final this.ra, final this.rb, final this.t0, final this.t1, final this.v0, final this.v1) {
//    if ((id == null) || (ra == null) || (rb == null)) {
//      throw Exception(SettingsData.log("Failed to get data from device. One of 'id' or 'ra' or 'rb' is null}"));
//    }
//  }
//
//  static RemoteDeviceStatus fromJson(String json) {
//    Map m = jsonDecode(json);
//    return RemoteDeviceStatus(m, m["id"], m["ra"], m["rb"], m["t0"], m["t1"], m["v0"], m["v1"]);
//  }
//
//  @override
//  String toString() {
//    return 'RemoteDeviceStatus{id: $id, ra: $ra, rb: $rb, t0: $t0, t1: $t1, v0: $v0, v1: $v1}';
//  }
//}
