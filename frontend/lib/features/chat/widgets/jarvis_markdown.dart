import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../../../core/theme/colors.dart';

/// Custom styled markdown renderer with Jarvis gold theme
/// Uses GptMarkdown with custom styling
class JarvisMarkdown extends StatelessWidget {
  final String data;
  final TextStyle? baseStyle;

  const JarvisMarkdown(
    this.data, {
    super.key,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GptMarkdown(
      data,
      style: baseStyle ??
          const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            height: 1.6,
          ),
    );
  }
}

/// Styled markdown text style config
class JarvisMarkdownTheme {
  static TextStyle get h1 => TextStyle(
        color: AppColors.primary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get h2 => const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.4,
      );

  static TextStyle get h3 => TextStyle(
        color: AppColors.textPrimary.withValues(alpha: 0.9),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get body => const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        height: 1.6,
      );

  static TextStyle get bold => const TextStyle(
        fontWeight: FontWeight.w600,
      );

  static TextStyle get italic => const TextStyle(
        fontStyle: FontStyle.italic,
      );

  static TextStyle get link => TextStyle(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary.withValues(alpha: 0.5),
      );

  static TextStyle get code => TextStyle(
        color: AppColors.primary,
        fontFamily: 'monospace',
        fontSize: 13,
        backgroundColor: const Color(0xFF141414),
      );
}

/// Custom list item with gold bullet
class JarvisListItem extends StatelessWidget {
  final Widget child;
  final bool ordered;
  final int? index;

  const JarvisListItem({
    super.key,
    required this.child,
    this.ordered = false,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ordered && index != null)
            SizedBox(
              width: 24,
              child: Text(
                '${index! + 1}.',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 8, right: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Styled blockquote with gold left border
class JarvisBlockquote extends StatelessWidget {
  final Widget child;

  const JarvisBlockquote({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: AppColors.primary,
            width: 3,
          ),
        ),
        color: AppColors.surface.withValues(alpha: 0.5),
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
        child: child,
      ),
    );
  }
}

/// Table with gold header
class JarvisTable extends StatelessWidget {
  final List<List<String>> data;
  final List<String>? headers;

  const JarvisTable({
    super.key,
    required this.data,
    this.headers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 1,
            ),
            verticalInside: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          children: [
            if (headers != null)
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                children: headers!.map((header) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      header,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ...data.map((row) {
              return TableRow(
                children: row.map((cell) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      cell,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
