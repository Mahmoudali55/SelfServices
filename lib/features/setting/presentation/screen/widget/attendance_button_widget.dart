import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template/core/theme/app_colors.dart';

class AttendanceButtonWidget extends StatelessWidget {
  const AttendanceButtonWidget({
    super.key,
    required this.label,
    required this.color,
    required this.isLoading,
    required this.isOtherButtonLoading,
    this.onTap,
  });

  final String label;
  final Color color;
  final bool isLoading;
  final bool isOtherButtonLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isLoading || isOtherButtonLoading;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDisabled
                    ? [color.withOpacity(0.3), color.withOpacity(0.4)]
                    : [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDisabled ? Colors.grey.withOpacity(0.3) : color.withOpacity(0.5),
                  blurRadius: isDisabled ? 6 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : const Icon(Icons.fingerprint, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDisabled ? Colors.grey : AppColor.blackColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
