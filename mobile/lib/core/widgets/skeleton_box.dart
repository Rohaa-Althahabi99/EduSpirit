import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// يُستخدم أثناء تحميل أي بيانات (Dashboard, Timetable...) لإعطاء إحساس "التطبيق حي"
/// بدل شاشة تحميل فارغة — جزء من متطلبات الحركة والتفاعل السلس في التصميم.
class SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const SkeletonBox({super.key, required this.height, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E9F0),
      highlightColor: isDark ? const Color(0xFF2A3A55) : const Color(0xFFF5F7FB),
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}
