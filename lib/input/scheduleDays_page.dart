import 'package:flutter/material.dart';
import 'package:iot_app/data/data_objects.dart';
import 'package:iot_app/data/settings_data.dart';
import '../styles.dart';

const double ICON_SCALE = 4.5;

class ScheduleDayPage extends StatefulWidget {
  @override
  _ScheduleDayPageState createState() => _ScheduleDayPageState();
}

class _ScheduleDayPageState extends State<ScheduleDayPage> {
  double screenWidth = 0;
  bool canDelete = true;

  Widget _makeCard(BuildContext context, ScheduleOnOff scheduleOnOff) {
    bool isSet = scheduleOnOff.isSet();
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                  "${scheduleOnOff.fromStr()} ${scheduleOnOff.descriptionStr()}",
                  textAlign: TextAlign.left,
                  style: const ScheduleDataStyle()),
              isSet
                  ? EmptyContainer()
                  : FlatButton.icon(
                      onPressed: () {
                        setState(() {
                          scheduleOnOff.initOn();
                        });
                      },
                      icon: Icon(
                        Icons.access_time,
                        color: Colors.blue,
                      ),
                      label: Text("Click here!",
                          style: const ScheduleDataIconStyle()),
                    ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                isSet
                    ? FlatButton.icon(
                        icon: Icon(
                          Icons.arrow_upward,
                          color: Colors.blue,
                        ),
                        label: Text("Add Before",
                            style: const ScheduleDataIconStyle()),
                      )
                    : EmptyContainer(),
                isSet
                    ? FlatButton.icon(
                        icon: Icon(
                          Icons.access_time,
                          color: Colors.blue,
                        ),
                        label:
                            Text("Set", style: const ScheduleDataIconStyle()),
                      )
                    : EmptyContainer(),
              ]),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                isSet
                    ? FlatButton.icon(
                        icon: Icon(
                          Icons.arrow_downward,
                          color: Colors.blue,
                        ),
                        label: Text(
                          "Add After ",
                          style: const ScheduleDataIconStyle(),
                        ),
                      )
                    : EmptyContainer(),
                canDelete
                    ? FlatButton.icon(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.blue,
                        ),
                        label:
                            Text("Del", style: const ScheduleDataIconStyle()),
                      )
                    : EmptyContainer(),
                isSet
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
                        label:
                            Text("Clear", style: const ScheduleDataIconStyle()),
                      )
                    : EmptyContainer(),
              ]),
        ],
      ),
    );
  }

  List<Widget> populate(
      BuildContext context, ScheduleTypeAndRange scheduleTypeAndRange) {
    List<ScheduleOnOff> temp = SettingsData.scheduleList.filter(scheduleTypeAndRange.type, scheduleTypeAndRange.startDay);
    if (temp.isEmpty) {
      ScheduleOnOff scheduleOnOff = ScheduleOnOff(scheduleTypeAndRange, SEC_HALF_DAY, SEC_HALF_DAY);
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
    final ScheduleTypeAndRange args = ModalRoute.of(context).settings.arguments;
    List<Widget> list = populate(context, args);
    return Scaffold(
      appBar: new AppBar(
        toolbarHeight: 80,
        title: new Text(
          'Schedule ${args.name()}\n$args',
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
}
