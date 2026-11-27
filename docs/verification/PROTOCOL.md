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

## Milestone 6
- App renamed AutoSpect (app title, Android label, PDF/report headers). Package id (automotive_scanner / applicationId) unchanged on purpose.
- Used-car inspection wizard (read from car, hand-entered form, PDF). Checklist items start as "not checked" (was: pre-marked OK). Paint, tires, brakes, fluids, test drive, photos are hand-entered and print as "not measured / not checked" when empty.
- The wizard screenshots use demo data for layout only.

## Milestone 7: car history, draft saving, job cards
- Wizard autosaves a draft every 5 s and on exit; offers to continue it. "Skip, no car" allows a hand-only inspection.
- "Save visit" stores the record (JSON in app storage) and the PDF file; history groups visits per car (plate, else VIN) and compares two visits. Only saved values are compared; empty = "not measured".
- Job cards: parts and labour with prices typed by the user (EGP), discount, optional VAT %, quote/invoice PDF, WhatsApp via wa.me text plus the system share sheet for the PDF.
- Verified here: unit tests (JSON round trips, compare, totals, PDF build) and widget renders. NOT verified: on-phone storage, share sheet, WhatsApp opening, Arabic font download for PDFs (needs internet once; offline falls back to default font and Arabic letters may not print).

## Milestone 8: bundled Arabic font and shared input theme
- Noto Sans Arabic is bundled in assets/fonts and used by every PDF (scorecard, hand-only inspection, quote/invoice, report) and as the UI fallback font. No download.
- All text fields share AppInputTheme (lib/core/theme/input_theme.dart). Per-screen border/fill overrides were removed. Verified: analyze, tests, widget renders (dark and light) and a rendered Arabic PDF page. NOT verified on a phone.

## Milestone 9: workshop identity, backup, search, Arabic PDF fix
- PDFs print the workshop name, phone, address and optional logo from Workshop Settings (empty fields are not printed). The fake default address "Cairo, Egypt" was removed. "OFFICIAL ... CERTIFICATE" in the scorecard title was changed to "REPORT" (nothing certifies it).
- Backup: Settings > Export backup shares one JSON file (visits with their PDFs, job cards, workshop identity and logo). Import merges and never overwrites existing records or identity.
- Search on Car History and Job Cards (plate, customer, phone, VIN; ignores case, spaces, Arabic digits and alef forms).
- Arabic in PDFs: the `pdf` package orders and shapes Arabic wrongly (measured). Arabic lines are now laid out by Flutter's text engine with the bundled Noto Sans Arabic and placed in the PDF as images. Checked against an independent HarfBuzz render: pixel difference about 4 for correct layout versus about 50 for mirrored or word-swapped text. Regression tests: test/arabic_pdf_test.dart with golden images. Trade-off: Arabic lines in a PDF are not selectable or searchable.
- NOT verified on a phone: file picker and share sheet, logo picker, and the fonts as they look on the device.

## Milestone 10 (l10n start)
ARB/gen-l10n added: lib/l10n/app_en.arb, app_ar.arb, l10n.yaml, generated code in lib/l10n/gen (committed).
Regenerate: temporarily add `generate: true` under `flutter:` in pubspec.yaml, run `flutter gen-l10n`, remove it.
Converted so far: history, job cards, used-car wizard, identity/backup card. App locale now follows the language switch.
Other screens still use ObdState.isArabic / AppStrings* and are not yet migrated.

## Milestone 11 (legacy protocols, verified clear)
Tested only with a scripted adapter double (test/legacy_protocol_test.dart), NOT a real car or adapter.
- Per-protocol wait: auto search 20 s, ISO 9141 / KWP 5-baud 10 s, KWP fast 6 s, CAN 3 s, J1850 4 s. Old buses tried before CAN.
- 0100 answer must be "41 00" + 4 bytes (was: any text containing "41").
- Manual protocol choice (Connection screen, saved). Per-protocol attempt list shown when no ECU answers.
- Legacy Mode 03/07/0A replies (7-byte groups per ECU) parsed per group.
- Clear DTC: snapshot saved first (last 20, in app preferences), success only if the read-back shows no codes.
Needs a real-car test: Hyundai Matrix 2007 and an old-protocol adapter.

## Milestone 12 (adapter check)
Scripted-adapter tests only. Connection screen: "Check adapter" (AT I, AT @1, ST I, AT RV, AT DP/DPN, 10x 0100, VIN long reply). Slow adapters (median > 500 ms) get double timeouts for the session. A device that never answers ELM327 commands is reported as possibly proprietary (e.g. some Launch/DiagZone dongles).
