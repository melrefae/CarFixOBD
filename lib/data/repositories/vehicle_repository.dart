import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle_profile.dart';
import '../models/worldwide_brand.dart';
import '../../domain/services/vin_decoder_service.dart';

/// Repository managing vehicle profiles for the Egyptian market
class VehicleRepository {
  static const String _prefSelectedVehicleKey = "selected_vehicle_profile_id";
  List<VehicleProfile> _profiles = [];
  bool _isLoaded = false;
  VehicleProfile? _selectedProfile;

  List<VehicleProfile> get profiles => _profiles;
  VehicleProfile? get selectedProfile => _selectedProfile;

  /// Load vehicle profiles from JSON database
  Future<List<VehicleProfile>> loadProfiles() async {
    if (_isLoaded) return _profiles;
    try {
      final jsonString = await rootBundle.loadString('assets/databases/egypt_cars_preset.json');
      final List<dynamic> list = json.decode(jsonString);
      _profiles = list.map((item) => VehicleProfile.fromJson(item)).toList();
      _isLoaded = true;

      // Restore saved vehicle profile or select first vehicle as default
      if (_profiles.isNotEmpty && _selectedProfile == null) {
        final prefs = await SharedPreferences.getInstance();
        final savedId = prefs.getString(_prefSelectedVehicleKey);
        if (savedId != null && savedId.isNotEmpty) {
          _selectedProfile = _profiles.firstWhere(
            (p) => p.id == savedId,
            orElse: () => _profiles.first,
          );
        } else {
          _selectedProfile = _profiles.first;
        }
      }
    } catch (_) {
      _profiles = [];
    }
    return _profiles;
  }

  /// Select active profile and persist selection
  void selectProfile(VehicleProfile profile) {
    _selectedProfile = profile;
    _persistSelectedProfile(profile.id);
  }

  void selectProfileById(String id) {
    try {
      final p = _profiles.firstWhere((item) => item.id == id);
      _selectedProfile = p;
      _persistSelectedProfile(id);
    } catch (_) {}
  }

  Future<void> _persistSelectedProfile(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefSelectedVehicleKey, id);
    } catch (_) {}
  }

  /// Search vehicle profiles by query
  List<VehicleProfile> searchProfiles(String query) {
    if (query.trim().isEmpty) return _profiles;
    final q = query.toLowerCase().trim();
    return _profiles.where((p) {
      return p.make.toLowerCase().contains(q) ||
          p.makeAr.contains(q) ||
          p.model.toLowerCase().contains(q) ||
          p.years.toLowerCase().contains(q) ||
          p.engine.toLowerCase().contains(q) ||
          p.transmission.toLowerCase().contains(q) ||
          p.notesEn.toLowerCase().contains(q) ||
          p.notesAr.contains(q);
    }).toList();
  }

  /// Get all unique geographic regions
  List<String> getRegions() {
    return WorldwideBrandCatalog.regions;
  }

  /// Get distinct brands in a given region from preset profiles
  List<String> getBrands({String region = "All Regions"}) {
    final filtered = region == "All Regions" ? _profiles : _profiles.where((p) => p.region == region);
    return filtered.map((p) => p.make).toSet().toList()..sort();
  }

  /// Get worldwide catalog brands
  List<WorldwideBrand> getWorldwideBrands({String region = "All Regions", String query = ""}) {
    return WorldwideBrandCatalog.filter(region: region, query: query);
  }

  /// Get models for a specific brand
  List<VehicleProfile> getModelsByBrand(String brand) {
    return _profiles.where((p) => p.make.toLowerCase() == brand.toLowerCase()).toList();
  }

  /// Create a generic vehicle profile for any worldwide brand without existing presets
  VehicleProfile createGenericProfile(WorldwideBrand brand) {
    return VehicleProfile(
      id: "gen_${brand.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}",
      make: brand.name,
      makeAr: brand.nameAr,
      model: "Standard OBD2 / UDS Diagnostics",
      years: "All Production Years",
      engine: "Generic Petrol / Diesel / Hybrid",
      protocol: "ISO 15765-4 (CAN 11/500 Auto)",
      atProtocolCmd: "AT SP 0",
      transmission: "Automatic / Manual",
      notesAr: "ملف تشخيصي قياسي لسيارات ${brand.nameAr} (${brand.country}). دعم كامل لقراءة الحساسات، مسح الأعطال، واختبارات المشغلات.",
      notesEn: "Standard diagnostic profile for ${brand.name} (${brand.country}). Supports full ECU scanning, live sensor streaming, and actuator bi-directional tests.",
      region: brand.region,
      customPids: [],
    );
  }

  /// Automatically match the closest preset or synthesize a tailored profile from decoded VIN / ECU telemetry
  VehicleProfile autoMatchOrCreateProfile(DecodedVehicleInfo info) {
    final targetMake = info.make.toLowerCase();
    final aliasMakes = <String>{targetMake};
    if (targetMake == 'chevrolet') aliasMakes.add('daewoo');
    if (targetMake == 'daewoo') aliasMakes.add('chevrolet');
    if (targetMake == 'chery') aliasMakes.add('speranza');
    if (targetMake == 'speranza') aliasMakes.add('chery');

    final candidates = _profiles.where((p) {
      final pm = p.make.toLowerCase();
      return aliasMakes.any((a) => pm == a || pm.contains(a));
    }).toList();

    VehicleProfile? bestMatch;
    if (candidates.isNotEmpty) {
      int bestScore = -1;
      final hintTokens = info.modelHint
          .toLowerCase()
          .split(RegExp(r'[\s/()]+'))
          .where((t) => t.length >= 2)
          .toList();

      for (final p in candidates) {
        int score = p.make.toLowerCase() == targetMake ? 20 : 10;
        final modelLower = p.model.toLowerCase();

        for (final token in hintTokens) {
          if (modelLower.contains(token)) {
            score += 35;
          }
        }

        if (info.year != null) {
          final yearMatch = RegExp(r'(\d{4})\s*[-–]\s*(\d{4})').firstMatch(p.years);
          if (yearMatch != null) {
            final startY = int.tryParse(yearMatch.group(1)!) ?? 1990;
            final endY = int.tryParse(yearMatch.group(2)!) ?? 2030;
            if (info.year! >= startY && info.year! <= endY) {
              score += 25;
            } else {
              score -= 10;
            }
          }
        }

        if (info.suggestedProtocolCmd != null && p.atProtocolCmd == info.suggestedProtocolCmd) {
          score += 5;
        }

        if (score > bestScore) {
          bestScore = score;
          bestMatch = p;
        }
      }
    }

    if (bestMatch != null) {
      selectProfile(bestMatch);
      return bestMatch;
    }

    // Fallback to WorldwideBrandCatalog match
    final catalogMatches = WorldwideBrandCatalog.allBrands.where(
      (b) => b.name.toLowerCase() == targetMake || b.name.toLowerCase().contains(targetMake),
    );
    final brand = catalogMatches.isNotEmpty
        ? catalogMatches.first
        : WorldwideBrand(
            name: info.make,
            nameAr: info.make,
            region: info.region,
            country: info.country,
          );

    final yrStr = info.year != null ? '${info.year}' : 'All Production Years';
    final modStr = info.modelHint.isNotEmpty ? info.modelHint : 'Auto-Detected OBD2 / UDS';
    final autoProfile = VehicleProfile(
      id: "auto_${info.make.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${info.year ?? 'gen'}",
      make: brand.name,
      makeAr: brand.nameAr,
      model: modStr,
      years: yrStr,
      engine: 'Auto-Detected via ${info.detectionSource}',
      protocol: info.suggestedProtocolCmd == 'AT SP 6'
          ? 'ISO 15765-4 (CAN 11/500)'
          : 'Auto OBD-II / UDS',
      atProtocolCmd: info.suggestedProtocolCmd ?? 'AT SP 0',
      transmission: 'Automatic / Manual',
      notesAr: 'تم التعرف تلقائياً على السيارة ${brand.nameAr} $modStr ($yrStr) عبر ${info.detectionSource}.',
      notesEn: 'Auto-detected ${brand.name} $modStr ($yrStr) via ${info.detectionSource}. VIN: ${info.vin}.',
      region: brand.region,
      customPids: [],
    );

    _profiles.removeWhere((p) => p.id == autoProfile.id);
    _profiles.insert(0, autoProfile);
    selectProfile(autoProfile);
    return autoProfile;
  }

  /// Add custom workshop vehicle profile
  void addCustomProfile(VehicleProfile newProfile) {
    _profiles.add(newProfile);
  }
}
