import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class EventMapWidget extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String  venue;

  const EventMapWidget({
    super.key,
    this.latitude,
    this.longitude,
    required this.venue,
  });

  Future<void> _openMaps() async {
    if (latitude == null || longitude == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _openMaps,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color:        AppColors.surface1,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border:       Border.all(color: AppColors.border, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ─── Map grid background ──────────────
              CustomPaint(painter: _MapGridPainter()),

              // ─── Center pin ───────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: AppColors.accent, size: 40),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:        AppColors.dark.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        venue,
                        style: AppFonts.caption.copyWith(color: AppColors.light),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Bottom bar ───────────────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin:  Alignment.topCenter,
                      end:    Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.dark.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: Row(children: [
                    const Icon(Icons.directions_outlined,
                        color: AppColors.accent, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Open in Google Maps',
                      style: AppFonts.labelSmall
                          .copyWith(color: AppColors.accent),
                    ),
                    const Spacer(),
                    Text(
                      '${latitude!.toStringAsFixed(4)}, '
                      '${longitude!.toStringAsFixed(4)}',
                      style: AppFonts.caption,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a subtle street-map-like grid on the map placeholder
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF242220);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    final road = Paint()
      ..color   = const Color(0xFF2C2823)
      ..strokeWidth = 10
      ..style   = PaintingStyle.stroke;

    final thin = Paint()
      ..color   = const Color(0xFF282422)
      ..strokeWidth = 2
      ..style   = PaintingStyle.stroke;

    // Horizontal roads
    for (var y = 30.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          y % 80 == 30 ? road : thin);
    }
    // Vertical roads
    for (var x = 40.0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height),
          x % 120 == 40 ? road : thin);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
