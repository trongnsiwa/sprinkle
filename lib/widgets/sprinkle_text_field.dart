import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../utils/typography.dart';

enum SprinkleTextFieldStyle { underline, outline }

class SprinkleTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final SprinkleTextFieldStyle style;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<Widget>? chips;
  final bool isDark;

  const SprinkleTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.style = SprinkleTextFieldStyle.underline,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.chips,
    this.isDark = true,
  });

  @override
  State<SprinkleTextField> createState() => _SprinkleTextFieldState();
}

class _SprinkleTextFieldState extends State<SprinkleTextField> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode.addListener(_handleFocusChange);
    _isFocused = _effectiveFocusNode.hasFocus;
  }

  @override
  void didUpdateWidget(SprinkleTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(_handleFocusChange);
      _effectiveFocusNode.addListener(_handleFocusChange);
      _isFocused = _effectiveFocusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_effectiveFocusNode.hasFocus != _isFocused) {
      if (mounted) {
        setState(() {
          _isFocused = _effectiveFocusNode.hasFocus;
        });
      }
      if (_effectiveFocusNode.hasFocus) {
        HapticFeedback.selectionClick();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasChips = widget.chips != null && widget.chips!.isNotEmpty;
    final showChipsOnly = hasChips && !_isFocused;

    const labelColor = AppColors.primary;
    final hintColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.3)
        : AppColors.neutralLight;
    final textColor = widget.isDark ? Colors.white : AppColors.neutral;
    final fillColor = widget.isDark ? const Color(0xFF2C2C2E) : AppColors.neutralUltraLight;
    final iconColor = _isFocused
        ? AppColors.primary
        : (widget.isDark ? Colors.white54 : AppColors.neutralLight);

    return AnimatedScale(
      scale: _isFocused ? 1.01 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (!_effectiveFocusNode.hasFocus) {
                FocusScope.of(context).requestFocus(_effectiveFocusNode);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFocused
                      ? AppColors.primary
                      : (widget.isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : AppColors.neutralLight.withValues(alpha: 0.3)),
                  width: _isFocused ? 1.5 : 1.0,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: widget.maxLines > 1
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      if (widget.prefixIcon != null) ...[
                        Padding(
                          padding: EdgeInsets.only(
                            top: widget.maxLines > 1 ? 6 : 0,
                            right: 10,
                          ),
                          child: IconTheme(
                            data: IconThemeData(
                              color: iconColor,
                              size: 20,
                            ),
                            child: widget.prefixIcon!,
                          ),
                        ),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.label.toUpperCase(),
                              style: AppTypography.labelBold.copyWith(
                                color: labelColor,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (showChipsOnly) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: widget.chips!,
                              ),
                            ] else ...[
                              TextField(
                                controller: widget.controller,
                                focusNode: _effectiveFocusNode,
                                onChanged: widget.onChanged,
                                maxLines: widget.maxLines,
                                maxLength: widget.maxLength,
                                keyboardType: widget.keyboardType,
                                textInputAction: widget.textInputAction,
                                onSubmitted: widget.onSubmitted,
                                style: AppTypography.bodyLarge.copyWith(color: textColor),
                                buildCounter: widget.maxLength != null
                                    ? (context, {required currentLength, required isFocused, maxLength}) =>
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              '$currentLength/$maxLength',
                                              style: AppTypography.caption.copyWith(
                                                color: _isFocused
                                                    ? AppColors.primary.withValues(alpha: 0.8)
                                                    : (widget.isDark ? Colors.white38 : AppColors.neutralLight),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        )
                                    : null,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  isDense: true,
                                  hintText: widget.hint,
                                  hintStyle: AppTypography.bodyLarge.copyWith(color: hintColor),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                  suffixIcon: widget.suffixIcon,
                                ),
                              ),
                              if (hasChips) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: widget.chips!,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
