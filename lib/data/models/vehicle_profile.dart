/// Vehicle Profile representing a specific car model, its OBD protocol, and custom PIDs
class VehicleProfile {
  final String id;
  final String make;
  final String makeAr;
  final String model;
  final String years;
  final String engine;
  final String protocol;
  final String atProtocolCmd;
  final String transmission;
  final String notesAr;
  final String notesEn;
  final String region;
  final List<CustomPid> customPids;

  VehicleProfile({
    required this.id,
    required this.make,
    required this.makeAr,
    required this.model,
    required this.years,
    required this.engine,
    required this.protocol,
    required this.atProtocolCmd,
    required this.transmission,
    required this.notesAr,
    String? notesEn,
    required this.customPids,
    String? region,
  })  : notesEn = notesEn ?? (notesAr.contains(RegExp(r'[\u0600-\u06FF]')) ? make : notesAr),
        region = region ?? deriveRegion(make);

  String get name => "$make $model";

  /// Safe localized display name ensuring 0 Arabic in English mode
  String getDisplayName(bool isAr) {
    if (isAr) {
      final m = makeAr.isNotEmpty ? makeAr : make;
      return "$m $model";
    }
    final sanitizedModel = sanitizeEnglish(model);
    return "$make $sanitizedModel";
  }

  /// Safe localized workshop notes ensuring 0 Arabic in English mode
  String getDisplayNotes(bool isAr) {
    if (isAr) {
      return notesAr.isNotEmpty ? notesAr : notesEn;
    }
    final rawNotes = notesEn.isNotEmpty ? notesEn : "Standard OBD-II compliant vehicle.";
    return sanitizeEnglish(rawNotes);
  }

  static String sanitizeEnglish(String text) {
    String cleaned = text.replaceAll(RegExp(r'\s*\([\u0600-\u06FF\s\/0-9\-\.]+\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'[\u0600-\u06FF]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+/\s*$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\(\s+'), '(');
    cleaned = cleaned.replaceAll(RegExp(r'\s+\)'), ')');
    cleaned = cleaned.replaceAll(RegExp(r'\(\s*\)'), '');
    return cleaned.trim();
  }

  String get year => years;

  static String deriveRegion(String make) {
    final m = make.toLowerCase();
    if (m.contains("king long") ||
        m.contains("golden dragon") ||
        m.contains("jumbo") ||
        m.contains("canter") ||
        m.contains("fuso") ||
        m.contains("iveco") ||
        m.contains("hino") ||
        m.contains("foton") ||
        m.contains("isuzu commercial") ||
        m.contains("yutong") ||
        m.contains("higer") ||
        m.contains("sinotruk") ||
        m.contains("shacman") ||
        m.contains("man") ||
        m.contains("scania") ||
        m.contains("daf")) {
      return "Commercial";
    }
    if (m.contains("chery") ||
        m.contains("geely") ||
        m.contains("byd") ||
        m.contains("mg") ||
        m.contains("jetour") ||
        m.contains("haval") ||
        m.contains("changan") ||
        m.contains("baic") ||
        m.contains("jac") ||
        m.contains("dongfeng") ||
        m.contains("soueast") ||
        m.contains("zotye") ||
        m.contains("lifan") ||
        m.contains("great wall") ||
        m.contains("speranza") ||
        m.contains("brilliance") ||
        m.contains("wuling") ||
        m.contains("baojun") ||
        m.contains("gac") ||
        m.contains("hongqi") ||
        m.contains("zeekr") ||
        m.contains("lynk") ||
        m.contains("omoda") ||
        m.contains("jaecoo") ||
        m.contains("exeed") ||
        m.contains("deepal") ||
        m.contains("avatr") ||
        m.contains("xpeng") ||
        m.contains("nio") ||
        m.contains("li auto")) {
      return "Chinese";
    }
    if (m.contains("mercedes") ||
        m.contains("bmw") ||
        m.contains("audi") ||
        m.contains("volkswagen") ||
        m.contains("skoda") ||
        m.contains("seat") ||
        m.contains("renault") ||
        m.contains("peugeot") ||
        m.contains("citroen") ||
        m.contains("fiat") ||
        m.contains("opel") ||
        m.contains("volvo") ||
        m.contains("land rover") ||
        m.contains("jaguar") ||
        m.contains("porsche") ||
        m.contains("alfa") ||
        m.contains("mini") ||
        m.contains("dacia") ||
        m.contains("cupra") ||
        m.contains("lancia") ||
        m.contains("smart") ||
        m.contains("saab") ||
        m.contains("bentley") ||
        m.contains("rolls-royce") ||
        m.contains("ferrari") ||
        m.contains("maserati") ||
        m.contains("aston martin")) {
      return "European";
    }
    if (m.contains("ford") ||
        m.contains("jeep") ||
        m.contains("dodge") ||
        m.contains("chrysler") ||
        m.contains("gmc") ||
        m.contains("cadillac") ||
        m.contains("ram") ||
        m.contains("lincoln") ||
        m.contains("chevrolet") ||
        m.contains("tesla") ||
        m.contains("rivian") ||
        m.contains("buick")) {
      return "American";
    }
    return "Asian";
  }

  factory VehicleProfile.fromJson(Map<String, dynamic> json) {
    final makeStr = json['make'] ?? '';
    return VehicleProfile(
      id: json['id'] ?? '',
      make: makeStr,
      makeAr: json['make_ar'] ?? '',
      model: json['model'] ?? '',
      years: json['years'] ?? '',
      engine: json['engine'] ?? '',
      protocol: json['protocol'] ?? 'ISO 15765-4 (CAN 11/500)',
      atProtocolCmd: json['at_protocol_cmd'] ?? 'AT SP 0',
      transmission: json['transmission'] ?? '',
      notesAr: json['notes_ar'] ?? '',
      notesEn: json['notes_en'] ?? json['notes_ar'] ?? '',
      region: json['region'] ?? deriveRegion(makeStr),
      customPids: (json['custom_pids'] as List<dynamic>?)
              ?.map((item) => CustomPid.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'make_ar': makeAr,
      'model': model,
      'years': years,
      'engine': engine,
      'protocol': protocol,
      'at_protocol_cmd': atProtocolCmd,
      'transmission': transmission,
      'notes_ar': notesAr,
      'notes_en': notesEn,
      'region': region,
      'custom_pids': customPids.map((p) => p.toJson()).toList(),
    };
  }
}

/// Custom PID definition for manufacturer specific diagnostic sensors
class CustomPid {
  final String name;
  final String nameEn;
  final String mode;
  final String pid;
  final String formula;
  final String unit;
  final double min;
  final double max;

  CustomPid({
    required this.name,
    required this.nameEn,
    required this.mode,
    required this.pid,
    required this.formula,
    required this.unit,
    required this.min,
    required this.max,
  });

  factory CustomPid.fromJson(Map<String, dynamic> json) {
    return CustomPid(
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? json['name'] ?? '',
      mode: json['mode'] ?? '21',
      pid: json['pid'] ?? '',
      formula: json['formula'] ?? 'A',
      unit: json['unit'] ?? '',
      min: (json['min'] as num?)?.toDouble() ?? 0.0,
      max: (json['max'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_en': nameEn,
      'mode': mode,
      'pid': pid,
      'formula': formula,
      'unit': unit,
      'min': min,
      'max': max,
    };
  }

  /// Safe localized display name ensuring 0 Arabic in English mode
  String getDisplayName(bool isAr) {
    if (isAr) {
      return name.isNotEmpty ? name : nameEn;
    }
    return nameEn.isNotEmpty ? nameEn : (name.contains(RegExp(r'[\u0600-\u06FF]')) ? "Custom PID $pid" : name);
  }
}
