import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/enums/hazard_type.dart';

class MarkerResponse {
  final String id;
  final String source;
  final double latitude;
  final double longitude;
  final HazardType hazardType;
  final HazardLevel hazardLevel;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  MarkerResponse({
    required this.id,
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.hazardType,
    required this.hazardLevel,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory MarkerResponse.fromJson(Map<String, dynamic> json) {
    return MarkerResponse(
      id: json['id'] as String,
      source: json['source'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hazardType: HazardType.fromString(json['hazardType'] as String?),
      hazardLevel: HazardLevel.fromString(json['hazardLevel'] as String? ?? ''),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
