import 'dart:async';
import 'package:iot_app/data/schedule_data.dart';
import 'package:iot_app/data/notification.dart';
import 'package:iot_app/data/settings_data.dart';
import 'package:iot_app/styles.dart';
import 'package:flutter/material.dart';

class ManagePage extends StatefulWidget {
  final DevType deviceType;

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
  Widget notification = EmptyContainer();

  @override
  void dispose() {
    super.dispose();
    Notifier.remove(this);
  }

  @override
  void initState() {
    super.initState();
    deviceState = SettingsData.getState(widget.deviceType);
    deviceState.clearSync();
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

  Widget _makeBoostCard(BuildContext context, String mode, int count, double size, String route, String arg, String text, String image) {
    return InkWell(
      onTap: () {
        setState(() {
          if (deviceState.isInSync()) {
            deviceState.setOn(mode);
          }
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
           setState(() {
             if (deviceState.isInSync()) {
               deviceState.setOn(!deviceState.isOn()?"on":"off");
             }
          });
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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Control ${deviceState.typeData.name}',
          style: const TitleStyle(),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            notification,
            Text(
              deviceState.statusString(),
              textAlign: TextAlign.center,
              style: const HeadingDataStyle(),
            ),
            _makeOnOffCard(context, 1, 1.6, "/input", deviceState),
             BlackDivider(),
            _makeBoostCard(context, "b1", 1, 1.6, "/input", "${deviceState.typeData.name},1", "1 Hour\nBoost", "Boost"),
            _makeBoostCard(context, "b2", 2, 2, "/input", "${deviceState.typeData.name},2", "2 Hour\nBoost", "Boost"),
            _makeBoostCard(context, "b3", 3, 2.8, "/input", "${deviceState.typeData.name},3", "3 Hour\nBoost", "Boost"),
          ],
        ),
      ),
    );
  }

  @override
  void update(String m, int count, bool error) {
    print("Manage Notification ${error?"ERROR":""} $m");
    setState(() {
      if (count > 0) {
        deviceState.clearSync();
      }
      notification = !error?EmptyContainer():Text("[$m]", style: StatusTextStyle(error),textAlign: TextAlign.center,);
    });
  }
}
