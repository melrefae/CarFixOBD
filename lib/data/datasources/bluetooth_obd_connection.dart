import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'obd_connection.dart';

/// Bluetooth Classic SPP (RFCOMM) OBD-II Connection implementation
class BluetoothObdConnection implements ObdConnection {
  BluetoothConnection? _connection;
  StreamSubscription<Uint8List>? _inputSubscription;
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  bool _isConnected = false;
  String _targetAddress = "";
  void Function()? onDisconnected;

  @override
  bool get isConnected => _isConnected && (_connection?.isConnected ?? false);

  @override
  String get connectionType => "Bluetooth";

  String get targetAddress => _targetAddress;
  StreamSubscription<Uint8List>? get inputSubscription => _inputSubscription;

  @override
  Stream<String> get responseStream => _responseController.stream;

  void _bindInputStream(BluetoothConnection conn) {
    _inputSubscription?.cancel();
    _inputSubscription = conn.input?.listen(
      (Uint8List data) {
        final text = latin1.decode(data);
        _responseController.add(text);
      },
      onDone: () {
        _isConnected = false;
        onDisconnected?.call();
      },
      onError: (err) {
        _isConnected = false;
        onDisconnected?.call();
      },
    );
  }

  @override
  Future<bool> connect(String target) async {
    _targetAddress = target;
    try {
      await disconnect();

      // Attempt initial connection with an 8-second timeout
      _connection = await BluetoothConnection.toAddress(target).timeout(
        const Duration(seconds: 8),
      );

      _isConnected = true;

      // Small stabilization pause for RFCOMM buffers
      await Future.delayed(const Duration(milliseconds: 150));

      _bindInputStream(_connection!);
      return true;
    } catch (e) {
      // Retry once if first attempt failed (common on paired OBD adapters re-establishing RFCOMM link)
      try {
        await disconnect();
        await Future.delayed(const Duration(milliseconds: 300));
        _connection = await BluetoothConnection.toAddress(target).timeout(
          const Duration(seconds: 6),
        );
        _isConnected = true;

        _bindInputStream(_connection!);
        return true;
      } catch (_) {
        _isConnected = false;
        return false;
      }
    }
  }

  @override
  Future<void> send(String command) async {
    if (!isConnected || _connection == null) {
      throw Exception("Bluetooth adapter is not currently connected.");
    }

    final formatted = command.endsWith('\r') ? command : '$command\r';
    _connection!.output.add(Uint8List.fromList(ascii.encode(formatted)));
    await _connection!.output.allSent;
  }

  @override
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      await _inputSubscription?.cancel();
      _inputSubscription = null;
      await _connection?.close();
      _connection?.dispose();
      _connection = null;
    } catch (_) {}
  }
}
