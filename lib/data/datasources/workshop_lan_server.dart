import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/inspection_report.dart';
import '../repositories/report_repository.dart';
import '../../core/utils/app_logger.dart';

/// سيرفر الورشة المحلي (Offline Workshop LAN Hub)
/// يتيح لأجهزة الكمبيوتر والتابلت الأخرى داخل الورشة الوصول لكروت الفحص
/// ومراقبة الفحص اللحظي عبر متصفح الويب بدون إنترنت
class WorkshopLanServer {
  static final WorkshopLanServer _instance = WorkshopLanServer._internal();
  factory WorkshopLanServer() => _instance;
  WorkshopLanServer._internal();

  HttpServer? _server;
  int _port = 8080;
  String? _localIp;
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  int get port => _port;
  String? get localIp => _localIp;
  String get serverUrl => _localIp != null ? "http://$_localIp:$_port" : "http://localhost:$_port";

  // Provider callback للحصول على الحالة اللحظية
  Map<String, dynamic> Function()? getLiveStatusCallback;
  Function(InspectionReport)? onReportReceived;

  /// بدء تشغيل السيرفر المحلي
  Future<bool> startServer({int port = 8080}) async {
    if (_isRunning) return true;
    _port = port;

    try {
      _localIp = await _findLocalIp();
      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      _isRunning = true;
      AppLogger().info("Workshop LAN Hub started at $serverUrl");

      _server!.listen(_handleRequest, onError: (e) {
        AppLogger().warning("LAN Server error: $e");
      });

      return true;
    } catch (e) {
      AppLogger().warning("Failed to start Workshop LAN Server: $e");
      _isRunning = false;
      return false;
    }
  }

  /// إيقاف السيرفر
  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }
    _isRunning = false;
    AppLogger().info("Workshop LAN Hub stopped");
  }

  /// اكتشاف عنوان الـ IP المحلي للجهاز على شبكة الورشة (Wi-Fi)
  Future<String?> _findLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            final ip = addr.address;
            if (ip.startsWith("192.168.") || ip.startsWith("10.") || ip.startsWith("172.")) {
              return ip;
            }
          }
        }
      }
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
    } catch (e) {
      AppLogger().warning("Error getting local IP: $e");
    }
    return "127.0.0.1";
  }

  /// معالجة طلبات الـ HTTP
  Future<void> _handleRequest(HttpRequest request) async {
    // إضافة CORS Headers للسماح بالوصول من أي متصفح
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    final path = request.uri.path;

    try {
      if (path == '/' || path == '/index.html') {
        await _serveWebDashboard(request);
      } else if (path == '/api/status' && request.method == 'GET') {
        await _handleApiStatus(request);
      } else if (path == '/api/reports' && request.method == 'GET') {
        await _handleApiGetReports(request);
      } else if (path == '/api/reports' && request.method == 'POST') {
        await _handleApiPostReport(request);
      } else if (path.startsWith('/report/')) {
        final id = path.replaceFirst('/report/', '');
        await _serveSingleReportHtml(request, id);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write("الصفحة غير موجودة 404");
        await request.response.close();
      }
    } catch (e) {
      AppLogger().warning("Error handling HTTP request $path: $e");
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write("Internal Server Error: $e");
      await request.response.close();
    }
  }

  /// HTML5 Web Dashboard
  Future<void> _serveWebDashboard(HttpRequest request) async {
    final reports = await ReportRepository().getReports();
    final live = getLiveStatusCallback != null ? getLiveStatusCallback!() : <String, dynamic>{};

    final isConnected = live['isConnected'] ?? false;
    final batteryVolt = live['batteryVoltage'] ?? 0.0;
    final vehicleModel = live['vehicleModel'] ?? "Unspecified";
    final dtcCount = (live['dtcs'] as List?)?.length ?? 0;

    final html = '''
<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="refresh" content="6">
  <title>AutoSpect | Workshop LAN Hub</title>
  <style>
    :root {
      --bg: #12151B;
      --card: #1A1F29;
      --yellow: #FFB300;
      --blue: #2979FF;
      --green: #00E676;
      --red: #FF3D00;
      --text: #F5F7FA;
      --muted: #8E9BAE;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
      background-color: var(--bg);
      color: var(--text);
      margin: 0;
      padding: 20px;
      direction: ltr;
    }
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2px solid #283040;
      padding-bottom: 15px;
      margin-bottom: 25px;
    }
    .header h1 {
      margin: 0;
      color: var(--yellow);
      font-size: 24px;
    }
    .badge-lan {
      background: #00E67622;
      color: var(--green);
      border: 1px solid var(--green);
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: bold;
    }
    .status-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 15px;
      margin-bottom: 30px;
    }
    .stat-card {
      background: var(--card);
      border-radius: 12px;
      padding: 16px;
      border-left: 4px solid var(--yellow);
    }
    .stat-card.blue { border-left-color: var(--blue); }
    .stat-card.green { border-left-color: var(--green); }
    .stat-card.red { border-left-color: var(--red); }
    .stat-title { color: var(--muted); font-size: 13px; margin-bottom: 6px; }
    .stat-val { font-size: 22px; font-weight: bold; }
    .section-title {
      color: var(--yellow);
      font-size: 18px;
      margin-bottom: 15px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background: var(--card);
      border-radius: 12px;
      overflow: hidden;
    }
    th, td {
      padding: 14px 16px;
      text-align: left;
      border-bottom: 1px solid #232B3A;
    }
    th {
      background: #1F2633;
      color: var(--yellow);
      font-size: 14px;
    }
    tr:hover {
      background: #222938;
    }
    .btn {
      background: var(--yellow);
      color: #000;
      border: none;
      padding: 6px 12px;
      border-radius: 6px;
      font-weight: bold;
      text-decoration: none;
      font-size: 13px;
      display: inline-block;
      cursor: pointer;
    }
    .empty-msg {
      text-align: center;
      padding: 40px;
      color: var(--muted);
    }
  </style>
</head>
<body>
  <div class="header">
    <div>
      <h1>🚗 AutoSpect | Offline LAN Hub Dashboard</h1>
      <p style="color: var(--muted); margin: 5px 0 0 0; font-size: 14px;">Automotive Diagnostics Center | Phone & WhatsApp: +20 155 366 6635</p>
    </div>
    <div class="badge-lan">LAN Connected: $serverUrl</div>
  </div>

  <div class="status-grid">
    <div class="stat-card ${isConnected ? 'green' : 'red'}">
      <div class="stat-title">OBD Adapter & ECU Status</div>
      <div class="stat-val">${isConnected ? 'Connected & Ready ✅' : 'Disconnected ❌'}</div>
    </div>
    <div class="stat-card blue">
      <div class="stat-title">Current Vehicle Inspected</div>
      <div class="stat-val">$vehicleModel</div>
    </div>
    <div class="stat-card yellow">
      <div class="stat-title">Real-Time Battery Voltage</div>
      <div class="stat-val">${batteryVolt > 0 ? batteryVolt.toStringAsFixed(1) + ' V' : '--'}</div>
    </div>
    <div class="stat-card ${dtcCount > 0 ? 'red' : 'green'}">
      <div class="stat-title">Detected Trouble Codes</div>
      <div class="stat-val">$dtcCount Fault(s)</div>
    </div>
  </div>

  <div class="section-title">📋 Saved Inspection Reports (${reports.length} Reports):</div>

  ${_buildReportsTableHtml(reports)}

</body>
</html>
''';

    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    await request.response.close();
  }

  String _buildReportsTableHtml(List<InspectionReport> reports) {
    if (reports.isEmpty) {
      return '<div class="empty-msg">No inspection reports recorded yet.</div>';
    }
    final buffer = StringBuffer();
    buffer.writeln('<table><thead><tr>');
    buffer.writeln('<th>Report ID</th><th>Customer</th><th>Phone</th><th>Vehicle</th>');
    buffer.writeln('<th>Plate</th><th>Faults</th><th>Date</th><th>Action</th>');
    buffer.writeln('</tr></thead><tbody>');
    for (final r in reports) {
      final cardId = r.id.length >= 8 ? r.id.substring(0, 8) : r.id;
      final cName = r.customerName.isEmpty ? 'Walk-in Customer' : r.customerName;
      final cPhone = r.customerPhone.isEmpty ? '--' : r.customerPhone;
      final pNum = r.plateNumber.isEmpty ? '--' : r.plateNumber;
      final dtcColor = r.dtcCodes.isNotEmpty ? 'var(--red)' : 'var(--green)';
      final dtcText = '${r.dtcCodes.length} DTC(s)';
      final dateStr = r.timestamp.toString().length >= 16 ? r.timestamp.toString().substring(0, 16) : r.timestamp.toString();
      buffer.writeln('<tr>');
      buffer.writeln('<td style="font-family: monospace; font-weight: bold; color: var(--yellow);">$cardId</td>');
      buffer.writeln('<td style="font-weight: bold;">$cName</td>');
      buffer.writeln('<td>$cPhone</td>');
      buffer.writeln('<td>${r.vehicleModel}</td>');
      buffer.writeln('<td><span style="background: #252D3D; padding: 4px 8px; border-radius: 4px; font-weight: bold;">$pNum</span></td>');
      buffer.writeln('<td style="color: $dtcColor; font-weight: bold;">$dtcText</td>');
      buffer.writeln('<td style="color: var(--muted); font-size: 13px;">$dateStr</td>');
      buffer.writeln('<td><a href="/report/${r.id}" class="btn" target="_blank">View & Print 🖨️</a></td>');
      buffer.writeln('</tr>');
    }
    buffer.writeln('</tbody></table>');
    return buffer.toString();
  }

  /// Print single report HTML view
  Future<void> _serveSingleReportHtml(HttpRequest request, String id) async {
    final reports = await ReportRepository().getReports();
    if (reports.isEmpty) {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write("No inspection reports found");
      await request.response.close();
      return;
    }
    final report = reports.firstWhere((r) => r.id == id, orElse: () => reports.first);

    final dateStr = report.timestamp.toString().length >= 16 ? report.timestamp.toString().substring(0, 16) : report.timestamp.toString();
    final vinStr = report.vin.isEmpty ? 'Not Available' : report.vin;
    final custName = report.customerName.isEmpty ? 'Customer' : report.customerName;
    final custPhone = report.customerPhone.isEmpty ? '--' : report.customerPhone;
    final plateStr = report.plateNumber.isEmpty ? '--' : report.plateNumber;
    final voltStr = report.batteryVoltage.toStringAsFixed(1);
    final milText = report.milStatus ? 'ACTIVE (Check Engine ON)' : 'CLEAR (OFF)';
    final notesText = report.technicianNotes.isEmpty ? 'Standard diagnostic inspection completed without issues.' : report.technicianNotes;

    final html = '''
<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
  <meta charset="UTF-8">
  <title>Vehicle Inspection Job Card - ${report.vehicleModel}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 30px; direction: ltr; color: #111; }
    .header { text-align: center; border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 20px; }
    .header h1 { margin: 0; font-size: 24px; }
    .meta-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 20px; font-size: 15px; }
    .box { border: 1px solid #ccc; padding: 12px; border-radius: 6px; }
    .box-title { font-weight: bold; border-bottom: 1px solid #eee; padding-bottom: 5px; margin-bottom: 8px; color: #d32f2f; }
    .dtc-item { margin-bottom: 8px; padding-bottom: 6px; border-bottom: 1px dashed #ddd; }
    .print-btn { background: #d32f2f; color: #fff; border: none; padding: 10px 20px; font-size: 16px; border-radius: 6px; cursor: pointer; margin-bottom: 20px; }
    @media print { .print-btn { display: none; } }
  </style>
</head>
<body>
  <button class="print-btn" onclick="window.print()">Print Job Card (Print)</button>
  <div class="header">
    <h1>AutoSpect | Diagnostic Inspection Job Card</h1>
    <p>Inspection Date: $dateStr | Vehicle Identification Number (VIN): $vinStr</p>
  </div>

  <div class="meta-grid">
    <div class="box">
      <div class="box-title">Customer & Vehicle Data</div>
      <p><strong>Customer Name:</strong> $custName</p>
      <p><strong>Phone:</strong> $custPhone</p>
      <p><strong>Vehicle Model:</strong> ${report.vehicleModel}</p>
      <p><strong>License Plate:</strong> $plateStr</p>
    </div>
    <div class="box">
      <div class="box-title">Engine & Battery Status</div>
      <p><strong>Battery Voltage:</strong> $voltStr V</p>
      <p><strong>MIL Status:</strong> $milText</p>
      <p><strong>Logged Faults:</strong> ${report.dtcCodes.length} DTC(s)</p>
    </div>
  </div>

  <div class="box" style="margin-bottom: 20px;">
    <div class="box-title">Diagnostic Trouble Codes (DTCs)</div>
    ${_buildDtcListHtml(report.dtcCodes)}
  </div>

  <div class="box">
    <div class="box-title">Technician Notes & Recommendations</div>
    <p>$notesText</p>
  </div>
</body>
</html>
''';

    request.response.headers.contentType = ContentType.html;
    request.response.write(html);
    await request.response.close();
  }

  String _buildDtcListHtml(List<dynamic> dtcCodes) {
    if (dtcCodes.isEmpty) {
      return '<p style="color: green; font-weight: bold;">No trouble codes stored in ECU memory.</p>';
    }
    final buffer = StringBuffer();
    for (final c in dtcCodes) {
      buffer.writeln('<div class="dtc-item">');
      buffer.writeln('<strong style="color: #d32f2f;">[${c.code}]</strong>: ${c.title}');
      buffer.writeln('<br><small style="color: #555;"><strong>Multimeter Inspection Guide:</strong> ${c.workshopCheck}</small>');
      buffer.writeln('</div>');
    }
    return buffer.toString();
  }

  /// REST API: جلب الحالة اللحظية JSON
  Future<void> _handleApiStatus(HttpRequest request) async {
    final live = getLiveStatusCallback != null ? getLiveStatusCallback!() : <String, dynamic>{};
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(live));
    await request.response.close();
  }

  /// REST API: جلب قائمة التقارير JSON
  Future<void> _handleApiGetReports(HttpRequest request) async {
    final reports = await ReportRepository().getReports();
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(reports.map((r) => r.toJson()).toList()));
    await request.response.close();
  }

  /// REST API: استلام تقرير جديد ومزامنته من تابلت آخر
  Future<void> _handleApiPostReport(HttpRequest request) async {
    final content = await utf8.decoder.bind(request).join();
    try {
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;
      final report = InspectionReport.fromJson(jsonMap);

      await ReportRepository().saveReport(report);
      if (onReportReceived != null) {
        onReportReceived!(report);
      }

      request.response.statusCode = HttpStatus.created;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'success': true, 'id': report.id}));
      AppLogger().info("Synced report ${report.id} from LAN client");
    } catch (e) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(jsonEncode({'error': e.toString()}));
    }
    await request.response.close();
  }

  /// عميل المزامنة (LAN Client Sync): دفع تقرير إلى سيرفر رئيسي آخر
  static Future<bool> pushReportToMaster({
    required String masterIp,
    required InspectionReport report,
    int port = 8080,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.post(masterIp, port, '/api/reports');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(report.toJson()));
      final response = await request.close();
      client.close();
      return response.statusCode == HttpStatus.created || response.statusCode == HttpStatus.ok;
    } catch (e) {
      AppLogger().warning("Error pushing report to master $masterIp: $e");
      return false;
    }
  }
}
