import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_sizes.dart';

class OrganizerCard extends StatelessWidget {
  final String name;
  final String phone;

  const OrganizerCard({super.key, required this.name, required this.phone});

  Future<void> _call() async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'E';

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: AppFonts.headlineMedium
                    .copyWith(color: AppColors.accent, fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: AppSizes.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'EventFi Organizer',
                  style: AppFonts.labelLarge,
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone, style: AppFonts.bodySmall),
                ],
              ],
            ),
          ),

          // Call button
          if (phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone_outlined,
                  color: AppColors.accent, size: 22),
              onPressed: _call,
              tooltip: 'Call organizer',
            ),
        ],
      ),
    );
  }
}
