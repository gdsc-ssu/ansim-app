class MarkerModel {
  final String id;
  final String source;
  final double latitude;
  final double longitude;
  final String hazardType;
  final String? hazardLevel;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  MarkerModel({
    required this.id,
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.hazardType,
    this.hazardLevel,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    return MarkerModel(
      id: json['id'] as String,
      source: json['source'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hazardType: json['hazardType'] as String,
      hazardLevel: json['hazardLevel'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
