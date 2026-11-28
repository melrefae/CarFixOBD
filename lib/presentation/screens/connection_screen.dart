import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../data/models/adapter_profile.dart';
import '../../data/datasources/wifi_obd_connection.dart';
import '../providers/obd_state.dart';
import '../../domain/services/adapter_check.dart';
import '../../domain/services/uds_read_service.dart';

/// Connection manager screen for Bluetooth Classic, BLE 5.0, Wi-Fi, USB-OTG / Serial, and Universal Auto-Detect
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _wifiIpController = TextEditingController(text: "192.168.0.10:35000");
  final TextEditingController _bleIdController = TextEditingController();
  final TextEditingController _usbPortController = TextEditingController();
  int _selectedUsbBaud = 115200;

  List<BluetoothDevice> _pairedDevices = [];
  final List<BluetoothDevice> _discoveredDevices = [];
  bool _isLoadingPaired = false;
  bool _isDiscoveringNearby = false;
  StreamSubscription<BluetoothDiscoveryResult>? _discoverySub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPairedDevices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ObdState>(context, listen: false).scanSerialDevices();
      }
    });
  }

  @override
  void dispose() {
    _discoverySub?.cancel();
    _tabController.dispose();
    _wifiIpController.dispose();
    _bleIdController.dispose();
    _usbPortController.dispose();
    super.dispose();
  }

  Future<void> _loadPairedDevices() async {
    setState(() {
      _isLoadingPaired = true;
    });

    try {
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      if (mounted) {
        setState(() {
          _pairedDevices = devices;
          _isLoadingPaired = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingPaired = false;
        });
      }
    }
  }

  Future<void> _startActiveDiscovery() async {
    setState(() {
      _isDiscoveringNearby = true;
      _discoveredDevices.clear();
    });

    try {
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      _discoverySub?.cancel();
      _discoverySub = FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        if (mounted) {
          final exists = _discoveredDevices.any((d) => d.address == result.device.address) ||
              _pairedDevices.any((d) => d.address == result.device.address);
          if (!exists) {
            setState(() {
              _discoveredDevices.add(result.device);
            });
          }
        }
      }, onDone: () {
        if (mounted) {
          setState(() {
            _isDiscoveringNearby = false;
          });
        }
      }, onError: (_) {
        if (mounted) {
          setState(() {
            _isDiscoveringNearby = false;
          });
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isDiscoveringNearby = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).connectionTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.bluetooth), text: "BT Classic"),
            Tab(icon: Icon(Icons.bluetooth_searching), text: "BLE 5.0"),
            Tab(icon: Icon(Icons.wifi), text: "Wi-Fi"),
            Tab(icon: Icon(Icons.usb), text: "USB / Serial"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Connection status banner
          _buildStatusBanner(state),
          _buildProtocolPicker(state),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBluetoothTab(state),
                _buildBleTab(state),
                _buildWifiTab(state),
                _buildUsbSerialTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const _protocolNames = <int, String>{
    0: 'Auto (adapter searches all protocols)',
    1: 'SAE J1850 PWM (old Ford)',
    2: 'SAE J1850 VPW (old GM)',
    3: 'ISO 9141-2 (slow init, old Asian/European)',
    4: 'ISO 14230-4 KWP 5-baud (slow init)',
    5: 'ISO 14230-4 KWP fast init (many 2000-2008 cars)',
    6: 'CAN 11-bit 500k (most 2008+)',
    7: 'CAN 29-bit 500k',
    8: 'CAN 11-bit 250k',
    9: 'CAN 29-bit 250k',
  };

  Widget _buildProtocolPicker(ObdState state) {
    final attempts = state.protocolAttempts;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(AppLocalizations.of(context).protocolPickerLabel, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            Expanded(
              child: DropdownButton<int>(
                isExpanded: true,
                value: state.protocolOverride,
                items: [for (final e in _protocolNames.entries) DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))],
                onChanged: state.isConnecting ? null : (v) { if (v != null) state.setProtocolOverride(v); },
              ),
            ),
          ]),
          if (state.isConnected)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.fact_check_outlined, size: 18),
                label: Text(AppLocalizations.of(context).checkAdapter20s, style: const TextStyle(fontSize: 12)),
                onPressed: () async {
                  final d = state.driver;
                  if (d == null) return;
                  showDialog(context: context, barrierDismissible: false, builder: (_) => const AlertDialog(content: SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))));
                  final r = await AdapterCheck.run(d);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text(AppLocalizations.of(context).adapterCheckTitle),
                    content: SingleChildScrollView(child: Text(r.toText(), style: const TextStyle(fontSize: 12))),
                    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                  ));
                },
              ),
            ),
          if (state.isConnected)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.memory, size: 18),
                label: Text(AppLocalizations.of(context).readModulesUds, style: const TextStyle(fontSize: 12)),
                onPressed: () async {
                  final d = state.driver;
                  if (d == null) return;
                  showDialog(context: context, barrierDismissible: false, builder: (_) => const AlertDialog(content: SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))));
                  final r = await UdsReadService.run(d);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  final lines = <String>[r.note, ''];
                  for (final e in r.ecus.where((e) => e.answered)) {
                    lines.add('Module ${e.header}');
                    e.ident.forEach((k, v) => lines.add('  $k: $v'));
                    if (e.dtcServiceAnswered) {
                      lines.add(e.dtcs.isEmpty ? '  No fault codes stored' : '  Fault codes:');
                      for (final c in e.dtcs) { lines.add('   ${c.code} (${c.statusText})'); }
                    }
                    if (e.note.isNotEmpty) lines.add('  ${e.note}');
                  }
                  showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text(AppLocalizations.of(context).modulesUdsTitle),
                    content: SingleChildScrollView(child: Text(lines.join('\n'), style: const TextStyle(fontSize: 12))),
                    actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                  ));
                },
              ),
            ),
          if (attempts.isNotEmpty && !state.isEcuReady)
            Text('${AppLocalizations.of(context).lastAttempt}\n${attempts.join("\n")}', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(ObdState state) {
    Color bannerColor = AppColors.cardSurfaceHighlight;
    Color iconColor = AppColors.textMuted;
    IconData icon = Icons.info_outline;

    if (state.isEcuReady) {
      bannerColor = const Color(0xFF1B5E20).withOpacity(0.4);
      iconColor = AppColors.successGreen;
      icon = Icons.check_circle;
    } else if (state.isAdapterOnly) {
      bannerColor = const Color(0xFFE65100).withOpacity(0.3);
      iconColor = AppColors.warningOrange;
      icon = Icons.power;
    } else if (state.isConnecting) {
      bannerColor = const Color(0xFF0D47A1).withOpacity(0.3);
      iconColor = AppColors.accentCyan;
      icon = Icons.sync;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bannerColor,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.statusMessage,
                  style: const TextStyle(fontSize: 12, color: AppColors.textWhite, fontWeight: FontWeight.w500),
                ),
              ),
              if (state.isConnected)
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.dangerRed),
                  label: Text(AppLocalizations.of(context).disconnect, style: const TextStyle(color: AppColors.dangerRed, fontSize: 12)),
                  onPressed: () => state.disconnect(),
                ),
            ],
          ),
          if (state.isAdapterOnly) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(AppLocalizations.of(context).retryEcuHandshake),
                    onPressed: () => state.retryEcuHandshake(),
                  ),
                ),
              ],
            ),
          ] else if (!state.isConnected && !state.isConnecting && state.lastSavedAdapterTarget != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryYellow,
                      side: const BorderSide(color: AppColors.primaryYellow),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.history, size: 18),
                    label: Text(
                      AppLocalizations.of(context).quickReconnect(state.lastSavedAdapterName ?? state.lastSavedAdapterTarget ?? '', state.lastSavedAdapterType ?? 'OBD'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => state.reconnectLastAdapter(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBluetoothTab(ObdState state) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // 1. Universal Multi-Transport Auto Detect & Connect Hero Card
        Card(
          elevation: 3,
          color: const Color(0xFF1A2634),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.primaryYellow, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.radar, color: AppColors.primaryYellow, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).autoDetectConnect,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppLocalizations.of(context).autoDetectSubtitle,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: state.isConnecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.flash_on),
                  label: Text(
                    state.isConnecting ? AppLocalizations.of(context).autoDetecting : AppLocalizations.of(context).autoDetectAnyAdapter,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: state.isConnecting
                      ? null
                      : () async {
                          final ok = await state.autoDetectAndConnectAny();
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).connectedToAdapter(state.detectedAdapterProfile.displayName)),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          }
                        },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildHardwareChip("USB / Serial", AppColors.successGreen),
                    _buildHardwareChip("BT Classic SPP", AppColors.primaryYellow),
                    _buildHardwareChip("BLE 4.0 / 5.0", AppColors.accentCyan),
                    _buildHardwareChip("Wi-Fi TCP", AppColors.electricBlue),
                    _buildHardwareChip("Auto Car VIN", AppColors.primaryAmber),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Paired Devices Header & Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).pairedDevicesOs,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
            ),
            Row(
              children: [
                TextButton.icon(
                  icon: Icon(_isDiscoveringNearby ? Icons.stop : Icons.search, size: 16, color: AppColors.accentCyan),
                  label: Text(_isDiscoveringNearby ? AppLocalizations.of(context).scanning : AppLocalizations.of(context).scanNearby, style: const TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                  onPressed: _isDiscoveringNearby ? () => _discoverySub?.cancel() : _startActiveDiscovery,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primaryYellow, size: 20),
                  tooltip: AppLocalizations.of(context).refreshPaired,
                  onPressed: _loadPairedDevices,
                ),
              ],
            ),
          ],
        ),

        if (_isLoadingPaired)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow)),
          )
        else if (_pairedDevices.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Icon(Icons.bluetooth_disabled, size: 40, color: AppColors.textDisabled),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context).noPairedDevices, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).pairedNonAndroidNote,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ..._pairedDevices.map((d) => _buildDeviceCard(d, state, isPaired: true)),

        // 3. Discovered Nearby Devices Section
        if (_isDiscoveringNearby || _discoveredDevices.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              if (_isDiscoveringNearby)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentCyan),
                ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).discoveredDevices,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accentCyan),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_discoveredDevices.isEmpty && _isDiscoveringNearby)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(child: Text(AppLocalizations.of(context).listeningNearby, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
            )
          else
            ..._discoveredDevices.map((d) => _buildDeviceCard(d, state, isPaired: false)),
        ],
      ],
    );
  }

  Widget _buildHardwareChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device, ObdState state, {required bool isPaired}) {
    final profile = AdapterProfile.detect(device.name);
    final isKnownObd = profile.brand != AdapterBrand.unknown || ObdState.isObdDeviceName(device.name);
    final score = AdapterProfile.scoreDevice(
      name: device.name,
      address: device.address,
      isBonded: isPaired,
      isRecentlyConnected: device.name != null && device.name == state.connectedDeviceName,
    );

    Color badgeColor = AppColors.textMuted;
    if (profile.highSpeedCapable) {
      badgeColor = AppColors.accentCyan;
    } else if (isKnownObd) {
      badgeColor = AppColors.primaryYellow;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isKnownObd ? badgeColor.withOpacity(0.5) : const Color(0xFF263238),
        ),
      ),
      child: ListTile(
        leading: Icon(
          profile.highSpeedCapable ? Icons.speed : Icons.bluetooth,
          color: isKnownObd ? badgeColor : AppColors.textMuted,
          size: 28,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name ?? AppLocalizations.of(context).unknownDevice,
                style: TextStyle(
                  fontWeight: isKnownObd ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textWhite,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                profile.brand != AdapterBrand.unknown
                    ? profile.displayName
                    : (isKnownObd ? "OBD-II" : (isPaired ? AppLocalizations.of(context).pairedBadge : AppLocalizations.of(context).nearbyBadge)),
                style: TextStyle(
                  fontSize: 10,
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device.address,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).chipLabel(profile.chipsetFamily),
                    style: TextStyle(
                      fontSize: 10,
                      color: profile.highSpeedCapable ? AppColors.accentCyan : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).scoreLabel(score),
                    style: const TextStyle(fontSize: 10, color: AppColors.primaryYellow),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isKnownObd ? AppColors.primaryYellow : AppColors.cardSurfaceHighlight,
            foregroundColor: isKnownObd ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
          ),
          onPressed: state.isConnecting
              ? null
              : () async {
                  final ok = await state.connectBluetooth(device.address, deviceName: device.name);
                  if (ok && mounted) {
                    Navigator.pop(context);
                  }
                },
          child: Text(AppLocalizations.of(context).connect, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildWifiTab(ObdState state) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          AppLocalizations.of(context).wifiSettingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context).wifiDescription,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: WifiObdConnection.commonWifiEndpoints.map((ep) {
            return ActionChip(
              label: Text(ep, style: const TextStyle(fontSize: 11, color: AppColors.textWhite)),
              backgroundColor: AppColors.cardSurface,
              onPressed: () {
                setState(() {
                  _wifiIpController.text = ep;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _wifiIpController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).adapterAddressLabel,
            prefixIcon: const Icon(Icons.settings_ethernet, color: AppColors.primaryYellow),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          icon: const Icon(Icons.wifi, color: Colors.black),
          label: Text(AppLocalizations.of(context).connectWifi),
          onPressed: state.isConnecting
              ? null
              : () async {
                  final ok = await state.connectWifi(_wifiIpController.text.trim());
                  if (ok && mounted) {
                    Navigator.pop(context);
                  }
                },
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          icon: const Icon(Icons.radar, color: AppColors.accentCyan),
          label: Text(AppLocalizations.of(context).autoProbeWifi, style: const TextStyle(color: AppColors.accentCyan)),
          onPressed: state.isConnecting
              ? null
              : () async {
                  final ep = await WifiObdConnection.detectReachableWifiEndpoint();
                  if (!mounted) return;
                  if (ep != null) {
                    _wifiIpController.text = ep;
                    final ok = await state.connectWifi(ep);
                    if (ok && mounted) Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).noWifiGateway),
                        backgroundColor: AppColors.warningOrange,
                      ),
                    );
                  }
                },
        ),
      ],
    );
  }

  Widget _buildBleTab(ObdState state) {
    final discoveredBle = state.discoveredBleDevices;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFF141F2B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.accentCyan, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bluetooth_searching, color: AppColors.accentCyan, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).bleTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).bleDescription,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCyan,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  icon: state.isScanningBle
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.radar),
                  label: Text(
                    state.isScanningBle ? AppLocalizations.of(context).scanningBle : AppLocalizations.of(context).scanBleAdapters,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: state.isScanningBle ? null : () => state.scanBleDevices(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context).bleScanResults(discoveredBle.length),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentCyan),
            ),
            if (state.isScanningBle)
              Text(AppLocalizations.of(context).listening, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(height: 8),
        if (discoveredBle.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              state.isScanningBle
                  ? AppLocalizations.of(context).searchingBle
                  : AppLocalizations.of(context).tapScanBle,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...discoveredBle.map((item) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: item.isKnownObd ? AppColors.accentCyan.withOpacity(0.6) : const Color(0xFF263238),
                ),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.bluetooth_audio,
                  color: item.isKnownObd ? AppColors.accentCyan : AppColors.textMuted,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name.isNotEmpty ? item.name : item.remoteId,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                      ),
                    ),
                    if (item.isKnownObd)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.matchedProfileBrand,
                          style: const TextStyle(fontSize: 10, color: AppColors.accentCyan, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  AppLocalizations.of(context).bleIdRssi(item.remoteId, item.rssi),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isKnownObd ? AppColors.accentCyan : AppColors.cardSurfaceHighlight,
                    foregroundColor: item.isKnownObd ? Colors.black : AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  onPressed: state.isConnecting
                      ? null
                      : () async {
                          final ok = await state.connectBle(
                            item.remoteId,
                            deviceName: item.name.isNotEmpty ? item.name : item.matchedProfileBrand,
                          );
                          if (ok && mounted) Navigator.pop(context);
                        },
                  child: const Text("Connect", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        const SizedBox(height: 18),
        Text(
          AppLocalizations.of(context).manualBleId,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bleIdController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).bleIdHint,
                  prefixIcon: const Icon(Icons.fingerprint, color: AppColors.accentCyan),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: state.isConnecting || _bleIdController.text.trim().isEmpty
                  ? null
                  : () async {
                      final target = _bleIdController.text.trim();
                      final ok = await state.connectBle(target, deviceName: target);
                      if (ok && mounted) Navigator.pop(context);
                    },
              child: const Text("Connect"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsbSerialTab(ObdState state) {
    const baudRates = [38400, 115200, 230400, 500000];
    final attachedSerial = state.discoveredSerialDevices;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFF1B221B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.successGreen, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.usb, color: AppColors.successGreen, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).usbSerialTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).usbSerialDescription,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  icon: state.isScanningSerial
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    state.isScanningSerial ? AppLocalizations.of(context).enumeratingPorts : AppLocalizations.of(context).refreshUsbDevices,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: state.isScanningSerial ? null : () => state.scanSerialDevices(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AppLocalizations.of(context).detectedSerialPorts(attachedSerial.length),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.successGreen),
        ),
        const SizedBox(height: 8),
        if (attachedSerial.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context).noUsbDetected,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...attachedSerial.map((dev) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: AppColors.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(
                  dev.isLikelyBluetoothSerial ? Icons.bluetooth_connected : Icons.usb,
                  color: AppColors.successGreen,
                ),
                title: Text(
                  dev.displayName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                ),
                subtitle: Text(
                  AppLocalizations.of(context).portLine(dev.portId, dev.transportKind) + (dev.chipsetName != null ? ' • ${dev.chipsetName}' : ''),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  onPressed: state.isConnecting
                      ? null
                      : () async {
                          _usbPortController.text = dev.portId;
                          final ok = await state.connectUsbSerial(
                            "${dev.portId}:$_selectedUsbBaud",
                            deviceName: dev.displayName,
                          );
                          if (ok && mounted) Navigator.pop(context);
                        },
                  child: const Text("Connect", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        Card(
          color: AppColors.cardSurface,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).manualSerialOverride,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite)),
                const SizedBox(height: 10),
                TextField(
                  controller: _usbPortController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).serialPortPathLabel,
                    prefixIcon: const Icon(Icons.cable, color: AppColors.successGreen),
                    hintText: "/dev/cu.987696098341 or Android USB ID",
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(AppLocalizations.of(context).uartBaudRate, style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _selectedUsbBaud,
                      dropdownColor: AppColors.cardSurface,
                      style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold),
                      items: baudRates.map((b) {
                        return DropdownMenuItem<int>(
                          value: b,
                          child: Text("$b baud"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedUsbBaud = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardSurfaceHighlight,
                    foregroundColor: AppColors.successGreen,
                    minimumSize: const Size(double.infinity, 42),
                  ),
                  icon: const Icon(Icons.power),
                  label: Text(AppLocalizations.of(context).openSerialPort, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: state.isConnecting
                      ? null
                      : () async {
                          final rawPort = _usbPortController.text.trim();
                          if (rawPort.isEmpty) return;
                          final ok = await state.connectUsbSerial(
                            "$rawPort:$_selectedUsbBaud",
                            deviceName: "Serial ($rawPort @ $_selectedUsbBaud)",
                          );
                          if (ok && mounted) Navigator.pop(context);
                        },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
