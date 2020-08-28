import 'dart:ui';

import 'package:flutter/material.dart';

class TitleStyle extends TextStyle {
  const TitleStyle()
      : super(
          fontSize: 30.0,
          color: Colors.black,
        );
}

class HeadingDataStyle extends TextStyle {
  const HeadingDataStyle()
      : super(
          fontSize: 23.0,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        );
}

class HeadingDataStyleHi extends TextStyle {
  const HeadingDataStyleHi()
      : super(
          fontSize: 23.0,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
        );
}

class InfoTextStyle extends TextStyle {
  const InfoTextStyle()
      : super(
          fontSize: 15.0,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );
}

class StatusTextStyle extends TextStyle {
  const StatusTextStyle(bool error)
      : super(
          fontSize: 20.0,
          color: (error ? Colors.pink : Colors.green),
          fontWeight: FontWeight.bold,
        );
}

class CardTextStyle extends TextStyle {
  const CardTextStyle()
      : super(
          fontSize: 35.0,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        );
}

class BoostTextStyle extends TextStyle {
  const BoostTextStyle()
      : super(
          fontSize: 30.0,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );
}

Widget infoStyleWithText(String text) {
  return Card(
    color: Colors.green,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const InfoTextStyle(),
      ),
    ),
  );
}
Widget boostButtonWithText(String text) {
  return DecoratedBox(
    decoration: const BoxDecoration(color: Colors.green),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const BoostTextStyle(),
      ),
    ),
  );
}

class InputButtonStyle extends TextStyle {
  const InputButtonStyle(double size, Color c)
      : super(
          fontSize: size,
          color: c,
          fontWeight: FontWeight.bold,
        );
}

final RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0));

RoundedRectangleBorder ButtonShape() {
  return _buttonShape;
}

class BlackDivider extends Divider {
  const BlackDivider()
      : super(
          thickness: 2,
          height: 30,
          color: Colors.black,
        );
}

class ClearDivider extends Divider {
  const ClearDivider()
      : super(
          height: 30,
        );
}
