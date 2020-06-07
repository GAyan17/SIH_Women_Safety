import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back :
      return Icons.camera_rear;
    case CameraLensDirection.front :
      return Icons.camera_front;
    case CameraLensDirection.external :
      return Icons.camera;
  }
  throw ArgumentError('Unknown Lens Directions');
}