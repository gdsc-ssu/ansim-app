import 'package:ansim_app/constansts/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum HazardLevel {
  HIGH,
  MEDIUM,
  LOW,
  UNKNOWN;

  String get koLabel {
    switch (this) {
      case HazardLevel.HIGH: return "심각";
      case HazardLevel.MEDIUM: return "주의";
      case HazardLevel.LOW: return "경미";
      case HazardLevel.UNKNOWN: return "알 수 없음";
    }
  }

  /// 1. UI 신고 화면에서 사용할 유효한 레벨 리스트 (UNKNOWN 제외)
  static List<HazardLevel> get reportLevels {
    return HazardLevel.values.where((e) => e != HazardLevel.UNKNOWN).toList();
  }

  static HazardLevel fromString(String value) {
    return HazardLevel.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => HazardLevel.UNKNOWN,
    );
  }

  static HazardLevel fromKoLabel(String label) {
    return HazardLevel.values.firstWhere(
          (e) => e.koLabel == label,
      orElse: () => HazardLevel.UNKNOWN,
    );
  }
}

extension HazardLevelExtension on HazardLevel {
  Color get color {
    switch (this) {
      case HazardLevel.HIGH: return AnsimColor.critical;
      case HazardLevel.MEDIUM: return  AnsimColor.warning;
      case HazardLevel.LOW: return  AnsimColor.resolved;
      case HazardLevel.UNKNOWN: return AnsimColor.minor;
    }
  }

  IconData get icon {
    switch (this) {
      case HazardLevel.HIGH: return Icons.priority_high;
      case HazardLevel.MEDIUM: return Icons.priority_high;
      case HazardLevel.LOW: return Icons.check;
      case HazardLevel.UNKNOWN: return Icons.add;
    }
  }

  String get iconPath {
    switch (this) {
    case HazardLevel.HIGH: return 'assets/icons/critical.svg';
    case HazardLevel.MEDIUM: return 'assets/icons/warning.svg';
    case HazardLevel.LOW: return 'assets/icons/resolved.svg';
    case HazardLevel.UNKNOWN: return 'assets/icons/minor.svg';
    }
  }
}