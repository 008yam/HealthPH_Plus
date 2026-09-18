import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SixDigitPinField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const SixDigitPinField({
    super.key,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<SixDigitPinField> createState() => _SixDigitPinFieldState();
}

class _SixDigitPinFieldState extends State<SixDigitPinField> {
  FocusNode? _internalFocusNode;

  FocusNode get pinFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SixDigitPinField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  void _handleControllerChanged() {
    final pin = widget.controller.text;

    if (mounted) {
      setState(() {});
    }

    widget.onChanged?.call(pin);

    if (pin.length == 6) {
      widget.onCompleted?.call(pin);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pin = widget.controller.text;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: "Six-digit PIN",
      textField: true,
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            Row(
              children: List.generate(6, (index) {
                final hasDigit = index < pin.length;
                final isActive =
                    widget.enabled &&
                    pin.length < 6 &&
                    index == pin.length;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 5 ? 0 : 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        hasDigit ? "•" : "",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: ExcludeSemantics(
                child: Opacity(
                  opacity: 0.01,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: pinFocusNode,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      widget.controller.selection =
                          TextSelection.collapsed(
                            offset: widget.controller.text.length,
                          );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}