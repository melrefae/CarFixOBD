/// Honest verification status per feature.
/// A feature may be marked [verified] ONLY after a test on a real car with a
/// raw request/response log kept in docs/verification/ (car, adapter, date).
enum FeatureStatus { verified, partiallyVerified, unverified }

class FeatureRecord {
  final String id;
  final FeatureStatus status;
  final String evidence; // path or note; empty when none
  const FeatureRecord(this.id, this.status, [this.evidence = '']);
}

/// Currently NO feature has real-car evidence recorded, so none is "verified".
const List<FeatureRecord> kFeatureRegistry = [
  FeatureRecord('obd2_connection_autodetect', FeatureStatus.unverified, 'unit tests on mock only'),
  FeatureRecord('read_dtc', FeatureStatus.unverified, 'unit tests on mock only'),
  FeatureRecord('live_data', FeatureStatus.unverified, 'unit tests on mock only'),
  FeatureRecord('vin_identification', FeatureStatus.unverified, 'unit tests on mock only'),
  FeatureRecord('used_car_audit', FeatureStatus.unverified, 'odometer check requires 2+ real readings'),
  FeatureRecord('ecu_coding', FeatureStatus.unverified),
  FeatureRecord('immobilizer_keys', FeatureStatus.unverified),
  FeatureRecord('dpf_regeneration', FeatureStatus.unverified),
  FeatureRecord('adas_calibration', FeatureStatus.unverified),
  FeatureRecord('actuator_tests', FeatureStatus.unverified),
  FeatureRecord('ev_battery', FeatureStatus.unverified, 'no real data source yet'),
];
