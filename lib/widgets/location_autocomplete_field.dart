import 'package:flutter/material.dart';
import '../services/location_data_services.dart';

class LocationAutocompleteField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final LocationOption? value;
  final List<LocationOption> options;
  final ValueChanged<LocationOption> onSelected;
  final Object? refreshKey;

  const LocationAutocompleteField({
    super.key,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.value,
    required this.options,
    required this.onSelected,
    this.refreshKey,
  });


  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.label ?? "");
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(LocationAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final dependencyChanged = oldWidget.refreshKey != widget.refreshKey;

    if (dependencyChanged) {
      _controller.text = widget.value?.label ?? "";

      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }

      return;
    }

    if (oldWidget.value?.code != widget.value?.code) {
      _controller.text = widget.value?.label ?? "";
    }

    if (!widget.enabled && oldWidget.enabled) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<LocationOption>(
      textEditingController: _controller,
      focusNode: _focusNode,
      displayStringForOption: (option) => option.label,
      optionsBuilder: (value) {
        if(!widget.enabled) return const Iterable<LocationOption>.empty();

        final query = value.text.trim().toLowerCase();

        if(query.isEmpty) {
          return widget.options.take(25);
        }

        return widget.options
          .where((option) => option.label.toLowerCase().contains(query))
          .take(30);
      },
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);

                  return ListTile(
                    dense: true,
                    title: Text(option.label),
                    onTap:  () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
