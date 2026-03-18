/// 위험 수위 Enum
enum HazardLevel {
  LOW,
  MEDIUM,
  HIGH,
  UNKNOWN;

  static HazardLevel fromString(String value) {
    return HazardLevel.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => HazardLevel.UNKNOWN,
    );
  }
}