import 'package:flutter/material.dart';

import './routing_assets.dart' as routes;

class IncidentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx < 0) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          title: Text('Incidents FIR'),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 8,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).pushNamed(routes.fileIncidentScreen);
          },
        ),
      ),
    );
  }
}
