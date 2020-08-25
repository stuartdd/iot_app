import 'package:iot_app/data/settings_data.dart';
import 'package:iot_app/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> with RouteAware {
  static double screenWidth = 0;

  Widget _makeCard(BuildContext context, String text, String route, String image) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              "assets/${image}",
              width: screenWidth / 2,
              height: screenWidth / 2,
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
          _makeCard(context, "Manage\nCentral\nHeating", "/manageCH", "${SettingsData.getState("CH").iconPrefix()}.png"),
          _makeCard(context, "Manage\nHot\nWater", "/manageHW", "${SettingsData.getState("HW").iconPrefix()}.png"),
          _makeCard(context, "Schedule", "/schedule", "Dial.png"),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SettingsData.load(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    SettingsData.save(false);
    setState(() {});
  }

}
