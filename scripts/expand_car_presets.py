import json

additional_cars = [
    {
        "id": "kia_cerato_forte",
        "make": "Kia",
        "make_ar": "كيا",
        "model": "Cerato / Forte (سيراتو)",
        "years": "2010-2023",
        "engine": "1.6L Gamma MPI (128 hp)",
        "protocol": "ISO 15765-4 (CAN 11/500)",
        "at_protocol_cmd": "AT SP 6",
        "transmission": "4-AT / 6-AT",
        "notes_ar": "نفس منظومة محركات هيونداي إلنترا وأكسنت. استجابة سريعة جداً لمحولات ELM327. تدعم جميع PIDs الحساسات القياسية مع فحص الميس فاير بدقة.",
        "custom_pids": [
            {
                "name": "حرارة زيت الفتيس 6 سرعات",
                "name_en": "AT Oil Temp",
                "mode": "21",
                "pid": "02",
                "formula": "A - 40",
                "unit": "°C",
                "min": -40,
                "max": 150
            }
        ]
    },
    {
        "id": "hyundai_accent_rb",
        "make": "Hyundai",
        "make_ar": "هيونداي",
        "model": "Accent RB (أكسنت)",
        "years": "2011-2024",
        "engine": "1.6L Gamma G4FC",
        "protocol": "ISO 15765-4 (CAN 11/500)",
        "at_protocol_cmd": "AT SP 6",
        "transmission": "4-AT",
        "notes_ar": "السيارة المجمعة محلياً واسعة الانتشار. فحص حساس الشكمان والبوابة وبلف الـ VVT بانتظام.",
        "custom_pids": []
    },
    {
        "id": "suzuki_swift_dzire",
        "make": "Suzuki",
        "make_ar": "سوزوكي",
        "model": "Swift / Dzire (سويفت / ديزاير)",
        "years": "2015-2024",
        "engine": "1.2L K12M DualJet",
        "protocol": "ISO 15765-4 (CAN 11/500)",
        "at_protocol_cmd": "AT SP 6",
        "transmission": "5-AMT / 4-AT",
        "notes_ar": "محرك اقتصادي جداً بحقن مزدوج. يفضل مراقبة حرارة الكولانت وفتيس الـ AGS/AMT الأوتوماتيك المعرب.",
        "custom_pids": []
    },
    {
        "id": "opel_astra_j",
        "make": "Opel",
        "make_ar": "أوبل",
        "model": "Astra J / H (أسترا)",
        "years": "2010-2020",
        "engine": "1.4L Turbo A14NET / 1.6L Ecotec",
        "protocol": "ISO 15765-4 (CAN 11/500)",
        "at_protocol_cmd": "AT SP 6",
        "transmission": "6-AT Hydra-Matic",
        "notes_ar": "حساسة جداً لدورة التبريد ومقاومة مروحة الردياتير وثرموستات الكوعة الكهربائي المشترك مع كروز.",
        "custom_pids": [
            {
                "name": "حرارة زيت المحرك الحقيقية",
                "name_en": "Engine Oil Temp",
                "mode": "22",
                "pid": "1154",
                "formula": "A - 40",
                "unit": "°C",
                "min": -40,
                "max": 160
            }
        ]
    },
    {
        "id": "chevrolet_cruze",
        "make": "Chevrolet",
        "make_ar": "شيفروليه",
        "model": "Cruze (كروز)",
        "years": "2010-2017",
        "engine": "1.6L Ecotec / 1.8L",
        "protocol": "ISO 15765-4 (CAN 11/500)",
        "at_protocol_cmd": "AT SP 6",
        "transmission": "6-AT 6T30/6T40",
        "notes_ar": "شائعة الأعطال في بلوف الكامات VVT P0011/P0014، وحرارة الفتيس وثرموستات الكوعة وسخان حساس الشكمان.",
        "custom_pids": [
            {
                "name": "حرارة فتيس كروز 6T30",
                "name_en": "Trans Temp 6T30",
                "mode": "22",
                "pid": "1940",
                "formula": "A - 40",
                "unit": "°C",
                "min": -40,
                "max": 150
            }
        ]
    },
    {
        "id": "geely_emgrand_7",
        "make": "Geely",
        "make_ar": "جيلي",
        "model": "Emgrand 7 (إمجراند 7)",
        "years": "2013-2019",
        "engine": "1.5L JL4G15 CVVT",
        "protocol": "ISO 15765-4 (CAN 11/500)",
        "at_protocol_cmd": "AT SP 6",
        "transmission": "5-MT / CVT",
        "notes_ar": "سيارة أجرة وملاكي شهيرة. كنترول Bosch M7.8 أو Delphi. فحص حساس الكرنك وحساس الشكمان والماف أساسي.",
        "custom_pids": []
    }
]

def main():
    preset_path = 'assets/databases/egypt_cars_preset.json'
    with open(preset_path, 'r', encoding='utf-8') as f:
        existing = json.load(f)

    existing_ids = {c['id'] for c in existing}
    added = 0
    for car in additional_cars:
        if car['id'] not in existing_ids:
            existing.append(car)
            added += 1

    with open(preset_path, 'w', encoding='utf-8') as f:
        json.dump(existing, f, ensure_ascii=False, indent=2)

    print(f"Added {added} cars. Total presets now: {len(existing)}")

if __name__ == '__main__':
    main()
