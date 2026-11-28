import 'package:flutter/widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../presentation/providers/obd_state.dart';

/// Returns the localized, user-facing status line for the current ObdState.
/// Falls back to the raw English statusMessage for any unknown key.
String localizedObdStatus(BuildContext context, ObdState state) {
  final l10n = AppLocalizations.of(context);
  final p = state.statusParams;
  String p0() => p['p0'] ?? '';
  String p1() => p['p1'] ?? '';
  switch (state.statusKey) {
    case 'statusDisconnected': return l10n.statusDisconnected;
    case 'statusDisconnectedShort': return l10n.statusDisconnectedShort;
    case 'statusConnectionLost': return l10n.statusConnectionLost(p0());
    case 'statusLaunchingSimulator': return l10n.statusLaunchingSimulator;
    case 'statusSimulatorFailed': return l10n.statusSimulatorFailed;
    case 'statusConnectingBluetooth': return l10n.statusConnectingBluetooth(p0());
    case 'statusBluetoothFailed': return l10n.statusBluetoothFailed;
    case 'statusConnectingWifi': return l10n.statusConnectingWifi(p0());
    case 'statusWifiFailed': return l10n.statusWifiFailed;
    case 'statusConnectingBle': return l10n.statusConnectingBle(p0());
    case 'statusBleGattFailed': return l10n.statusBleGattFailed;
    case 'statusOpeningSerial': return l10n.statusOpeningSerial(p0());
    case 'statusSerialFailed': return l10n.statusSerialFailed;
    case 'statusAutoDetecting': return l10n.statusAutoDetecting;
    case 'statusCheckingRecent': return l10n.statusCheckingRecent(p0());
    case 'statusCheckingUsb': return l10n.statusCheckingUsb;
    case 'statusProbingSerial': return l10n.statusProbingSerial(p0(), p1());
    case 'statusScanningBle': return l10n.statusScanningBle;
    case 'statusConnectingBleNamed': return l10n.statusConnectingBleNamed(p0());
    case 'statusProbingWifi': return l10n.statusProbingWifi;
    case 'statusFoundWifi': return l10n.statusFoundWifi(p0());
    case 'statusNoAdapterFound': return l10n.statusNoAdapterFound;
    case 'statusAutoConnectFailed': return l10n.statusAutoConnectFailed(p0());
    case 'statusAuditing': return l10n.statusAuditing;
    case 'statusAuditDone': return l10n.statusAuditDone(p0());
    case 'statusEvaluating': return l10n.statusEvaluating;
    case 'statusNoBtDevices': return l10n.statusNoBtDevices;
    case 'statusBestMatched': return l10n.statusBestMatched(p0(), p1());
    case 'statusHandshakeFailed': return l10n.statusHandshakeFailed;
    case 'statusRequestingBtPerm': return l10n.statusRequestingBtPerm;
    case 'statusScanningPaired': return l10n.statusScanningPaired;
    case 'statusFoundAdapter': return l10n.statusFoundAdapter(p0());
    case 'statusProbingPaired': return l10n.statusProbingPaired(p0());
    case 'statusDiscovering': return l10n.statusDiscovering;
    case 'statusFoundNearby': return l10n.statusFoundNearby(p0());
    case 'statusNoBtAdapter': return l10n.statusNoBtAdapter;
    case 'statusBtError': return l10n.statusBtError(p0());
    case 'statusInitProtocol': return l10n.statusInitProtocol;
    case 'statusConnectedDetecting': return l10n.statusConnectedDetecting;
    case 'statusConnectedDetected': return l10n.statusConnectedDetected(p0(), p1());
    case 'statusConnectedProtocol': return l10n.statusConnectedProtocol(p0());
    case 'statusAdapterReadyKeyOff': return l10n.statusAdapterReadyKeyOff(p0());
    case 'statusInitFailed': return l10n.statusInitFailed(p0());
    case 'statusRetrying': return l10n.statusRetrying;
    case 'statusEcuNotResponding': return l10n.statusEcuNotResponding;
    case 'statusReadingVin': return l10n.statusReadingVin;
    case 'statusQuickScanDone': return l10n.statusQuickScanDone;
    default: return state.statusMessage;
  }
}
