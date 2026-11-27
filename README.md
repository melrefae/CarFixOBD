> **Status note (milestone 1).** This README describes the original vision. What is actually verified:
> - Verified by unit tests only (not yet on a real car): standard OBD2 parsing, DTC/PID logic, reports.
> - DTC data: 78 Arabic entries + 112 real repair guides; padding that generated placeholder guides for hundreds of codes was removed. About 9.4k generic and 2.9k manufacturer-specific code definitions (English only) come from an open MIT database, see NOTICE.md. Codes with only a definition show no symptoms or causes.
> - Verification rules: docs/verification/PROTOCOL.md. Arabic/English audit: docs/BILINGUAL_AUDIT.md.
> - Features that write to the car or use unverified commands (special functions, ECU coding, SGW, actuator tests, ADAS, DPF) are only reachable from the **Lab (experimental)** screen, are marked UNVERIFIED, and show a warning first. A write counts as successful only if the ECU answers with a positive response.
> - Immobilizer/key programming was removed.
> - EV battery cell data is not generated; it stays empty until real brand-specific BMS reads are verified.
> - Odometer cross-check compares only values really read from the car; with fewer than two readings it reports "cannot verify".
> - Lab scope, DPF aftertreatment values and dyno figures are estimates from formulas, not measurements; they sit in the Lab with a red warning banner.
> - Requires Flutter stable with intl ^0.20.

# سكانر الورشة | تطبيق تشخيص وصيانة السيارات عبر OBD2 (ELM327)

تطبيق أندرويد احترافي متكامل مخصص لبيئة ورش ومراكز صيانة السيارات في مصر (للاستخدام الداخلي الفني). يعمل التطبيق عبر محولات **ELM327** الشائعة (Bluetooth Classic SPP و Wi-Fi TCP)، ويتميز بسرعة الاستجابة وسهولة الاستخدام مع شاشات مخصصة للهواتف والتابلت، وقاعدة بيانات تشخيصية محلية تفهم لغة الورشة المصرية وتفاصيل أعطال السيارات الأكثر انتشاراً.

---

## 🌟 أبرز مميزات التطبيق

1. **الاتصال بمحولات ELM327:**
   - دعم كامل لمحولات البلوتوث (Bluetooth Classic SPP RFCOMM UUID: `00001101-0000-1000-8000-00805F9B34FB`).
   - دعم محولات الواي فاي (Wi-Fi TCP Socket `192.168.0.10:35000` أو أي IP مخصص).
   - **وضع المحاكي الفني المدمج (ECU Simulator Mode):** يتيح تجربة واختبار كافة الشاشات والبيانات الحية والأعطال ومسحها فوراً دون الحاجة لسيارة حقيقية أو محول.
   - تهيئة ذكية متتالية (`AT Z`, `ATE0`, `ATL0`, `ATS0`, `ATH0`, `ATAT1`, `ATSTFF`, `ATSP0`).

2. **تشخيص وقراءة ومسح الأعطال (DTC Diagnostics):**
   - قراءة كافة تصنيفات الأعطال:
     - **الأعطال المسجلة (Stored / Current - Mode 03)**
     - **الأعطال المعلقة (Pending - Mode 07)**
     - **الأعطال الدائمة (Permanent - Mode 0A)**
   - قاعدة بيانات داخلية أوفلاين (3500+ كود عطل) مترجمة ومفسرة باللهجة الفنية للورش مع الأسباب الشائعة في مصر.
   - **دليل اختبار الحساس بالأفوميتر:** خطوات فحص الفولت والتغذية والإشارة والأرضي لكل كود قبل الشروع في استبدال قطع الغيار.
   - **مسح أكواد الأعطال (Mode 04):** محمي بنافذة تأكيد مشددة تطلب التحقق من شرط الأمان الإلزامي: **المحرك متوقف مع فتح الكونتاكت فقط (Key ON, Engine OFF)**.

3. **الفحص السريع الشامل (Quick Scan في 30 ثانية):**
   - قراءة رقم الشاسيه (VIN - Mode 09 PID 02).
   - قراءة حالة لمبة الأعطال (MIL) وعدد الأكواد المسجلة (Mode 01 PID 01).
   - قراءة فولت البطارية اللحظي عبر أمر `AT RV`.
   - كشف الأعطال وعرض تقرير فوري لحالة المحرك.

4. **البيانات الحية والراسم البياني (Live Data & Waveforms):**
   - قراءة حساسات المحرك المتعددة في نفس الوقت: (RPM، السرعة، حرارة المياه، فتحة البوابة، حساس الماب، حساس الماف، حساسات الشكمان B1S1 و B1S2، ونسب الوقود STFT و LTFT).
   - فلاتر سريعة للورشة: (المحرك - الوقود والهواء - دورة التبريد - الكهرباء).
   - **راسم إشارة حي (Oscilloscope Mode):** رسم بياني سلس بمعدل 60 إطار/ثانية.
   - **المقارنة المزدوجة (Dual-Channel Comparison):** مقارنة حساس الشكمان الأول بالثاني لفحص علبة البيئة، أو مقارنة البوابة بحساس الماب.

5. **المساعد التشخيصي الذكي (Diagnostic Assistant):**
   - **مصفوفة نسب الوقود (Fuel Trim Matrix):** تقارن STFT و LTFT على السلانسيه وعند 2500 RPM وتحدد أوتوماتيكياً: (تسريب فاكيوم، ضعف طلمبة بنزين، انسداد رشاشات، أو تسييل رشاش).
   - **فحص البطارية والدينامو (Battery & Alternator Test):** قياس جهد السكون، وهبوط الجهد أثناء تشغيل المارش (Cranking Drop < 9.6V)، وكفاءة شحن الدينامو تحت الأحمال.

6. **بروفايل سيارات السوق المصري (Egyptian Fleet Presets):**
   - معد مسبقاً لأشهر سيارات مصر:
     - **نيسان:** صني N16/N17، سنترا، قشقاي.
     - **هيونداي وكيا:** فيرنا، إلنترا (HD/MD/AD)، أكسنت RB، سيراتو، سبورتاج.
     - **تويوتا:** كورولا (2008-2022)، ياريس.
     - **شيفروليه ودايو:** لانوس، أفيو، أوبترا، كروز.
     - **السيارات الصينية:** شيري تيجو (3/7/8)، أريزو 5، إم جي 5 و ZS، وبي واي دي F3.
     - **رينو وفيات وميتسوبيشي:** لوجان، تيبو، لانسر (شارك/بوما).
   - إمكانية إضافة وتعديل Custom PIDs لأي سيارة.

7. **كروت الفحص وتقارير العملاء (PDF Job Cards):**
   - تسجيل الفحص برقم اللوحة ورقم الشاسيه واسم العميل وهاتفه.
   - إضافة ملاحظات وتوصيات الفني وقطع الغيار المطلوبة.
   - تصدير كارت الفحص بصيغة PDF عربي احترافي يحمل اسم الورشة وختم الفني.
   - إرسال التقرير مباشرة إلى واتساب العميل بضغطة زر واحدة أوفلاين بالكامل.

8. **موجه أوامر الـ OBD للمحترفين (Terminal):**
   - شاشة كونسول لإرسال أوامر AT وأوامر الـ Hex يدوياً مع أزرار سريعة لأهم الأوامر.

---

## 🏗️ المعمارية البرمجية وهيكل المشروع

تم بناء التطبيق وفق معمارية نظيفة مجردة (Clean Architecture) مع فصل طبقة البروتوكول عن واجهة المستخدم:

```
Automotive_Scanner/
├── pubspec.yaml
├── README.md
├── assets/
│   └── databases/
│       ├── dtc_codes_ar.json       # قاعدة بيانات أكواد الأعطال والشروحات
│       └── egypt_cars_preset.json  # إعدادات سيارات مصر والبروتوكولات
├── test/
│   └── obd_core_test.dart          # اختبارات فك تشفير Hex ومعادلات PIDs
└── lib/
    ├── main.dart                   # نقطة الدخول، إعداد RTL والثيم
    ├── core/
    │   ├── constants/              # obd_commands.dart, app_colors.dart
    │   ├── localization/           # workshop_ar.dart (مصطلحات الورشة)
    │   ├── theme/                  # workshop_theme.dart (أزرار كبيرة وتباين داكن)
    │   └── utils/                  # hex_parser.dart, unit_converter.dart
    ├── data/
    │   ├── datasources/            # obd_connection.dart, bluetooth, wifi, mock, elm327_driver.dart
    │   ├── models/                 # dtc_model.dart, sensor_pid.dart, vehicle_profile.dart, inspection_report.dart
    │   └── repositories/           # obd_repository.dart, dtc_repository.dart, vehicle_repository.dart, report_repository.dart
    ├── domain/
    │   ├── analyzers/              # fuel_trim_analyzer.dart, battery_health_checker.dart
    │   └── exporters/              # pdf_report_generator.dart
    └── presentation/
        ├── providers/              # obd_state.dart (ChangeNotifier مركزي)
        ├── screens/                # الشاشات الـ 9 الرئيسية للتطبيق
        └── widgets/                # sensor_gauge_card.dart, dtc_card_item.dart, safety_confirmation_dialog.dart
```

---

## 🚀 طريقة التثبيت والتشغيل

1. **المتطلبات:**
   - تثبيت Flutter SDK (الإصدار 3.0.0 فما فوق).
   - تابلت أو هاتف بنظام أندرويد 6.0 (API 23) أو أحدث.
   - محول ELM327 (يفضل إصدار v1.5 حقيقي بشريحة PIC18F25K80 لتحقيق أعلى استقرار مع بروتوكولات CAN و K-Line).

2. **التشغيل السريع:**
   ```bash
   cd "Automotive Scanner"
   flutter pub get
   flutter run
   ```

3. **التشغيل في وضع المحاكي الفوري:**
   - افتح التطبيق -> اضغط على شريط الاتصال بالأعلى.
   - انتقل إلى تبويب **"محاكي واقعي"** -> اضغط على **"تشغيل وضع المحاكي الآن"**.
   - يمكنك الآن تجربة الفحص السريع، مراقبة الحساسات الحية، راسم الإشارة، قراءة ومسح الأعطال، واختبار البطارية ومصفوفة الوقود دون الحاجة لسيارة حقيقية!

---

## 🔒 إرشادات أمان هامة للورشة

- **مسح الأعطال (Clear DTCs - Mode 04):**
  - لا تقم أبداً بمسح الأعطال ومحرك السيارة قيد الدوران.
  - تأكد دائماً أن وضع السيارة هو **KOEO (Key ON, Engine OFF)**.
  - مسح الأعطال يصفر قيم تعلم كمبيوتر الماكينة (Fuel Trims) ومؤشرات فحص الانبعاثات (Readiness Monitors)، مما قد يجعل السيارة تحتاج لدورة قيادة (Drive Cycle) لتعود لسلاستها الطبيعية.
- **حدود فحص OBD2 القياسي:**
  - بروتوكول OBD2 القياسي (SAE J1979) مخصص لقراءة الحساسات المساندة للانبعاثات وأعطال المحرك العامة.
  - التعديل البرمجي على جداول الحقن أو تعطيل الحساسات بشكل نهائي (Remapping / ECU Tuning / DPF EGR Off) يحتاج أدوات برمجة فلاش مخصصة (مثل Kess, Ktag, PCMFlash) ومبرمجين متخصصين ولا يتم عبر محولات ELM327 العادية.
