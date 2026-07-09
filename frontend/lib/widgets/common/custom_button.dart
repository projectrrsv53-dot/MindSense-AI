// lib/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final Color? solidColor;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.gradient,
    this.solidColor,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.solidColor ?? PatientColors.primary;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              color: widget.gradient == null ? color : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_isHovered ? 0.45 : 0.35),
                  blurRadius: _isHovered ? 20 : 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                overlayColor: AppColors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.white),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: AppColors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(widget.label, style: AppTextStyles.labelLarge()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color textColor;
  final double height;

  const OutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor = PatientColors.primary,
    this.textColor = PatientColors.primary,
    this.height = 54,
  });

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: _isHovered ? widget.borderColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: widget.borderColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.labelLarge(color: widget.textColor),
          ),
        ),
      ),
    );
  }
}
