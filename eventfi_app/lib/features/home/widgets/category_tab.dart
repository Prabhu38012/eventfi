import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class CategoryTab extends StatelessWidget {
  final String       selected;
  final ValueChanged<String> onSelect;

  const CategoryTab({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _cats = [
    {'id': 'all',       'label': 'All',        'icon': Icons.grid_view_rounded},
    {'id': 'concert',   'label': 'Concert',    'icon': Icons.music_note_outlined},
    {'id': 'theatre',   'label': 'Theatre',    'icon': Icons.theater_comedy_outlined},
    {'id': 'standup',   'label': 'Standup',    'icon': Icons.mic_outlined},
    {'id': 'dance',     'label': 'Dance',      'icon': Icons.directions_run_outlined},
    {'id': 'themePark', 'label': 'Theme Park', 'icon': Icons.attractions_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        scrollDirection: Axis.horizontal,
        itemCount: _cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (_, i) {
          final cat    = _cats[i];
          final id     = cat['id'] as String;
          final active = selected == id;

          return GestureDetector(
            onTap: () => onSelect(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color:        active ? AppColors.accent : AppColors.surface2,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    size: 15,
                    color: active ? AppColors.dark : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cat['label'] as String,
                    style: AppFonts.labelMedium.copyWith(
                      color: active ? AppColors.dark : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
