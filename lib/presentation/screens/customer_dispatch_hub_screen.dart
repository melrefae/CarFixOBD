import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/customer_dispatch_models.dart';
import '../providers/obd_state.dart';
import 'full_vehicle_test_screen.dart';

/// WhatsApp Customer Care & Multi-Stage Diagnostic Dispatch Hub
class CustomerDispatchHubScreen extends StatefulWidget {
  const CustomerDispatchHubScreen({super.key});

  @override
  State<CustomerDispatchHubScreen> createState() => _CustomerDispatchHubScreenState();
}

class _CustomerDispatchHubScreenState extends State<CustomerDispatchHubScreen> {
  final List<CustomerWorkOrder> _orders = [];
  CustomerWorkOrder? _selectedOrder;
  late DispatchStage _activeStage;
  final TextEditingController _messageDraftController = TextEditingController();
  bool _hasSyncedReports = false;

  @override
  void initState() {
    super.initState();
    _activeStage = DispatchStage.checkIn;
  }

  void _syncOrdersFromReports(ObdState obdState) {
    if (_hasSyncedReports) return;
    _hasSyncedReports = true;

    for (final report in obdState.savedReports) {
      final orderId = "WO-${report.id.length >= 4 ? report.id.substring(0, 4).toUpperCase() : '1001'}";
      final exists = _orders.any((o) => o.orderId == orderId);
      if (!exists) {
        final plate = report.plateNumber.isNotEmpty
            ? report.plateNumber
            : (report.vin.isNotEmpty ? report.vin.substring(0, 8) : "N/A");
        final model = "${report.vehicleMake} ${report.vehicleModel}".trim().isEmpty
            ? "Customer Vehicle"
            : "${report.vehicleMake} ${report.vehicleModel}";

        _orders.add(
          CustomerWorkOrder(
            orderId: orderId,
            customerName: "Vehicle Client",
            phoneNumber: "",
            plateNumber: plate,
            vehicleModel: model,
            currentMileageKm: report.mileageKm,
            currentStage: report.dtcs.isEmpty ? DispatchStage.readyForPickup : DispatchStage.diagnosticFindings,
            activeDtcCount: report.dtcs.length,
            estimatedCost: (report.dtcs.length * 750.0).clamp(500.0, 15000.0),
            createdAt: report.timestamp,
          ),
        );
      }
    }

    if (_orders.isNotEmpty && _selectedOrder == null) {
      _selectedOrder = _orders.first;
      _activeStage = _selectedOrder!.currentStage;
      _syncDraftMessage();
    }
  }

  @override
  void dispose() {
    _messageDraftController.dispose();
    super.dispose();
  }

  void _syncDraftMessage() {
    if (_selectedOrder == null) return;
    final isAr = Provider.of<ObdState>(context, listen: false).isArabic;
    _messageDraftController.text = _selectedOrder!.generateWhatsappMessage(_activeStage, isAr);
  }

  void _dispatchViaWhatsapp() {
    if (_selectedOrder == null) return;
    final text = _messageDraftController.text;
    // Share message text directly via system share sheet / WhatsApp target
    Share.share(
      text,
      subject: "AutoSpect: ${_selectedOrder!.vehicleModel} (${_selectedOrder!.plateNumber})",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cardSurface,
        content: Text(
          Provider.of<ObdState>(context, listen: false).isArabic
              ? "تم إرسال رسالة الواتساب للعميل بنجاح! 🚀"
              : "WhatsApp notification dispatched successfully! 🚀",
          style: const TextStyle(color: AppColors.successGreen),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final obdState = Provider.of<ObdState>(context);
    final isAr = obdState.isArabic;

    _syncOrdersFromReports(obdState);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(isAr ? "مركز خدمة ومراسلة العملاء واتساب" : "WhatsApp Customer Care Hub"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: isAr ? "إضافة عميل / أمر شغل جديد" : "New Work Order",
            onPressed: () => _showAddOrderDialog(context, isAr),
          ),
        ],
      ),
      body: _orders.isEmpty
          ? _buildEmptyState(context, isAr)
          : Column(
              children: [
                // Active Work Orders Carousel / Horizontal Selector
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.cardSurface,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: _orders.map((order) {
                        final isSelected = _selectedOrder?.orderId == order.orderId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: isSelected,
                            selectedColor: AppColors.primaryYellow,
                            backgroundColor: AppColors.backgroundDark,
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  order.customerName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isSelected ? Colors.black : Colors.white,
                                  ),
                                ),
                                Text(
                                  order.vehicleModel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.black87 : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedOrder = order;
                                  _activeStage = order.currentStage;
                                  _syncDraftMessage();
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

          if (_selectedOrder != null) ...[
            // Vehicle & Order Overview Card
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_car, color: AppColors.primaryYellow, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedOrder!.customerName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            "${_selectedOrder!.vehicleModel} • ${_selectedOrder!.plateNumber}",
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            "Odo: ${_selectedOrder!.currentMileageKm} km | Phone: ${_selectedOrder!.phoneNumber}",
                            style: const TextStyle(fontSize: 11, color: AppColors.accentCyan),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedOrder!.orderId,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.electricBlue),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_selectedOrder!.estimatedCost.toStringAsFixed(0)} EGP",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 5-Stage Stepper Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: DispatchStage.values.map((stage) {
                  final isCurrent = _activeStage == stage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: isCurrent,
                      selectedColor: AppColors.successGreen,
                      backgroundColor: AppColors.cardSurface,
                      checkmarkColor: Colors.black,
                      label: Text(
                        _getStageShortName(stage, isAr),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? Colors.black : Colors.white,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() {
                          _activeStage = stage;
                          _syncDraftMessage();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Live Message Preview Box
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.chat, color: AppColors.successGreen, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isAr ? "معاينة رسالة الواتساب للعميل:" : "WhatsApp Message Preview:",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _syncDraftMessage,
                            child: Text(
                              isAr ? "إعادة ضبط" : "Reset Template",
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      Expanded(
                        child: TextField(
                          controller: _messageDraftController,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Draft your customer message...",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Dispatch Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366), // Official WhatsApp Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.send, size: 20),
                        label: Text(
                          isAr ? "إرسال للعميل عبر واتساب" : "Dispatch via WhatsApp",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _dispatchViaWhatsapp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStageShortName(DispatchStage stage, bool isArabic) {
    if (isArabic) {
      switch (stage) {
        case DispatchStage.checkIn:
          return "1. الاستلام";
        case DispatchStage.diagnosticFindings:
          return "2. الأعطال";
        case DispatchStage.estimateApproval:
          return "3. المقايسة";
        case DispatchStage.finalInspectionReport:
          return "4. تقرير PDF";
        case DispatchStage.readyForPickup:
          return "5. الاستلام";
      }
    } else {
      switch (stage) {
        case DispatchStage.checkIn:
          return "1. Check-In";
        case DispatchStage.diagnosticFindings:
          return "2. Findings";
        case DispatchStage.estimateApproval:
          return "3. Estimate";
        case DispatchStage.finalInspectionReport:
          return "4. PDF Report";
        case DispatchStage.readyForPickup:
          return "5. Ready";
      }
    }
  }

  void _showAddOrderDialog(BuildContext context, bool isArabic) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final carCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final odoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: Text(isArabic ? "فتح أمر شغل جديد" : "New Customer Work Order"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: isArabic ? "اسم العميل" : "Customer Name"),
                ),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: isArabic ? "رقم الهاتف / الواتساب" : "Phone / WhatsApp"),
                ),
                TextField(
                  controller: carCtrl,
                  decoration: InputDecoration(labelText: isArabic ? "موديل وسنة السيارة" : "Vehicle Model & Year"),
                ),
                TextField(
                  controller: plateCtrl,
                  decoration: InputDecoration(labelText: isArabic ? "رقم اللوحة" : "Plate Number"),
                ),
                TextField(
                  controller: odoCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: isArabic ? "قراءة العداد الحالية (كم)" : "Current Odometer (km)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isArabic ? "إلغاء" : "Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: Colors.black),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                  final newOrder = CustomerWorkOrder(
                    orderId: "WO-${DateTime.now().millisecondsSinceEpoch % 10000}",
                    customerName: nameCtrl.text.trim(),
                    phoneNumber: phoneCtrl.text.trim(),
                    plateNumber: plateCtrl.text.trim().isEmpty ? "ABC 123" : plateCtrl.text.trim(),
                    vehicleModel: carCtrl.text.trim().isEmpty ? "Vehicle" : carCtrl.text.trim(),
                    currentMileageKm: int.tryParse(odoCtrl.text.trim()) ?? 50000,
                    createdAt: DateTime.now(),
                  );
                  setState(() {
                    _orders.insert(0, newOrder);
                    _selectedOrder = newOrder;
                    _activeStage = DispatchStage.checkIn;
                    _syncDraftMessage();
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(isArabic ? "إنشاء كارت العمل" : "Create Order"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isArabic) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 56,
                color: AppColors.primaryYellow,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isArabic ? "لا توجد أوامر شغل نشطة للعملاء" : "No Active Customer Work Orders",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? "قم بإجراء فحص تشخيصي للسيارة لحفظ تقرير فني، أو اضغط أدناه لإنشاء أمر شغل يدوي وإرسال تحديثات الصيانة للعميل عبر واتساب."
                  : "Perform a vehicle diagnostic scan to save an inspection report, or create a customer work order below to dispatch WhatsApp updates.",
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: Text(
                    isArabic ? "تسجيل عميل جديد" : "New Work Order",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showAddOrderDialog(context, isArabic),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentCyan,
                    side: const BorderSide(color: AppColors.accentCyan),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.speed),
                  label: Text(
                    isArabic ? "فحص كمبيوتر" : "Diagnostic Scan",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FullVehicleTestScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
