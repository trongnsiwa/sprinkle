import 'package:flutter/material.dart';

class SprinkleLogo extends StatelessWidget {
  final double size;
  final bool usePng;

  const SprinkleLogo({super.key, this.size = 60, this.usePng = true});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Center(
            child: Text('✨', style: TextStyle(fontSize: size * 0.5)),
          ),
        );
      },
    );
  }
}
