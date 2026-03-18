import 'dart:convert';

import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/enums/hazard_type.dart';

class AnalysisResponse {
  final HazardType hazardType;
  final HazardLevel hazardLevel;

  AnalysisResponse({
    required this.hazardType,
    required this.hazardLevel,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      hazardType: HazardType.fromString(json['hazardType'] ?? ''),
      hazardLevel: HazardLevel.fromString(json['hazardLevel'] ?? ''),
    );
  }

  factory AnalysisResponse.fromRawJson(String str) =>
      AnalysisResponse.fromJson(json.decode(str));

  Map<String, dynamic> toJson() => {
    'hazardType': hazardType.name,
    'hazardLevel': hazardLevel.name,
  };
}