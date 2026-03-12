// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// /// Text field that expands with content up to [maxHeightPx],
// /// then blocks further typing. Works across different fonts/sizes.
// class HeightCappedTextField extends StatefulWidget {
//   const HeightCappedTextField({
//     super.key,
//     required this.controller,
//     required this.maxHeightPx,
//     this.decoration = const InputDecoration(
//       border: OutlineInputBorder(),
//       hintText: 'Type…',
//       isCollapsed: false,
//       contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     ),
//     this.style,
//     this.onLimitReached,
//     this.cursorColor,
//   });
//
//   final TextEditingController controller;
//   final double maxHeightPx;
//   final InputDecoration decoration;
//   final TextStyle? style;
//   final VoidCallback? onLimitReached;
//   final Color? cursorColor;
//
//   @override
//   State<HeightCappedTextField> createState() => _HeightCappedTextFieldState();
// }
//
// class _HeightCappedTextFieldState extends State<HeightCappedTextField> {
//   late final _formatter = _HeightLimitFormatter(widget.maxHeightPx);
//
//   @override
//   void didUpdateWidget(covariant HeightCappedTextField oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // keep formatter in sync if max height or style changes
//     _formatter.maxHeightPx = widget.maxHeightPx;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final baseStyle = DefaultTextStyle.of(context).style.merge(widget.style);
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final contentPad =
//             widget.decoration.contentPadding ?? const EdgeInsets.all(0);
//         // tell formatter how wide the actual text area is
//         _formatter
//           ..availableWidth = constraints.maxWidth - contentPad.horizontal
//           ..textStyle = baseStyle
//           ..verticalPadding = contentPad.vertical
//           ..onLimitReached = widget.onLimitReached;
//
//         return ConstrainedBox(
//           constraints: BoxConstraints(maxHeight: widget.maxHeightPx),
//           child: TextFormField(
//             controller: widget.controller,
//             maxLines: null, // expand naturally
//             keyboardType: TextInputType.multiline,
//             textInputAction: TextInputAction.newline,
//             style: baseStyle,
//             textAlign: TextAlign.center,
//             showCursor: true,
//             cursorColor: widget.cursorColor,
//             decoration: widget.decoration,
//             // kill internal scrolling; we hard-stop instead
//             scrollPhysics: const NeverScrollableScrollPhysics(),
//             inputFormatters: <TextInputFormatter>[_formatter],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _HeightLimitFormatter extends TextInputFormatter {
//   _HeightLimitFormatter(this.maxHeightPx);
//
//   double maxHeightPx;
//   double availableWidth = double.infinity;
//   double verticalPadding = 0;
//   TextStyle? textStyle;
//   VoidCallback? onLimitReached;
//
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue,
//       TextEditingValue newValue,
//       ) {
//     // If we don't know width yet, allow the input.
//     if (availableWidth == double.infinity || textStyle == null) {
//       return newValue;
//     }
//
//     // Measure rendered height of the *new* text
//     final painter = TextPainter(
//       text: TextSpan(text: newValue.text, style: textStyle),
//       textDirection: TextDirection.ltr,
//       maxLines: null,
//     )..layout(maxWidth: availableWidth);
//
//     final totalHeight = painter.size.height + verticalPadding;
//
//     if (totalHeight > maxHeightPx) {
//       // block input and ping callback (once per try)
//       onLimitReached?.call();
//       return oldValue;
//     }
//     return newValue;
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Expands with content up to [maxHeightPx], then:
///  - blocks more typing, and
///  - auto-trims on font/width changes so text still fits.
class HeightCappedTextField extends StatefulWidget {
  const HeightCappedTextField({
    super.key,
    required this.controller,
    required this.maxHeightPx,
    this.decoration = const InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Type…',
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    this.style,
    this.onLimitReached,
    this.cursorColor,
    this.autoTrimOnStyleOrWidthChange = true,
  });

  final TextEditingController controller;
  final double maxHeightPx;
  final InputDecoration decoration;
  final TextStyle? style;
  final VoidCallback? onLimitReached;
  final Color? cursorColor;
  final bool autoTrimOnStyleOrWidthChange;

  @override
  State<HeightCappedTextField> createState() => _HeightCappedTextFieldState();
}

class _HeightCappedTextFieldState extends State<HeightCappedTextField> {
  late final _formatter = _HeightLimitFormatter(widget.maxHeightPx);

  @override
  void didUpdateWidget(covariant HeightCappedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _formatter.maxHeightPx = widget.maxHeightPx;
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style.merge(widget.style);

    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = widget.decoration.contentPadding ?? EdgeInsets.zero;

        _formatter
          ..availableWidth = constraints.maxWidth - pad.horizontal
          ..textStyle = baseStyle
          ..verticalPadding = pad.vertical
          ..onLimitReached = widget.onLimitReached;

        if (widget.autoTrimOnStyleOrWidthChange &&
            _formatter.availableWidth.isFinite) {
          // After layout, make sure current text still fits new font/width.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _enforceFit(baseStyle, _formatter.availableWidth, pad.vertical);
          });
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.maxHeightPx),
          child: TextFormField(
            controller: widget.controller,
            maxLines: null, // natural expansion
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: baseStyle,
            textAlign: TextAlign.center,
            showCursor: true,
            cursorColor: widget.cursorColor,
            decoration: widget.decoration,
            scrollPhysics: const NeverScrollableScrollPhysics(), // no hidden scroll
            inputFormatters: <TextInputFormatter>[_formatter],
          ),
        );
      },
    );
  }

  void _enforceFit(TextStyle style, double maxWidth, double verticalPad) {
    final text = widget.controller.text;
    if (text.isEmpty) return;

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);

    final total = painter.size.height + verticalPad;
    if (total <= widget.maxHeightPx) return;

    final trimmed = _trimToFit(
      text: text,
      style: style,
      maxWidth: maxWidth,
      maxHeightPx: widget.maxHeightPx - verticalPad,
    );

    if (trimmed != text) {
      widget.controller.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
      widget.onLimitReached?.call();
    }
  }

  String _trimToFit({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required double maxHeightPx,
  }) {
    final chars = text.characters;
    int lo = 0, hi = chars.length, best = 0;

    while (lo <= hi) {
      final mid = (lo + hi) >> 1;
      final candidate = chars.take(mid).toString();
      final p = TextPainter(
        text: TextSpan(text: candidate, style: style),
        textDirection: TextDirection.ltr,
        maxLines: null,
      )..layout(maxWidth: maxWidth);

      if (p.size.height <= maxHeightPx) {
        best = mid;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }

    return chars.take(best).toString();
  }
}

class _HeightLimitFormatter extends TextInputFormatter {
  _HeightLimitFormatter(this.maxHeightPx);

  double maxHeightPx;
  double availableWidth = double.infinity;
  double verticalPadding = 0;
  TextStyle? textStyle;
  VoidCallback? onLimitReached;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (availableWidth == double.infinity || textStyle == null) {
      return newValue; // can't measure yet
    }

    final painter = TextPainter(
      text: TextSpan(text: newValue.text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: availableWidth);

    final totalHeight = painter.size.height + verticalPadding;
    if (totalHeight > maxHeightPx) {
      onLimitReached?.call();
      return oldValue; // block overflow
    }
    return newValue;
  }
}

