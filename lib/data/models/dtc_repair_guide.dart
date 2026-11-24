import 'package:flutter/foundation.dart';

/// Detailed diagnostic & workshop repair roadmap for a Diagnostic Trouble Code (DTC)
@immutable
class DtcRepairGuide {
  final String code;
  final String titleEn;
  final String titleAr;
  final String category; // Powertrain, Chassis, Body, Network
  final String severity; // Low, Medium, High, Critical
  final String descriptionEn;
  final String descriptionAr;
  final List<String> symptomsEn;
  final List<String> symptomsAr;
  final List<String> causesEn;
  final List<String> causesAr;
  final List<String> diagnosticStepsEn;
  final List<String> diagnosticStepsAr;
  final String multimeterChecksEn;
  final String multimeterChecksAr;
  final String repairSolutionsEn;
  final String repairSolutionsAr;
  final int laborDifficulty; // 1 to 5 wrenches
  final String estimatedRepairTime; // e.g. "30-60 mins"

  const DtcRepairGuide({
    required this.code,
    required this.titleEn,
    required this.titleAr,
    required this.category,
    required this.severity,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.symptomsEn,
    required this.symptomsAr,
    required this.causesEn,
    required this.causesAr,
    required this.diagnosticStepsEn,
    required this.diagnosticStepsAr,
    required this.multimeterChecksEn,
    required this.multimeterChecksAr,
    required this.repairSolutionsEn,
    required this.repairSolutionsAr,
    this.laborDifficulty = 2,
    this.estimatedRepairTime = "45 mins",
  });

  String getTitle(bool isAr) => isAr ? titleAr : titleEn;
  String getDescription(bool isAr) => isAr ? descriptionAr : descriptionEn;
  List<String> getSymptoms(bool isAr) => isAr ? symptomsAr : symptomsEn;
  List<String> getCauses(bool isAr) => isAr ? causesAr : causesEn;
  List<String> getDiagnosticSteps(bool isAr) => isAr ? diagnosticStepsAr : diagnosticStepsEn;
  String getMultimeterChecks(bool isAr) => isAr ? multimeterChecksAr : multimeterChecksEn;
  String getRepairSolutions(bool isAr) => isAr ? repairSolutionsAr : repairSolutionsEn;

  // Convenience aliases for flexible API access
  List<String> get probableCausesEn => causesEn;
  List<String> get diagnosticRoadmapEn => diagnosticStepsEn;
  List<String> get pinoutChecksEn => [multimeterChecksEn];
  String get recommendedFixEn => repairSolutionsEn;
  String getRecommendedFix(bool isAr) => getRepairSolutions(isAr);
  List<String> getDiagnosticRoadmap(bool isAr) => getDiagnosticSteps(isAr);
  List<String> getElectricalChecks(bool isAr) => isAr ? [multimeterChecksAr] : [multimeterChecksEn];
  List<String> getProbableCauses(bool isAr) => getCauses(isAr);

  Map<String, dynamic> toJson() => {
    'code': code,
    'titleEn': titleEn,
    'titleAr': titleAr,
    'category': category,
    'severity': severity,
    'descriptionEn': descriptionEn,
    'descriptionAr': descriptionAr,
    'symptomsEn': symptomsEn,
    'symptomsAr': symptomsAr,
    'causesEn': causesEn,
    'causesAr': causesAr,
    'diagnosticStepsEn': diagnosticStepsEn,
    'diagnosticStepsAr': diagnosticStepsAr,
    'multimeterChecksEn': multimeterChecksEn,
    'multimeterChecksAr': multimeterChecksAr,
    'repairSolutionsEn': repairSolutionsEn,
    'repairSolutionsAr': repairSolutionsAr,
    'laborDifficulty': laborDifficulty,
    'estimatedRepairTime': estimatedRepairTime,
  };

  factory DtcRepairGuide.fromJson(Map<String, dynamic> json) => DtcRepairGuide(
    code: json['code'] ?? '',
    titleEn: json['titleEn'] ?? '',
    titleAr: json['titleAr'] ?? '',
    category: json['category'] ?? 'Powertrain',
    severity: json['severity'] ?? 'Medium',
    descriptionEn: json['descriptionEn'] ?? '',
    descriptionAr: json['descriptionAr'] ?? '',
    symptomsEn: List<String>.from(json['symptomsEn'] ?? []),
    symptomsAr: List<String>.from(json['symptomsAr'] ?? []),
    causesEn: List<String>.from(json['causesEn'] ?? []),
    causesAr: List<String>.from(json['causesAr'] ?? []),
    diagnosticStepsEn: List<String>.from(json['diagnosticStepsEn'] ?? []),
    diagnosticStepsAr: List<String>.from(json['diagnosticStepsAr'] ?? []),
    multimeterChecksEn: json['multimeterChecksEn'] ?? '',
    multimeterChecksAr: json['multimeterChecksAr'] ?? '',
    repairSolutionsEn: json['repairSolutionsEn'] ?? '',
    repairSolutionsAr: json['repairSolutionsAr'] ?? '',
    laborDifficulty: json['laborDifficulty'] ?? 2,
    estimatedRepairTime: json['estimatedRepairTime'] ?? '45 mins',
  );
}
