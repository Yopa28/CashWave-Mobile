import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final ValueChanged<T?>? onChanged;
  final String Function(T item)? itemLabel;
  final String? hint;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    this.onChanged,
    this.itemLabel,
    this.hint,
  });

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xff087A55);
  static const Color primaryLight = Color(0xffE8F5F0);

  static const Color background = Color(0xffF7F9F8);
  static const Color textPrimary = Color(0xff17221E);
  static const Color textSecondary = Color(0xff7A8581);
  static const Color borderColor = Color(0xffE5EBE8);

  // ============================================================
  // ITEM LABEL
  // ============================================================

  String _getItemLabel(T item) {
    if (itemLabel != null) {
      return itemLabel!(item);
    }

    return item.toString();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // LABEL
        // ======================================================

        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        // ======================================================
        // DROPDOWN
        // ======================================================
        DropdownButtonFormField<T>(
          value: value,

          onChanged: onChanged,

          isExpanded: true,

          icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: primary,
              size: 20,
            ),
          ),

          dropdownColor: colorScheme.surfaceContainerHighest,

          borderRadius: BorderRadius.circular(16),

          menuMaxHeight: 300,

          items: items.map((T item) {
            final String text = _getItemLabel(item);

            final bool isSelected = item == value;

            return DropdownMenuItem<T>(
              value: item,

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),

                  if (isSelected)
                    const Icon(Icons.check_rounded, color: primary, size: 18),
                ],
              ),
            );
          }).toList(),

          hint: hint != null
              ? Text(
                  hint!,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,

          decoration: InputDecoration(
            filled: true,

            fillColor: colorScheme.surface,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: borderColor),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: borderColor),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: primary, width: 1.4),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: borderColor),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xffD9534F)),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color(0xffD9534F),
                width: 1.4,
              ),
            ),

            errorStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
