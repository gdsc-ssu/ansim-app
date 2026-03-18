/// 위험 종류 Enum
enum HazardType {
  SINKHOLE,
  FLOOD,
  FIRE,
  EARTHQUAKE,
  UNKNOWN;

  static HazardType fromString(String value) {
    return HazardType.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => HazardType.UNKNOWN,
    );
  }
}