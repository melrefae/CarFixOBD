import 'package:flutter/foundation.dart';

/// Supported OBD-II Hardware Adapter Brands & Chipset Architectures
enum AdapterBrand {
  vLinker,
  obdLink,
  veepeak,
  carista,
  viecar,
  uniCarScan,
  konnwei,
  nexas,
  genericElm327,
  unknown,
}

/// Rich profile metadata and tuning parameters for recognized OBD-II adapters
@immutable
class AdapterProfile {
  final AdapterBrand brand;
  final String displayName;
  final String chipset;
  final bool supportsCanFd;
  final bool supportsMsCan;
  final bool supportsSwCan;
  final int maxBaudRate;
  final int speedRating; // 1 to 5 stars
  final List<String> recommendedInitCommands;
  final String descriptionEn;
  final String descriptionAr;

  const AdapterProfile({
    required this.brand,
    required this.displayName,
    required this.chipset,
    this.supportsCanFd = false,
    this.supportsMsCan = false,
    this.supportsSwCan = false,
    required this.maxBaudRate,
    required this.speedRating,
    required this.recommendedInitCommands,
    required this.descriptionEn,
    required this.descriptionAr,
  });

  bool get highSpeedCapable => maxBaudRate >= 500000 || supportsCanFd || speedRating >= 4;
  String get chipsetFamily => chipset;

  /// Factory detection from Bluetooth advertised name or ELM version string
  static AdapterProfile detect(String? deviceName, {String? elmVersion}) {
    final name = (deviceName ?? "").toUpperCase().trim();
    final version = (elmVersion ?? "").toUpperCase().trim();

    // 1. vLinker series (MC+, FD+, FS, BM+, etc.)
    if (name.contains('VLINKER') ||
        name.contains('V-LINKER') ||
        name.contains('VGATE') && (name.contains('MC') || name.contains('FD') || name.contains('FS')) ||
        version.contains('STN2') ||
        version.contains('VLINKER')) {
      final isFd = name.contains('FD') || version.contains('FD');
      return AdapterProfile(
        brand: AdapterBrand.vLinker,
        displayName: isFd ? "vLinker FD+ (CAN-FD STN2255)" : "vLinker MC+ (STN2120 Pro)",
        chipset: isFd ? "STN2255 Dual-Core ARM" : "STN2120 32-bit ARM",
        supportsCanFd: isFd,
        supportsMsCan: true,
        supportsSwCan: true,
        maxBaudRate: 2000000,
        speedRating: 5,
        recommendedInitCommands: ["STP 33", "AT AT 2", "AT ST 32", "STCMM 1"],
        descriptionEn: "High-performance STN chip. Supports SW-CAN, MS-CAN, and rapid multi-frame UDS polling.",
        descriptionAr: "شريحة STN عالية السرعة تدعم شبكات الفورد والجي إم وبروتوكولات UDS المتقدمة.",
      );
    }

    // 2. OBDLink series (MX+, CX, LX, EX, SX)
    if (name.contains('OBDLINK') ||
        name.contains('SCANTOOL') ||
        version.contains('STN1') ||
        version.contains('OBDLINK')) {
      final isMx = name.contains('MX') || name.contains('CX');
      return AdapterProfile(
        brand: AdapterBrand.obdLink,
        displayName: isMx ? "OBDLink MX+ / CX (STN1170)" : "OBDLink LX / SX (STN1110)",
        chipset: "STN1170 Co-Processor",
        supportsCanFd: false,
        supportsMsCan: isMx,
        supportsSwCan: isMx,
        maxBaudRate: 2000000,
        speedRating: 5,
        recommendedInitCommands: ["STP 33", "AT AT 2", "AT ST 28"],
        descriptionEn: "Professional benchmark adapter with zero packet drops and BatterySaver sleep mode.",
        descriptionAr: "محول احترافي فائق الدقة بدون فقدان بيانات مع دعم وضع توفير البطارية الذكي.",
      );
    }

    // 3. Veepeak series (OBDCheck BLE, BLE+, Mini BT)
    if (name.contains('VEEPEAK') || name.contains('OBDCHECK')) {
      return const AdapterProfile(
        brand: AdapterBrand.veepeak,
        displayName: "Veepeak OBDCheck (BLE / Classic)",
        chipset: "Microchip PIC18F25K80 + BLE 5.0",
        supportsCanFd: false,
        supportsMsCan: false,
        supportsSwCan: false,
        maxBaudRate: 500000,
        speedRating: 4,
        recommendedInitCommands: ["AT AT 1", "AT ST 48"],
        descriptionEn: "Stable, reliable connection with low power consumption. Ideal for standard diagnostics.",
        descriptionAr: "محول مستقر وموثوق جداً باستهلاك طاقة منخفض ومناسب للفحص القياسي الشامل.",
      );
    }

    // 4. Carista series
    if (name.contains('CARISTA')) {
      return const AdapterProfile(
        brand: AdapterBrand.carista,
        displayName: "Carista OBD2 (BLE UART)",
        chipset: "Nordic nRF52832 ARM",
        supportsCanFd: false,
        supportsMsCan: true,
        supportsSwCan: false,
        maxBaudRate: 1000000,
        speedRating: 4,
        recommendedInitCommands: ["AT AT 1", "AT ST 40"],
        descriptionEn: "Custom BLE UART adapter tailored for VW/Audi and Toyota/Lexus dealer coding routines.",
        descriptionAr: "محول مخصص لتكويد وظائف مجموعة فاج (فولكس فاجن/أودي) وتويوتا بدون تأخير.",
      );
    }

    // 5. Viecar series
    if (name.contains('VIECAR') || name.contains('VIEFFCAR')) {
      return const AdapterProfile(
        brand: AdapterBrand.viecar,
        displayName: "Viecar 4.0 / VP004 (Dual-Mode)",
        chipset: "ARM Cortex-M3 + BT 4.0",
        supportsCanFd: false,
        supportsMsCan: false,
        supportsSwCan: false,
        maxBaudRate: 500000,
        speedRating: 4,
        recommendedInitCommands: ["AT AT 1", "AT ST 50"],
        descriptionEn: "Popular Egyptian workshop adapter. Solid throughput on CAN bus vehicles.",
        descriptionAr: "محول منتشر ومفضل في الورش المصرية بكفاءة ممتازة على شبكات الكان باص.",
      );
    }

    // 6. UniCarScan (BMW BimmerCode certified)
    if (name.contains('UNICARSCAN') || name.contains('UCSI')) {
      return const AdapterProfile(
        brand: AdapterBrand.uniCarScan,
        displayName: "UniCarScan UCSI-2000 / 2100",
        chipset: "STMicroelectronics ARM Cortex-M4",
        supportsCanFd: false,
        supportsMsCan: true,
        supportsSwCan: true,
        maxBaudRate: 1000000,
        speedRating: 5,
        recommendedInitCommands: ["AT AT 2", "AT ST 32"],
        descriptionEn: "Certified for German brand deep ECU coding (BMW, MINI, VAG).",
        descriptionAr: "معتمد للتكويدات العميقة للسيارات الألمانية كـ بي إم دبليو ومجموعة فولكس فاجن.",
      );
    }

    // 7. Konnwei series
    if (name.contains('KONNWEI') || name.contains('KW90')) {
      return const AdapterProfile(
        brand: AdapterBrand.konnwei,
        displayName: "Konnwei KW902 / KW903",
        chipset: "Microchip PIC18F25K80 Clone",
        supportsCanFd: false,
        supportsMsCan: false,
        supportsSwCan: false,
        maxBaudRate: 115200,
        speedRating: 3,
        recommendedInitCommands: ["AT AT 1", "AT ST 64"],
        descriptionEn: "Affordable ELM327 hardware clone with physical power switch.",
        descriptionAr: "محول اقتصادي مزود بمفتاح تشغيل يدوي للتحكم في استهلاك الكهرباء.",
      );
    }

    // 8. Nexas series
    if (name.contains('NEXAS') || name.contains('NEXLINK')) {
      return const AdapterProfile(
        brand: AdapterBrand.nexas,
        displayName: "Nexas NexLink Pro",
        chipset: "ARM Cortex-M0 Core",
        supportsCanFd: false,
        supportsMsCan: false,
        supportsSwCan: false,
        maxBaudRate: 500000,
        speedRating: 4,
        recommendedInitCommands: ["AT AT 1", "AT ST 48"],
        descriptionEn: "Fast connection handshake with wide European and Asian car coverage.",
        descriptionAr: "سرعة اتصال عالية وتغطية شاملة للسيارات الأوروبية والآسيوية.",
      );
    }

    // 9. Generic ELM327 / V-Gate / HH OBD
    final isObd = name.contains('OBD') || name.contains('ELM') || name.contains('SCAN') || name.contains('LINK') || name.contains('VGATE') || version.contains('ELM');
    if (isObd) {
      return const AdapterProfile(
        brand: AdapterBrand.genericElm327,
        displayName: "Generic ELM327 / V-Gate (OBD-II)",
        chipset: "PIC18F25K80 / Clone Microcontroller",
        supportsCanFd: false,
        supportsMsCan: false,
        supportsSwCan: false,
        maxBaudRate: 38400,
        speedRating: 3,
        recommendedInitCommands: ["AT AT 1", "AT ST 64"],
        descriptionEn: "Standard OBD-II ELM327 interface with basic baud rates.",
        descriptionAr: "محول ELM327 قياسي شائع متوافق مع كافة بروتوكولات الفحص الأساسية.",
      );
    }

    return const AdapterProfile(
      brand: AdapterBrand.unknown,
      displayName: "Unknown Bluetooth Device",
      chipset: "Standard Bluetooth Radio",
      supportsCanFd: false,
      supportsMsCan: false,
      supportsSwCan: false,
      maxBaudRate: 9600,
      speedRating: 1,
      recommendedInitCommands: [],
      descriptionEn: "Unrecognized non-OBD Bluetooth device.",
      descriptionAr: "جهاز بلوتوث عام غير معروف كقارئ أعطال.",
    );
  }

  /// Calculates an auto-connection suitability score (0-100+)
  static int scoreDevice({
    required String? name,
    required String address,
    bool isBonded = false,
    bool isRecentlyConnected = false,
    int? rssi,
  }) {
    if (name == null || name.trim().isEmpty) return 0;
    int score = 0;

    // Bonded devices are ready without pairing friction
    if (isBonded) score += 40;

    // Recently connected adapter gets highest workshop preference
    if (isRecentlyConnected) score += 35;

    final profile = detect(name);
    switch (profile.brand) {
      case AdapterBrand.vLinker:
      case AdapterBrand.obdLink:
      case AdapterBrand.uniCarScan:
        score += 30; // Premier professional chipsets
        break;
      case AdapterBrand.veepeak:
      case AdapterBrand.carista:
      case AdapterBrand.viecar:
      case AdapterBrand.nexas:
        score += 20; // High quality standard adapters
        break;
      case AdapterBrand.konnwei:
      case AdapterBrand.genericElm327:
        score += 10;
        break;
      case AdapterBrand.unknown:
        break;
    }

    // Additional boost if name explicitly includes OBD or ELM
    final upper = name.toUpperCase();
    if (upper.contains("OBD") || upper.contains("ELM") || upper.contains("LINK")) {
      score += 10;
    }

    // Signal strength bonus (RSSI e.g. -50 is better than -90)
    if (rssi != null && rssi > -70) {
      score += 5;
    }

    return score;
  }
}
