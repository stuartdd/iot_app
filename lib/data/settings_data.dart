import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:iot_app/data/comms.dart';
import 'package:path_provider/path_provider.dart';

import 'notification.dart';

const String FN_PREF = "settings";
const String FN_TYPE = "json";
const String J_TYPE = "type";
const String J_NAME = "name";
const String J_HOST = "host";
const String J_PORT = "port";
const String J_PERIOD = "period";
const String J_REMOTE_ID = "remoteId";

const String DEFAULT_HOST = "http://192.168.1.177";
const int DEFAULT_PORT = 80;
const int DEFAULT_PERIOD_SECONDS = 5;
const String ELLIPSES = "......";
const String J_STATE = "state";
const String J_DEVICES = "devices";

class DeviceState {
  final String type;
  final String name;
  final String remoteId;

  bool _on = false;
  DateTime _boostUntil;

  DeviceState(this.type, this.name, this.remoteId);

  String toJson() {
    return '{\"$J_TYPE\":\"$type\",\"$J_NAME\":\"$name\",\"$J_REMOTE_ID\":\"$remoteId\",\"$J_STATE\":\"${onString()}\"}';
  }

  boost(int mins) {
    _boostUntil = DateTime.now().add(Duration(minutes: mins));
    _on = true;
  }

  bool isBoosted() {
    return remainingBoostSeconds() > 0;
  }

  String iconPrefix() {
    return "${_on ? "ON" : "OFF"}_$type";
  }

  String pad(int i) {
    if (i < 10) {
      return "0" + i.toString();
    }
    return i.toString();
  }

  int remainingBoostSeconds() {
    if (_boostUntil == null) {
      return 0;
    }
    return _boostUntil.difference(DateTime.now()).inSeconds;
  }

  String boostedUntil() {
    return "${pad(_boostUntil.hour)}:${pad(_boostUntil.minute)}";
  }

  isOn() {
    return _on;
  }

  String onString() {
    return _on ? "ON" : "OFF";
  }

  String notOnString() {
    return _on ? "OFF" : "ON";
  }

  setOn(bool newState) {
    _boostUntil = null;
    _on = newState;
  }

  bool updateState(Map m) {
    bool currentOn = _on;
    if (m[remoteId] == null) {
      SettingsData.log("$type map[$remoteId] is null");
      _on = false;
      _boostUntil = null;
    } else {
      int t = m[remoteId];
      if ((t != null) && (t > 0)) {
        _on = true;
        _boostUntil = DateTime.now().add(Duration(seconds: t));
      } else {
        _on = false;
        _boostUntil = null;
      }
    }
    return (_on != currentOn);
  }
}

class SettingsData {
  static Map<String, DeviceState> _state;
  static String userName = "UN";
  static bool var1 = true;
  static List<String> _logList = [];
  static int _logListIndex = 0;
  static String host;
  static int _port;
  static bool connected = false;
  static Timer updateTimer;
  static int updateCounter = 0;
  static int _updatePeriodSeconds = DEFAULT_PERIOD_SECONDS;

  static getPort() {
    return _port == null ? 80 : _port;
  }

  static setPort(int newPort) {
    _port = newPort;
  }

  static getUpdatePeriodSeconds() {
    return _updatePeriodSeconds == null ? DEFAULT_PERIOD_SECONDS : _updatePeriodSeconds;
  }

  static setUpdatePeriodSeconds(int newUpdatePeriodSeconds) {
    _updatePeriodSeconds = newUpdatePeriodSeconds;
    initTimer();
  }

  static updateState() async {
    SettingsData.updateCounter++;
    if (!connected) {
      await Notifier.send("Contacting device." + ellipses(), true);
    }
    Remote rd = Remote(host, getPort());
    try {
      Map m = await rd.get("switch");
      int count = 0;
      _state.forEach((k, v) {
        if (v.updateState(m)) {
          count++;
        }
      });
      if (count > 0) {
        await Notifier.send("$count change${count > 1 ? 's' : ''}." + ellipses(), false);
      } else {
        await Notifier.send('', false);
      }
      connected = true;
    } on Exception {
      await Notifier.send("Failed to read device." + ellipses(), true);
      connected = false;
    }
  }

  static String ellipses() {
    return ELLIPSES.substring(0, (SettingsData.updateCounter % 4));
  }

  static _defaultState(bool justDoIt) {
    if (justDoIt || (_state == null) || (_state.isEmpty)) {
      log("Loaded defaultState.");
      host = DEFAULT_HOST;
      _port = DEFAULT_PORT;
      _updatePeriodSeconds = DEFAULT_PERIOD_SECONDS;
      _state = {"CH": DeviceState("CH", "Heating", "ra"), "HW": DeviceState("HW", "Hot Water", "rb")};
    }
  }

  static initState() async {
    _defaultState(true);
    final file = await _localFile();
    if (file.existsSync()) {
      await load();
    } else {
      log("Saving Default State!");
      save();
    }
    await updateState();
    if (updateTimer == null) {
      initTimer();
    }
  }

  static initTimer() {
    if (updateTimer != null) {
      updateTimer.cancel();
    }

    updateTimer = Timer.periodic(Duration(seconds: getUpdatePeriodSeconds()), (t) async {
      await updateState();
    });
  }

  static DeviceState getState(String type) {
    return _state[type];
  }

  static String toJson() {
    String s = "";
    _state.forEach((k, v) => s = s + v.toJson() + ',');
    return '{\"$J_NAME\":\"Stuart\",\"$J_HOST\":\"$host\",\"$J_PORT\":${getPort()},\"$J_PERIOD\":${getUpdatePeriodSeconds()}, \"$J_DEVICES\" : [${s.substring(0, s.length - 1)}]}';
  }

  static int readInt(Map map, String name, int def) {
    int val = map[name];
    return val == null ? def : val;
  }

  static String readString(Map map, String name, String def) {
    var val = map[name];
    return val == null ? def : val;
  }

  static bool readBool(Map map, String name, bool def) {
    bool val = map[name];
    return val == null ? def : val;
  }

  // {"name":"Stuart", "host":"http://192.168.1.177","port":80, "devices" : [{"type":"CH","name":"Heating","state":"OFF"},{"type":"HW","name":"Hot Water","state":"OFF"}]}

  static parseJson(String json) {
    Map userMap;
    try {
      userMap = jsonDecode(json);
    } on Exception catch (e) {
      SettingsData.log("Unable to parse JSON input. ${e.toString()}");
      _defaultState(false);
      return;
    }
    if (userMap[J_DEVICES] == null) {
      log("parse: No 'devices' in json");
      _defaultState(false);
      return;
    }
    userName = readString(userMap, J_NAME, "Unknown");
    host = readString(userMap, J_HOST, DEFAULT_HOST);
    _port = readInt(userMap, J_PORT, DEFAULT_PORT);
    _updatePeriodSeconds = readInt(userMap, J_PERIOD, DEFAULT_PERIOD_SECONDS);

    Map<String, DeviceState> temp = {};
    for (Map dMap in userMap[J_DEVICES]) {
      String type = readString(dMap, J_TYPE, null);
      if (type != null) {
        DeviceState ds = DeviceState(type, readString(dMap, J_NAME, "Unknown"), readString(dMap, J_REMOTE_ID, null));
        temp[ds.type] = ds;
      } else {
        log("parse: 'devices.type' is null. Skipping entry!");
      }
    }
    if (temp.length == 0) {
      log("parse: device map is empty!");
      _defaultState(false);
    } else {
      _state = temp;
    }
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile() async {
    final path = await _localPath;
    return File('$path/$FN_PREF.$FN_TYPE');
  }

  static void save() async {
    final file = await _localFile();
    try {
      log("Save [${file.path}]");
      await file.writeAsString(toJson());
    } on Exception catch (e) {
      log("Save [${file.path}] failed. Reason:" + e.toString());
    }
  }

  static Future<void> load() async {
    final file = await _localFile();
    try {
      log("load [${file.path}]");
      String contents = await file.readAsString();
      parseJson(contents);
    } on Exception catch (e) {
      log("Load [${file.path}] failed. Reason:" + e.toString());
    }
  }

  static Future<String> copyFileToClipboard(bool fromFile) async {
    String contents;
    if (fromFile) {
      final file = await _localFile();
      try {
        if (file.existsSync()) {
          contents = await file.readAsString();
        } else {
          contents = SettingsData.log("File [${file.path}] does not exist:\n" + toJson());
        }
        Clipboard.setData(ClipboardData(text: contents));
        return contents;
      } on Exception catch (e) {
        return SettingsData.log("Unable to read file [${file.path})]");
      }
    } else {
      contents = toJson();
      Clipboard.setData(ClipboardData(text: contents));
      return contents;
    }
  }

  static String log(String s) {
    _logListIndex++;
    _logList.add("$_logListIndex: $s");
    if (_logList.length > 20) {
      _logList.removeAt(0);
    }
    return s;
  }

  static String getLog() {
    String l = '';
    _logList.forEach((st) {
      l = l + st + '\n';
    });
    return l;
  }
}
