import 'package:flutter/material.dart';

import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_dimensions.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';

/// A placeholder screen for the unit conversion feature.
class ConversionScreen extends StatelessWidget {
  const ConversionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconContainerSize = (screenWidth * 0.28).clamp(80.0, 120.0);
    final double iconSize = (iconContainerSize * 0.5).clamp(40.0, 64.0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXXL,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryList.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  size: iconSize,
                  color: AppColors.primaryList,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXXL),
              Text(
                AppStrings.convComingSoon,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: AppDimensions.fontTitleM,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.navBarDark,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                AppStrings.convFlavorText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: AppDimensions.fontXXL,
                  color: AppColors.neutralText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
