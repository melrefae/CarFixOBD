import '../../data/datasources/elm327_driver.dart';
import '../../data/models/ecu_coding_feature.dart';
import '../../core/utils/uds_response.dart';

/// Service managing vehicle ECU Variant Coding, safety backups, and parameter write routines
class EcuCodingService {
  final List<EcuCodingFeature> features = EcuCodingFeature.getDefaultFeatures();
  final Map<String, bool> _originalBackup = {};

  bool get hasBackup => _originalBackup.isNotEmpty;

  /// Backup original vehicle variant coding before any writes
  void createBackupSnapshot() {
    if (_originalBackup.isNotEmpty) return;
    for (final feature in features) {
      _originalBackup[feature.id] = feature.isEnabled;
    }
  }

  /// Toggle an individual variant coding feature
  Future<bool> toggleFeature({
    required EcuCodingFeature feature,
    required bool enable,
    Elm327Driver? driver,
  }) async {
    // 1. Ensure backup is taken
    createBackupSnapshot();

    // 2. A write is reported as successful ONLY if the ECU answered with a
    // positive response (6E for service 2E). No connection, no reply, or a
    // negative response means failure and the state is left unchanged.
    final cmd = enable ? feature.writeCommandEnable : feature.writeCommandDisable;
    if (driver == null) return false;
    try {
      final raw = await driver.sendToModule(feature.ecuHeader, cmd);
      final result = UdsResult.evaluate(raw, 0x2E);
      if (result.isPositive) {
        feature.isEnabled = enable;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Restore vehicle coding back to original factory snapshot
  Future<bool> restoreFactoryBackup({Elm327Driver? driver}) async {
    if (_originalBackup.isEmpty) return false;

    bool allSuccess = true;
    for (final feature in features) {
      final originalVal = _originalBackup[feature.id];
      if (originalVal != null && originalVal != feature.isEnabled) {
        final ok = await toggleFeature(feature: feature, enable: originalVal, driver: driver);
        if (!ok) allSuccess = false;
      }
    }
    return allSuccess;
  }
}
