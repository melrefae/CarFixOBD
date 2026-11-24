enum EgyptianFuelGrade {
  octane80,
  octane92,
  octane95,
  diesel,
  custom,
}

/// Computes real-time fuel economy (L/100km, km/L) and Egyptian fuel trip cost in EGP
class FuelEconomyCalculator {
  EgyptianFuelGrade selectedGrade = EgyptianFuelGrade.octane92;
  double customPricePerLiter = 15.25;

  double totalDistanceKm = 0.0;
  double totalFuelConsumedLiters = 0.0;

  double instantLitersPerHour = 0.0;
  double instantLitersPer100Km = 0.0;

  int _lastTimestampMs = 0;

  /// Default regulated prices in Egypt (EGP per Liter)
  double get pricePerLiter {
    switch (selectedGrade) {
      case EgyptianFuelGrade.octane80:
        return 13.75;
      case EgyptianFuelGrade.octane92:
        return 15.25;
      case EgyptianFuelGrade.octane95:
        return 17.00;
      case EgyptianFuelGrade.diesel:
        return 13.50;
      case EgyptianFuelGrade.custom:
        return customPricePerLiter;
    }
  }

  String getGradeLabel([bool isArabic = false]) {
    if (isArabic) {
      switch (selectedGrade) {
        case EgyptianFuelGrade.octane80:
          return "بنزين ٨٠ (Octane 80)";
        case EgyptianFuelGrade.octane92:
          return "بنزين ٩٢ (Octane 92)";
        case EgyptianFuelGrade.octane95:
          return "بنزين ٩٥ (Octane 95)";
        case EgyptianFuelGrade.diesel:
          return "سولار (Diesel Solar)";
        case EgyptianFuelGrade.custom:
          return "تسعيرة مخصصة";
      }
    }
    switch (selectedGrade) {
      case EgyptianFuelGrade.octane80:
        return "Octane 80";
      case EgyptianFuelGrade.octane92:
        return "Octane 92";
      case EgyptianFuelGrade.octane95:
        return "Octane 95";
      case EgyptianFuelGrade.diesel:
        return "Diesel Solar";
      case EgyptianFuelGrade.custom:
        return "Custom Fuel Grade";
    }
  }

  String get gradeLabel => getGradeLabel(false);

  double get averageLitersPer100Km =>
      totalDistanceKm > 0.1 ? (totalFuelConsumedLiters / totalDistanceKm) * 100.0 : 0.0;

  double get averageKmPerLiter =>
      totalFuelConsumedLiters > 0.01 ? totalDistanceKm / totalFuelConsumedLiters : 0.0;

  double get totalTripCostEgp => totalFuelConsumedLiters * pricePerLiter;

  double get costPerKmEgp =>
      totalDistanceKm > 0.1 ? totalTripCostEgp / totalDistanceKm : 0.0;

  void resetTrip() {
    totalDistanceKm = 0.0;
    totalFuelConsumedLiters = 0.0;
    instantLitersPerHour = 0.0;
    instantLitersPer100Km = 0.0;
    _lastTimestampMs = 0;
  }

  /// Ingest real-time sensor stream
  void ingestSample({
    required double speedKmh,
    required double rpm,
    required double? mafGramsPerSec,
    required double? mapKpa,
    required int timestampMs,
    double engineDisplacementLiters = 1.6,
  }) {
    if (_lastTimestampMs == 0) {
      _lastTimestampMs = timestampMs;
      return;
    }

    final dtSec = (timestampMs - _lastTimestampMs) / 1000.0;
    _lastTimestampMs = timestampMs;

    if (dtSec <= 0 || dtSec > 2.0) return;

    // Determine MAF flow rate (g/s)
    double calculatedMaf = mafGramsPerSec ?? 0.0;

    // Speed-Density estimate if physical MAF is not fitted (common on Hyundai Verna / Daewoo Lanos)
    if (calculatedMaf <= 0.1 && (mapKpa ?? 0) > 10 && rpm > 300) {
      // Speed-Density: MAF = (MAP * RPM * Displacement * VolumetricEfficiency) / (120 * R * T)
      const volumetricEfficiency = 0.82;
      const airTempK = 303.15; // ~30°C
      calculatedMaf = ((mapKpa ?? 35) * rpm * engineDisplacementLiters * volumetricEfficiency) /
          (120.0 * 287.05 * airTempK / 1000.0);
    }

    if (calculatedMaf <= 0.05) {
      calculatedMaf = 1.8 + (rpm / 1000.0) * 1.5; // Baseline idle fallback
    }

    // Fuel mass flow (g/s) at stoichiometric AFR (14.7 : 1 for gasoline)
    final afr = selectedGrade == EgyptianFuelGrade.diesel ? 14.5 : 14.7;
    final fuelGramsPerSec = calculatedMaf / afr;

    // Fuel density ~ 740 g/L (Gasoline) or 830 g/L (Diesel)
    final fuelDensityGramsPerLiter = selectedGrade == EgyptianFuelGrade.diesel ? 830.0 : 740.0;
    final litersPerSec = fuelGramsPerSec / fuelDensityGramsPerLiter;

    instantLitersPerHour = litersPerSec * 3600.0;

    // Accumulate total fuel consumed
    final consumedThisInterval = litersPerSec * dtSec;
    totalFuelConsumedLiters += consumedThisInterval;

    // Accumulate trip distance
    final distanceThisIntervalKm = (speedKmh * (dtSec / 3600.0));
    totalDistanceKm += distanceThisIntervalKm;

    // Compute instantaneous L/100km
    if (speedKmh > 5.0) {
      instantLitersPer100Km = (instantLitersPerHour / speedKmh) * 100.0;
    } else {
      instantLitersPer100Km = 0.0; // Idle mode (expressed in L/h)
    }
  }
}
