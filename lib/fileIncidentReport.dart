import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

class FileIncidentReport extends StatefulWidget {
  @override
  _FileIncidentReportState createState() => _FileIncidentReportState();
}

class _FileIncidentReportState extends State<FileIncidentReport> {
  final _formKey = GlobalKey<FormState>();
  String name;
  String place;
  String report;
  DateTime dateTime;

  Widget incidentForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'Incident name'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter a name';
              }
            },
            onSaved: (value) {
              setState(() {
                name = value;
                print(name);
              });
            },
          ),
          DateTimeField(
            format: DateFormat("yyyy-MM-dd HH:mm"),
            decoration:
                InputDecoration(labelText: 'Enter date and time of Incident'),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  initialDate: currentValue ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    currentValue ?? DateTime.now(),
                  ),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            validator: (value) {
              if (value.isAfter(DateTime.now())) {
                return 'Do not enter future dates';
              }
            },
            onSaved: (value) {
              setState(() {
                dateTime = value;
                print(dateTime);
              });
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Place'),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter place';
              }
            },
            onSaved: (value) {
              setState(() {
                place = value;
                print(place);
              });
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Report'),
            validator: (value) {
              if (value.isEmpty || value.length < 100) {
                return 'Please report in detail';
              }
            },
            onSaved: (value) {
              setState(() {
                report = value;
                print(report);
              });
            },
          ),
          RaisedButton(
            onPressed: () {
              setState(() {
                final form = _formKey.currentState;
                if (form.validate()) {
                  form.save();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Form Saved'),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              });
            },
            child: Text('Save'),
            color: Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report the Incident'),
      ),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Builder(
          builder: (context) => incidentForm(context),
        ),
      ),
    );
  }
}
