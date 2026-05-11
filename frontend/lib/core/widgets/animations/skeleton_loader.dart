import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';

/// Base skeleton loader with gold shimmer gradient animation
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? (borderRadius ?? BorderRadius.circular(AppRadius.sm)) : null,
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0A0A0A), // AppColors.surface
            Color(0xFF1A1610), // Dark gold tint
            Color(0xFF0A0A0A), // AppColors.surface
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: AppColors.primary.withValues(alpha: 0.1),
          angle: 0, // Horizontal shimmer
        )
        .animate(onPlay: (controller) => controller.repeat())
        .custom(
          duration: 2000.ms,
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Color(0x00D4AF37),
                    AppColors.primary,
                    Color(0x00D4AF37),
                  ],
                  stops: [
                    (value - 0.3).clamp(0.0, 1.0),
                    value.clamp(0.0, 1.0),
                    (value + 0.3).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: child,
            );
          },
        );
  }
}

/// Skeleton placeholder for text with configurable width and lines
class SkeletonText extends StatelessWidget {
  final double? width;
  final int lines;
  final double lineHeight;
  final double lineSpacing;
  final double? lastLineWidth;

  const SkeletonText({
    super.key,
    this.width,
    this.lines = 1,
    this.lineHeight = 16,
    this.lineSpacing = 8,
    this.lastLineWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return SkeletonLoader(
        width: width ?? double.infinity,
        height: lineHeight,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) {
          final isLastLine = index == lines - 1;
          final lineWidth = isLastLine && lastLineWidth != null
              ? lastLineWidth!
              : (width ?? double.infinity);

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < lines - 1 ? lineSpacing : 0,
            ),
            child: SkeletonLoader(
              width: lineWidth,
              height: lineHeight,
            ),
          );
        },
      ),
    );
  }
}

/// Circular skeleton placeholder for avatars
class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({
    super.key,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      shape: BoxShape.circle,
    );
  }
}

/// Card-shaped skeleton placeholder
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
        ),
        child: child,
      );
    }

    return SkeletonLoader(
      width: width ?? double.infinity,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
    );
  }
}

/// Skeleton placeholder that matches the message bubble layout
class SkeletonMessageBubble extends StatelessWidget {
  final bool isUser;
  final int lines;

  const SkeletonMessageBubble({
    super.key,
    this.isUser = false,
    this.lines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar skeleton
          const SkeletonAvatar(size: 28),
          const SizedBox(width: AppSpacing.md),
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label skeleton
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SkeletonLoader(
                    width: isUser ? 30 : 50,
                    height: 13,
                  ),
                ),
                // Message content skeleton
                SkeletonText(
                  lines: lines,
                  lineHeight: 15,
                  lineSpacing: 6,
                  lastLineWidth: MediaQuery.of(context).size.width * 0.6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton placeholder for a list of message bubbles
class SkeletonMessageList extends StatelessWidget {
  final int messageCount;

  const SkeletonMessageList({
    super.key,
    this.messageCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        messageCount,
        (index) => SkeletonMessageBubble(
          isUser: index.isEven,
          lines: (index % 3) + 2, // Vary between 2-4 lines
        ),
      ),
    );
  }
}

/// Skeleton placeholder for list items
class SkeletonListItem extends StatelessWidget {
  final bool hasAvatar;
  final bool hasTrailing;
  final int titleLines;
  final int? subtitleLines;

  const SkeletonListItem({
    super.key,
    this.hasAvatar = false,
    this.hasTrailing = false,
    this.titleLines = 1,
    this.subtitleLines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Leading avatar
          if (hasAvatar) ...[
            const SkeletonAvatar(size: 40),
            const SizedBox(width: AppSpacing.md),
          ],
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonText(
                  lines: titleLines,
                  lineHeight: 16,
                  lineSpacing: 4,
                ),
                if (subtitleLines != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  SkeletonText(
                    lines: subtitleLines!,
                    lineHeight: 14,
                    lineSpacing: 4,
                    width: MediaQuery.of(context).size.width * 0.7,
                  ),
                ],
              ],
            ),
          ),
          // Trailing
          if (hasTrailing) ...[
            const SizedBox(width: AppSpacing.md),
            const SkeletonLoader(width: 60, height: 20),
          ],
        ],
      ),
    );
  }
}

/// Skeleton placeholder for a button
class SkeletonButton extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonButton({
    super.key,
    this.width = 120,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(AppRadius.full),
    );
  }
}

/// Skeleton placeholder for an image or thumbnail
class SkeletonImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const SkeletonImage({
    super.key,
    this.width,
    this.height,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? (width != null ? width! / aspectRatio : null);

    return SkeletonLoader(
      width: width ?? double.infinity,
      height: effectiveHeight ?? 200,
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.md),
    );
  }
}
