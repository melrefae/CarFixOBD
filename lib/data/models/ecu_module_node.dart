import 'package:flutter/material.dart';

enum EcuModuleStatus {
  notScanned,
  scanning,
  healthy,
  faultPresent,
  notResponding,
}

enum CanBusType {
  ptCan500k,
  chassisCan500k,
  bodyCan125k,
  lin19k,
}

/// Model representing an individual electronic control unit node in the vehicle network topology
class EcuModuleNode {
  final String header;
  final String shortName;
  final String fullName;
  final String description;
  final IconData icon;
  final CanBusType busType;
  final String softwarePartNumber;
  final String hardwarePartNumber;
  final String codingHex;
  final String baudRate;
  EcuModuleStatus status;
  List<String> dtcs;
  String vin;
  String protocol;
  int responseLatencyMs;

  EcuModuleNode({
    required this.header,
    required this.shortName,
    required this.fullName,
    required this.description,
    required this.icon,
    this.busType = CanBusType.ptCan500k,
    this.softwarePartNumber = "03C 906 014 CF",
    this.hardwarePartNumber = "03C 907 309 J",
    this.codingHex = "0000072",
    this.baudRate = "500 kbps",
    this.status = EcuModuleStatus.notScanned,
    List<String>? dtcs,
    this.vin = "N/A",
    this.protocol = "CAN 11/500",
    this.responseLatencyMs = 0,
  }) : dtcs = dtcs ?? [];

  bool get isFaulted => dtcs.isNotEmpty || status == EcuModuleStatus.faultPresent;
  bool get isOnline => status == EcuModuleStatus.healthy || status == EcuModuleStatus.faultPresent;
  int get arbitrationId => int.tryParse(header.replaceAll("0x", ""), radix: 16) ?? 0;

  String get busNameEn {
    switch (busType) {
      case CanBusType.ptCan500k:
        return "Powertrain CAN (500 kbps)";
      case CanBusType.chassisCan500k:
        return "Chassis & Safety CAN (500 kbps)";
      case CanBusType.bodyCan125k:
        return "Body & Comfort CAN (125 kbps)";
      case CanBusType.lin19k:
        return "Sub-Bus LIN (19.2 kbps)";
    }
  }

  String get busNameAr {
    switch (busType) {
      case CanBusType.ptCan500k:
        return "شبكة المحرك وناقل الحركة CAN (500k)";
      case CanBusType.chassisCan500k:
        return "شبكة الشاسيه والأمان CAN (500k)";
      case CanBusType.bodyCan125k:
        return "شبكة الراحة والبودي CAN (125k)";
      case CanBusType.lin19k:
        return "الناقل الفرعي التابع LIN (19.2k)";
    }
  }

  Color get busColor {
    switch (busType) {
      case CanBusType.ptCan500k:
        return const Color(0xFFFF9800); // Amber / Orange
      case CanBusType.chassisCan500k:
        return const Color(0xFF00B0FF); // Electric Blue
      case CanBusType.bodyCan125k:
        return const Color(0xFF00E676); // Neon Green
      case CanBusType.lin19k:
        return const Color(0xFFD500F9); // Purple / Magenta
    }
  }

  static List<EcuModuleNode> getStandardCanTopology() {
    return [
      EcuModuleNode(
        header: "7E0",
        shortName: "ECM",
        fullName: "Engine Control Module (PCM)",
        description: "Controls ignition timing, electronic fuel injection, emissions, and throttle drive-by-wire.",
        icon: Icons.speed,
        busType: CanBusType.ptCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "03C 906 014 CF",
        hardwarePartNumber: "03C 907 309 J",
        codingHex: "0000072",
      ),
      EcuModuleNode(
        header: "7E1",
        shortName: "TCM",
        fullName: "Transmission Control Module",
        description: "Controls automatic gearbox, dual-clutch solenoids, shift schedules, and torque converter lockup.",
        icon: Icons.change_circle,
        busType: CanBusType.ptCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "0AM 300 048 M",
        hardwarePartNumber: "0AM 927 769 D",
        codingHex: "0000020",
      ),
      EcuModuleNode(
        header: "7E2",
        shortName: "ABS/ESP",
        fullName: "Anti-lock Brake & Stability System",
        description: "Manages hydraulic brake pressure modulation, traction control, and electronic stability program.",
        icon: Icons.pan_tool,
        busType: CanBusType.chassisCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "1K0 907 379 BE",
        hardwarePartNumber: "1K0 907 379 AD",
        codingHex: "113B200D092400FB880C04E5901A00413000",
      ),
      EcuModuleNode(
        header: "7E3",
        shortName: "SRS",
        fullName: "Supplemental Restraint System (Airbag)",
        description: "Monitors crash impact sensors, pyrotechnic belt tensioners, and steering/curtain airbags.",
        icon: Icons.security,
        busType: CanBusType.chassisCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "5N0 959 655 R",
        hardwarePartNumber: "5N0 959 655 J",
        codingHex: "0012338",
      ),
      EcuModuleNode(
        header: "7E4",
        shortName: "BCM",
        fullName: "Body Control Module & Cluster",
        description: "Controls central door locking, lighting, instrument dials, immobilizer key antenna, and power windows.",
        icon: Icons.dashboard,
        busType: CanBusType.bodyCan125k,
        baudRate: "125 kbps",
        softwarePartNumber: "1K0 937 087 Q",
        hardwarePartNumber: "1K0 937 087 K",
        codingHex: "40180A3B88251AC04008008034000124435500",
      ),
    ];
  }

  static List<EcuModuleNode> getExtendedNetworkTopology() {
    return [
      // --- Trunk 1: Powertrain CAN (500 kbps) ---
      EcuModuleNode(
        header: "7E0",
        shortName: "ECM",
        fullName: "Engine Control Module (PCM)",
        description: "Controls ignition timing, fuel injection, VVT, turbo boost, and emissions.",
        icon: Icons.speed,
        busType: CanBusType.ptCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "03C 906 014 CF",
        hardwarePartNumber: "03C 907 309 J",
        codingHex: "0000072",
      ),
      EcuModuleNode(
        header: "7E1",
        shortName: "TCM",
        fullName: "Transmission Control Module",
        description: "Controls automatic gearbox, dual-clutch mechatronics, and torque converter lockup.",
        icon: Icons.change_circle,
        busType: CanBusType.ptCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "0AM 300 048 M",
        hardwarePartNumber: "0AM 927 769 D",
        codingHex: "0000020",
      ),
      EcuModuleNode(
        header: "7E7",
        shortName: "AWD",
        fullName: "All-Wheel Drive / Transfer Coupling",
        description: "Controls multi-plate electromagnetic clutch torque distribution to rear differential.",
        icon: Icons.alt_route,
        busType: CanBusType.ptCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "0AY 907 554 J",
        hardwarePartNumber: "0AY 907 554 D",
        codingHex: "0000005",
      ),

      // --- Trunk 2: Chassis & Safety CAN (500 kbps) ---
      EcuModuleNode(
        header: "7E2",
        shortName: "ABS/ESP",
        fullName: "Anti-lock Brake & Stability System",
        description: "Hydraulic pressure valves, individual wheel speed sensors, and yaw/lateral acceleration.",
        icon: Icons.pan_tool,
        busType: CanBusType.chassisCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "1K0 907 379 BE",
        hardwarePartNumber: "1K0 907 379 AD",
        codingHex: "113B200D092400FB880C04E5901A00413000",
      ),
      EcuModuleNode(
        header: "7E5",
        shortName: "EPB",
        fullName: "Electronic Parking Brake",
        description: "Manages caliper electric motor actuators, emergency dynamic braking, and auto-hold.",
        icon: Icons.disc_full,
        busType: CanBusType.chassisCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "3C0 907 801 J",
        hardwarePartNumber: "3C0 907 801 E",
        codingHex: "0000010",
      ),
      EcuModuleNode(
        header: "7E6",
        shortName: "EPS",
        fullName: "Electronic Power Steering",
        description: "Torque sensor feedback, electric rack assist motor, and steering angle calibration.",
        icon: Icons.sports_motorsports,
        busType: CanBusType.chassisCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "1K0 909 144 J",
        hardwarePartNumber: "1K0 909 144 E",
        codingHex: "0000002",
      ),
      EcuModuleNode(
        header: "7E3",
        shortName: "SRS",
        fullName: "Supplemental Restraint System (Airbag)",
        description: "Crash front/side sensors, pyrotechnic belt tensioners, and passenger detection mat.",
        icon: Icons.security,
        busType: CanBusType.chassisCan500k,
        baudRate: "500 kbps",
        softwarePartNumber: "5N0 959 655 R",
        hardwarePartNumber: "5N0 959 655 J",
        codingHex: "0012338",
      ),

      // --- Trunk 3: Body & Comfort CAN (125 kbps) ---
      EcuModuleNode(
        header: "7E4",
        shortName: "BCM",
        fullName: "Body Control Module & Gateway",
        description: "Central door locks, exterior/interior lighting, immobilizer antenna, and gateway routing.",
        icon: Icons.dashboard,
        busType: CanBusType.bodyCan125k,
        baudRate: "125 kbps",
        softwarePartNumber: "1K0 937 087 Q",
        hardwarePartNumber: "1K0 937 087 K",
        codingHex: "40180A3B88251AC04008008034000124435500",
      ),
      EcuModuleNode(
        header: "7E8",
        shortName: "HVAC",
        fullName: "Climate Control & Air Conditioning",
        description: "A/C compressor clutch/solenoid, air flap stepper motors, blower speed, and evaporator temp.",
        icon: Icons.ac_unit,
        busType: CanBusType.bodyCan125k,
        baudRate: "125 kbps",
        softwarePartNumber: "5K0 907 044 EA",
        hardwarePartNumber: "5K0 907 044 BT",
        codingHex: "0000000002",
      ),
      EcuModuleNode(
        header: "7E9",
        shortName: "IC",
        fullName: "Instrument Cluster & Display",
        description: "Speedometer/tachometer stepper motors, fuel gauge, coolant indicator, and driver display.",
        icon: Icons.dialpad,
        busType: CanBusType.bodyCan125k,
        baudRate: "125 kbps",
        softwarePartNumber: "5K0 920 870 F",
        hardwarePartNumber: "5K0 920 870 C",
        codingHex: "110F00",
      ),
      EcuModuleNode(
        header: "7EA",
        shortName: "DDM",
        fullName: "Driver Door Module",
        description: "Power window pinch protection, electric folding mirror, blind spot indicator, and puddle lamp.",
        icon: Icons.sensor_door,
        busType: CanBusType.bodyCan125k,
        baudRate: "125 kbps",
        softwarePartNumber: "1K0 959 701 Q",
        hardwarePartNumber: "1K0 959 701 M",
        codingHex: "0000180",
      ),

      // --- Trunk 4: Sub-Bus LIN (19.2 kbps) ---
      EcuModuleNode(
        header: "LIN-1",
        shortName: "LIN-ALT",
        fullName: "Alternator Voltage Regulator (LIN)",
        description: "Smart charging communication, excitation voltage modulation, and battery current load.",
        icon: Icons.battery_charging_full,
        busType: CanBusType.lin19k,
        baudRate: "19.2 kbps",
        softwarePartNumber: "BOSCH-LIN2-014",
        hardwarePartNumber: "06F 903 023 F",
        codingHex: "01",
      ),
      EcuModuleNode(
        header: "LIN-2",
        shortName: "LIN-RLS",
        fullName: "Rain & Light Sensor (LIN)",
        description: "Infrared windshield moisture detection and ambient daylight photocell sensor.",
        icon: Icons.water_drop,
        busType: CanBusType.lin19k,
        baudRate: "19.2 kbps",
        softwarePartNumber: "1K0 955 559 AH",
        hardwarePartNumber: "1K0 955 559 M",
        codingHex: "0730ED",
      ),
      EcuModuleNode(
        header: "LIN-3",
        shortName: "LIN-SRF",
        fullName: "Sunroof & Shade Motor (LIN)",
        description: "Anti-pinch sliding tilt roof motor, one-touch position encoder, and convenience closure.",
        icon: Icons.window,
        busType: CanBusType.lin19k,
        baudRate: "19.2 kbps",
        softwarePartNumber: "1K6 959 591 E",
        hardwarePartNumber: "1K6 959 591 B",
        codingHex: "05",
      ),
    ];
  }
}
