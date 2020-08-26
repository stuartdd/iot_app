import 'package:flutter_test/flutter_test.dart';
import 'package:iot_app/data/comms.dart';

void main() {
  test("Get device status", () async {
    Device dev = Device("http://192.168.1.177");
    String s = await dev.get("switch");
    print(DeviceStatus.fromJson(s));
  });
}
