import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/enums/hazard_type.dart';

class ReportResponse {
  // MarkerResponse와 공통 필드
  final String id;
  final String source;
  final double latitude;
  final double longitude;
  final HazardType hazardType;
  final HazardLevel hazardLevel;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  // 단건 조회 추가 필드
  final ReportDetail? report;
  final SafetyMungoReport? safetyMungoReport;

  ReportResponse({
    required this.id,
    required this.source,
    required this.latitude,
    required this.longitude,
    required this.hazardType,
    required this.hazardLevel,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.report,
    this.safetyMungoReport,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      id: json['id'] as String,
      source: json['source'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      hazardType: HazardType.fromString(json['hazardType'] as String?),
      hazardLevel: HazardLevel.fromString(json['hazardLevel'] as String? ?? ''),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      report: json['report'] != null
          ? ReportDetail.fromJson(json['report'] as Map<String, dynamic>)
          : null,
      safetyMungoReport: json['safetyMungoReport'] != null
          ? SafetyMungoReport.fromJson(json['safetyMungoReport'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReportDetail {
  final String id;
  final String userId;
  final String? description;
  final List<ReportImage> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReportDetail({
    required this.id,
    required this.userId,
    this.description,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      id: json['id'] as String,
      userId: json['userId'] as String,
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ReportImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ReportImage {
  final String id;
  final String url;
  final String? mimeType;

  ReportImage({
    required this.id,
    required this.url,
    this.mimeType,
  });

  factory ReportImage.fromJson(Map<String, dynamic> json) {
    return ReportImage(
      id: json['id'] as String,
      url: json['url'] as String,
      mimeType: json['mimeType'] as String?,
    );
  }
}

class SafetyMungoReport {
  final String id;
  final String? spotName;
  final String? category;
  final String? description;
  final String? origin;
  final DateTime? occurrenceDate;

  SafetyMungoReport({
    required this.id,
    this.spotName,
    this.category,
    this.description,
    this.origin,
    this.occurrenceDate,
  });

  factory SafetyMungoReport.fromJson(Map<String, dynamic> json) {
    return SafetyMungoReport(
      id: json['id'] as String,
      spotName: json['spotName'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      origin: json['origin'] as String?,
      occurrenceDate: json['occurrenceDate'] != null
          ? DateTime.parse(json['occurrenceDate'] as String)
          : null,
    );
  }
}
