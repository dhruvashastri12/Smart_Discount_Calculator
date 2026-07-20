import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:smart_discount_calculator/core/constants/app_colors.dart';
import 'package:smart_discount_calculator/core/constants/app_strings.dart';
import 'package:smart_discount_calculator/core/constants/app_constants.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String originalPriceStr = "0";
  String discountStr = "0";
  bool isPercent = true;
  bool selectingPrice = true;
  String? limitWarning;

  double get originalPrice => double.tryParse(originalPriceStr) ?? 0.0;
  double get discountValue => double.tryParse(discountStr) ?? 0.0;

  double get savedAmount {
    if (isPercent) {
      return (originalPrice * discountValue) / 100;
    } else {
      return discountValue;
    }
  }

  double get payableAmount => (originalPrice - savedAmount).clamp(0, double.infinity);

  // Logs custom calc_discount_calculated event to Firebase Analytics
  Future<void> _logCalculation() async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'calc_discount_calculated',
        parameters: {
          'original_price': originalPrice,
          'discount_amount': savedAmount,
          'discount_type': isPercent ? 'percent' : 'flat',
          'final_price': payableAmount,
        },
      );
    } catch (e) {
      // Safe try-catch block to prevent crashes from analytics failure
      debugPrint('Error logging calc_discount_calculated event: $e');
    }
  }

  void _onKeyTap(String key) {
    setState(() {
      limitWarning = null;
      if (key == "AC") {
        originalPriceStr = "0";
        discountStr = "0";
        selectingPrice = true;
      } else if (key == "backspace") {
        String current = selectingPrice ? originalPriceStr : discountStr;
        if (current.length > 1) {
          current = current.substring(0, current.length - 1);
        } else {
          current = "0";
        }
        if (selectingPrice) {
          originalPriceStr = current;
        } else {
          discountStr = current;
        }
      } else {
        String current = selectingPrice ? originalPriceStr : discountStr;
        if (current.replaceAll(".", "").length >= AppConstants.maxInputDigits) {
          limitWarning = "Maximum ${AppConstants.maxInputDigits} digits allowed";
          return;
        }
        if (current == "0") {
          current = key;
        } else {
          current += key;
        }
        if (selectingPrice) {
          originalPriceStr = current;
        } else {
          discountStr = current;
        }
      }
    });
    // Log the calculation event asynchronously on key tap
    _logCalculation();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              flex: AppConstants.calcTopFlex.toInt(),
              child: _buildResultBoard(isDark),
            ),
            Expanded(
              flex: AppConstants.calcBottomFlex.toInt(),
              child: _buildControlsSection(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBoard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceS),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.calcFinalPrice,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
               fit: BoxFit.scaleDown,
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 20),
                 child: Text(
                   "${AppStrings.calcRupeeSymbol}${payableAmount.toStringAsFixed(0)}",
                   style: TextStyle(fontFamily: 'JetBrainsMono', 
                     fontSize: 64,
                     fontWeight: FontWeight.w700,
                     color: AppColors.primaryGreen,
                     letterSpacing: -1.0,
                   ),
                 ),
               ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("SAVED ", style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  Text(
                    "${AppStrings.calcRupeeSymbol}${savedAmount.toStringAsFixed(0)}", 
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.success)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (limitWarning != null)
            Text(limitWarning!, style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Expanded(child: _inputBox(AppStrings.calcOriginalPrice, originalPriceStr, AppStrings.calcRupeeSymbol, true, selectingPrice, isDark)),
              const SizedBox(width: 16),
              Expanded(child: _inputBox(AppStrings.calcDiscountPercent, discountStr, isPercent ? AppStrings.calcPercentSymbol : AppStrings.calcRupeeSymbol, false, !selectingPrice, isDark)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 45,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                _toggleButton("PERCENT %", isPercent, isDark, () {
                  setState(() => isPercent = true);
                  _logCalculation();
                }),
                _toggleButton("FLAT ₹", !isPercent, isDark, () {
                  setState(() => isPercent = false);
                  _logCalculation();
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _keyButton("1", isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("2", isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("3", isDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _keyButton("4", isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("5", isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("6", isDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _keyButton("7", isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("8", isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("9", isDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _keyButton("AC", isDark, isAction: true)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("0", isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _keyButton("backspace", isDark, isIcon: true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBox(String label, String value, String unit, bool unitPrefix, bool active, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() { selectingPrice = (label == AppStrings.calcOriginalPrice); limitWarning = null; }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontFamily: 'DMSans', fontSize: 10, fontWeight: FontWeight.bold, color: active ? AppColors.primaryGreen : AppColors.neutralText)),
          const SizedBox(height: 6),
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? AppColors.primaryGreen : Colors.transparent, width: 1.5),
            ),
            child: Row(
              children: [
                if (unitPrefix) ...[
                  Text(unit.trim(), style: TextStyle(fontFamily: 'JetBrainsMono', color: AppColors.neutralText, fontSize: 16)),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(value, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      ),
                      if (active) ...[const SizedBox(width: 4), const _BlinkingCursor()],
                    ],
                  ),
                ),
                if (!unitPrefix) ...[
                  const SizedBox(width: 4),
                  Text(unit.trim(), style: TextStyle(fontFamily: 'JetBrainsMono', color: AppColors.neutralText, fontSize: 16)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _toggleButton(String text, bool active, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: active ? AppColors.primaryGreen : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(fontFamily: 'DMSans', color: active ? Colors.white : AppColors.neutralText, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _keyButton(String label, bool isDark, {bool isAction = false, bool isIcon = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyTap(label),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: label == "AC" ? AppColors.error.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: isIcon 
            ? Icon(Icons.backspace_outlined, size: 20, color: isDark ? Colors.white : AppColors.textDark)
            : Text(label, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: isAction ? 16 : 24, fontWeight: FontWeight.bold, color: label == "AC" ? AppColors.error : (isDark ? Colors.white : AppColors.textDark))),
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 2, height: 20, color: AppColors.primaryGreen),
    );
  }
}
