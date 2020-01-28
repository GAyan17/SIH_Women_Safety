import 'package:flutter/material.dart';

import './IncidentModel.dart';

class IncidentsModel with ChangeNotifier {

  List<IncidentModel> _incidents = [];

  void addIncident(String name, DateTime dateTime, String place, String report) {
    _incidents.add(IncidentModel(id: DateTime.now().millisecondsSinceEpoch, name: name, dateTime: dateTime, place: place, report: report));
  }
}