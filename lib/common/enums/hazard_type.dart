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

  /// 1. UI 표시용 한글 라벨 (ReportScreen에서 사용)
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

  /// 2. 서버 전송용 문자열 (Enum 이름을 소문자로 변환하거나 그대로 사용)
  String get apiValue => name;

  /// 3. 서버 응답(String)을 Enum으로 변환
  static HazardType fromString(String? value) {
    if (value == null) return HazardType.NONE;
    return HazardType.values.firstWhere(
          (e) => e.name == value.toUpperCase(),
      orElse: () => HazardType.OTHER,
    );
  }

  /// 4. UI의 한글 라벨로 Enum 찾기 (Chip 클릭 시 사용)
  static HazardType fromKoLabel(String label) {
    return HazardType.values.firstWhere(
          (e) => e.koLabel == label,
      orElse: () => HazardType.OTHER,
    );
  }

  /// 5. 신고 화면의 카테고리 칩 리스트 생성 (NONE 제외)
  static List<String> get reportLabels {
    return HazardType.values
        .where((type) => type != HazardType.NONE)
        .map((type) => type.koLabel)
        .toList();
  }
}