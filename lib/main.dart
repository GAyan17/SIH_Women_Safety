import 'dart:async';
// import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './home.dart';
import './story_screen.dart';
import './IncidentScreen.dart';
import './fileIncidentReport.dart';
import './logerror.dart';
import './morestories.dart';
import './gallery.dart';
import './strings.dart' as string;
import './routing_assets.dart' as routesAssets;

List<CameraDescription> cameras = [];

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {
    runApp(MyApp());
  });
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
      routes:  {
        routesAssets.storyScreen : (context) => StoryScreen(),
        routesAssets.incidentScreen : (context) => IncidentScreen(),
        routesAssets.MoreStoriesScreen : (context) => MoreStories(),
        routesAssets.fileIncidentScreen : (context) => FileIncidentReport(),
        routesAssets.Gallery : (context) => Gallery(),
      },
    );
  }
}
