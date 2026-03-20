import 'dart:async';
import 'dart:ui' as ui;

import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Widget customMarker(HazardLevel level) {
  return SizedBox(
    width: 40,
    height: 50,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 원형 상단 부분
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: level.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              level.iconPath,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                level == HazardLevel.UNKNOWN ? Colors.black : Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        // 원과 삼각형 사이 간격 제거 (음수 마진)
        Transform.translate(
          offset: const Offset(0, -1), // 1px 위로 올려서 완전히 붙임
          child: CustomPaint(
            size: const Size(14, 10),
            painter: _MarkerTailPainter(color: level.color),
          ),
        ),
      ],
    ),
  );
}

class _MarkerTailPainter extends CustomPainter {
  final Color color;
  const _MarkerTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkerTailPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Flutter 위젯을 Google Maps BitmapDescriptor로 변환
Future<BitmapDescriptor> widgetToMarkerIcon(
    Widget widget, BuildContext context) async {
  final key = GlobalKey();
  final completer = Completer<BitmapDescriptor>();

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      left: -500,
      top: -500,
      child: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(key: key, child: widget),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
        overlayEntry.remove();
        completer.complete(
            BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List()));
      } catch (e) {
        overlayEntry.remove();
        completer.completeError(e);
      }
    });
  });

  return completer.future;
}