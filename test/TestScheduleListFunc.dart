import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:iot_app/data/schedule_data.dart';


const int T1 = SEC_HOUR * 1;
const int T2 = SEC_HOUR * 2;
const int T3 = SEC_HOUR * 3;
const int T4 = SEC_HOUR * 4;
const int T5 = SEC_HOUR * 5;
const int T6 = SEC_HOUR * 6;
const int T7 = SEC_HOUR * 7;
const int T8 = SEC_HOUR * 8;

void main() {
  test('Index of', () {
    ScheduleList list = ScheduleList.init();

    ScheduleOnOff sc1 = ScheduleOnOff(DevType.CH, 1, T1, T2);
    ScheduleOnOff sc2 = ScheduleOnOff(DevType.CH, 1, T3, T4);
    ScheduleOnOff sc3 = ScheduleOnOff(DevType.CH, 1, T5, T6);

    expect(-1, list.indexOf(sc2));
    expect(null, list.next(sc2));
    expect(null, list.previous(sc2));

    list.add(sc2);
    expect(0, list.indexOf(sc2));
    expect(null, list.next(sc2));
    expect(null, list.previous(sc2));

    list.add(sc1);
    expect(1, list.indexOf(sc2));
    expect(null, list.next(sc2));
    expect(sc1, list.previous(sc2));

    list.add(sc3);
    expect(1, list.indexOf(sc2));
    expect(sc3, list.next(sc2));
    expect(sc1, list.previous(sc2));
  });

  test('HMS', () {
    expect("00:00:00", HMS(0));
    expect("00:00:10", HMS(10));
    expect("00:01:00", HMS(60));
    expect("00:01:01", HMS(61));
    expect("01:00:00", HMS(SEC_HOUR));
    expect("01:01:01", HMS(SEC_HOUR+61));
    expect("12:01:01", HMS(SEC_HALF_DAY+61));
  });


}
