import 'package:flutter/material.dart';
import 'package:my_template/core/theme/app_text_style.dart';

class SlidingTextWidget extends StatefulWidget {
  final String text;

  const SlidingTextWidget({required this.text});

  @override
  State<SlidingTextWidget> createState() => _SlidingTextWidgetState();
}

class _SlidingTextWidgetState extends State<SlidingTextWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

    _animation = Tween<double>(
      begin: 1,
      end: -1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return FractionalTranslation(translation: Offset(_animation.value, 0), child: child);
        },
        child: Row(
          children: [
            Text(
              widget.text,
              style: AppTextStyle.text14RGrey(
                context,
                color: Colors.white,
              ).copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}
