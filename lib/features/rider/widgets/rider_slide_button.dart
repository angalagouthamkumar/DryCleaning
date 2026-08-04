import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RiderSlideButton extends StatefulWidget {
  final String label;
  final VoidCallback onConfirmed;
  final bool disabled;

  const RiderSlideButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.disabled = false,
  });

  @override
  State<RiderSlideButton> createState() => _RiderSlideButtonState();
}

class _RiderSlideButtonState extends State<RiderSlideButton> {
  double _dragPosition = 0.0;
  bool _isCompleted = false;

  @override
  void didUpdateWidget(covariant RiderSlideButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label) {
      setState(() {
        _isCompleted = false;
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxDrag = maxWidth - 52;

        return ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Container(
            height: 54,
            width: maxWidth,
            decoration: BoxDecoration(
              color: AppColors.darkNavy,
              borderRadius: BorderRadius.circular(27),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _dragPosition + 48,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 48, right: 16),
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: (_dragPosition / (maxDrag == 0 ? 1 : maxDrag)) > 0.45
                            ? AppColors.darkNavy
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _dragPosition + 4,
                  top: 4,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (widget.disabled || _isCompleted) return;
                      setState(() {
                        _dragPosition += details.delta.dx;
                        if (_dragPosition < 0) _dragPosition = 0;
                        if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (widget.disabled || _isCompleted) return;
                      if (_dragPosition >= maxDrag * 0.45) {
                        setState(() {
                          _dragPosition = maxDrag;
                          _isCompleted = true;
                        });
                        widget.onConfirmed();
                      } else {
                        setState(() {
                          _dragPosition = 0;
                        });
                      }
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isCompleted ? Icons.check_rounded : Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
