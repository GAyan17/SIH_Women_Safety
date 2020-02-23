import 'dart:io';
import 'dart:async';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import './video_preview.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String currentFilePath;
  FirebaseApp app;
  FirebaseStorage storage;

  @override
  void initState() {
    _initializeStorage();
    super.initState();
  }

  _initializeStorage() async {
    app = await FirebaseApp.configure(
      name: 'test',
      options: FirebaseOptions(
          googleAppID: '1:341344832168:android:9369e5577d63bbfba0509d',
          projectID: 'imageupload-f32e1',
          apiKey: 'AIzaSyDFZJeYgw_QoaVHPljAyCRMT8OwgusdloM'),
    );
    storage = FirebaseStorage(
        app: app, storageBucket: 'gs://imageupload-f32e1.appspot.com');
  }

  _shareFile() async {
    var extension = path.extension(currentFilePath);
    await Share.file(
        'image',
        (extension == '.jpeg') ? 'image.jpeg' : 'video.mp4',
        File(currentFilePath).readAsBytesSync(),
        (extension == '.jpeg') ? 'image/jpeg' : 'video/mp4');
  }

  _deleteFile() async {
    final dir = Directory(currentFilePath);
    dir.deleteSync(recursive: true);
    print('deleted');
    setState(() {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('File Deleted'),
        ),
      );
    });
  }

  _uploadFile() async {
    final dir = Directory(currentFilePath);
    File file = File(dir.path);
    String fileName = path.basename(currentFilePath);
    StorageReference ref = storage.ref().child(fileName);
    StorageUploadTask uploadTask = ref.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Image Uploaded'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Gallery'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _getAllImages(),
        builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Container();
          }
          print('${snapshot.data.length} ${snapshot.data}');
          if (snapshot.data.length == 0) {
            return Center(
              child: Text('No images found'),
            );
          }
          return PageView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              currentFilePath = snapshot.data[index].path;
              var extension = path.extension(snapshot.data[index].path);
              if (extension == '.jpeg') {
                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.file(File(snapshot.data[index].path)),
                );
              } else {
                return VideoPreview(
                  videoPath: snapshot.data[index].path,
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(icon: Icon(Icons.share), onPressed: _shareFile),
              IconButton(icon: Icon(Icons.delete), onPressed: _deleteFile),
              IconButton(
                  icon: Icon(Icons.cloud_upload), onPressed: _uploadFile),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<FileSystemEntity>> _getAllImages() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Media/saved_flutter_test';
    final myDir = Directory(dirPath);
    List<FileSystemEntity> _images =
        myDir.listSync(recursive: true, followLinks: false);
    _images.sort((a, b) {
      return b.path.compareTo(a.path);
    });
    if (_images.length > 0) {
      print('Images');
    }
    return _images;
  }
}
