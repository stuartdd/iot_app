import 'package:flutter_test/flutter_test.dart';
import 'package:iot_app/data/comms.dart';

void main() {
  test("Get device status", () async {
    Remote dev = Remote("http://192.168.1.177");
    Map s = await dev.get("switch");
    print(s);
  });
}
