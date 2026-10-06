import 'dart:async';

import 'package:flutter/material.dart';

/// Search box that reports the text once the user stops typing.
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.hint, required this.onChanged, this.width = 280});

  final String hint;
  final ValueChanged<String> onChanged;
  final double width;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) => SizedBox(
    width: widget.width,
    child: TextField(
      decoration: InputDecoration(hintText: widget.hint, prefixIcon: const Icon(Icons.search), isDense: true),
      onChanged: (value) {
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 350), () => widget.onChanged(value.trim()));
      },
    ),
  );
}

/// Labelled dropdown for list filters, with an "All" option.
class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 200,
  });

  final String label;
  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: DropdownButtonFormField<T?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: [
        DropdownMenuItem<T?>(value: null, child: const Text('All')),
        ...items.entries.map(
          (e) => DropdownMenuItem<T?>(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    ),
  );
}
