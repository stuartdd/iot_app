import 'dart:async';
import 'package:iot_app/data/notification.dart';
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

class _ManagePageState extends State<ManagePage> implements NotifiablePage {
  DeviceState deviceState;
  double screenWidth = 0;
  String name;

  String deviceDesc() {
    if (deviceState.isOn()) {
      return "${deviceState.onString()} until ${deviceState.boostedUntil()}";
    } else {
      return "${deviceState.name} is ${deviceState.onString()}";
    }
  }

  @override
  void dispose() {
    super.dispose();
    Notifier.remove(this);
  }

  @override
  void initState() {
    super.initState();
    deviceState = SettingsData.getState(widget.deviceType);
    deviceState.forceSync();
    Notifier.addListener(this);
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
    list.add(boostButtonWithText(text, deviceState.isInSync()?Colors.green:Colors.pink));
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: _makeIcons(count, size, text, image),
        ),
      ),
    );
  }

  Widget _makeOnOffCard(BuildContext context, int count, double size, String route, DeviceState deviceState) {
    return InkWell(
      onTap: () {
        if (deviceState.isInSync()) {
          setState(() {
              deviceState.setOn(!deviceState.isOn());
          });
        }
      },
      child: Card(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Image.asset(
            "assets/${deviceState.iconPrefix()}.png",
            width: screenWidth / size / screenDiv,
            height: screenWidth / size / screenDiv,
          ),
          boostButtonWithText("Turn it\n${deviceState.notOnString()}", deviceState.isInSync()?Colors.green:Colors.pink),
        ]),
      ),
    );
  }

  Widget notification() {
    if (Notifier.lastMessage.isEmpty) {
      return Container(width: 0, height: 0);
    }
    return Text("[${Notifier.lastMessage}]", style: StatusTextStyle(Notifier.lastError),textAlign: TextAlign.center,);
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
            notification(),
            Text(
              deviceDesc(),
              textAlign: TextAlign.center,
              style: const HeadingDataStyle(),
            ),
            _makeOnOffCard(context, 1, 1.6, "/input", deviceState),
            Text(
              "Until next scheduled ${deviceState.onString()} time",
              textAlign: TextAlign.center,
              style: const HeadingDataStyle(),
            ),
            BlackDivider(),
            _makeBoostCard(context, 1, 1.6, "/input", "${deviceState.type},1", "1 Hour\nBoost", "Boost"),
            _makeBoostCard(context, 2, 2, "/input", "${deviceState.type},2", "2 Hour\nBoost", "Boost"),
            _makeBoostCard(context, 3, 2.8, "/input", "${deviceState.type},3", "3 Hour\nBoost", "Boost"),
          ],
        ),
      ),
    );
  }

  @override
  void update() {
    setState(() {
    });
  }
}
