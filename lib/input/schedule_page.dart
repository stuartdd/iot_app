import 'package:flutter/material.dart';
import 'package:iot_app/data/schedule_data.dart';
import 'package:iot_app/data/settings_data.dart';
import '../styles.dart';

const double ICON_SCALE = 4.5;

final RouteObserver<PageRoute> routeObserverSP = RouteObserver<PageRoute>();

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with RouteAware {
  double screenWidth = 0;

  Widget _makeCard(
      BuildContext context, String route, int day) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: screenWidth / ICON_SCALE,
            child: FlatButton(
              child: image(DevType.CH, day),
              onPressed: () {
                Navigator.pushNamed(context, "/scheduleDays",
                    arguments: DayAndType(DevTypeData.forDevType(DevType.CH), day));
              },
            ),
          ),
          SizedBox(
            width: screenWidth / ICON_SCALE,
            child: FlatButton(
                child: image(DevType.HW, day),
                onPressed: () {
                  Navigator.pushNamed(context, "/scheduleDays",
                      arguments: DayAndType(DevTypeData.forDevType(DevType.HW), day));
                }),
          ),
          Text("${DAYS[day]}",
              textAlign: TextAlign.left, style: const CardTextStyle()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Schedule',
          style: const TitleStyle(),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
        shrinkWrap: true,
        children: [
          _makeCard(context, "",  0),
          _makeCard(context, "",  1),
          _makeCard(context, "",  2),
          _makeCard(context, "",  3),
          _makeCard(context, "",  4),
          _makeCard(context, "",  5),
          _makeCard(context, "",  6),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserverSP.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    setState(() {
    });
  }

  Widget image(DevType type, int day) {
    return Image.asset(SettingsData.scheduleList.hasAnySet(type, day) ? "assets/${DevTypeData.forDevType(type).id}.png" : "assets/DIS_${DevTypeData.forDevType(type).id}.png");
  }
}
