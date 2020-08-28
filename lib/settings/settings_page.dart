import 'package:iot_app/data/notification.dart';
import 'package:iot_app/data/settings_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../styles.dart';

const double fieldFontSize = 19;

class SettingsPage extends StatefulWidget  {
  @override
  _SettingsPageState createState() => _SettingsPageState();

}

class _SettingsPageState extends State<SettingsPage> implements NotifiablePage {
  TextEditingController hostController;
  TextEditingController portController;
  TextEditingController pollController;
  String portText = SettingsData.getPort().toString();
  String pollText = SettingsData.getUpdatePeriodSeconds().toString();
  double screenWidth = 0;
  double fieldWidth = 0;

  Widget notification() {
    String m = Notifier.lastMessage.isEmpty ? "Connection OK${SettingsData.ellipses()}" : Notifier.lastMessage;
    return Text("[$m]", style: StatusTextStyle(Notifier.lastError),textAlign: TextAlign.center,);
  }

  bool validatePort() {
    try {
      int i = int.parse(portText);
      return ((i > 0) && (i < 65536));
    } on Exception {
      return false;
    }
  }

  bool validatePoll() {
    try {
      int i = int.parse(pollText);
      return ((i > 4) && (i < 31));
    } on Exception {
      return false;
    }
  }

  @override
  void dispose() {
    Notifier.remove(this);
    hostController.dispose();
    portController.dispose();
    pollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    hostController = TextEditingController(text: SettingsData.host);
    portController = TextEditingController(text: SettingsData.getPort().toString());
    pollController = TextEditingController(text: SettingsData.getUpdatePeriodSeconds().toString());
    Notifier.addListener(this);
  }

  Widget makeCard(String label, double fieldWidth, Widget inputWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: fieldWidth,
          child: Text(
            label,
            style: GoogleFonts.robotoMono(
              fontSize: fieldFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        SizedBox(width: screenWidth - fieldWidth - 10, child: inputWidget)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    fieldWidth = (screenWidth / 3);
    return Scaffold(
      appBar: new AppBar(
          title: new Text(
            'Settings',
            style: const TitleStyle(),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.build),
              onPressed: () {
                Navigator.pushNamed(context, "/maintenance");
              },
            ),
          ]),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            notification(),
            infoStyleWithText("The HOST Device's http address\nExample: https://myDevice\nExample: http://192.168.1.255"),
            makeCard(
              "Host:" ,
              fieldWidth * 0.6,
              TextField(
                style: GoogleFonts.robotoMono(
                  fontSize: fieldFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                controller: hostController,
                autocorrect: true,
                keyboardType: TextInputType.url,
                onSubmitted: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      SettingsData.host = value;
                    } else {
                      hostController.text = SettingsData.host;
                    }
                  });
                },
              ),
            ),
            infoStyleWithText("The HOST Device's port number\nBetween 1 and 65535"),
            makeCard(
              "Port:",
              fieldWidth * 1.6,
              TextField(
                style: GoogleFonts.robotoMono(
                  fontSize: fieldFontSize,
                  fontWeight: FontWeight.bold,
                  color: validatePort()?Colors.green:Colors.red,
                ),
                autocorrect: true,
                keyboardType: TextInputType.number,
                controller: portController,
                onChanged: (value) {
                  setState(() {
                    portText = value;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    if (validatePort()) {
                      SettingsData.setPort(int.parse(portText));
                    } else {
                      portText = SettingsData.getPort().toString();
                      portController.text = portText;
                    }
                  });
                },
              ),
            ),
            infoStyleWithText("Number of seconds between Device updates\n Between 5 and 30"),
            makeCard(
              "Update period:",
              fieldWidth * 1.6,
              TextField(
                style: GoogleFonts.robotoMono(
                  fontSize: fieldFontSize,
                  fontWeight: FontWeight.bold,
                  color: validatePoll()?Colors.green:Colors.red,
                ),
                autocorrect: true,
                keyboardType: TextInputType.number,
                controller: pollController,
                onChanged: (value) {
                  setState(() {
                    pollText = value;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    if (validatePoll()) {
                      SettingsData.setUpdatePeriodSeconds(int.parse(pollText));
                    } else {
                      pollText = SettingsData.getUpdatePeriodSeconds().toString();
                      pollController.text = pollText;
                    }
                  });
                },
              ),
            ),
            makeCard(
                "Show Hidden",
                fieldWidth * 1.5,
                Checkbox(
                    value: SettingsData.var1,
                    onChanged: (v) {
                      setState(() {
                        SettingsData.var1 = v;
                      });
                    })),
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
