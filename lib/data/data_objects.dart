import 'package:intl/intl.dart';
import 'package:iot_app/data/settings_data.dart';

const int MS_DAY = 86400000;
const int SEC_DAY = 86400;
const int SEC_HALF_DAY = 43200;

const List<String> DAYS = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

const List<String> DAYS_S = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

const Map<String, String> DEV_NAMES = {"CH": "Heating", "HW": "Hot Water"};

class ScheduleList {
  List<ScheduleOnOff> scheduleList;

  ScheduleList(this.scheduleList);

  static ScheduleList init() {
    List<ScheduleOnOff> scheduleList = [];
    return ScheduleList(scheduleList);
  }

  bool hasAnySet(String type, int startDay) {
    return filter(type, startDay).length > 0;
  }

  List<ScheduleOnOff> filter(String type, int startDay) {
    List<ScheduleOnOff> temp = [];
    scheduleList.forEach((s) {
      if (s.type() == type) {
        if (s.startDay() == startDay) {
          if (s.isSet()) {
            temp.add(s);
          }
        }
      }
    });
    print("$type, $startDay, Size = ${temp.length}");
    return temp;
  }

  List<ScheduleOnOff> list() {
    return scheduleList;
  }

  void add(ScheduleOnOff scheduleOnOff) {
    scheduleList.add(scheduleOnOff);
  }

  void remove(ScheduleOnOff scheduleOnOff) {
    scheduleList.remove(scheduleOnOff);
  }
}

class ScheduleTypeAndRange {
  final String type;
  final int startDay;
  final int endDay;

  ScheduleTypeAndRange(this.type, this.startDay, this.endDay);

  @override
  String toString() {
    return "${startDay == endDay ? DAYS[startDay] : "${DAYS_S[startDay]}-${DAYS_S[endDay]}"}";
  }

  String name() {
    return DEV_NAMES[type];
  }
}

class ScheduleOnOff {
  final ScheduleTypeAndRange _scheduleTypeAndRange;
  int onTime;
  int offTime;

  ScheduleOnOff(this._scheduleTypeAndRange, this.onTime, this.offTime);

  String type() {
    return _scheduleTypeAndRange.type;
  }

  int startDay() {
    return _scheduleTypeAndRange.startDay;
  }

  String name() {
    return _scheduleTypeAndRange.name();
  }

  DateTime fromDT() {
    return dateTimePlusDS(_scheduleTypeAndRange.startDay, onTime);
  }

  DateTime toDT() {
    return dateTimePlusDS(_scheduleTypeAndRange.startDay, offTime);
  }

  String fromStr() {
    if (_isSet(duration())) {
      DateTime dt = fromDT();
      return "${DAYS_S[dt.weekday - 1]} ${pad(dt.hour)}:${pad(dt.minute)}";
    }
    return "";
  }

  Duration duration() {
    return toDT().difference(fromDT());
  }

  bool _isSet(Duration d) {
    return d.inSeconds > 5;
  }

  bool isSet() {
    return _isSet(duration());
  }

  String descriptionStr() {
    Duration d = duration();
    if (_isSet(d)) {
      return "for ${d.inHours}:${pad(d.inMinutes % 60)} m";
    }
    return "Is not set.";
  }

  @override
  String toString() {
    return "$onTime : $offTime";
  }

  void clear() {
    onTime = SEC_HALF_DAY;
    offTime = SEC_HALF_DAY;
  }

  void initOn() {
    onTime = SEC_HALF_DAY;
    offTime = SEC_HALF_DAY + 3600;
  }
}

DateTime dateTimeMonday() {
  DateTime now = DateTime.now();
  DateTime mon1 = DateTime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch - ((now.weekday - 1) * MS_DAY));
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
