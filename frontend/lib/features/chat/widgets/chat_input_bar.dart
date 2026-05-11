import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/adaptive_colors.dart';
import '../../../core/theme/gradients.dart';
import '../../../core/theme/shadows.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/services/haptics.dart';

/// Chat input bar with attachment support and preview chips
class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  final bool isLoading;
  final List<AttachmentPreview> attachments;
  final Function(int index) onRemoveAttachment;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttachment,
    this.isLoading = false,
    this.attachments = const [],
    required this.onRemoveAttachment,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
          ),
          decoration: BoxDecoration(
            // Glassmorphism - adaptive background
            color: isDark
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: AdaptiveColors.primary.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Attachment preview chips
              if (widget.attachments.isNotEmpty) ...[
                _buildAttachmentPreviews(),
                const SizedBox(height: AppSpacing.md),
              ],

              // Input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.isLoading
                        ? null
                        : () {
                            AppHaptics.lightTap();
                            widget.onAttachment();
                          },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isLoading
                            ? AdaptiveColors.fillSecondary(context)
                            : AdaptiveColors.primary.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        CupertinoIcons.plus,
                        color: widget.isLoading
                            ? AdaptiveColors.textTertiary(context)
                            : AdaptiveColors.primary,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Text input
                  Expanded(
                    child: CupertinoTextField(
                      controller: widget.controller,
                      maxLines: 5,
                      minLines: 1,
                      placeholder: 'Ask Jarvis...',
                      placeholderStyle: TextStyle(
                        color: AdaptiveColors.textTertiary(context),
                        fontSize: 16,
                      ),
                      style: TextStyle(
                        color: AdaptiveColors.textPrimary(context),
                        fontSize: 16,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AdaptiveColors.fillPrimary(context),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      onSubmitted: (_) => _handleSend(),
                      enabled: !widget.isLoading,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Send button
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: widget.isLoading ? null : _handleSend,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: widget.isLoading
                            ? null
                            : AppGradients.primary,
                        color: widget.isLoading
                            ? AdaptiveColors.fillSecondary(context)
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: widget.isLoading
                            ? null
                            : AppShadows.primaryGlowIntense,
                      ),
                      child: widget.isLoading
                          ? CupertinoActivityIndicator(
                              color: AdaptiveColors.textSecondary(context),
                            )
                          : const Icon(
                              CupertinoIcons.arrow_up,
                              color: Colors.black,
                              size: 18,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentPreviews() {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.attachments.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final attachment = widget.attachments[index];
          return _AttachmentPreviewChip(
            attachment: attachment,
            onRemove: () {
              AppHaptics.lightTap();
              widget.onRemoveAttachment(index);
            },
          );
        },
      ),
    );
  }

  void _handleSend() {
    if (widget.controller.text.trim().isEmpty && widget.attachments.isEmpty) {
      return;
    }
    AppHaptics.sendMessage();
    widget.onSend();
  }
}

/// Model for attachment preview
class AttachmentPreview {
  final String name;
  final String? path;
  final AttachmentType type;
  final int? size;

  const AttachmentPreview({
    required this.name,
    this.path,
    required this.type,
    this.size,
  });
}

enum AttachmentType { image, document, location }

/// Preview chip for attached files/images
class _AttachmentPreviewChip extends StatelessWidget {
  final AttachmentPreview attachment;
  final VoidCallback onRemove;

  const _AttachmentPreviewChip({
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AdaptiveColors.isDark(context);

    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AdaptiveColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Content
          Center(
            child:
                attachment.type == AttachmentType.image &&
                    attachment.path != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.file(
                      File(attachment.path!),
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getIcon(), color: AdaptiveColors.primary, size: 28),
                      const SizedBox(height: AppSpacing.xs),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Text(
                          attachment.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AdaptiveColors.textSecondary(context),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (attachment.type) {
      case AttachmentType.image:
        return CupertinoIcons.photo;
      case AttachmentType.document:
        return CupertinoIcons.doc;
      case AttachmentType.location:
        return CupertinoIcons.location_fill;
    }
  }
}
