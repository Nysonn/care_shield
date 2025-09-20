import 'package:flutter/material.dart';
import 'package:care_shield/core/constants.dart';

enum ButtonVariant { primary, secondary, outline }

enum ButtonSize { small, medium, large }

class LoadingButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final Color? customColor;
  final String? loadingText;
  final bool fullWidth;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.loading,
    required this.label,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.customColor,
    this.loadingText,
    this.fullWidth = true,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.loading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final buttonSize = _getButtonSize();

    Widget button = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: Container(
        width: widget.fullWidth ? double.infinity : null,
        height: buttonSize.height,
        child: ElevatedButton(
          onPressed: widget.loading ? null : widget.onPressed,
          style: buttonStyle,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: widget.loading
                ? _buildLoadingContent()
                : _buildNormalContent(),
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: button,
    );
  }

  Widget _buildLoadingContent() {
    final colors = _getColors();
    final textStyle = _getTextStyle();

    return Row(
      key: const ValueKey('loading'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
          ),
        ),
        if (widget.loadingText != null) ...[
          const SizedBox(width: 12),
          Text(widget.loadingText!, style: textStyle),
        ],
      ],
    );
  }

  Widget _buildNormalContent() {
    final textStyle = _getTextStyle();

    return Row(
      key: const ValueKey('normal'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: _getIconSize()),
          const SizedBox(width: 8),
        ],
        Text(widget.label, style: textStyle),
      ],
    );
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();
    final buttonSize = _getButtonSize();

    return ElevatedButton.styleFrom(
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      elevation: widget.variant == ButtonVariant.outline ? 0 : 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonSize.borderRadius),
        side: widget.variant == ButtonVariant.outline
            ? BorderSide(color: colors.background, width: 1.5)
            : BorderSide.none,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: buttonSize.horizontalPadding,
        vertical: buttonSize.verticalPadding,
      ),
      minimumSize: Size(0, buttonSize.height),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.pressed)) {
          return colors.foreground.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return colors.foreground.withOpacity(0.05);
        }
        return null;
      }),
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.disabled)) {
          return colors.background.withOpacity(0.5);
        }
        return colors.background;
      }),
    );
  }

  _ButtonColors _getColors() {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          background: widget.customColor ?? Colors.blue,
          foreground: Colors.white,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.surface,
          foreground: AppColors.text,
        );
      case ButtonVariant.outline:
        return _ButtonColors(
          background: widget.customColor ?? Colors.blue,
          foreground: widget.customColor ?? Colors.blue,
        );
    }
  }

  _ButtonSize _getButtonSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return _ButtonSize(
          height: 36,
          horizontalPadding: 16,
          verticalPadding: 8,
          fontSize: 13,
          borderRadius: 8,
        );
      case ButtonSize.medium:
        return _ButtonSize(
          height: 48,
          horizontalPadding: 20,
          verticalPadding: 12,
          fontSize: 15,
          borderRadius: 12,
        );
      case ButtonSize.large:
        return _ButtonSize(
          height: 56,
          horizontalPadding: 24,
          verticalPadding: 16,
          fontSize: 16,
          borderRadius: 14,
        );
    }
  }

  TextStyle _getTextStyle() {
    final buttonSize = _getButtonSize();
    return TextStyle(
      fontSize: buttonSize.fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;

  _ButtonColors({required this.background, required this.foreground});
}

class _ButtonSize {
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double borderRadius;

  _ButtonSize({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.borderRadius,
  });
}
