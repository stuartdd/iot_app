import 'package:flutter/material.dart';
import 'package:iot_app/data/schedule_data.dart';
import 'package:iot_app/data/settings_data.dart';
import '../styles.dart';

const double ICON_SCALE = 4.5;

enum CHOICE_ENUM { CHOICE_ADD_TIME, CHOICE_SAT_SUN, CHOICE_MON_FRIDAY, CHOICE_CLEAR, CHOICE_CLEAR_SAT_SUN, CHOICE_CLEAR_MON_FRI, CHOICE_DISP_TIMES, CHOICE_DISP_DUR }
const _Choice AddTime = _Choice(Text("Set the ON time", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_ADD_TIME);
const _Choice SatSun = _Choice(Text("Use For Sat to Sun", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_SAT_SUN);
const _Choice MonFri = _Choice(Text("Use For Mon to Fri", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_MON_FRIDAY);
const _Choice ClearDay = _Choice(Text("Clear Day", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_CLEAR);
const _Choice ClearSatSun = _Choice(Text("Clear Sat to Sun", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_CLEAR_SAT_SUN);
const _Choice ClearMonFri = _Choice(Text("Clear Mon to Fri", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_CLEAR_MON_FRI);
const _Choice DisplayTimes = _Choice(Text("Display TO as Time", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_DISP_TIMES);
const _Choice DisplayDuration = _Choice(Text("Display TO as Duration", style: const ScheduleDataIconStyle()), CHOICE_ENUM.CHOICE_DISP_DUR);

class ScheduleDayPage extends StatefulWidget {
  @override
  _ScheduleDayPageState createState() => _ScheduleDayPageState();
}

class _Period {
  final String text;
  final int mins;

  const _Period(this.text, this.mins);
}

class _Choice {
  final Text text;
  final CHOICE_ENUM choice;

  const _Choice(this.text, this.choice);
}

class _ScheduleDayPageState extends State<ScheduleDayPage> {
  double screenWidth = 0;
  bool canDelete = true;

  List<_Period> periodList(ScheduleOnOff scheduleOnOff) {
    List<_Period> list = [];
    int mins = scheduleOnOff.getMaxPeriod() ~/ 60;
    int sub = 15;
    while (mins >= 15) {
      list.insert(0, _Period("${HM(mins)}", mins));
      mins = mins - sub;
    }
    list.insert(0, _Period('For', -1));
    return list;
  }

  Widget _makeDropDown(ScheduleOnOff scheduleOnOff) {
    List<_Period> list = periodList(scheduleOnOff);
    _Period _dropdownValue = list[0];
    return DropdownButton<_Period>(
      value: _dropdownValue,
      icon: Icon(
        Icons.arrow_drop_down,
        color: Colors.blue,
      ),
      style: ScheduleDataIconStyle(),
      underline: Container(
        height: 3,
        color: Colors.blue,
      ),
      onChanged: (_Period newValue) {
        setState(() {
          _dropdownValue = newValue;
          scheduleOnOff.setPeriodSeconds(newValue.mins * 60);
        });
      },
      items: list.map((_Period val) {
        return DropdownMenuItem<_Period>(
          child: new Text(val.text),
          value: val,
        );
      }).toList(),
    );
  }

  Widget _makeAddBefore(ScheduleOnOff scheduleOnOff) {
    bool canAdd = SettingsData.scheduleList.canAddBefore(scheduleOnOff);
    Icon icon = Icon(
      Icons.arrow_upward,
      color: canAdd ? Colors.blue : Colors.blueGrey[100],
    );
    Text text = Text("Add Before", style: (canAdd ? ScheduleDataIconStyle() : ScheduleDataIconStyleDis()));
    if (canAdd) {
      return FlatButton.icon(
        onPressed: () {
          setState(() {
            SettingsData.scheduleList.addBefore(scheduleOnOff);
          });
        },
        label: text,
        icon: icon,
      );
    } else {
      return FlatButton.icon(label: text, icon: icon, onPressed: () {});
    }
  }

  Widget _makeAddAfter(ScheduleOnOff scheduleOnOff) {
    bool canAdd = SettingsData.scheduleList.canAddAfter(scheduleOnOff);
    Icon icon = Icon(
      Icons.arrow_downward,
      color: canAdd ? Colors.blue : Colors.blueGrey[100],
    );
    Text text = Text("Add After", style: (canAdd ? ScheduleDataIconStyle() : ScheduleDataIconStyleDis()));
    if (canAdd) {
      return FlatButton.icon(
        onPressed: () {
          setState(() {
            SettingsData.scheduleList.addAfter(scheduleOnOff);
          });
        },
        icon: icon,
        label: text,
      );
    } else {
      return FlatButton.icon(label: text, icon: icon, onPressed: () {});
    }
  }

  Widget _makeCard(BuildContext context, ScheduleOnOff scheduleOnOff) {
    bool isSet = scheduleOnOff.isSet();
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text("${scheduleOnOff.onTimeStr()} ${scheduleOnOff.descriptionStr()}", textAlign: TextAlign.left, style: const ScheduleDataStyle()),
              isSet
                  ? EmptyContainer()
                  : FlatButton.icon(
                      onPressed: () {
                        setState(() {
                          SettingsData.scheduleList.addInitialSchedule(DayAndType(scheduleOnOff.type, scheduleOnOff.dayOfWeek));
                        });
                      },
                      icon: Icon(
                        Icons.access_time,
                        color: Colors.blue,
                      ),
                      label: Text("Click here to set!", style: ScheduleDataIconStyle()),
                    ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            (isSet) ? _makeAddBefore(scheduleOnOff) : EmptyContainer(),
            isSet ? _makeAddAfter(scheduleOnOff) : EmptyContainer(),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
            isSet
                ? FlatButton.icon(
                    onPressed: () async {
                      TimeOfDay tod1 = getTimeOfDay(scheduleOnOff);
                      await _selectTime(context, tod1).then((tod2) {
                        if ((tod2 != null) && (tod2 != tod1)) {
                          setState(() {
                            setTimeOfDay(tod2, scheduleOnOff);
                          });
                        }
                      });
                    },
                    icon: Icon(
                      Icons.access_time,
                      color: Colors.blue,
                    ),
                    label: Text("Time", style: const ScheduleDataIconStyle()),
                  )
                : EmptyContainer(),
            isSet
                ? Icon(
                    Icons.av_timer,
                    color: Colors.blue,
                  )
                : EmptyContainer(),
            isSet ? _makeDropDown(scheduleOnOff) : EmptyContainer(),
            canDelete
                ? FlatButton.icon(
                    onPressed: () {
                      setState(() {
                        SettingsData.scheduleList.remove(scheduleOnOff);
                      });
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.blue,
                    ),
                    label: Text("Del", style: const ScheduleDataIconStyle()),
                  )
                : EmptyContainer(),
            (isSet && !canDelete)
                ? FlatButton.icon(
                    onPressed: () {
                      setState(() {
                        scheduleOnOff.clear();
                      });
                    },
                    icon: Icon(
                      Icons.backspace,
                      color: Colors.blue,
                    ),
                    label: Text("Clear", style: const ScheduleDataIconStyle()),
                  )
                : EmptyContainer(),
          ]),
        ],
      ),
    );
  }

  List<Widget> populate(BuildContext context, DayAndType dayAndType) {
    List<ScheduleOnOff> temp = SettingsData.scheduleList.filter(dayAndType.typeData, dayAndType.day, true);
    if (temp.isEmpty) {
      ScheduleOnOff scheduleOnOff = ScheduleOnOff(dayAndType.typeData, dayAndType.day, SEC_HALF_DAY, SEC_HALF_DAY);
      SettingsData.scheduleList.add(scheduleOnOff);
      temp.add(scheduleOnOff);
      canDelete = false;
    } else {
      canDelete = temp.length > 1;
    }
    List<Widget> widgets = [];
    temp.forEach((scheduleOnOff) {
      widgets.add(_makeCard(context, scheduleOnOff));
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    final DayAndType dayAndType = ModalRoute.of(context).settings.arguments;
    List<Widget> list = populate(context, dayAndType);
    return Scaffold(
      appBar: new AppBar(
        toolbarHeight: 80,
        actions: <Widget>[
          PopupMenuButton<_Choice>(
            onSelected: (_Choice s) {
              setState(() {
                switch (s.choice) {
                  case CHOICE_ENUM.CHOICE_MON_FRIDAY:
                    SettingsData.scheduleList.duplicateMonFri(dayAndType);
                    break;
                  case CHOICE_ENUM.CHOICE_SAT_SUN:
                    SettingsData.scheduleList.duplicateSatSun(dayAndType);
                    break;
                  case CHOICE_ENUM.CHOICE_ADD_TIME:
                    SettingsData.scheduleList.addInitialSchedule(dayAndType);
                    break;
                  case CHOICE_ENUM.CHOICE_DISP_DUR:
                    SettingsData.dispScheduleAsDuration = true;
                    break;
                  case CHOICE_ENUM.CHOICE_DISP_TIMES:
                    SettingsData.dispScheduleAsDuration = false;
                    break;
                  case CHOICE_ENUM.CHOICE_CLEAR:
                    SettingsData.scheduleList.clear(dayAndType);
                    break;
                  case CHOICE_ENUM.CHOICE_CLEAR_MON_FRI:
                    SettingsData.scheduleList.clearMonFri(dayAndType);
                    break;
                  case CHOICE_ENUM.CHOICE_CLEAR_SAT_SUN:
                    SettingsData.scheduleList.clearSatSun(dayAndType);
                    break;

                }
              });
            },
            itemBuilder: (BuildContext context) {
              return menuChoices(dayAndType).map((choice) {
                return PopupMenuItem<_Choice>(
                  value: choice,
                  child: choice.text,
                );
              }).toList();
            },
          )
        ],
        title: new Text(
          '${dayAndType.name()}',
          textAlign: TextAlign.center,
          style: const TitleStyle(),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
        shrinkWrap: true,
        children: list,
      ),
    );
  }

  List<_Choice> menuChoices(DayAndType dayAndType) {
    List<_Choice> l = [];
    if (SettingsData.scheduleList.hasAnySet(dayAndType.typeData, dayAndType.day)) {
      l.add(dayAndType.isWeakend() ? SatSun : MonFri);
      l.add(ClearDay);
      l.add(SettingsData.dispScheduleAsDuration ? DisplayTimes : DisplayDuration);
    } else {
      l.add(AddTime);
      l.add(dayAndType.isWeakend() ? ClearSatSun : ClearMonFri);
    }
    return l;
  }

  Future<TimeOfDay> _selectTime(BuildContext context, TimeOfDay time) async {
    final TimeOfDay picked = await showTimePicker(context: context, initialTime: time);
    if (picked != null && picked != time) {
      return picked;
    }
    return null;
  }

  TimeOfDay getTimeOfDay(ScheduleOnOff scheduleOnOff) {
    return TimeOfDay.fromDateTime(dateTimePlusS(scheduleOnOff.getOnTimeToday()));
  }

  void setTimeOfDay(TimeOfDay selectTime, ScheduleOnOff scheduleOnOff) {
    if (selectTime == null) {
      return;
    }
    int diff = (selectTime.hour * SEC_HOUR) + (selectTime.minute * SEC_MIN) - scheduleOnOff.getOnTimeToday();
    scheduleOnOff.advance(diff);
  }
}
