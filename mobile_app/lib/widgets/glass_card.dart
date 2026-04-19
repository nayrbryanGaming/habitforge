import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Alignment begin;
  final Alignment end;
  final Color? color;
  final double opacity;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 32.0,
    this.blur = 20.0,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.color,
    this.opacity = 0.1,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? Colors.white;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: baseColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
              gradient: LinearGradient(
                begin: begin,
                end: end,
                colors: [
                  baseColor.withValues(alpha: opacity),
                  baseColor.withValues(alpha: opacity * 0.4),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Inner Shine / Rim Light
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

