import 'package:permission_handler/permission_handler.dart';

class CameraPermissionHandler {
  static Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    
    if (status.isDenied) {
      // Request permission
      status = await Permission.camera.request();
    }
    
    return status.isGranted;
  }

  static Future<bool> checkCameraPermission() async {
    var status = await Permission.camera.status;
    return status.isGranted;
  }
}