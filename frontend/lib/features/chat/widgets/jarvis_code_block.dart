import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

/// Premium code block with syntax highlighting appearance and copy button
class JarvisCodeBlock extends StatefulWidget {
  final String code;
  final String? language;

  const JarvisCodeBlock({
    super.key,
    required this.code,
    this.language,
  });

  @override
  State<JarvisCodeBlock> createState() => _JarvisCodeBlockState();
}

class _JarvisCodeBlockState extends State<JarvisCodeBlock> {
  bool _copied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);

    // Reset after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.md - 1),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Language label
                if (widget.language != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.language!,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // Copy button
                _CopyButton(
                  copied: _copied,
                  onTap: _copyToClipboard,
                ),
              ],
            ),
          ),
          // Code content with line numbers
          _CodeContent(code: widget.code),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.98, 0.98),
          duration: 200.ms,
        );
  }
}

class _CopyButton extends StatelessWidget {
  final bool copied;
  final VoidCallback onTap;

  const _CopyButton({
    required this.copied,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: copied
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: copied
                ? AppColors.success.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 14,
              color: copied ? AppColors.success : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              copied ? 'Copied!' : 'Copy',
              style: TextStyle(
                color: copied ? AppColors.success : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeContent extends StatelessWidget {
  final String code;

  const _CodeContent({required this.code});

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    final lineCount = lines.length;
    final lineNumberWidth = lineCount.toString().length * 10.0 + 16;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line numbers
              SizedBox(
                width: lineNumberWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(lineCount, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                          fontSize: 13,
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Separator
              Container(
                width: 1,
                height: lineCount * 19.5,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              const SizedBox(width: 12),
              // Code
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.map((line) {
                  return Text(
                    line.isEmpty ? ' ' : line,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontFamily: 'monospace',
                      height: 1.5,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline code style widget
class JarvisInlineCode extends StatelessWidget {
  final String code;

  const JarvisInlineCode({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
