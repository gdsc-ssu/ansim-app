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