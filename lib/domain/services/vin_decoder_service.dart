import '../../core/utils/hex_parser.dart';

/// Decoded vehicle identity extracted from ISO 3779 VIN or UDS/Mode 09 ECU fingerprinting
class DecodedVehicleInfo {
  final String vin;
  final bool isValidVin;
  final String make;
  final String modelHint;
  final int? year;
  final String country;
  final String region;
  final String detectionSource;
  final String? suggestedProtocolCmd;
  final double confidence;

  const DecodedVehicleInfo({
    required this.vin,
    required this.isValidVin,
    required this.make,
    required this.modelHint,
    required this.year,
    required this.country,
    required this.region,
    required this.detectionSource,
    this.suggestedProtocolCmd,
    this.confidence = 0.0,
  });

  String get displaySummary {
    final yr = year != null ? '$year ' : '';
    final mod = modelHint.isNotEmpty ? ' $modelHint' : '';
    return '$yr$make$mod'.trim();
  }
}

class _WmiInfo {
  final String make;
  final String country;
  final String region;
  final String? modelHint;

  const _WmiInfo(this.make, this.country, this.region, [this.modelHint]);
}

/// Offline ISO 3779 VIN & ECU Fingerprint decoder covering 200+ global WMIs & Egyptian CKD vehicles
class VinDecoderService {
  static final RegExp _vinFormatRegex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

  static const Map<String, int> _transliteration = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
    'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
    '0': 0, '1': 1, '2': 2, '3': 3, '4': 4,
    '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
  };

  static const List<int> _weights = [
    8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2,
  ];

  // ISO 3779 Year Character Table (30-year cycle: A-Y, 1-9 excluding I,O,Q,U,Z,0)
  static const String _yearCycle = 'ABCDEFGHJKLMNPRSTVWXY123456789';

  // Comprehensive WMI (3-char World Manufacturer Identifier) Lookup Table
  static const Map<String, _WmiInfo> _wmiTable = {
    // --- Nissan / Infiniti ---
    'JN1': _WmiInfo('Nissan', 'Japan', 'Asian'),
    'JN3': _WmiInfo('Nissan', 'Japan', 'Asian'),
    'JN6': _WmiInfo('Nissan', 'Japan', 'Asian'),
    'JN8': _WmiInfo('Nissan', 'Japan', 'Asian'),
    'JNK': _WmiInfo('Infiniti', 'Japan', 'Asian'),
    '1N4': _WmiInfo('Nissan', 'USA', 'Asian'),
    '1N6': _WmiInfo('Nissan', 'USA', 'Asian'),
    '3N1': _WmiInfo('Nissan', 'Mexico', 'Asian', 'Sunny / Sentra'),
    '3N6': _WmiInfo('Nissan', 'Mexico', 'Asian'),
    '5N1': _WmiInfo('Nissan', 'USA', 'Asian'),
    'SJN': _WmiInfo('Nissan', 'UK', 'Asian', 'Qashqai / Juke'),
    'VSK': _WmiInfo('Nissan', 'Spain', 'Asian'),
    'MDH': _WmiInfo('Nissan', 'India', 'Asian', 'Sunny N17'),
    'NMA': _WmiInfo('Nissan', 'Egypt CKD', 'Asian', 'Sunny N17'),
    'DAN': _WmiInfo('Nissan', 'Egypt CKD', 'Asian', 'Sunny'),

    // --- Toyota / Lexus ---
    'JTD': _WmiInfo('Toyota', 'Japan', 'Asian'),
    'JTE': _WmiInfo('Toyota', 'Japan', 'Asian'),
    'JTF': _WmiInfo('Toyota', 'Japan', 'Asian', 'HiAce'),
    'JTG': _WmiInfo('Toyota', 'Japan', 'Asian'),
    'JTH': _WmiInfo('Lexus', 'Japan', 'Asian'),
    'JTJ': _WmiInfo('Lexus', 'Japan', 'Asian'),
    'JTK': _WmiInfo('Toyota', 'Japan', 'Asian'),
    'JTM': _WmiInfo('Toyota', 'Japan', 'Asian', 'RAV4'),
    'JTN': _WmiInfo('Toyota', 'Japan', 'Asian', 'Corolla'),
    'JT1': _WmiInfo('Toyota', 'Japan', 'Asian'),
    'JT2': _WmiInfo('Toyota', 'Japan', 'Asian'),
    'NMT': _WmiInfo('Toyota', 'Turkey', 'Asian', 'Corolla'),
    'SB1': _WmiInfo('Toyota', 'UK', 'Asian', 'Corolla / Avensis'),
    'MR0': _WmiInfo('Toyota', 'Thailand', 'Asian', 'Hilux / Fortuner'),
    'MHF': _WmiInfo('Toyota', 'Indonesia', 'Asian', 'Fortuner / Rush'),
    'MBJ': _WmiInfo('Toyota', 'India', 'Asian'),
    'AHT': _WmiInfo('Toyota', 'South Africa', 'Asian', 'Hilux / Fortuner'),
    '2T1': _WmiInfo('Toyota', 'Canada', 'Asian', 'Corolla'),
    '4T1': _WmiInfo('Toyota', 'USA', 'Asian', 'Camry'),
    '5TD': _WmiInfo('Toyota', 'USA', 'Asian'),
    '5YF': _WmiInfo('Toyota', 'USA', 'Asian', 'Corolla'),

    // --- Hyundai / Kia / Genesis / Daewoo ---
    'KMH': _WmiInfo('Hyundai', 'South Korea', 'Asian'),
    'KM8': _WmiInfo('Hyundai', 'South Korea', 'Asian', 'Tucson / Santa Fe'),
    'KMF': _WmiInfo('Hyundai', 'South Korea', 'Asian'),
    'KMJ': _WmiInfo('Hyundai', 'South Korea', 'Asian'),
    'KMT': _WmiInfo('Genesis', 'South Korea', 'Asian'),
    '5NP': _WmiInfo('Hyundai', 'USA', 'Asian', 'Elantra / Sonata'),
    '5NM': _WmiInfo('Hyundai', 'USA', 'Asian', 'Tucson / Santa Fe'),
    'NLH': _WmiInfo('Hyundai', 'Turkey', 'Asian', 'i20 / Accent'),
    'TMA': _WmiInfo('Hyundai', 'Czech Republic', 'Asian', 'Tucson / i30'),
    'MAL': _WmiInfo('Hyundai', 'India', 'Asian', 'i10 / Grand i10 / Accent'),
    'Z94': _WmiInfo('Hyundai', 'CIS / CKD', 'Asian', 'Accent / Solaris'),
    'KNA': _WmiInfo('Kia', 'South Korea', 'Asian'),
    'KNB': _WmiInfo('Kia', 'South Korea', 'Asian'),
    'KNC': _WmiInfo('Kia', 'South Korea', 'Asian'),
    'KND': _WmiInfo('Kia', 'South Korea', 'Asian', 'Sportage / Sorento'),
    'KNE': _WmiInfo('Kia', 'South Korea', 'Asian'),
    'U5Y': _WmiInfo('Kia', 'Slovakia', 'Asian', 'Sportage / Ceed'),
    'U6Y': _WmiInfo('Kia', 'Slovakia', 'Asian', 'Sportage'),
    '3KP': _WmiInfo('Kia', 'Mexico', 'Asian', 'Cerato / Forte / Rio'),
    '5XX': _WmiInfo('Kia', 'USA', 'Asian'),
    'KPT': _WmiInfo('SsangYong', 'South Korea', 'Asian'),
    'KLA': _WmiInfo('Daewoo', 'South Korea', 'Asian', 'Nubira / Lanos'),
    'KL1': _WmiInfo('Chevrolet', 'South Korea (GM Korea)', 'American', 'Aveo / Lanos / Optra'),
    'KL3': _WmiInfo('Chevrolet', 'South Korea (GM Korea)', 'American', 'Captiva'),
    'KL4': _WmiInfo('Chevrolet', 'South Korea (GM Korea)', 'American', 'Trax'),
    'KL7': _WmiInfo('Chevrolet', 'South Korea (GM Korea)', 'American', 'Spark'),
    'KL8': _WmiInfo('Chevrolet', 'South Korea (GM Korea)', 'American', 'Spark'),
    'XUF': _WmiInfo('Chevrolet', 'GM CKD', 'American', 'Cruze / Lanos'),

    // --- Honda / Mitsubishi / Mazda / Suzuki / Subaru / Isuzu ---
    'JHM': _WmiInfo('Honda', 'Japan', 'Asian', 'Civic / Accord'),
    'JHL': _WmiInfo('Honda', 'Japan', 'Asian', 'CR-V'),
    '1HG': _WmiInfo('Honda', 'USA', 'Asian', 'Accord / Civic'),
    '2HG': _WmiInfo('Honda', 'Canada', 'Asian', 'Civic'),
    'SHH': _WmiInfo('Honda', 'UK', 'Asian', 'Civic'),
    'SHS': _WmiInfo('Honda', 'UK', 'Asian', 'CR-V'),
    'MRH': _WmiInfo('Honda', 'Thailand', 'Asian'),
    'JA3': _WmiInfo('Mitsubishi', 'Japan', 'Asian', 'Lancer'),
    'JA4': _WmiInfo('Mitsubishi', 'Japan', 'Asian', 'Outlander / Eclipse Cross'),
    'JA7': _WmiInfo('Mitsubishi', 'Japan', 'Asian'),
    'JMB': _WmiInfo('Mitsubishi', 'Japan', 'Asian', 'Lancer'),
    'MMB': _WmiInfo('Mitsubishi', 'Thailand', 'Asian', 'Attrage / Mirage / L200'),
    'MMT': _WmiInfo('Mitsubishi', 'Thailand', 'Asian', 'Attrage / Pajero Sport'),
    'MK2': _WmiInfo('Mitsubishi', 'Indonesia', 'Asian', 'Xpander'),
    'JM1': _WmiInfo('Mazda', 'Japan', 'Asian'),
    'JMZ': _WmiInfo('Mazda', 'Japan', 'Asian'),
    'JM6': _WmiInfo('Mazda', 'Japan', 'Asian'),
    '3MZ': _WmiInfo('Mazda', 'Mexico', 'Asian', 'Mazda 3'),
    'JS2': _WmiInfo('Suzuki', 'Japan', 'Asian', 'Swift / Ciaz'),
    'JS3': _WmiInfo('Suzuki', 'Japan', 'Asian', 'Vitara'),
    'TSM': _WmiInfo('Suzuki', 'Hungary', 'Asian', 'Vitara / S-Cross'),
    'MA3': _WmiInfo('Suzuki', 'India', 'Asian', 'Swift / Dzire / Alto'),
    'MBH': _WmiInfo('Suzuki', 'India', 'Asian', 'Ertiga / Ciaz / Baleno'),
    'JF1': _WmiInfo('Subaru', 'Japan', 'Asian'),
    'JF2': _WmiInfo('Subaru', 'Japan', 'Asian'),
    'JAA': _WmiInfo('Isuzu', 'Japan', 'Commercial'),
    'JAB': _WmiInfo('Isuzu', 'Japan', 'Commercial'),
    'JAC': _WmiInfo('Isuzu', 'Japan', 'Commercial'),
    'JAL': _WmiInfo('Isuzu', 'Japan', 'Commercial', 'NPR / Jumbo'),
    'MP1': _WmiInfo('Isuzu', 'Thailand', 'Commercial', 'D-Max'),

    // --- European (VAG, BMW, Mercedes, Stellantis, Renault, Opel) ---
    'WDB': _WmiInfo('Mercedes-Benz', 'Germany', 'European'),
    'WDD': _WmiInfo('Mercedes-Benz', 'Germany', 'European', 'C-Class / E-Class'),
    'WDC': _WmiInfo('Mercedes-Benz', 'Germany', 'European'),
    'WDF': _WmiInfo('Mercedes-Benz', 'Germany', 'European', 'Vito / Sprinter'),
    'W1K': _WmiInfo('Mercedes-Benz', 'Germany', 'European', 'C-Class / CLA / A-Class'),
    'W1N': _WmiInfo('Mercedes-Benz', 'Germany', 'European', 'GLC / GLA'),
    '4JG': _WmiInfo('Mercedes-Benz', 'USA', 'European'),
    'WBA': _WmiInfo('BMW', 'Germany', 'European', '3 Series / 5 Series'),
    'WBS': _WmiInfo('BMW', 'Germany', 'European', 'M Series'),
    'WBX': _WmiInfo('BMW', 'Germany', 'European', 'X Series'),
    'WBY': _WmiInfo('BMW', 'Germany', 'European', 'BMW i'),
    '5UX': _WmiInfo('BMW', 'USA', 'European', 'X3 / X5'),
    'WMW': _WmiInfo('Mini', 'UK', 'European'),
    'WAU': _WmiInfo('Audi', 'Germany', 'European', 'A3 / A4 / A6'),
    'WA1': _WmiInfo('Audi', 'Germany', 'European', 'Q3 / Q5 / Q7'),
    'WUA': _WmiInfo('Audi', 'Germany', 'European'),
    'WVW': _WmiInfo('Volkswagen', 'Germany', 'European', 'Golf / Passat'),
    'WVG': _WmiInfo('Volkswagen', 'Germany', 'European', 'Tiguan / Touareg'),
    'WV1': _WmiInfo('Volkswagen', 'Germany', 'European'),
    'WV2': _WmiInfo('Volkswagen', 'Germany', 'European'),
    '1VW': _WmiInfo('Volkswagen', 'USA', 'European', 'Passat'),
    '3VW': _WmiInfo('Volkswagen', 'Mexico', 'European', 'Jetta / Golf'),
    'WP0': _WmiInfo('Porsche', 'Germany', 'European'),
    'WP1': _WmiInfo('Porsche', 'Germany', 'European', 'Cayenne / Macan'),
    'TMB': _WmiInfo('Skoda', 'Czech Republic', 'European', 'Octavia / Superb / Kodiaq'),
    'VSS': _WmiInfo('Seat', 'Spain', 'European', 'Leon / Ibiza / Ateca'),
    'W0L': _WmiInfo('Opel', 'Germany', 'European', 'Astra / Vectra / Corsa'),
    'W0V': _WmiInfo('Opel', 'Germany', 'European', 'Astra / Insignia / Crossland'),
    'VXK': _WmiInfo('Opel', 'France (Stellantis)', 'European', 'Corsa / Mokka'),
    'VF3': _WmiInfo('Peugeot', 'France', 'European', '301 / 508 / 3008'),
    'VF7': _WmiInfo('Citroën', 'France', 'European', 'C-Elysee / C4 / C5'),
    'VR3': _WmiInfo('Peugeot', 'France', 'European'),
    'VR7': _WmiInfo('Citroën', 'France', 'European'),
    'VF1': _WmiInfo('Renault', 'France', 'European', 'Megane / Fluence / Kadjar'),
    'UU1': _WmiInfo('Renault', 'Romania (Dacia)', 'European', 'Logan / Sandero / Duster'),
    'KNM': _WmiInfo('Renault', 'South Korea', 'European'),
    'ZFA': _WmiInfo('Fiat', 'Italy', 'European', 'Tipo / Punto / 500'),
    'NM4': _WmiInfo('Fiat', 'Turkey (Tofas)', 'European', 'Tipo / Doblo'),
    'ZAR': _WmiInfo('Alfa Romeo', 'Italy', 'European'),
    'YV1': _WmiInfo('Volvo', 'Sweden', 'European'),
    'YV4': _WmiInfo('Volvo', 'Sweden', 'European', 'XC60 / XC90'),
    'SAL': _WmiInfo('Land Rover', 'UK', 'European'),
    'SAJ': _WmiInfo('Jaguar', 'UK', 'European'),
    'XTA': _WmiInfo('Lada', 'Russia', 'European', 'Granta / Vesta / Largus'),

    // --- American ---
    '1FA': _WmiInfo('Ford', 'USA', 'American'),
    '1FM': _WmiInfo('Ford', 'USA', 'American'),
    '1FT': _WmiInfo('Ford', 'USA', 'American'),
    '3FA': _WmiInfo('Ford', 'Mexico', 'American', 'Fusion'),
    'WF0': _WmiInfo('Ford', 'Germany', 'American', 'Focus / Fiesta / EcoSport'),
    'NM0': _WmiInfo('Ford', 'Turkey', 'American'),
    '1G1': _WmiInfo('Chevrolet', 'USA', 'American', 'Cruze / Malibu'),
    '1GC': _WmiInfo('Chevrolet', 'USA', 'American'),
    '2G1': _WmiInfo('Chevrolet', 'Canada', 'American'),
    '3G1': _WmiInfo('Chevrolet', 'Mexico', 'American'),
    '1GT': _WmiInfo('GMC', 'USA', 'American'),
    '1G6': _WmiInfo('Cadillac', 'USA', 'American'),
    '1C3': _WmiInfo('Chrysler', 'USA', 'American'),
    '1C4': _WmiInfo('Jeep', 'USA', 'American', 'Grand Cherokee / Wrangler'),
    '1J4': _WmiInfo('Jeep', 'USA', 'American'),
    'ZAC': _WmiInfo('Jeep', 'Italy', 'American', 'Renegade / Compass'),
    '2C3': _WmiInfo('Dodge', 'Canada', 'American'),
    '5YJ': _WmiInfo('Tesla', 'USA', 'American', 'Model S / Model 3'),
    '7SA': _WmiInfo('Tesla', 'USA', 'American', 'Model X / Model Y'),
    'LRW': _WmiInfo('Tesla', 'China', 'American', 'Model 3 / Model Y'),

    // --- Chinese (Huge Egyptian & MENA Fleet) ---
    'LVV': _WmiInfo('Chery', 'China', 'Chinese', 'Tiggo / Arrizo 5'),
    'LNN': _WmiInfo('Chery', 'China', 'Chinese'),
    'L6T': _WmiInfo('Geely', 'China', 'Chinese', 'Emgrand 7 / Coolray'),
    'LB3': _WmiInfo('Geely', 'China', 'Chinese', 'Emgrand / Coolray'),
    'LC0': _WmiInfo('BYD', 'China', 'Chinese', 'F3 / L3 / Song / Dolphin'),
    'LGX': _WmiInfo('BYD', 'China', 'Chinese', 'F3 / Atto 3 / Seal'),
    'LSJ': _WmiInfo('MG', 'China (SAIC)', 'Chinese', 'MG 5 / MG ZS / MG HS'),
    'LSG': _WmiInfo('Chevrolet', 'China (SAIC-GM)', 'Chinese', 'Sail / Captiva'),
    'LZW': _WmiInfo('Chevrolet', 'China (SGMW)', 'Chinese', 'Optra (New Shape Baojun 630)'),
    'LGW': _WmiInfo('Haval', 'China (Great Wall)', 'Chinese', 'H6 / Jolion'),
    'LS4': _WmiInfo('Changan', 'China', 'Chinese', 'Alsvin / CS35 / CS55'),
    'LS5': _WmiInfo('Changan', 'China', 'Chinese', 'CS35 / CS55 / UNI-T'),
    'LNB': _WmiInfo('Baic', 'China', 'Chinese', 'X3 / X5 / X7'),
    'LJ1': _WmiInfo('JAC', 'China', 'Chinese', 'J7 / JS3 / JS4'),
    'LGA': _WmiInfo('Dongfeng', 'China', 'Chinese'),
    'LGB': _WmiInfo('Dongfeng', 'China', 'Chinese', 'Aeolus'),
    'LDN': _WmiInfo('Soueast', 'China', 'Chinese', 'DX3 / DX7'),
    'LSY': _WmiInfo('Brilliance', 'China', 'Chinese', 'V5 / V6 / FSV'),
    'LVB': _WmiInfo('Foton', 'China', 'Commercial', 'View CS2 / Tunland'),
    'LFV': _WmiInfo('Volkswagen', 'China (FAW-VW)', 'Chinese'),
    'LMG': _WmiInfo('GAC', 'China', 'Chinese', 'GS3 / GS4 / Empow'),
    'LFP': _WmiInfo('FAW', 'China', 'Chinese', 'Besturn'),
    'LA6': _WmiInfo('King Long', 'China', 'Commercial', 'Microbus'),
    'L69': _WmiInfo('Golden Dragon', 'China', 'Commercial', 'Microbus'),
    'LZZ': _WmiInfo('Sinotruk HOWO', 'China', 'Commercial'),
  };

  /// Clean and validate VIN formatting
  static String normalizeVin(String rawVin) {
    return rawVin.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '').trim();
  }

  /// Validate ISO 3779 check digit (character 9, mandatory in North America & common globally)
  static bool validateCheckDigit(String vin) {
    final clean = normalizeVin(vin);
    if (!_vinFormatRegex.hasMatch(clean)) return false;

    int sum = 0;
    for (int i = 0; i < 17; i++) {
      final val = _transliteration[clean[i]];
      if (val == null) return false;
      sum += val * _weights[i];
    }
    final remainder = sum % 11;
    final expected = remainder == 10 ? 'X' : remainder.toString();
    return clean[8] == expected;
  }

  /// Decode Year Character (VIN pos 10, 0-based index 9) using ISO 3779 30-year rollover disambiguation
  static int? decodeModelYear(String vin, {String activeProtocol = ''}) {
    final clean = normalizeVin(vin);
    if (clean.length < 10) return null;

    final ch = clean[9];
    final idx = _yearCycle.indexOf(ch);
    if (idx == -1) return null;

    // Year table starts at 1980 (`A`) and wraps every 30 years (`A`=1980 or 2010)
    final baseYear = 1980 + idx; // 1980..2009
    final modernYear = baseYear + 30; // 2010..2039

    // Standard ISO 3779 rule: if position 7 (index 6) is alphabetic, model year >= 2010
    final bool pos7Alpha = clean.length >= 7 && RegExp(r'^[A-Z]$').hasMatch(clean[6]);
    final protoUpper = activeProtocol.toUpperCase();
    final bool isCanEra = protoUpper.contains('CAN') || protoUpper.contains('15765');

    if (pos7Alpha && modernYear <= 2030) {
      return modernYear;
    }

    // Characters `1..9`: 2001..2009 vs 2031..2039 -> all current cars 1..9 are 2001..2009
    if (RegExp(r'^[1-9]$').hasMatch(ch)) {
      return baseYear; // 2001..2009
    }

    // Characters `A..Y` without pos7 alpha: disambiguate 1980..2000 vs 2010..2030
    // Pre-1996 didn't have OBD-II; post-2008 CAN heavily implies 2010..2030
    if (isCanEra && modernYear <= 2030) {
      return modernYear;
    }
    // `A..T` (2010..2026) vs `L..Y` (1990..2000) -> OBD-II era overwhelmingly >= 2010 if <= 2028
    if (modernYear <= 2028) {
      return modernYear;
    }
    return baseYear;
  }

  /// Decode full vehicle details from a 17-character VIN (+ optional active ELM protocol)
  static DecodedVehicleInfo? decodeVin(
    String rawVin, {
    String activeProtocol = '',
    String source = 'Mode 09 PID 02 (VIN)',
  }) {
    final vin = normalizeVin(rawVin);
    if (!_vinFormatRegex.hasMatch(vin)) return null;

    final wmi = vin.substring(0, 3);
    final wmiInfo = _wmiTable[wmi] ?? _fallbackRegionFromFirstChar(vin[0]);
    if (wmiInfo == null) return null;

    final year = decodeModelYear(vin, activeProtocol: activeProtocol);
    final vdsHint = _inferVdsModelHint(vin, wmiInfo.make, year);
    final modelHint = vdsHint ?? wmiInfo.modelHint ?? '';
    final protocolCmd = _inferSuggestedProtocol(year, activeProtocol);

    return DecodedVehicleInfo(
      vin: vin,
      isValidVin: validateCheckDigit(vin) || _wmiTable.containsKey(wmi),
      make: wmiInfo.make,
      modelHint: modelHint,
      year: year,
      country: wmiInfo.country,
      region: wmiInfo.region,
      detectionSource: source,
      suggestedProtocolCmd: protocolCmd,
      confidence: _wmiTable.containsKey(wmi) ? (modelHint.isNotEmpty ? 0.95 : 0.85) : 0.6,
    );
  }

  /// Fallback ECU Fingerprinting when Mode 09 02 / UDS F190 VIN is unavailable (common on K-Line/older cars)
  static DecodedVehicleInfo? decodeFromEcuFingerprint({
    String? calId,
    String? ecuName,
    String? oemPartNumber,
    String? raw0902,
    String activeProtocol = '',
  }) {
    final fingerprint = '${calId ?? ''} ${ecuName ?? ''} ${oemPartNumber ?? ''} ${raw0902 ?? ''}'.toUpperCase();
    final cleanFp = fingerprint.trim();
    if (cleanFp.isEmpty) return null;

    // 1. Check if raw0902 contains a partial or slightly non-standard 17-char VIN
    if (raw0902 != null && raw0902.length >= 15) {
      final direct = decodeVin(raw0902, activeProtocol: activeProtocol, source: 'Mode 09 VIN Match');
      if (direct != null) return direct;
    }

    // 2. Nissan / Infiniti part/CALID patterns (e.g., 23710-1KA0A, MEC, HITACHI)
    if (RegExp(r'23710|23703|1KA0|3RC0|3WX|NISSAN|HITACHI.*MEC').hasMatch(cleanFp)) {
      String hint = 'Sunny / Sentra';
      if (cleanFp.contains('1KA')) hint = 'Sunny N17 / Juke';
      return DecodedVehicleInfo(
        vin: 'N/A',
        isValidVin: false,
        make: 'Nissan',
        modelHint: 'Unconfirmed guess: ' + (hint),
        year: null,
        country: 'Japan',
        region: 'Asian',
        detectionSource: 'ECU Fingerprint (CALID: ${calId ?? oemPartNumber})',
        suggestedProtocolCmd: _inferSuggestedProtocol(null, activeProtocol),
        confidence: 0.78,
      );
    }

    // 3. Hyundai / Kia / Kefico / SIM2K / MEG17
    if (RegExp(r'39110|39120|SIM2K|KEFICO|HYUNDAI|KIA|G4FC|G4FD|G4FG').hasMatch(cleanFp)) {
      final isKia = cleanFp.contains('KIA') || cleanFp.contains('39110-2B');
      return DecodedVehicleInfo(
        vin: 'N/A',
        isValidVin: false,
        make: isKia ? 'Kia' : 'Hyundai',
        modelHint: 'Unconfirmed guess: ' + (isKia ? 'Cerato / Sportage' : 'Elantra / Accent / Tucson'),
        year: null,
        country: 'South Korea',
        region: 'Asian',
        detectionSource: 'ECU Fingerprint (CALID/Name)',
        suggestedProtocolCmd: _inferSuggestedProtocol(null, activeProtocol),
        confidence: 0.72,
      );
    }

    // 4. VAG (VW / Skoda / Seat / Audi): 03C, 04E, 06A, 06J, 1K0, 5Q0, MED17, SIMOS
    if (RegExp(r'03C|04E|06A|06J|0AM|SIMOS|MED17|BOSCH.*VAG|VOLKSWAGEN|SKODA|AUDI|SEAT').hasMatch(cleanFp)) {
      String make = 'Volkswagen';
      if (cleanFp.contains('SKODA')) make = 'Skoda';
      if (cleanFp.contains('AUDI')) make = 'Audi';
      if (cleanFp.contains('SEAT')) make = 'Seat';
      return DecodedVehicleInfo(
        vin: 'N/A',
        isValidVin: false,
        make: make,
        modelHint: 'Unconfirmed guess: ' + ('TSI / MPI Platform'),
        year: null,
        country: 'Germany',
        region: 'European',
        detectionSource: 'VAG ECU Hardware Fingerprint',
        suggestedProtocolCmd: 'AT SP 6',
        confidence: 0.75,
      );
    }

    // 5. Toyota / Denso
    if (RegExp(r'89661|89663|TOYOTA|1ZR|2ZR|DENSO').hasMatch(cleanFp)) {
      return DecodedVehicleInfo(
        vin: 'N/A',
        isValidVin: false,
        make: 'Toyota',
        modelHint: 'Unconfirmed guess: ' + (cleanFp.contains('ZR') ? 'Corolla' : 'Toyota OBD2'),
        year: null,
        country: 'Japan',
        region: 'Asian',
        detectionSource: 'ECU Calibration Match (Toyota/Denso)',
        suggestedProtocolCmd: _inferSuggestedProtocol(null, activeProtocol),
        confidence: 0.75,
      );
    }

    // 6. Stellantis / Fiat / Peugeot / Citroen / Opel
    if (RegExp(r'MARELLI|96\d{8}|VALEO.*V\d|PEUGEOT|CITROEN|FIAT').hasMatch(cleanFp)) {
      final isFiat = cleanFp.contains('FIAT') || cleanFp.contains('MARELLI');
      return DecodedVehicleInfo(
        vin: 'N/A',
        isValidVin: false,
        make: isFiat ? 'Fiat' : 'Peugeot',
        modelHint: 'Unconfirmed guess: ' + (isFiat ? 'Tipo / Punto' : '301 / 3008 / 508'),
        year: null,
        country: isFiat ? 'Italy' : 'France',
        region: 'European',
        detectionSource: 'ECU Fingerprint (${ecuName ?? calId})',
        confidence: 0.68,
      );
    }

    // 7. Chery / Delphi MT / Bosch M7.8 (Speranza / BYD / Chinese fleet)
    if (RegExp(r'DELPHI.*MT|4G15|481F|ACTECO|CHERY').hasMatch(cleanFp)) {
      return DecodedVehicleInfo(
        vin: 'N/A',
        isValidVin: false,
        make: 'Chery',
        modelHint: 'Unconfirmed guess: ' + (cleanFp.contains('481F') ? 'Tiggo / Arrizo / A516' : 'Tiggo / Arrizo 5'),
        year: null,
        country: 'China',
        region: 'Chinese',
        detectionSource: 'ECU Calibration Match',
        confidence: 0.65,
      );
    }

    return null;
  }

  /// Helper to parse VIN directly from Mode 09 / UDS hex response string
  static DecodedVehicleInfo? decodeFromRawObdResponse(
    String rawResponse, {
    String activeProtocol = '',
  }) {
    final bytes = HexParser.extractBytes(rawResponse);
    final vin = HexParser.parseVin(bytes);
    if (vin.isEmpty) return null;
    return decodeVin(vin, activeProtocol: activeProtocol);
  }

  static String? _inferVdsModelHint(String vin, String make, int? year) {
    final vds = vin.substring(3, 8);
    switch (make) {
      case 'Hyundai':
        if (vds.startsWith('D') || vin.startsWith('5NP')) {
          if (year != null && year >= 2021) return 'Elantra CN7';
          if (year != null && year >= 2016) return 'Elantra AD';
          if (year != null && year >= 2011) return 'Elantra MD';
          return 'Elantra HD';
        }
        if (vds.startsWith('C') || vds.startsWith('T') || vin.startsWith('NLH')) {
          return (year != null && year < 2012) ? 'Verna' : 'Accent RB';
        }
        if (vin.startsWith('KM8') || vin.startsWith('TMA') || vds.startsWith('J')) {
          if (year != null && year >= 2021) return 'Tucson NX4';
          if (year != null && year >= 2016) return 'Tucson TL';
          return 'Tucson / IX35';
        }
        if (vin.startsWith('MAL')) return 'Getz / i10 / Grand i10';
        break;
      case 'Kia':
        if (vds.startsWith('F')) return 'Cerato';
        if (vin.startsWith('KND') || vin.startsWith('U5Y') || vds.startsWith('P')) return 'Sportage';
        if (vds.startsWith('D')) return 'Rio / Picanto';
        break;
      case 'Nissan':
        if (vin.startsWith('SJN')) return 'Qashqai';
        if (vin.startsWith('3N1') && (year == null || year >= 2013)) return 'Sentra B17';
        if (vin.startsWith('MDH') || vin.startsWith('NMA') || vds.startsWith('B')) return 'Sunny N17';
        break;
      case 'Toyota':
        if (vin.startsWith('NMT') || vin.startsWith('2T1') || vin.startsWith('5YF') || vds.startsWith('B')) {
          if (year != null && year >= 2019) return 'Corolla E210';
          if (year != null && year >= 2014) return 'Corolla E170';
          if (year != null && year >= 2008) return 'Corolla E140';
          return 'Corolla E120';
        }
        if (vin.startsWith('MR0') || vin.startsWith('MHF')) return 'Fortuner / Hilux';
        break;
      case 'Chevrolet':
        if (vds.startsWith('T') || vds.startsWith('D')) return 'Aveo';
        if (vds.startsWith('S')) return 'Lanos';
        if (vds.startsWith('J') || vds.startsWith('L')) return 'Optra';
        if (vin.startsWith('LZW')) return 'Optra (New Shape Baojun 630)';
        if (vds.startsWith('P')) return 'Cruze';
        break;
      case 'Skoda':
        if (vds.contains('NE') || vds.contains('NX') || vds.contains('1Z') || vds.contains('1U')) {
          return (year != null && year >= 2014) ? 'Octavia (A7 / A8)' : 'Octavia (A4 / A5)';
        }
        break;
      case 'MG':
        if (vds.startsWith('A')) return 'MG ZS / MG HS';
        if (vds.startsWith('W') || vds.startsWith('S')) return 'MG 5';
        break;
      case 'Chery':
        if (year != null && year <= 2014) return 'Tiggo / A516';
        if (vds.startsWith('D') || vds.startsWith('T')) return 'Tiggo / Arrizo 5';
        break;
    }
    return null;
  }

  static _WmiInfo? _fallbackRegionFromFirstChar(String firstChar) {
    switch (firstChar) {
      case 'J':
        return const _WmiInfo('Japanese OEM', 'Japan', 'Asian');
      case 'K':
        return const _WmiInfo('Korean OEM', 'South Korea', 'Asian');
      case 'L':
        return const _WmiInfo('Chinese OEM', 'China', 'Chinese');
      case 'W':
        return const _WmiInfo('German OEM', 'Germany', 'European');
      case 'V':
        return const _WmiInfo('European OEM', 'France / Spain', 'European');
      case 'Z':
        return const _WmiInfo('Italian OEM', 'Italy', 'European');
      case 'S':
        return const _WmiInfo('UK / Polish OEM', 'UK / Europe', 'European');
      case 'T':
        return const _WmiInfo('Central Europe OEM', 'Czech / Hungary', 'European');
      case '1':
      case '4':
      case '5':
        return const _WmiInfo('North American OEM', 'USA', 'American');
      case '2':
        return const _WmiInfo('North American OEM', 'Canada', 'American');
      case '3':
        return const _WmiInfo('North American OEM', 'Mexico', 'American');
      default:
        return null;
    }
  }

  static String? _inferSuggestedProtocol(int? year, String activeProtocol) {
    final p = activeProtocol.toUpperCase();
    if (p.contains('CAN') || p.contains('15765')) {
      return p.contains('29') ? 'AT SP 7' : 'AT SP 6';
    }
    if (p.contains('14230') || p.contains('KWP')) return 'AT SP 5';
    if (p.contains('9141')) return 'AT SP 3';
    if (year != null && year >= 2008) return 'AT SP 6';
    return null;
  }
}
