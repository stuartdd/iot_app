import 'package:http/http.dart' as http;
import 'dart:convert';

const int MS_DAY = 86400000;

int secondsSinceMonday() {
  DateTime now = DateTime.now();
  DateTime mon1 = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - ((now.weekday-1) * MS_DAY));
  DateTime mon2 = DateTime(mon1.year, mon1.month, mon1.day, 0, 0, 1);
  return now.difference(mon2).inSeconds;
}

class Device {
  final String hostIp;
  final int hostPort;

  Device(this.hostIp, [this.hostPort]);

  Future<String> get(final String path) async {
    final url = "$hostIp${hostPort==null?"":":${hostPort.toString()}"}/$path?sync=${secondsSinceMonday()}";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get data from device. Code ${response.statusCode} : ${response.reasonPhrase}. Req : $url');
    }
  }
}

class DeviceStatus {
  final String id;
  final int ra;
  final int rb;
  final double t0;
  final double t1;
  final double v0;
  final double v1;


  DeviceStatus(final this.id, final this.ra, final this.rb, final this.t0, final this.t1, final this.v0, final this.v1) {
    if ((id == null) || (ra == null) || (rb == null)) {
      throw Exception("Failed to get data from device. One of 'id' or 'ra' or 'rb' is null}");
    }
  }

  static DeviceStatus fromJson(String json) {
    Map m = jsonDecode(json);
    return DeviceStatus(m["id"], m["ra"], m["rb"], m["t0"], m["t1"], m["v0"], m["v1"]);
  }

  @override
  String toString() {
    return 'DeviceStatus{id: $id, ra: $ra, rb: $rb, t0: $t0, t1: $t1, v0: $v0, v1: $v1}';
  }
}