import 'package:iot_app/data/notification.dart';
import 'package:iot_app/data/settings_data.dart';
import 'package:iot_app/styles.dart';
import 'package:flutter/material.dart';

import 'data/schedule_data.dart';

final RouteObserver<PageRoute> routeObserverMP = RouteObserver<PageRoute>();

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with RouteAware implements NotifiablePage {
  static double screenWidth = 0;
  Widget notification = EmptyContainer();

  @override
  void dispose() {
    super.dispose();
    Notifier.remove(this);
  }

  @override
  void initState() {
    super.initState();
    Notifier.addListener(this);
  }

  Widget _makeCard(BuildContext context, String text, String route, String image, bool ignoreConnection) {
    return InkWell(
      onTap: () {
        if (SettingsData.connected || ignoreConnection) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              "assets/${image}",
              width: screenWidth / 2.2,
              height: screenWidth / 2.2,
            ),
            Text(text, textAlign: TextAlign.center ,style: const CardTextStyle()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Heating Controller',
          style: const TitleStyle(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
          ),
       ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          notification,
          deviceDesc(DevType.CH),
          _makeCard(context, "Manage\n${DevTypeData.forDevType(DevType.CH).name}", "/manageCH", "${SettingsData.getState(DevType.CH).iconPrefix()}.png",false),
          deviceDesc(DevType.HW),
          _makeCard(context, "Manage\n${DevTypeData.forDevType(DevType.HW).name}", "/manageHW", "${SettingsData.getState(DevType.HW).iconPrefix()}.png",false),
          _makeCard(context, "Schedule", "/schedule", "Dial.png",true),
        ],
      ),
    );
  }

  Widget deviceDesc(DevType type) {
      return Text(
        SettingsData.statusString(type),
        textAlign: TextAlign.center,
        style: const HeadingDataStyle(),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserverMP.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    setState(() {
      SettingsData.save();
    });
  }

  @override
  void update(String m, int count, bool error) {
    setState(() {
      notification = !error?EmptyContainer():Text("[$m]", style: StatusTextStyle(error),textAlign: TextAlign.center,);
    });
  }
}
