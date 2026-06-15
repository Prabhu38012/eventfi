import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class QrTicketWidget extends StatelessWidget {
  final String data;
  final double size;

  const QrTicketWidget({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size + 24,
      height: size + 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.light,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: QrImageView(
        data:    data,
        version: QrVersions.auto,
        size:    size,
        eyeStyle: const QrEyeStyle(
          eyeShape:  QrEyeShape.square,
          color:     AppColors.dark,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color:           AppColors.dark,
        ),
        backgroundColor: AppColors.light,
      ),
    );
  }
}
