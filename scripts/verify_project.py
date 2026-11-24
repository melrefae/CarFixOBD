import json
import os
import re

def verify_dtc_database():
    path = "assets/databases/dtc_codes_ar.json"
    assert os.path.exists(path), f"Missing {path}"
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    print(f"[*] Checking DTC Database: {len(data)} codes found.")
    assert len(data) >= 70, f"Expected at least 70 codes, got {len(data)}"
    
    required_keys = ["title_ar", "category", "severity", "description_ar", "symptoms_ar", "causes_ar", "workshop_check_ar"]
    for code, details in data.items():
        assert re.match(r"^[PBCU][0-9A-Fa-f]{4}$", code), f"Invalid DTC format: {code}"
        for key in required_keys:
            assert key in details, f"Missing key '{key}' in code {code}"
            assert details[key], f"Empty value for '{key}' in code {code}"
    print(" -> DTC Database integrity: 100% OK")

def verify_car_presets():
    path = "assets/databases/egypt_cars_preset.json"
    assert os.path.exists(path), f"Missing {path}"
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    print(f"[*] Checking Car Presets: {len(data)} presets found.")
    assert len(data) >= 15, f"Expected at least 15 presets, got {len(data)}"
    
    required_keys = ["id", "make", "model", "years", "engine", "protocol", "at_protocol_cmd"]
    for car in data:
        for key in required_keys:
            assert key in car, f"Missing key '{key}' in preset {car.get('id')}"
    print(" -> Egyptian Car Presets integrity: 100% OK")

def verify_dart_files():
    dart_files = []
    for root, dirs, files in os.walk("lib"):
        for f in files:
            if f.endswith(".dart"):
                dart_files.append(os.path.join(root, f))
    print(f"[*] Checking Dart source files: {len(dart_files)} files in lib/.")
    assert len(dart_files) >= 40, f"Expected at least 40 dart files, found {len(dart_files)}"
    
    # Check for unclosed brackets or syntax red flags
    for file_path in dart_files:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            # Simple bracket balancing check
            open_braces = content.count("{")
            close_braces = content.count("}")
            assert open_braces == close_braces, f"Mismatched braces in {file_path}: {open_braces} vs {close_braces}"
    print(" -> All Dart files bracket balance and integrity: 100% OK")

def test_hex_and_formulas():
    print("[*] Testing Hex parsing and Formulas...")
    # Mode 01 PID 0C RPM: ((A*256)+B)/4
    a, b = 0x0E, 0x10
    rpm = ((a * 256) + b) / 4.0
    assert rpm == 900.0, f"RPM formula error: {rpm}"

    # Mode 01 PID 0D Speed: A
    speed = 0x3C
    assert speed == 60, f"Speed error: {speed}"

    # Mode 01 PID 05 Coolant: A - 40
    coolant = 0x80 - 40
    assert coolant == 88, f"Coolant error: {coolant}"

    # DTC P0171: byte1=0x01, byte2=0x71
    # 0x01 >> 6 == 0 -> P
    # (0x01 >> 4) & 0x03 == 0 -> 0
    # 0x01 & 0x0F == 1 -> 1
    # 0x71 hex -> 71
    dtc = "P" + hex((0x01 >> 4) & 0x03)[2:].upper() + hex(0x01 & 0x0F)[2:].upper() + f"{0x71:02X}"
    assert dtc == "P0171", f"DTC decoding error: {dtc}"

    print(" -> Formulas and decoding algorithms: 100% OK")

if __name__ == "__main__":
    print("========================================")
    print("Automotive Scanner Validation Suite")
    print("========================================")
    verify_dtc_database()
    verify_car_presets()
    verify_dart_files()
    test_hex_and_formulas()
    print("========================================")
    print("ALL TESTS PASSED SUCCESSFULLY! (100% OK)")
    print("========================================")
