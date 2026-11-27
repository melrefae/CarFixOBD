# Real-car verification protocol

A feature may be marked `verified` in `lib/core/constants/feature_status.dart` only when ALL of this exists:

1. A real test on a real car with a real adapter (not the simulator, not unit tests).
2. The raw request/response log (the app's traffic log export) saved as `docs/verification/<feature>/<car>-<date>.log`.
3. A record file `docs/verification/<feature>/<car>-<date>.md` with: car (make, model, year, engine, VIN last 6), adapter (brand, chip/version, original or clone), app commit, date, tester, steps, expected result, actual result, pass or fail.
4. For write or actuation features: the ECU gave a positive response (service id + 0x40), and the effect was checked independently (for example live data or a second tool). A positive reply alone is "partially verified".
5. The same command is not assumed to work on another car. Status is kept per car/ECU in the record. Only record "verified for: <list of cars>".

Status values: `unverified` (default), `partiallyVerified` (works on some cars, or accepted but effect not independently checked), `verified`.

## Verified-commands dataset
Every command that passes goes into a table: brand, model, year range, ECU address, request bytes, expected reply, notes, record file. The app may offer a brand-specific command only if it has a row here.

## Rules
- No value is shown as measured unless it was read from the car. Anything computed or estimated must say so on screen.
- No success message without a positive ECU reply.
- Commands that write to the car stay in the Lab section until verified for that car.

## Milestone 3 changes (not verified on a car)
- `kTrustUnverifiedDids = false`: TCM 22 11 05 / 21 01, ABS 22 2B 01/02, SRS 22 3C 01, HVAC 22 4D 01 replies are logged but no longer decoded as values.
- DPF screen shows only Mode 01 PIDs 78, 7C, 7A read on demand ("not supported" if no reply). Soot mass, ash, AdBlue, NOx conversion removed (not readable over standard OBD).
- Used-car audit: battery cranking/alternator/ripple are "not measured" (NaN), not invented. A notice lists the sections that are manual / not measured (paint, flood, title, checklist, estimates, sub-scores).
- New raw command log screen (dashboard card "Raw command log") with export, for test evidence.

## Milestone 5 (UX)
Dashboard rebuilt: Daily / Inspection & Customers / Analysis & Tools, then Lab (PIN) and collapsed "More tools". Compact 3-column tiles with short titles, shield = not yet tested on a real car. Duplicate network cards merged into "Network Map" (chooser). Lab PIN: lab_pin.dart (staff guard, reset from the Lab screen). Screenshots in docs/screenshots (rendered by a widget test, not a phone).
