import 'dart:async';

/// الواجهة المجردة (Interface) لطبقة الاتصال الفيزيائي بمحول الـ OBD
abstract class ObdConnection {
  /// الاتصال بالهدف (عنوان الماك للبلوتوث أو عنوان IP:Port للواي فاي)
  Future<bool> connect(String target);

  /// قطع الاتصال وإغلاق المنافذ والمجاري
  Future<void> disconnect();

  /// إرسال أمر نصي إلى المحول (مثل "AT Z" أو "01 0C\r")
  Future<void> send(String command);

  /// مجرى البايتات أو السلاسل النصية القادمة من المحول
  Stream<String> get responseStream;

  /// هل الاتصال نشط حالياً
  bool get isConnected;

  /// نوع الاتصال الحالي (Bluetooth, WiFi, Simulator)
  String get connectionType;
}
