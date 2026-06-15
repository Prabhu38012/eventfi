import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class SeatGrid extends StatefulWidget {
  final int   totalSeats;
  final int   bookedCount;
  final int   selectedCount;
  final int   maxSelect;
  final ValueChanged<int> onChanged;

  const SeatGrid({
    super.key,
    required this.totalSeats,
    required this.bookedCount,
    required this.selectedCount,
    required this.onChanged,
    this.maxSelect = 10,
  });

  @override
  State<SeatGrid> createState() => _SeatGridState();
}

class _SeatGridState extends State<SeatGrid> {
  late Set<int> _taken;
  late Set<int> _selected;
  static const int _display = 60; // max seats shown in grid
  static const int _perRow  = 7;

  @override
  void initState() {
    super.initState();
    _taken    = _generateTaken();
    _selected = {};
  }

  Set<int> _generateTaken() {
    final rng   = math.Random(42); // fixed seed = consistent UI
    final taken = <int>{};
    final cap   = math.min(widget.bookedCount, _display - 5);
    while (taken.length < cap) {
      taken.add(rng.nextInt(_display) + 1);
    }
    return taken;
  }

  void _tap(int seat) {
    if (_taken.contains(seat)) return;
    setState(() {
      if (_selected.contains(seat)) {
        _selected.remove(seat);
      } else if (_selected.length < widget.maxSelect) {
        _selected.add(seat);
      }
    });
    widget.onChanged(_selected.length);
  }

  @override
  Widget build(BuildContext context) {
    final count = math.min(_display, widget.totalSeats);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        Row(children: [
          _Legend(color: AppColors.surface2,         label: 'Available'),
          const SizedBox(width: 16),
          _Legend(color: AppColors.accent,            label: 'Selected'),
          const SizedBox(width: 16),
          _Legend(color: AppColors.surface1,          label: 'Taken',
              border: AppColors.border),
        ]),
        const SizedBox(height: AppSizes.lg),

        // Screen label
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('STAGE / SCREEN',
              textAlign: TextAlign.center,
              style: AppFonts.caption.copyWith(letterSpacing: 2)),
        ),
        const SizedBox(height: AppSizes.xl),

        // Seat grid
        GridView.builder(
          shrinkWrap:  true,
          physics:     const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:   _perRow,
            crossAxisSpacing: 6,
            mainAxisSpacing:  6,
            childAspectRatio: 1,
          ),
          itemCount: count,
          itemBuilder: (_, i) {
            final seatNum = i + 1;
            final isTaken    = _taken.contains(seatNum);
            final isSelected = _selected.contains(seatNum);

            Color bg;
            Color? border;
            Color textColor = AppColors.textPrimary;
            if (isTaken) {
              bg        = AppColors.surface1;
              border    = AppColors.border;
              textColor = AppColors.textHint;
            } else if (isSelected) {
              bg = AppColors.accent;
              textColor = AppColors.dark;
            } else {
              bg = AppColors.surface2;
            }

            return GestureDetector(
              onTap: () => _tap(seatNum),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color:        bg,
                  borderRadius: BorderRadius.circular(4),
                  border:       border != null
                      ? Border.all(color: border, width: 0.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$seatNum',
                    style: AppFonts.caption.copyWith(
                      color:    textColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color  color;
  final String label;
  final Color? border;
  const _Legend({required this.color, required this.label, this.border});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 14, height: 14,
      decoration: BoxDecoration(
        color:        color,
        borderRadius: BorderRadius.circular(3),
        border:       border != null ? Border.all(color: border!, width: 0.5) : null,
      ),
    ),
    const SizedBox(width: 5),
    Text(label, style: AppFonts.caption),
  ]);
}
