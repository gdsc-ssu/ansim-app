enum HazardLevel {
  LOW,
  MEDIUM,
  HIGH,
  UNKNOWN;

  String get koLabel {
    switch (this) {
      case HazardLevel.LOW: return "주의";
      case HazardLevel.MEDIUM: return "보통";
      case HazardLevel.HIGH: return "심각";
      case HazardLevel.UNKNOWN: return "알 수 없음";
    }
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