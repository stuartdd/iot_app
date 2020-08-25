import 'dart:async';

import 'package:iot_app/data/settings_data.dart';
import 'package:iot_app/styles.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  final String deviceType;

  ManagePage(this.deviceType);

  @override
  _ManagePageState createState() => _ManagePageState();
}

const double screenDiv = 2;
const timerDelay = const Duration(seconds:1);

class _ManagePageState extends State<ManagePage> {
  DeviceState deviceState;
  double screenWidth = 0;
  String name;
  Timer timer;

  String heatingDesc() {
    String s = "${deviceState.name} is currently ";
    if (deviceState.isBoosted()) {
      return s + "Boosted\nuntil ${deviceState.boostedUntil()}";
    } else {
      return s + "${deviceState.onString()}\nuntil next scheduled ${deviceState.notOnString()} time.";
    }
  }

  @override
  void initState() {
    deviceState = SettingsData.getState(widget.deviceType);
//    timer = Timer.periodic(timerDelay, (Timer t) {
//      setState(() {
//      });
//    });
  }

  List<Widget> _makeIcons(int count, double size, String text, String icon) {
    List<Widget> list = [];
    for (int i = 0; i < count; i++) {
      list.add(Image.asset(
        "assets/$icon.png",
        width: screenWidth / size / screenDiv,
        height: screenWidth / size / screenDiv,
      ));
    }
    list.add(Text(
      text,
      textAlign: TextAlign.center,
      style: const BoostTextStyle(),
    ));
    return list;
  }

  Widget _makeBoostCard(BuildContext context, int count, double size, String route, String arg, String text, String image) {
    return InkWell(
      onTap: () {
        setState(() {
          deviceState.boost(count * 60);
        });
      },
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _makeIcons(count, size, text, image),
        ),
      ),
    );
  }

  Widget _makeOnOffCard(BuildContext context, int count, double size, String route, DeviceState deviceState) {
    return InkWell(
      onTap: () {
        setState(() {
          deviceState.setOn(!deviceState.isOn());
        });
      },
      child: Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Image.asset(
            "assets/${deviceState.iconPrefix()}.png",
            width: screenWidth / size / screenDiv,
            height: screenWidth / size / screenDiv,
          ),
          Text(
            "Turn\n${deviceState.notOnString()}",
            textAlign: TextAlign.center,
            style: const BoostTextStyle(),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    int remainingMinutes = deviceState.remainingBoostSeconds();
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Control ${deviceState.name}',
          style: const TitleStyle(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              heatingDesc(),
              textAlign: TextAlign.center,
              style: const HeadingDataStyle(),
            ),
            BlackDivider(),
            _makeOnOffCard(context, 1, 1.6, "/input", deviceState),
            Text(
              "Until next scheduled ${deviceState.onString()} time",
              textAlign: TextAlign.center,
              style: const HeadingDataStyle(),
            ),
            BlackDivider(),
            _makeBoostCard(context, 1, 1.6, "/input", "${deviceState.type},1", "1 Hour\nBoost", "Boost"),
            _makeBoostCard(context, 2, 2, "/input", "${deviceState.type},2", "2 Hour\nBoost", "Boost"),
            _makeBoostCard(context, 3, 3, "/input", "${deviceState.type},3", "3 Hour\nBoost", "Boost"),
            Text(
              "${deviceState.isBoosted() ? "BOOSTED Until ${deviceState.boostedUntil()}" : ""}",
              textAlign: TextAlign.center,
              style: const InfoTextStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
