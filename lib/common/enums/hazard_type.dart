enum HazardType {
  FIRE,
  FLOOD,
  LANDSLIDE,
  SINKHOLE,
  ROAD_DAMAGE,
  COLLAPSE,
  BUILDING_DAMAGE,
  CHEMICAL,
  TRAFFIC,
  CONSTRUCTION,
  OTHER,
  NONE;

  /// 한글 라벨 가져오기
  String get koLabel {
    switch (this) {
      case HazardType.FIRE: return "화재";
      case HazardType.FLOOD: return "침수";
      case HazardType.LANDSLIDE: return "산사태";
      case HazardType.SINKHOLE: return "싱크홀";
      case HazardType.ROAD_DAMAGE: return "도로 파손";
      case HazardType.COLLAPSE: return "붕괴";
      case HazardType.BUILDING_DAMAGE: return "건물 손상";
      case HazardType.CHEMICAL: return "화학 사고";
      case HazardType.TRAFFIC: return "교통 사고";
      case HazardType.CONSTRUCTION: return "공사 중";
      case HazardType.OTHER: return "기타";
      case HazardType.NONE: return "해당 없음";
    }
  }

  static HazardType fromString(String value) {
    return HazardType.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => HazardType.OTHER,
    );
  }

  /// 한글 이름으로 Enum 찾기 (UI에서 선택 시 필요)
  static HazardType fromKoLabel(String label) {
    return HazardType.values.firstWhere(
          (e) => e.koLabel == label,
      orElse: () => HazardType.OTHER,
    );
  }
}