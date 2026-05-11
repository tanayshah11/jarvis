import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/widgets/animated_content.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/jarvis_button.dart';
import '../../../core/widgets/jarvis_text_field.dart';
import '../../../core/widgets/state_widgets.dart';
import '../controllers/memory_controller.dart';
import '../models/memory_node.dart';

class MemoryDetailScreen extends ConsumerStatefulWidget {
  final String nodeId;

  const MemoryDetailScreen({
    super.key,
    required this.nodeId,
  });

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _confidenceController = TextEditingController();
  final Map<String, TextEditingController> _attributeControllers = {};

  MemoryNode? _node;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadNode();
  }

  Future<void> _loadNode() async {
    setState(() => _isLoading = true);

    final controller = ref.read(memoryControllerProvider.notifier);
    final node = await controller.getNode(widget.nodeId);

    if (node != null && mounted) {
      setState(() {
        _node = node;
        _labelController.text = node.label;
        _confidenceController.text = node.confidence.toString();

        // Initialize attribute controllers
        for (final entry in node.attributes.entries) {
          _attributeControllers[entry.key] =
              TextEditingController(text: entry.value.toString());
        }

        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _confidenceController.dispose();
    for (final controller in _attributeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_node == null) return;

    setState(() => _isSaving = true);

    final controller = ref.read(memoryControllerProvider.notifier);

    // Parse confidence
    final confidence = double.tryParse(_confidenceController.text) ?? _node!.confidence;

    // Build updated attributes map
    final updatedAttributes = <String, dynamic>{};
    for (final entry in _attributeControllers.entries) {
      updatedAttributes[entry.key] = entry.value.text;
    }

    final success = await controller.updateNode(
      widget.nodeId,
      label: _labelController.text,
      attributes: updatedAttributes,
      confidence: confidence,
    );

    if (mounted) {
      setState(() => _isSaving = false);

      if (success) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload the node
        await _loadNode();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update memory'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  IconData _getNodeTypeIcon() {
    if (_node == null) return Icons.circle;

    switch (_node!.type.toLowerCase()) {
      case 'person':
        return Icons.person;
      case 'place':
        return Icons.place;
      case 'preference':
        return Icons.favorite;
      case 'organization':
        return Icons.business;
      case 'event':
        return Icons.event;
      case 'concept':
        return Icons.lightbulb;
      default:
        return Icons.circle;
    }
  }

  Color _getNodeTypeColor() {
    if (_node == null) return AppColors.textSecondary;

    switch (_node!.type.toLowerCase()) {
      case 'person':
        return const Color(0xFF00D9FF);
      case 'place':
        return const Color(0xFF00C48C);
      case 'preference':
        return const Color(0xFFFF4757);
      case 'organization':
        return const Color(0xFFFFB800);
      case 'event':
        return const Color(0xFF6C5CE7);
      case 'concept':
        return const Color(0xFF8B7CFF);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Memory Details'),
        backgroundColor: AppColors.background,
        actions: [
          if (_node != null && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditing = true);
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isEditing = false);
                // Reset controllers
                if (_node != null) {
                  _labelController.text = _node!.label;
                  _confidenceController.text = _node!.confidence.toString();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingStateWidget(
              message: 'Loading memory details...',
            )
          : _node == null
              ? EmptyStateWidget(
                  title: 'Memory not found',
                  message: 'This memory may have been deleted or does not exist.',
                  icon: Icons.error_outline,
                  iconColor: AppColors.error,
                  onAction: () => Navigator.of(context).pop(),
                  actionText: 'Go Back',
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card
                      AnimatedContent(
                        child: GlassContainer(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: _getNodeTypeColor().withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Icon(
                                  _getNodeTypeIcon(),
                                  size: 32,
                                  color: _getNodeTypeColor(),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _node!.type.toUpperCase(),
                                      style: TextStyle(
                                        color: _getNodeTypeColor(),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'ID: ${_node!.id}',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Label section
                      AnimatedContent(
                        delay: const Duration(milliseconds: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Label',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (_isEditing)
                              JarvisTextField(
                                controller: _labelController,
                                hintText: 'Enter label',
                              )
                            else
                              GlassContainer(
                                child: Text(
                                  _node!.label,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Confidence section
                      AnimatedContent(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Confidence',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (_isEditing)
                              JarvisTextField(
                                controller: _confidenceController,
                                hintText: 'Enter confidence (0.0 - 1.0)',
                                keyboardType: TextInputType.number,
                              )
                            else
                              GlassContainer(
                                child: Row(
                                  children: [
                                    Text(
                                      '${(_node!.confidence * 100).toInt()}%',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: _node!.confidence,
                                        backgroundColor: AppColors.surface,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _node!.confidence >= 0.7
                                              ? AppColors.success
                                              : _node!.confidence >= 0.4
                                                  ? AppColors.warning
                                                  : AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Attributes section
                      AnimatedContent(
                        delay: const Duration(milliseconds: 300),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Attributes',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            if (_node!.attributes.isEmpty)
                              GlassContainer(
                                child: const Text(
                                  'No attributes',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            else
                              ..._buildAttributesList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Stats section
                      AnimatedContent(
                        delay: const Duration(milliseconds: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statistics',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            GlassContainer(
                              child: Column(
                                children: [
                                  _buildStatRow(
                                    'Reference Count',
                                    _node!.referenceCount.toString(),
                                    Icons.link,
                                  ),
                                  if (_node!.similarity != null) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    _buildStatRow(
                                      'Similarity',
                                      '${(_node!.similarity! * 100).toStringAsFixed(1)}%',
                                      Icons.compare_arrows,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Save button
                      if (_isEditing)
                        AnimatedContent(
                          delay: const Duration(milliseconds: 500),
                          child: ScaleOnPress(
                            onPressed: _isSaving ? () {} : _saveChanges,
                            child: JarvisButton(
                              text: 'Save Changes',
                              onPressed: _isSaving ? null : _saveChanges,
                              isLoading: _isSaving,
                              fullWidth: true,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildAttributesList() {
    final widgets = <Widget>[];

    for (final entry in _attributeControllers.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _isEditing
              ? JarvisTextField(
                  controller: entry.value,
                  labelText: entry.key,
                  hintText: 'Enter ${entry.key}',
                )
              : GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        entry.value.text,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
