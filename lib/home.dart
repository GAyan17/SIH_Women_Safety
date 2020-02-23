import 'dart:io';
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;

import './logerror.dart';
// import './camera_lens_icon.dart';
import './routing_assets.dart' as routeAssets;
import './video_timer.dart';

class Home extends StatefulWidget {
  final String title;
  final List<CameraDescription> cameras;

  Home({this.title, this.cameras, Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _timerKey = GlobalKey<VideoTimerState>();
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  bool isRecordingMode = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    onNewCameraSelected(widget.cameras.first);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  // Widget _toggleAudioWidget() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 25.0),
  //     child: Row(
  //       children: <Widget>[
  //         const Text('Enable Audio'),
  //         Switch(
  //           value: enableAudio,
  //           onChanged: (bool value) {
  //             enableAudio = value;
  //             if (controller != null) {
  //               onNewCameraSelected(controller.description);
  //             }
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Widget _thumbnailWidget() {
  //   return Expanded(
  //     child: Align(
  //       alignment: Alignment.centerRight,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           videoController == null && imagePath == null
  //               ? Container()
  //               : SizedBox(
  //                   child: (videoController == null)
  //                       ? Image.file(
  //                           File(imagePath),
  //                           fit: BoxFit.cover,
  //                           width: MediaQuery.of(context).size.width,
  //                           height: MediaQuery.of(context).size.height * 0.6,
  //                         )
  //                       : Container(
  //                           child: Center(
  //                             child: AspectRatio(
  //                               aspectRatio: videoController.value.size != null
  //                                   ? videoController.value.aspectRatio
  //                                   : 1.0,
  //                               child: VideoPlayer(videoController),
  //                             ),
  //                           ),
  //                           decoration: BoxDecoration(
  //                             border: Border.all(color: Colors.purple),
  //                           ),
  //                           width: 64.0,
  //                           height: 64.0,
  //                         ),
  //                 ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _captureControlRowWidget() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     mainAxisSize: MainAxisSize.max,
  //     children: <Widget>[
  //       IconButton(
  //         icon: const Icon(Icons.camera_alt),
  //         color: Colors.deepOrange,
  //         onPressed: controller != null &&
  //                 controller.value.isInitialized &&
  //                 !controller.value.isRecordingVideo
  //             ? onTakePictureButtonPressed
  //             : null,
  //       ),
  //       IconButton(
  //         icon: const Icon(Icons.videocam),
  //         color: Colors.deepOrange,
  //         onPressed: controller != null &&
  //                 controller.value.isInitialized &&
  //                 !controller.value.isRecordingVideo
  //             ? onVideoRecordButtonPressed
  //             : null,
  //       ),
  //       IconButton(
  //           icon: controller != null && controller.value.isRecordingPaused
  //               ? Icon(Icons.play_arrow)
  //               : Icon(Icons.pause),
  //           color: Colors.deepOrange,
  //           onPressed: controller != null &&
  //                   controller.value.isInitialized &&
  //                   controller.value.isRecordingVideo
  //               ? (controller != null && controller.value.isRecordingPaused
  //                   ? onResumeButtonPressed
  //                   : onPauseButtonPressed)
  //               : null),
  //       IconButton(
  //           icon: const Icon(Icons.stop),
  //           color: Colors.red,
  //           onPressed: controller != null &&
  //                   controller.value.isInitialized &&
  //                   controller.value.isRecordingVideo
  //               ? onStopButtonPressed
  //               : null),
  //     ],
  //   );
  // }

  // Widget _cameraTogglesRowWidget() {
  //   final List<Widget> toggles = <Widget>[];

  //   if (widget.cameras.isEmpty) {
  //     return const Text('No Camera Found');
  //   } else {
  //     for (CameraDescription cameraDescription in widget.cameras) {
  //       toggles.add(
  //         SizedBox(
  //           width: 90.0,
  //           child: RadioListTile<CameraDescription>(
  //             title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
  //             groupValue: controller?.description,
  //             value: cameraDescription,
  //             onChanged: controller != null && controller.value.isRecordingVideo
  //                 ? null
  //                 : onNewCameraSelected,
  //           ),
  //         ),
  //       );
  //     }
  //   }
  //   return Row(
  //     children: toggles,
  //   );
  // }

  Future<void> onCameraSwitch() async {
    final CameraDescription cameraDescription =
        (controller.description == widget.cameras[0])
            ? widget.cameras[1]
            : widget.cameras[0];
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: enableAudio,
    );

    controller.addListener(() {
      if (mounted) {
        setState(() {});
        if (controller.value.hasError) {
          showInSnackBar('Camera error ${controller.value.errorDescription}');
        }
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          showInSnackBar('Picture saved to $filePath');
        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) {
        setState(() {});
      }
      if (filePath != null) {
        showInSnackBar('Saving video to $filePath');
      }
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) {
        setState(() {
          showInSnackBar('Video recorded to: $videoPath');
        });
      }
    });
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {
          showInSnackBar('Video recording paused');
        });
      }
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {
          showInSnackBar('Video recording resumed');
        });
      }
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first');
      return null;
    }

    _timerKey.currentState.startTimer();

    //file directory
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Media/saved_flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '${dirPath}/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      //video is being recorded nothing to do
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    _timerKey.currentState.stopTimer();

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    // await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        //Refresh the state to update video player with the correct ratio.
        if (mounted) {
          setState(() {
            videoController.removeListener(videoPlayerListener);
          });
        }
      }
    };

    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first');
      return null;
    }

    SystemSound.play(SystemSoundType.click);
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Media/saved_flutter_test';
    await Directory(dirPath)
        .create(recursive: true)
        .then((value) => print(value));
    final String filePath = '${dirPath}/${timestamp()}.jpeg';

    if (controller.value.isTakingPicture) {
      //a capture is pending, not to do anything
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<FileSystemEntity> getLastImage() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Media/saved_flutter_test';
    final myDir = Directory(dirPath);
    myDir.exists().then((isThere) =>
        (isThere) ? print('directory exists') : print('directory not exists'));
    List<FileSystemEntity> _images =
        myDir.listSync(recursive: true, followLinks: false);
    _images.sort((a, b) {
      return b.path.compareTo(a.path);
    });
    var lastFile = _images[0];
    var extension = path.extension(lastFile.path);
    if (extension == '.jpeg') {
      return lastFile;
    } else {
      String thumb = await Thumbnails.getThumbnail(
          videoFile: lastFile.path, imageType: ThumbFormat.PNG, quality: 30);
      return File(thumb);
    }
  }

  Widget buildBottomNavigationBar() {
    return Container(
      color: Colors.black87,
      height: 100.0,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FutureBuilder(
            future: getLastImage(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.0),
                  ),
                );
              }
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(routeAssets.Gallery);
                },
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.file(
                      snapshot.data,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          (!isRecordingMode)
              ? Container()
              : CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24.0,
                  child: IconButton(
                    icon: Icon(
                      (controller != null &&
                              controller.value.isInitialized &&
                              !controller.value.isRecordingPaused)
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 24.0,
                      color: (controller != null &&
                              controller.value.isInitialized &&
                              !controller.value.isRecordingPaused)
                          ? Colors.red
                          : Colors.black,
                    ),
                    onPressed: () {
                      if (controller != null &&
                          controller.value.isInitialized &&
                          !controller.value.isRecordingPaused) {
                        onPauseButtonPressed();
                      } else {
                        onResumeButtonPressed();
                      }
                    },
                  ),
                ),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28.0,
            child: IconButton(
                icon: Icon(
                  (controller != null &&
                          controller.value.isInitialized &&
                          !isRecordingMode)
                      ? Icons.camera_alt
                      : ((controller.value.isRecordingVideo)
                          ? Icons.stop
                          : Icons.videocam),
                  size: 28.0,
                  color: controller.value.isRecordingVideo
                      ? Colors.red
                      : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    if (!isRecordingMode) {
                      onTakePictureButtonPressed();
                    } else {
                      if (controller.value.isRecordingVideo) {
                        onStopButtonPressed();
                      } else {
                        onVideoRecordButtonPressed();
                      }
                    }
                  });
                }),
          ),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24.0,
            child: IconButton(
                icon: Icon(
                    (!isRecordingMode) ? Icons.videocam : Icons.camera_alt),
                onPressed: () {
                  setState(
                    () {
                      isRecordingMode = !isRecordingMode;
                    },
                  );
                }),
          )
        ],
      ),
    );
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (controller != null) {
      if (!controller.value.isInitialized) {
        return Container();
      }
    } else {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          GestureDetector(
              onDoubleTap: () {
                setState(() {
                  onCameraSwitch();
                });
              },
              onPanUpdate: (details) {
                if (details.delta.dx < 0 && details.delta.dy == 0) {
                  Navigator.of(context).pushNamed(routeAssets.storyScreen);
                }
                if (details.delta.dx > 0 && details.delta.dy == 0) {
                  Navigator.of(context).pushNamed(routeAssets.incidentScreen);
                }
              },
              child: _cameraPreviewWidget()),
          Positioned(
            top: 24.0,
            right: 12.0,
            child: IconButton(
              icon: Icon(Icons.switch_camera),
              color: Colors.white,
              onPressed: () {
                onCameraSwitch();
              },
            ),
          ),
          Positioned(
            bottom: 24.0,
            left: 12.0,
            child: IconButton(
              icon: Icon(Icons.chat_bubble),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(routeAssets.incidentScreen);
              },
            ),
          ),
          Positioned(
            bottom: 24.0,
            right: 12.0,
            child: IconButton(
              icon: Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed(routeAssets.storyScreen);
              },
            ),
          ),
          if (isRecordingMode)
            Positioned(
              left: 0,
              right: 0,
              top: 32.0,
              child: VideoTimer(
                key: _timerKey,
              ),
            ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }
}
