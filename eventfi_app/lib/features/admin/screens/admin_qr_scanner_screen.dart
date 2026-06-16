import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class AdminQrScannerScreen extends StatefulWidget {
  const AdminQrScannerScreen({super.key});
  @override
  State<AdminQrScannerScreen> createState() => _AdminQrScannerScreenState();
}

class _AdminQrScannerScreenState extends State<AdminQrScannerScreen> {
  final _ctrl        = MobileScannerController();
  final _textCtrl    = TextEditingController();
  bool  _scanning    = true;
  bool  _manualMode  = kIsWeb; // Always manual on web

  @override
  void dispose() {
    _ctrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_scanning) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code.startsWith('EVT')) {
      setState(() => _scanning = false);
      _lookup(code);
    }
  }

  Future<void> _lookup(String bookingId) async {
    await context.read<AdminProvider>().scanQr(bookingId);
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title:           Text('Gate Entry Scanner', style: AppFonts.headlineSmall),
        backgroundColor: AppColors.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin'),
        ),
        actions: [
          if (!kIsWeb)
            TextButton(
              onPressed: () => setState(() {
                _manualMode = !_manualMode;
                _scanning   = true;
              }),
              child: Text(_manualMode ? 'Camera' : 'Manual',
                  style: AppFonts.labelSmall.copyWith(color: AppColors.accent)),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Camera / Manual input ──────────────────────────
          if (!_manualMode && !kIsWeb)
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24)),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller:  _ctrl,
                      onDetect:    _onDetect,
                    ),
                    // Scan frame overlay
                    Center(
                      child: Container(
                        width: 220, height: 220,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.accent, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16, left: 0, right: 0,
                      child: Text(
                        'Point camera at attendee\'s QR code',
                        textAlign: TextAlign.center,
                        style: AppFonts.bodySmall.copyWith(
                            color: Colors.white, shadows: [
                          const Shadow(color: Colors.black, blurRadius: 8)
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Manual entry
            Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Column(children: [
                if (kIsWeb)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color:        AppColors.surface1,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.textHint, size: 16),
                      const SizedBox(width: 8),
                      Text('Camera scanner works on Android device.',
                          style: AppFonts.caption),
                    ]),
                  ),
                const SizedBox(height: AppSizes.lg),
                TextField(
                  controller:     _textCtrl,
                  style:          AppFonts.inputText,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText:  'Enter Booking ID  (e.g. EVT4F2K9)',
                    hintStyle: AppFonts.hintText,
                    filled:    true,
                    fillColor: AppColors.surface1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide:   BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      borderSide:   const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                    suffixIcon: IconButton(
                      icon:      const Icon(Icons.search_rounded, color: AppColors.accent),
                      onPressed: () => _lookup(_textCtrl.text.trim()),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  onSubmitted: _lookup,
                ),
              ]),
            ),

          // ── Result ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: _buildResult(ap),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(AdminProvider ap) {
    if (ap.scanLoading) {
      return const Center(child: CircularProgressIndicator(
          color: AppColors.accent, strokeWidth: 2));
    }

    if (ap.error != null) {
      return _ResultCard(
        icon:    Icons.cancel_outlined,
        color:   AppColors.error,
        title:   'Invalid QR Code',
        message: ap.error!,
        action:  TextButton(
          onPressed: () { ap.clearScan(); setState(() => _scanning = true); },
          child: const Text('Try Again'),
        ),
      );
    }

    if (ap.scanCheckedIn) {
      return _ResultCard(
        icon:    Icons.check_circle_outline_rounded,
        color:   AppColors.success,
        title:   '✅ Checked In!',
        message: 'Attendee has been marked as attended.',
        action:  ElevatedButton(
          onPressed: () { ap.clearScan(); setState(() => _scanning = true); _textCtrl.clear(); },
          child: const Text('Scan Next'),
        ),
      );
    }

    if (ap.scannedBooking != null) {
      final b     = ap.scannedBooking!;
      final user  = b['userId']  is Map ? b['userId']  as Map : {};
      final event = b['eventId'] is Map ? b['eventId'] as Map : {};
      final attended = b['attended'] == true;

      return Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: AppColors.success.withOpacity(0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.success, size: 22),
            const SizedBox(width: 8),
            Text('Valid Booking', style: AppFonts.labelLarge
                .copyWith(color: AppColors.success)),
          ]),

          const SizedBox(height: AppSizes.lg),
          const Divider(color: AppColors.divider),
          const SizedBox(height: AppSizes.md),

          _Detail('Booking ID',   b['bookingId'] ?? ''),
          _Detail('Event',        event['title'] ?? ''),
          _Detail('Attendee',     user['name']   ?? ''),
          _Detail('Email',        user['email']  ?? ''),
          _Detail('Seats',        '${b['seats']} seat(s)'),
          _Detail('Amount Paid',  '₹${(b['finalAmount'] ?? 0).toInt()}'),

          const SizedBox(height: AppSizes.xl),

          if (attended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Text('⚠️ Already checked in',
                  textAlign: TextAlign.center,
                  style: AppFonts.labelMedium.copyWith(color: AppColors.warning)),
            )
          else
            SizedBox(
              width:  double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: ap.saving
                    ? null
                    : () => ap.confirmAttendance(b['_id']),
                icon:  const Icon(Icons.check_circle_rounded),
                label: ap.saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: AppColors.dark, strokeWidth: 2))
                    : const Text('Confirm Entry'),
              ),
            ),

          const SizedBox(height: AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ap.clearScan();
                setState(() => _scanning = true);
                _textCtrl.clear();
              },
              child: const Text('Scan Another'),
            ),
          ),
        ]),
      );
    }

    // Idle state
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.qr_code_scanner_rounded,
            color: AppColors.textHint, size: 64),
        const SizedBox(height: 16),
        Text(kIsWeb ? 'Enter a Booking ID above' : 'Scan a QR code to get started',
            style: AppFonts.bodySmall, textAlign: TextAlign.center),
      ]),
    );
  }
}

class _Detail extends StatelessWidget {
  final String label, value;
  const _Detail(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 100,
          child: Text(label, style: AppFonts.caption)),
      Expanded(child: Text(value, style: AppFonts.bodySmall
          .copyWith(color: AppColors.textPrimary))),
    ]),
  );
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   title, message;
  final Widget   action;
  const _ResultCard({required this.icon, required this.color,
      required this.title, required this.message, required this.action});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.xl),
    decoration: BoxDecoration(
      color:        AppColors.surface1,
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
    ),
    child: Column(children: [
      Icon(icon, color: color, size: 56),
      const SizedBox(height: 12),
      Text(title,   style: AppFonts.headlineSmall),
      const SizedBox(height: 6),
      Text(message, style: AppFonts.bodySmall, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      action,
    ]),
  );
}
