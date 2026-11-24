import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'obd_connection.dart';

/// تنفيذ اتصال الواي فاي عبر الـ TCP Socket لمحول ELM327 Wi-Fi
class WifiObdConnection implements ObdConnection {
  Socket? _socket;
  StreamSubscription<List<int>>? _socketSubscription;
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  bool _isConnected = false;

  @override
  bool get isConnected => _isConnected && _socket != null;

  @override
  String get connectionType => "Wi-Fi (TCP)";

  @override
  Stream<String> get responseStream => _responseController.stream;

  @override
  Future<bool> connect(String target) async {
    try {
      await disconnect();

      // العنوان الافتراضي للمحولات في مصر هو 192.168.0.10:35000
      String host = "192.168.0.10";
      int port = 35000;

      if (target.contains(':')) {
        final parts = target.split(':');
        host = parts[0];
        port = int.tryParse(parts[1]) ?? 35000;
      } else if (target.isNotEmpty) {
        host = target;
      }

      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 6));
      _isConnected = true;

      _socketSubscription?.cancel();
      _socketSubscription = _socket!.listen(
        (List<int> data) {
          final text = ascii.decode(data, allowInvalid: true);
          _responseController.add(text);
        },
        onDone: () {
          _isConnected = false;
        },
        onError: (err) {
          _isConnected = false;
        },
      );

      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  @override
  Future<void> send(String command) async {
    if (!isConnected || _socket == null) {
      throw Exception("Wi-Fi OBD adapter is not currently connected.");
    }

    final formatted = command.endsWith('\r') ? command : '$command\r';
    _socket!.write(formatted);
    await _socket!.flush();
  }

  @override
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      await _socketSubscription?.cancel();
      _socketSubscription = null;
      await _socket?.close();
      _socket?.destroy();
      _socket = null;
    } catch (_) {}
  }
}
