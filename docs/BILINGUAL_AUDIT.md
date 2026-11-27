# Arabic/English audit (generated)

How strings work today: `ObdState.isArabic` picks Arabic or English; strings live in
`lib/core/localization/*`, in model fields (`titleAr`/`titleEn`) and inline in screens
(`isAr ? "..." : "..."`). No ARB/gen-l10n yet.

Screens/widgets that never reference isAr (likely English-only): 24 of 52 files

| file | isAr uses | Arabic literals | English literals | has language switch |
|---|---|---|---|---|
| lib/presentation/providers/obd_state.dart | 0 | 157 | 471 | yes |
| lib/presentation/screens/used_car_audit_screen.dart | 146 | 146 | 232 | yes |
| lib/presentation/screens/home_dashboard_screen.dart | 33 | 14 | 98 | yes |
| lib/presentation/screens/immo_key_programming_screen.dart | 37 | 34 | 98 | yes |
| lib/presentation/screens/full_vehicle_test_screen.dart | 44 | 70 | 98 | yes |
| lib/presentation/screens/ev_hybrid_battery_lab_screen.dart | 31 | 30 | 78 | yes |
| lib/presentation/screens/lab_scope_waveform_screen.dart | 21 | 20 | 68 | yes |
| lib/presentation/screens/dpf_regeneration_screen.dart | 26 | 23 | 65 | yes |
| lib/presentation/screens/interactive_can_topology_screen.dart | 28 | 20 | 62 | yes |
| lib/presentation/screens/connection_screen.dart | 0 | 0 | 56 | NO |
| lib/presentation/screens/workshop_settings_screen.dart | 5 | 5 | 51 | yes |
| lib/presentation/screens/adas_calibration_screen.dart | 25 | 22 | 51 | yes |
| lib/presentation/screens/live_data_screen.dart | 17 | 16 | 46 | yes |
| lib/presentation/screens/adapter_benchmark_screen.dart | 0 | 0 | 42 | NO |
| lib/presentation/screens/offline_vault_protocol_sniffer_screen.dart | 17 | 17 | 42 | yes |
| lib/presentation/screens/flight_recorder_screen.dart | 0 | 0 | 39 | NO |
| lib/presentation/screens/cloud_backup_screen.dart | 21 | 21 | 38 | yes |
| lib/presentation/screens/customer_dispatch_hub_screen.dart | 18 | 23 | 37 | yes |
| lib/presentation/screens/lab_hub_screen.dart | 6 | 22 | 35 | yes |
| lib/presentation/screens/ai_copilot_screen.dart | 0 | 0 | 33 | NO |
| lib/presentation/screens/workshop_lan_sync_screen.dart | 0 | 0 | 32 | NO |
| lib/presentation/screens/freeze_frame_screen.dart | 0 | 1 | 29 | NO |
| lib/presentation/screens/voice_inspection_assistant_screen.dart | 19 | 22 | 28 | yes |
| lib/presentation/screens/performance_dyno_screen.dart | 0 | 0 | 27 | NO |
| lib/presentation/screens/terminal_screen.dart | 0 | 0 | 27 | NO |
| lib/presentation/screens/ar_engine_bay_hud_screen.dart | 23 | 23 | 26 | yes |
| lib/presentation/screens/ecu_coding_screen.dart | 2 | 0 | 26 | yes |
| lib/presentation/screens/diagnostic_assistant_screen.dart | 0 | 0 | 25 | NO |
| lib/presentation/screens/sgw_assistant_screen.dart | 15 | 11 | 24 | yes |
| lib/presentation/screens/fuel_cost_calculator_screen.dart | 0 | 0 | 24 | NO |
| lib/presentation/screens/dtc_encyclopedia_screen.dart | 0 | 0 | 21 | NO |
| lib/presentation/screens/mode06_monitor_screen.dart | 7 | 7 | 21 | yes |
| lib/presentation/screens/vehicle_profiles_screen.dart | 3 | 2 | 21 | yes |
| lib/presentation/widgets/stage_detail_modal.dart | 14 | 13 | 20 | yes |
| lib/presentation/screens/actuator_tests_screen.dart | 14 | 14 | 20 | yes |
| lib/presentation/screens/multi_ecu_topology_screen.dart | 0 | 0 | 20 | NO |
| lib/presentation/screens/quick_scan_screen.dart | 0 | 0 | 19 | NO |
| lib/presentation/screens/ecu_info_screen.dart | 0 | 0 | 18 | NO |
| lib/presentation/screens/reports_screen.dart | 0 | 0 | 16 | NO |
| lib/presentation/screens/wiring_schematics_screen.dart | 5 | 2 | 16 | yes |
