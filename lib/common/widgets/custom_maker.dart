import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:flutter/material.dart';

Widget customMarker(HazardLevel level) {
  return SizedBox(
    width: 60,
    height: 60,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, size: 60, color: level.color), // 배경
        Positioned(
          top: 10,
          child: Icon(
            level.icon,
            size: 24,
            color: level == HazardLevel.UNKNOWN ? Colors.black : Colors.white,
          ),
        ),
      ],
    ),
  );
}