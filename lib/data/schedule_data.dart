import 'package:iot_app/data/settings_data.dart';

const int MS_DAY = 86400000;
const int SEC_MIN = 60;
const int SEC_15M = 900;
const int SEC_HOUR = 3600;
const int SEC_30M = 1800;

const int SEC_INIT_DURATION = SEC_30M;

const int SEC_DAY = 86400;
const int SEC_HALF_DAY = 43200;

const TYPE_CH = "CH";
const TYPE_HW = "HW";

const MONDAY = 0;
const TUESDAY = 1;
const WEDNESDAY = 2;
const THURSDAY = 3;
const FRIDAY = 4;
const SATURDAY = 5;
const SUNDAY = 6;

const List<String> DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
const List<String> DAYS_S = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

enum DevType { CH, HW }

const List<DevTypeData> _DEV_DATA = [const DevTypeData(DevType.CH, TYPE_CH, "Heating"), const DevTypeData(DevType.HW, TYPE_HW, "Hot Water")];

class DevTypeDataNotFound implements Exception {
  final String clue;
  final String id;

  DevTypeDataNotFound(this.clue, this.id);

  @override
  String toString() {
    return 'Device Type Data Not Found $clue[$id]';
  }
}

class DevTypeData {
  final DevType type;
  final String id;
  final String name;

  const DevTypeData(this.type, this.id, this.name);

  static DevTypeData devTypeForId(String id) {
    for (var value in _DEV_DATA) {
      if (value.id == id) {
        return value;
      }
    }
    throw DevTypeDataNotFound("id", id);
  }

  static DevTypeData forDevType(DevType type) {
    for (var value in _DEV_DATA) {
      if (value.type == type) {
        return value;
      }
    }
    throw DevTypeDataNotFound("type", type.toString());
  }

  static String nameForDevType(DevType type) {
    return forDevType(type).name;
  }

  static String idForDevType(DevType type) {
    return forDevType(type).id;
  }

  @override
  String toString() {
    return name;
  }
}

class DayAndType {
  final DevType typeData;
  final int day;

  const DayAndType(this.typeData, this.day);

  bool isWeakend() {
    return ((day == SUNDAY) || (day == SATURDAY));
  }

  String name() {
    return DevTypeData.nameForDevType(typeData);
  }
}

class ScheduleOnOff implements Comparable {
  ScheduleList parent;
  final DevType type;
  final int dayOfWeek;
  int _onTimeToday;
  int _offTimeToday;

  ScheduleOnOff(this.type, this.dayOfWeek, this._onTimeToday, this._offTimeToday);

  ScheduleOnOff clone(int newOnTime, newOffTime) {
    return ScheduleOnOff(this.type, this.dayOfWeek, newOnTime, newOffTime);
  }

  String name() {
    return DevTypeData.nameForDevType(type);
  }

  int getOnTimeToday() {
    return _onTimeToday;
  }

  int getOffTimeToday() {
    return _offTimeToday;
  }

  advance(int seconds) {
    _onTimeToday = _onTimeToday + seconds;
    if (_onTimeToday >= _offTimeToday) {
      _offTimeToday = _offTimeToday + seconds;
    }
    parent.sort();
  }

  bool overlaps(ScheduleOnOff b) {
    if (this.type != b.type) {
      return false;
    }
    int as = this.secondsSinceMondayOn();
    int af = this.secondsSinceMondayOff();
    int bs = b.secondsSinceMondayOn();
    if ((bs >= as) && (bs <= af)) {
      return true;
    }
    int bf = b.secondsSinceMondayOff();
    if ((bf >= as) && (bf <= af)) {
      return true;
    }
    return false;
  }

  DateTime onDT() {
    return dateTimePlusDS(dayOfWeek, _onTimeToday);
  }

  DateTime offDT() {
    return dateTimePlusDS(dayOfWeek, _offTimeToday);
  }

  String onTimeStr() {
    if (_isSet(duration())) {
      DateTime dt = onDT();
      return "${DAYS_S[dt.weekday - 1]} ${pad(dt.hour)}:${pad(dt.minute)}";
    }
    return "";
  }

  String offTimeStr() {
    if (_isSet(duration())) {
      DateTime dt = offDT();
      return "${DAYS_S[dt.weekday - 1]} ${pad(dt.hour)}:${pad(dt.minute)}";
    }
    return "";
  }

  Duration duration() {
    return offDT().difference(onDT());
  }

  bool _isSet(Duration d) {
    return d.inSeconds > 5;
  }

  bool isSet() {
    return _isSet(duration());
  }

  String descriptionStr() {
    if (SettingsData.dispScheduleAsDuration) {
      return HMWords(duration());
    }
    String s = offTimeStr();
    if (s.isEmpty) {
      return "Not Set";
    }
    return "Until " + offTimeStr();
  }

  @override
  String toString() {
    return 'ScheduleOnOff{type: $type, day: $dayOfWeek, onTime: ${onTimeStr()}, offTime: ${offTimeStr()}';
  }

  void clear() {
    _onTimeToday = SEC_HALF_DAY;
    _offTimeToday = SEC_HALF_DAY;
  }

  @override
  int compareTo(other) {
    return secondsSinceMondayOn().compareTo((other as ScheduleOnOff).secondsSinceMondayOn());
  }

  int secondsSinceMondayOn() {
    return (dayOfWeek * SEC_DAY) + _onTimeToday;
  }

  int secondsSinceMondayOff() {
    return (dayOfWeek * SEC_DAY) + _offTimeToday;
  }

  int getMaxPeriod() {
    ScheduleOnOff n = next();
    if (n == null) {
      return SEC_DAY - this.getOnTimeToday();
    }
    return n.getOnTimeToday() - this.getOnTimeToday();
  }

  void setPeriodSeconds(int secs) {
    _offTimeToday = _onTimeToday + secs;
    parent.sort();
  }

  /*
  Return true is the schedules are the same type and on the same day.
   */
  bool isSame(ScheduleOnOff scheduleOnOff) {
    if (scheduleOnOff == null) {
      return false;
    }
    return ((scheduleOnOff.type == this.type) && (scheduleOnOff.dayOfWeek == this.dayOfWeek));
  }

  /*
  get The next schedule of the same type;
   */
  next() {
    var n = parent.next(this);
    while (n != null) {
      if (isSame(n)) {
        return n;
      }
      n = parent.next(n);
    }
    return null;
  }
}

class ScheduleList {
  List<ScheduleOnOff> _scheduleList;

  ScheduleList(this._scheduleList);

  static ScheduleList init() {
    List<ScheduleOnOff> scheduleList = [];
    return ScheduleList(scheduleList);
  }

  bool hasAnySet(DevType type, int startDay) {
    return filter(type, startDay, false).length > 0;
  }

  List<ScheduleOnOff> filter(DevType type, int startDay, bool unSet) {
    List<ScheduleOnOff> temp = [];
    _scheduleList.forEach((s) {
      if ((s.type == type) && (s.dayOfWeek == startDay)) {
        if (s.isSet() || unSet) {
          temp.add(s);
        }
      }
    });
    return temp;
  }

  List<ScheduleOnOff> list() {
    return _scheduleList;
  }

  void sort() {
    bool removed;
    do {
      _scheduleList.sort();
      removed = false;
      for (int i = 0; i < (_scheduleList.length - 1); i++) {
        ScheduleOnOff sch1 = _scheduleList[i];
        ScheduleOnOff sch2 = _scheduleList[i + 1];
        if (sch1.overlaps(sch2)) {
          remove(sch2);
          if (sch1._offTimeToday < sch2._offTimeToday) {
            sch1._offTimeToday = sch2._offTimeToday;
          }
          removed = true;
          break;
        }
      }
    } while (removed);
  }

  void add(ScheduleOnOff scheduleOnOff) {
    _scheduleList.add(scheduleOnOff);
    scheduleOnOff.parent = this;
    this.sort();
  }

  void addInitialSchedule(DayAndType dnt) {
    var s = filter(dnt.typeData, dnt.day, true);
    if (s.isEmpty) {
      add(ScheduleOnOff(dnt.typeData, dnt.day, SEC_HALF_DAY, SEC_HALF_DAY + SEC_INIT_DURATION));
    } else {
      s[0]._onTimeToday = SEC_HALF_DAY;
      s[0]._offTimeToday = SEC_HALF_DAY + SEC_INIT_DURATION;
    }
    this.sort();
  }

  bool canAddAfter(ScheduleOnOff scheduleOnOff) {
    sort();
    if ((SEC_DAY - scheduleOnOff.getOffTimeToday()) <= (SEC_INIT_DURATION * 2)) {
      return false;
    }
    return true;
  }

  bool canAddBefore(ScheduleOnOff scheduleOnOff) {
    sort();
    if (scheduleOnOff._onTimeToday <= (SEC_INIT_DURATION * 2)) {
      return false;
    }
    return true;
  }

  void addAfter(ScheduleOnOff current) {
    int onTim = (current._offTimeToday - (current._offTimeToday % SEC_15M)) + SEC_15M;
    add(current.clone(onTim, onTim + SEC_INIT_DURATION));
  }

  void addBefore(ScheduleOnOff scheduleOnOff) {
    add(scheduleOnOff.clone(scheduleOnOff._onTimeToday - SEC_INIT_DURATION * 2, scheduleOnOff._onTimeToday - SEC_INIT_DURATION));
  }

  void remove(ScheduleOnOff scheduleOnOff) {
    _scheduleList.remove(scheduleOnOff);
  }

  @override
  String toString() {
    return 'ScheduleList{_scheduleList: $_scheduleList}';
  }

  int indexOf(ScheduleOnOff scheduleOnOff) {
    return _scheduleList.indexOf(scheduleOnOff);
  }

  ScheduleOnOff previous(ScheduleOnOff scheduleOnOff) {
    int index = indexOf(scheduleOnOff);
    if (index < 1) {
      return null;
    }
    return _scheduleList[index - 1];
  }

  /*
  Get the next entry in the _scheduleList relative to the one passed in.
  Return if there is none and iff the one passed in is not found!
   */
  ScheduleOnOff next(ScheduleOnOff scheduleOnOff) {
    int index = indexOf(scheduleOnOff);
    if ((index < 0) || (index >= (_scheduleList.length - 1))) {
      return null;
    }
    return _scheduleList[index + 1];
  }

  void clear(DayAndType dayAndType) {
    var list = filter(dayAndType.typeData, dayAndType.day, true);
    for (var s in list) {
      remove(s);
    }
  }
}

DateTime dateTimeMonday() {
  DateTime now = DateTime.now();
  DateTime mon1 = DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch - ((now.weekday - 1) * MS_DAY));
  return DateTime(mon1.year, mon1.month, mon1.day, 0, 0, 1);
}

DateTime dateTimePlusS(int seconds) {
  return dateTimeMonday().add(Duration(seconds: seconds));
}

DateTime dateTimePlusDS(int days, int seconds) {
  return dateTimeMonday().add(Duration(seconds: (days * SEC_DAY) + seconds));
}

String pad(int i) {
  if (i < 10) {
    return "0" + i.toString();
  }
  return i.toString();
}

String HMS(int sec) {
  int h = sec ~/ SEC_HOUR;
  int rem = sec - (h * SEC_HOUR);
  int m = rem ~/ 60;
  rem = rem - (m * 60);
  return "${pad(h)}:${pad(m)}:${pad(rem)}";
}

String HM(int min) {
  int h = min ~/ 60;
  int m = min - (h * 60);
  return "${pad(h)}:${pad(m)}";
}

String HMWords(Duration d) {
  int min = d.inMinutes;
  int h = min ~/ 60;
  int m = min - (h * 60);

  if (m == 0) {
    if (h == 0) {
      return "Not Set!";
    }
    return "for $h hour${h > 1 ? "s" : ""}";
  } else {
    if (h == 0) {
      return "for ${pad(m)} min${m > 1 ? "s" : ""}";
    }
  }
  return "for ${pad(h)}h ${pad(m)}m";
}
