import 'package:ansim_app/constansts/paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionViewModel extends ChangeNotifier {
  // 실제 권한 요청 로직
  Future<void> requestAllPermissions(BuildContext context) async {
    // 1. 요청할 권한 리스트
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.notification,
    ].request();

    // 2. 필수 권한(위치) 확인
    if (statuses[Permission.locationWhenInUse]!.isGranted) {
      print("위치 권한 허용됨");
      context.push(Paths.map);
    } else if (statuses[Permission.locationWhenInUse]!.isPermanentlyDenied) {
      // 사용자가 '다시 묻지 않음'을 선택한 경우 설정창으로 유도
      _showPermissionDialog(context);
    }
  }

  // 사용자가 거부했을 때 설정창으로 보내는 알림창
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("권한 설정 필요"),
        content: const Text("위치 권한이 거부되었습니다. 앱 설정에서 권한을 허용해주세요."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // 앱 설정 화면 열기
              Navigator.pop(context);
            },
            child: const Text("설정으로 이동"),
          ),
        ],
      ),
    );
  }
}