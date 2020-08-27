import 'dart:async';

import 'package:iot_app/settings/maintenance_page.dart';
import 'package:flutter/material.dart';
import 'data/settings_data.dart';
import 'input/manage_page.dart';
import 'main_page.dart';

void main() {
  runApp(BPApp());
}

class BPApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SettingsData.initState();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorObservers: [routeObserver],
      initialRoute: "/",
      routes: {
        "/": (context) => MainPage(),
        "/manageCH": (context) => ManagePage("CH"),
        "/manageHW": (context) => ManagePage("HW"),
        "/schedule": (context) => MaintenancePage(),
        "/settings": (context) => MaintenancePage(),
      },
    );
  }
}
