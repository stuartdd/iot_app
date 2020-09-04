import 'package:flutter/material.dart';
import 'package:iot_app/data/data_objects.dart';
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
      BuildContext context, String route, ScheduleTypeAndRange typeAndRange) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: screenWidth / ICON_SCALE,
            child: FlatButton(
              child: Image.asset(
                SettingsData.scheduleList.hasAnySet("CH", typeAndRange.startDay)?"assets/CH.png":"assets/OFF_CH.png",
              ),
              onPressed: () {
                print("CH $typeAndRange");
                Navigator.pushNamed(context, "/scheduleDays",
                    arguments: ScheduleTypeAndRange(
                        "CH", typeAndRange.startDay, typeAndRange.endDay));
              },
            ),
          ),
          SizedBox(
            width: screenWidth / ICON_SCALE,
            child: FlatButton(
                child: Image.asset(
                  SettingsData.scheduleList.hasAnySet("HW", typeAndRange.startDay)?"assets/HW.png":"assets/OFF_HW.png",
                ),
                onPressed: () {
                  print("HW $typeAndRange");
                  Navigator.pushNamed(context, "/scheduleDays",
                      arguments: ScheduleTypeAndRange(
                          "HW", typeAndRange.startDay, typeAndRange.endDay));
                }),
          ),
          Text("$typeAndRange",
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
          _makeCard(context, "", ScheduleTypeAndRange("", 0, 4)),
          _makeCard(context, "", ScheduleTypeAndRange("", 5, 6)),
          const BlackDivider(),
          _makeCard(context, "", ScheduleTypeAndRange("", 0, 0)),
          _makeCard(context, "", ScheduleTypeAndRange("", 1, 1)),
          _makeCard(context, "", ScheduleTypeAndRange("", 2, 2)),
          _makeCard(context, "", ScheduleTypeAndRange("", 3, 3)),
          _makeCard(context, "", ScheduleTypeAndRange("", 4, 4)),
          _makeCard(context, "", ScheduleTypeAndRange("", 5, 5)),
          _makeCard(context, "", ScheduleTypeAndRange("", 6, 6)),
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

}
