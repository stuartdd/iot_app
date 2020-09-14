

import 'package:flutter_test/flutter_test.dart';
import 'package:iot_app/data/schedule_data.dart';

const int T1 = SEC_HOUR * 1;
const int T2 = SEC_HOUR * 2;
const int T3 = SEC_HOUR * 3;
const int T4 = SEC_HOUR * 4;

const int T5 = (SEC_HOUR * 1) + SEC_15M;
const int T6 = (SEC_HOUR * 2) + SEC_15M;
const int T7 = (SEC_HOUR * 3) + SEC_15M;
const int T8 = (SEC_HOUR * 4) + SEC_15M;

void main() {

  test('DeviceType', () {
    expect('Heating', DevTypeData.nameForDevType(DevType.CH));
    expect('Hot Water', DevTypeData.nameForDevType(DevType.HW));
    expect('Heating', DevTypeData.forDevType(DevType.CH).toString());
    expect('Hot Water', DevTypeData.forDevType(DevType.HW).toString());
    expect('CH', DevTypeData.forDevType(DevType.CH).id);
    expect('HW', DevTypeData.forDevType(DevType.HW).id);
    expect(DevType.CH, DevTypeData.devTypeForId("CH").type);
    expect(DevType.HW, DevTypeData.devTypeForId("HW").type);
    expect("CH", DevTypeData.devTypeForId("CH").id);
    expect("HW", DevTypeData.devTypeForId("HW").id);
    try {
      DevTypeData.devTypeForId("XX");
    } catch (e) {
      expect("Device Type Data Not Found id[XX]", e.toString());
    }
  });

  test("Overlap Same Day and Type", () {
    //  T1......T2
    //  T1......T2
    expect(true, testHW(T1, T2, T1, T2));
    expect(true, testCH(T1, T2, T1, T2));
    //  T1......T2
    //                  T3......T4
    expect(false, testHW(T1, T2, T3, T4));
    expect(false, testCH(T1, T2, T3, T4));
    //                  T1......T2
    //  T3......T4
    expect(false, testHW(T3, T4, T1, T2));
    expect(false, testCH(T3, T4, T1, T2));
    //          T2......T3
    //      T5......T6
    expect(true, testHW(T2, T3, T5, T6));
    expect(true, testCH(T2, T3, T5, T6));
    //          T2......T3
    //              T6......T7
    expect(true, testHW(T2, T3, T6, T7));
    expect(true, testCH(T2, T3, T6, T7));
    //          T2......T3
    //                  T3......T4
    expect(true, testHW(T2, T3, T3, T4));
    expect(true, testCH(T2, T3, T3, T4));
    //                  T2......T3
    //          T1......T2
    expect(true, testHW(T1, T2, T2, T3));
    expect(true, testCH(T1, T2, T2, T3));
  });

  test("Overlap Diff Day Same Type", () {
    //  T1......T2
    //  T1......T2
    expect(false, testHWDD(3, 4, T1, T2, T1, T2));
    expect(false, testHWDD(5, 6, T1, T2, T1, T2));
    //  T1......T2
    //                  T3......T4
    expect(false, testHWDD(3, 4, T1, T2, T3, T4));
    expect(false, testHWDD(5, 6, T1, T2, T3, T4));
    //                  T1......T2
    //  T3......T4
    expect(false, testHWDD(3, 4, T3, T4, T1, T2));
    expect(false, testHWDD(5, 6, T3, T4, T1, T2));
    //          T2......T3
    //      T5......T6
    expect(false, testHWDD(3, 4, T2, T3, T5, T6));
    expect(false, testHWDD(5, 6, T2, T3, T5, T6));
    //          T2......T3
    //              T6......T7
    expect(false, testCHDD(3, 4, T2, T3, T6, T7));
    expect(false, testHWDD(5, 6, T2, T3, T6, T7));
  });

  test("Overlap Same Day Diff Type", () {
    //  T1......T2
    //  T1......T2
    expect(false, testAll(DevType.HW, DevType.CH, 3, 3, T1, T2, T1, T2));
    expect(false, testAll(DevType.CH, DevType.HW, 3, 3, T1, T2, T1, T2));
    //  T1......T2
    //                  T3......T4
    expect(false, testAll(DevType.HW, DevType.CH, 3, 3, T1, T2, T3, T4));
    expect(false, testAll(DevType.CH, DevType.HW, 3, 3, T1, T2, T3, T4));
    //                  T1......T2
    //  T3......T4
    expect(false, testAll(DevType.HW, DevType.CH, 3, 3, T3, T4, T1, T2));
    expect(false, testAll(DevType.CH, DevType.HW, 3, 3, T3, T4, T1, T2));
    //          T2......T3
    //      T5......T6
    expect(false, testAll(DevType.HW, DevType.CH, 3, 3, T2, T3, T5, T6));
    expect(false, testAll(DevType.CH, DevType.HW, 3, 3, T2, T3, T5, T6));
    //          T2......T3
    //              T6......T7
    expect(false, testAll(DevType.HW, DevType.CH, 3, 3, T2, T3, T6, T7));
    expect(false, testAll(DevType.CH, DevType.HW, 3, 3, T2, T3, T6, T7));
  });
}

bool testHW(int s1, int e1, int s2, int e2) {
  return testAll(DevType.HW, DevType.HW, 1, 1, s1, e1, s2, e2);
}

bool testCH(int s1, int e1, int s2, int e2) {
  return testAll(DevType.CH, DevType.CH, 2, 2, s1, e1, s2, e2);
}

bool testHWDD(int day1, int day2, int s1, int e1, int s2, int e2) {
  return testAll(DevType.HW, DevType.HW, day1, day2, s1, e1, s2, e2);
}

bool testCHDD(int day1, int day2, int s1, int e1, int s2, int e2) {
  return testAll(DevType.CH, DevType.CH, day1, day2, s1, e1, s2, e2);
}

bool testAll(DevType type1, DevType type2, int day1, int day2, int s1, int e1, int s2, int e2) {
  ScheduleOnOff sc1 = ScheduleOnOff(type1, day1, s1, e1);
  ScheduleOnOff sc2 = ScheduleOnOff(type2, day2, s2, e2);
  return sc1.overlaps(sc2);
}
