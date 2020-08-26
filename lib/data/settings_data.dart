import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const String FN_PREF = "settings";
const String FN_TYPE = "json";
const String J_TYPE = "type";
const String J_NAME = "name";
const String J_HOST = "host";
const String J_PORT = "port";
const String J_STATE = "state";
const String J_DEVICES = "devices";
class DeviceState {
  final String type;
  final String name;
  final String host;
  final int port;

  bool _on = false;
  DateTime _boostUntil;

  DeviceState(this.type, this.name, this.host, this.port);

  String toJson() {
    return '{\"$J_TYPE\":\"$type\",\"$J_NAME\":\"$name\",\"$J_HOST\":\"$host\",\"$J_PORT\":$port,\"$J_STATE\":\"${onString()}\"}';
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
}

class SettingsData {
  static Map<String, DeviceState> _state;
  
  static String userName = "UN";
  static bool var1 = true;

  static initState() async {
    final file = await _localFile(false);
    if (file.existsSync()) {
      print('TRY LOAD');
      load(false);
    } else {
      print('SAVING STATE');
      _state = {"CH": DeviceState("CH", "Heating", "http://192.168.1.177", 80), "HW": DeviceState("HW", "Hot Water", "http://192.168.1.177",80)};
      save(false);
    }
  }

  static DeviceState getState(String type) {
    return _state[type];
  }

  static String toJson() {
    String s = "";
    _state.forEach((k, v) => s = s + v.toJson() + ',');
    return '{\"$J_NAME\":\"Stuart\", \"$J_DEVICES\" : [${s.substring(0, s.length-1)}]}';
  }

  static int readInt(Map map, String name) {
    int val = map[name];
    return val == -1 ? false : val;
  }

  static DateTime readId(Map map, String name, int count) {
    int val = map[name];
    return val == null ? DateTime.now().add(Duration(minutes: count)) : DateTime.fromMillisecondsSinceEpoch(val);
  }

  static bool readBool(Map map, String name) {
    bool val = map[name];
    return val == null ? false : val;
  }

  static bool readBoolInt(Map map, String name) {
    int val = map[name];
    if (val == null) {
      return false;
    }
    return val == 0 ? false : true;
  }

  static parseJson(String json) {
    Map userMap = jsonDecode(json);
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(bool backup) async {
    final path = await _localPath;
    if (backup) {
      return File('$path/${FN_PREF}_bak.$FN_TYPE');
    }
    return File('$path/$FN_PREF.$FN_TYPE');
  }

  static void save(bool backup) async {
    final file = await _localFile(backup);
    await file.writeAsString(toJson());
  }

  static Future<String> copyFileToClipboard(bool backup) async {
    try {
      String contents;
      final file = await _localFile(backup);
      if (file.existsSync()) {
        contents = await file.readAsString();
      } else {
        contents = "File does not exist:\n"+toJson();
      }
      Clipboard.setData(ClipboardData(text: contents));
      return contents;
    } on Exception catch (e) {
      Clipboard.setData(ClipboardData(text: "Unable to read file!"));
      return "Unable to read ${backup ? "BACKUP" : ""} file!";
    }
  }

  static Future<void> load(bool backup) async {
    try {
      final file = await _localFile(backup);
      String contents = await file.readAsString();
      parseJson(contents);
    } on Exception catch (e) {
      print(e);
    }
  }
}
