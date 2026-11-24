import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/adapter_profile.dart';
import '../providers/obd_state.dart';

/// Connection manager screen for Bluetooth ELM327, Wi-Fi, and Simulator
class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _wifiIpController = TextEditingController(text: "192.168.0.10:35000");
  final TextEditingController _bleIdController = TextEditingController(text: "OBDII-BLE");
  final TextEditingController _usbPortController = TextEditingController(text: "/dev/bus/usb/001/002");
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
        title: const Text(AppStrings.connectionTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.bluetooth), text: "BT Classic"),
            Tab(icon: Icon(Icons.bluetooth_searching), text: "BLE 5.0"),
            Tab(icon: Icon(Icons.wifi), text: "Wi-Fi"),
            Tab(icon: Icon(Icons.usb), text: "USB OTG"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Connection status banner
          _buildStatusBanner(state),

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
                  label: const Text(AppStrings.disconnect, style: TextStyle(color: AppColors.dangerRed, fontSize: 12)),
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
                    label: const Text("Retry ECU Handshake (Key in ON/RUN)"),
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
                      "Quick Reconnect: ${state.lastSavedAdapterName ?? state.lastSavedAdapterTarget} (${state.lastSavedAdapterType ?? 'OBD'})",
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
        // 1. One-Tap Auto Detect & Connect Hero Card
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
                        children: const [
                          Text(
                            AppStrings.autoDetect,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                          ),
                          SizedBox(height: 3),
                          Text(
                            AppStrings.autoDetectSubtitle,
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
                    state.isConnecting ? "Connecting..." : "⚡ Auto-Connect Best Adapter",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: state.isConnecting
                      ? null
                      : () async {
                          final combined = [..._pairedDevices, ..._discoveredDevices];
                          final ok = await state.autoConnectBestAdapter(devices: combined.isNotEmpty ? combined : null);
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Connected to ${state.detectedAdapterProfile.displayName}!"),
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
                    _buildHardwareChip("vLinker MC+/FD+", AppColors.accentCyan),
                    _buildHardwareChip("OBDLink CX/MX+", AppColors.accentCyan),
                    _buildHardwareChip("Veepeak BLE+", AppColors.primaryYellow),
                    _buildHardwareChip("Carista BLE", AppColors.primaryYellow),
                    _buildHardwareChip("Viecar 4.0", AppColors.primaryYellow),
                    _buildHardwareChip("ELM327 BT", AppColors.textMuted),
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
            const Text(
              AppStrings.pairedDevices,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
            ),
            Row(
              children: [
                TextButton.icon(
                  icon: Icon(_isDiscoveringNearby ? Icons.stop : Icons.search, size: 16, color: AppColors.accentCyan),
                  label: Text(_isDiscoveringNearby ? "Scanning..." : "Scan Nearby", style: const TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                  onPressed: _isDiscoveringNearby ? () => _discoverySub?.cancel() : _startActiveDiscovery,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.primaryYellow, size: 20),
                  tooltip: "Refresh Paired",
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
              children: const [
                Icon(Icons.bluetooth_disabled, size: 40, color: AppColors.textDisabled),
                SizedBox(height: 8),
                Text(AppStrings.noPairedDevices, style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  AppStrings.pairDevicePrompt,
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
              const Text(
                AppStrings.discoveredDevices,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accentCyan),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_discoveredDevices.isEmpty && _isDiscoveringNearby)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: Text("Listening for nearby Bluetooth adapters...", style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
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
                device.name ?? AppStrings.unknownDevice,
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
                    : (isKnownObd ? "OBD-II" : (isPaired ? "Paired" : "Nearby")),
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
                    "Chip: ${profile.chipsetFamily}",
                    style: TextStyle(
                      fontSize: 10,
                      color: profile.highSpeedCapable ? AppColors.accentCyan : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Score: $score",
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
          child: const Text(AppStrings.connect, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildWifiTab(ObdState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            AppStrings.wifiSettingsTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.wifiDescription,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _wifiIpController,
            decoration: const InputDecoration(
              labelText: AppStrings.adapterAddressLabel,
              prefixIcon: Icon(Icons.settings_ethernet, color: AppColors.primaryYellow),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.wifi, color: Colors.black),
            label: const Text(AppStrings.connectWifi),
            onPressed: state.isConnecting
                ? null
                : () async {
                    final ok = await state.connectWifi(_wifiIpController.text.trim());
                    if (ok && mounted) {
                      Navigator.pop(context);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildBleTab(ObdState state) {
    final bleAdapters = [
      {"name": "Vgate iCar Pro BLE 4.0", "id": "00:1B:10:E2:33:44", "chip": "ARM Cortex-M0"},
      {"name": "OBDLink CX BLE", "id": "OBDLink-CX", "chip": "OBDLink STN BLE"},
      {"name": "Veepeak OBDCheck BLE+", "id": "VEEPEAK", "chip": "TI CC2541 BLE"},
      {"name": "Carista OBD BLE", "id": "Carista-BLE", "chip": "Custom BLE"},
    ];

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
                  children: const [
                    Icon(Icons.bluetooth_searching, color: AppColors.accentCyan, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "Bluetooth Low Energy (BLE 4.0/5.0)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "Connect to modern low-power OBD adapters supporting Nordic UART (0xFFE0 / 0xFFF0) and OBDLink BLE GATT profiles. Requires no PIN code pairing.",
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bleIdController,
                  decoration: const InputDecoration(
                    labelText: "BLE Device Name / UUID / MAC",
                    prefixIcon: Icon(Icons.fingerprint, color: AppColors.accentCyan),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentCyan,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  icon: const Icon(Icons.link),
                  label: const Text("Connect BLE Adapter", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: state.isConnecting
                      ? null
                      : () async {
                          final ok = await state.connectBle(
                            _bleIdController.text.trim(),
                            deviceName: _bleIdController.text.trim(),
                          );
                          if (ok && mounted) {
                            Navigator.pop(context);
                          }
                        },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Common BLE OBD Adapters:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite),
        ),
        const SizedBox(height: 8),
        ...bleAdapters.map((item) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.bluetooth_audio, color: AppColors.accentCyan),
              title: Text(item["name"]!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
              subtitle: Text("ID: ${item["id"]} • Chip: ${item["chip"]}", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardSurfaceHighlight,
                  foregroundColor: AppColors.accentCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                ),
                onPressed: state.isConnecting
                    ? null
                    : () async {
                        _bleIdController.text = item["id"]!;
                        final ok = await state.connectBle(item["id"]!, deviceName: item["name"]);
                        if (ok && mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: const Text("Connect", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUsbSerialTab(ObdState state) {
    const baudRates = [38400, 115200, 230400, 500000];

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
                  children: const [
                    Icon(Icons.usb, color: AppColors.successGreen, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "USB Serial / OTG Cable Hardware",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "High-speed wired connection using USB-OTG. Direct hardware UART access with 0% wireless packet drop. Supports FTDI FT232R, WCH CH340, CP2102, PL2303, and CDC-ACM adapters (e.g. OBDLink EX/SX, vLinker FS).",
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _usbPortController,
                  decoration: const InputDecoration(
                    labelText: "USB Serial Port / Device Node",
                    prefixIcon: Icon(Icons.cable, color: AppColors.successGreen),
                    hintText: "/dev/bus/usb/001/002 or COM1",
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text("UART Baud Rate: ", style: TextStyle(fontSize: 12, color: AppColors.textWhite)),
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  icon: const Icon(Icons.power),
                  label: const Text("Open USB Serial Port", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: state.isConnecting
                      ? null
                      : () async {
                          final portBaud = "${_usbPortController.text.trim()}@$_selectedUsbBaud";
                          final ok = await state.connectUsbSerial(
                            portBaud,
                            deviceName: "USB Serial (${_selectedUsbBaud}bps)",
                          );
                          if (ok && mounted) {
                            Navigator.pop(context);
                          }
                        },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Compatible USB Hardware Adapters:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite),
              ),
              SizedBox(height: 6),
              Text("• OBDLink EX / SX USB (FTDI 115200 - 500000 baud)", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text("• vLinker FS USB (CDC-ACM up to 3Mbps)", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text("• ELM327 USB with CH340 / CP2102 chip (38400 baud)", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text("• Tactrix OpenPort 2.0 / J2534 PassThru cable", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
