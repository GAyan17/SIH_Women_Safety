import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  String currentFilePath;

  Future<List<FileSystemEntity>> _getAllImages() async {
    final Directory extDir = getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Media/saved_flutter_test';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: ,
      ),
    );
  }
}
