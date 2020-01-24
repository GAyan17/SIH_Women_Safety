import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sih_women_safety_app/logerror.dart';

import './home.dart';
import './strings.dart' as string;

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: string.title,
      theme: ThemeData(
        primarySwatch: Colors.lime,
      ),
      home: Home(
        title: string.title,
        cameras: cameras,
      ),
    );
  }
}
