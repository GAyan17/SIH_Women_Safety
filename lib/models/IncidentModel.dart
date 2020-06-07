import 'package:flutter/material.dart';

class IncidentModel {
  int id;
  String name;
  DateTime dateTime;
  String place;
  String report;

  IncidentModel({@required this.id,
    @required this.name,
    @required this.dateTime,
    @required this.place,
    @required this.report});
}
