import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';

/// A flip-animated letter tile used in the scramble grid and input strip.
///
/// When [isSelected] changes, the tile animates a 3D flip. Tiles are square by
/// default; the input strip uses slightly smaller tiles via [size].
class LetterTile extends StatefulWidget {
  const LetterTile({
    super.key,
    required this.letter,
    this.onTap,
    this.isSelected = false,
    this.revealed = false,
    this.size = 56,
  });

  final String letter;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool revealed;
  final double size;

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _rotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected ||
        oldWidget.revealed != widget.revealed) {
      _controller.forward(from: 0).then((_) {
        if (mounted) {
          _controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final bg = widget.revealed
        ? AppColors.correct
        : (widget.isSelected
            ? Theme.of(context).colorScheme.primary
            : (isDark ? AppColors.tileDark : AppColors.tileLight));
    final fg = widget.revealed || widget.isSelected
        ? Colors.white
        : (isDark ? AppColors.textDark : AppColors.textLight);

    return AnimatedBuilder(
      animation: _rotation,
      builder: (context, child) {
        final angle = _rotation.value * math.pi;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(angle);
        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: _Tile(
            letter: widget.letter,
            onTap: widget.onTap,
            bg: bg,
            fg: fg,
            size: widget.size,
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.letter,
    required this.onTap,
    required this.bg,
    required this.fg,
    required this.size,
  });

  final String letter;
  final VoidCallback? onTap;
  final Color bg;
  final Color fg;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              letter.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
