import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

/// Filter options for conversation history
enum HistoryFilter {
  today('Today', Icons.today_outlined),
  thisWeek('This Week', Icons.date_range_outlined),
  favorites('Favorites', Icons.star_outline_rounded),
  hasMedia('Has Media', Icons.image_outlined);

  final String label;
  final IconData icon;

  const HistoryFilter(this.label, this.icon);
}

/// Horizontal scrollable filter chip bar with animations
///
/// Displays filter chips that can be selected to filter conversation history.
/// Supports both single and multi-select modes with gold-themed styling.
class FilterChipBar extends StatefulWidget {
  /// Callback when selected filters change
  final ValueChanged<Set<HistoryFilter>> onFilterChanged;

  /// Initial selected filters
  final Set<HistoryFilter> initialFilters;

  /// Allow multiple selections (default: true)
  final bool multiSelect;

  /// Show filter icons (default: true)
  final bool showIcons;

  const FilterChipBar({
    super.key,
    required this.onFilterChanged,
    this.initialFilters = const {},
    this.multiSelect = true,
    this.showIcons = true,
  });

  @override
  State<FilterChipBar> createState() => _FilterChipBarState();
}

class _FilterChipBarState extends State<FilterChipBar> {
  late Set<HistoryFilter> _selectedFilters;

  @override
  void initState() {
    super.initState();
    _selectedFilters = Set.from(widget.initialFilters);
  }

  void _toggleFilter(HistoryFilter filter) {
    HapticFeedback.selectionClick();

    setState(() {
      if (widget.multiSelect) {
        // Multi-select mode: toggle the filter
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.remove(filter);
        } else {
          _selectedFilters.add(filter);
        }
      } else {
        // Single-select mode: replace selection or deselect if same
        if (_selectedFilters.contains(filter)) {
          _selectedFilters.clear();
        } else {
          _selectedFilters = {filter};
        }
      }
    });

    widget.onFilterChanged(_selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: HistoryFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = HistoryFilter.values[index];
          final isSelected = _selectedFilters.contains(filter);

          return _FilterChip(
            filter: filter,
            isSelected: isSelected,
            showIcon: widget.showIcons,
            onTap: () => _toggleFilter(filter),
            index: index,
          );
        },
      ),
    );
  }
}

/// Individual filter chip with animations and haptic feedback
class _FilterChip extends StatefulWidget {
  final HistoryFilter filter;
  final bool isSelected;
  final bool showIcon;
  final VoidCallback onTap;
  final int index;

  const _FilterChip({
    required this.filter,
    required this.isSelected,
    required this.showIcon,
    required this.onTap,
    required this.index,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()
          ..setEntry(0, 0, _isPressed ? 0.95 : 1.0)
          ..setEntry(1, 1, _isPressed ? 0.95 : 1.0),
        padding: EdgeInsets.symmetric(
          horizontal: widget.showIcon ? AppSpacing.md : AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: widget.isSelected
              ? AppColors.primaryGradient
              : null,
          color: widget.isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.primary
                : Colors.white.withValues(alpha: 0.1),
            width: widget.isSelected ? 1.5 : 1,
          ),
          boxShadow: widget.isSelected && !_isPressed
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.filter.icon,
                  size: 18,
                  color: widget.isSelected
                      ? Colors.black
                      : AppColors.textSecondary,
                ),
              )
                  .animate(
                    target: widget.isSelected ? 1 : 0,
                  )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.15, 1.15),
                    duration: 200.ms,
                    curve: Curves.easeOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.15, 1.15),
                    end: const Offset(1.0, 1.0),
                    duration: 100.ms,
                    curve: Curves.easeIn,
                  ),
              const SizedBox(width: AppSpacing.xs),
            ],
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: widget.isSelected
                    ? Colors.black
                    : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(widget.filter.label),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }
}
