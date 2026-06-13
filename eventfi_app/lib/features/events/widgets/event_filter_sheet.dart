import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';

class EventFilterSheet extends StatefulWidget {
  final List<String> districts;
  final String?      selectedDistrict;
  final double?      minPrice;
  final double?      maxPrice;
  final void Function({String? district, double? minPrice, double? maxPrice}) onApply;

  const EventFilterSheet({
    super.key,
    required this.districts,
    this.selectedDistrict,
    this.minPrice,
    this.maxPrice,
    required this.onApply,
  });

  @override
  State<EventFilterSheet> createState() => _EventFilterSheetState();
}

class _EventFilterSheetState extends State<EventFilterSheet> {
  String?       _district;
  RangeValues   _priceRange = const RangeValues(0, 1500);

  @override
  void initState() {
    super.initState();
    _district   = widget.selectedDistrict;
    _priceRange = RangeValues(
      widget.minPrice ?? 0,
      widget.maxPrice ?? 1500,
    );
  }

  void _apply() {
    widget.onApply(
      district: _district,
      minPrice: _priceRange.start > 0    ? _priceRange.start : null,
      maxPrice: _priceRange.end   < 1500 ? _priceRange.end   : null,
    );
    Navigator.pop(context);
  }

  void _clear() {
    setState(() { _district = null; _priceRange = const RangeValues(0, 1500); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left:   AppSizes.pagePadding,
        right:  AppSizes.pagePadding,
        top:    AppSizes.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.xxl,
      ),
      child: Column(
        mainAxisSize: CrossAxisAlignment.start as MainAxisSize,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Events', style: AppFonts.headlineMedium),
              TextButton(
                onPressed: _clear,
                child: Text('Clear all',
                    style: AppFonts.labelMedium
                        .copyWith(color: AppColors.accent)),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.xl),

          // ─── District ────────────────────────────
          Text('District', style: AppFonts.labelLarge),
          const SizedBox(height: AppSizes.md),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: widget.districts.map((d) {
              final active = _district == d;
              return GestureDetector(
                onTap: () => setState(() => _district = active ? null : d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color:        active ? AppColors.accent : AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    d,
                    style: AppFonts.labelMedium.copyWith(
                      fontSize: 12,
                      color: active ? AppColors.dark : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSizes.xl),

          // ─── Price Range ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price range', style: AppFonts.labelLarge),
              Text(
                '₹${_priceRange.start.toInt()} – '
                '${_priceRange.end >= 1500 ? "Any" : "₹${_priceRange.end.toInt()}"}',
                style: AppFonts.labelMedium
                    .copyWith(color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:   AppColors.accent,
              inactiveTrackColor: AppColors.surface3,
              thumbColor:         AppColors.accent,
              overlayColor:       AppColors.accent.withOpacity(0.15),
            ),
            child: RangeSlider(
              values:  _priceRange,
              min:     0,
              max:     1500,
              divisions: 30,
              onChanged: (v) => setState(() => _priceRange = v),
            ),
          ),

          const SizedBox(height: AppSizes.xxl),

          // ─── Apply Button ─────────────────────────
          AppButton(text: 'Apply Filters', onTap: _apply),
        ],
      ),
    );
  }
}
