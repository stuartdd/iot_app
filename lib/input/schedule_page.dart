import 'package:flutter/material.dart';
import '../styles.dart';
class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  double screenWidth = 0;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Schdule',
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
              "HI",
              textAlign: TextAlign.center,
              style: const HeadingDataStyle(),
            ),
          ],
        ),
      ),
    );
  }
}
