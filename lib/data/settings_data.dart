import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot_app/data/comms.dart';
import 'package:iot_app/data/updatable.dart';
import 'package:path_provider/path_provider.dart';

const String FN_PREF = "settings";
const String FN_TYPE = "json";
const String J_TYPE = "type";
const String J_NAME = "name";
const String J_HOST = "host";
const String J_PORT = "port";
const String J_REMOTE_ID = "remoteId";

const String DEFAULT_HOST = "http://192.168.1.177";
const int DEFAULT_PORT = 80;

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
    return "${pad(_boostUntil.hour)}:${pad(_boostUntil.minute)}:${pad(_boostUntil.second)}";
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
  static UpdatablePage listener;
  static Map<String, DeviceState> _state;
  static String userName = "UN";
  static bool var1 = true;
  static String _logStr = "";
  static String host;
  static int port;
  static Timer updateTimer;

  static Future<bool> updateState() async {
    Remote rd = Remote(host, port);

    try {
      Map m = await rd.get("switch");
      int count = 0;
      _state.forEach((k, v) {
        if (v.updateState(m)) {
          count++;
        }
      });
      if (count > 0) {
        if (listener != null) {
          listener.update();
        }
      }
    } on Exception {
      return false;
    }
    return true;
  }

  static defaultState() {
    log("defaultState");
    host = DEFAULT_HOST;
    port = DEFAULT_PORT;
    _state = {"CH": DeviceState("CH", "Heating", "ra"), "HW": DeviceState("HW", "Hot Water", "rb")};
  }

  static initState() async {
    defaultState();
    final file = await _localFile();
    if (file.existsSync()) {
      await load();
    } else {
      log("Saving Default State!");
      save();
    }
    if (updateTimer == null) {
      updateTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
        bool success = await updateState();
      });
    }
  }

  static DeviceState getState(String type) {
    return _state[type];
  }

  static String toJson() {
    String s = "";
    _state.forEach((k, v) => s = s + v.toJson() + ',');
    return '{\"$J_NAME\":\"Stuart\",\"$J_HOST\":\"$host\",\"$J_PORT\":$port, \"$J_DEVICES\" : [${s.substring(0, s.length - 1)}]}';
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
    Map userMap = jsonDecode(json);
    userName = readString(userMap, J_NAME, "Unknown");
    host = readString(userMap, J_HOST, "http://192.168.1.177");
    port = readInt(userMap, J_PORT, null);
    if (userMap[J_DEVICES] == null) {
      log("parse: No 'devices' in json");
      defaultState();
      return;
    }

    Map<String, DeviceState> temp = {};
    for (Map dMap in userMap[J_DEVICES]) {
      String type = readString(dMap, J_TYPE, null);
      if (type != null) {
        DeviceState ds = DeviceState(type, readString(dMap, J_NAME, "Unknown"), readString(dMap, J_REMOTE_ID, null));
        temp[ds.type] = ds;
      } else {
        log("parse: 'devices.type' is null. Skipping");
      }
    }
    if (temp.length == 0) {
      log("parse: device map is empty!");
      defaultState();
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
          contents = "File [${file.path}] does not exist:\n" + toJson();
        }
        Clipboard.setData(ClipboardData(text: contents));
        return contents;
      } on Exception catch (e) {
        return "Unable to read file [${file.path}]";
      }
    } else {
      contents = toJson();
      Clipboard.setData(ClipboardData(text: contents));
      return contents;
    }
  }

  static String log(String s) {
    if (_logStr.isEmpty) {
      _logStr = s;
    } else {
      _logStr = _logStr + '\n' + s;
    }
    return s;
  }

  static String getLog() {
    return _logStr.trim();
  }
}
