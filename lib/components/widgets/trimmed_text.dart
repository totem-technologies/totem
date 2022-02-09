library readmore;

import 'package:flutter/material.dart';

enum TrimMode {
  length,
  line,
}

class TrimmedText extends StatefulWidget {
  const TrimmedText(
    this.text, {
    Key? key,
    required this.more,
    this.trimLines = 2,
    this.trimLength = 240,
    this.trimMode = TrimMode.line,
    this.style,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.delimiter = _kEllipsis + ' ',
  }) : super(key: key);

  /// Used on TrimMode.Length
  final int trimLength;

  /// Used on TrimMode.Lines
  final int trimLines;

  /// Determines the type of trim. TrimMode.Length takes into account
  /// the number of letters, while TrimMode.Lines takes into account
  /// the number of lines
  final TrimMode trimMode;

  final String delimiter;
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final Widget more;

  @override
  State<StatefulWidget> createState() => _TrimmedTextState();
}

const String _kEllipsis = '\u2026';

class _TrimmedTextState extends State<TrimmedText> {
  bool _readMore = false;

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    TextStyle? effectiveTextStyle = widget.style;
    if (widget.style?.inherit ?? false) {
      effectiveTextStyle = defaultTextStyle.style.merge(widget.style);
    }

    final textAlign =
        widget.textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;
    final textDirection = widget.textDirection ?? Directionality.of(context);
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);
    final overflow = defaultTextStyle.overflow;
    final locale = widget.locale ?? Localizations.maybeLocaleOf(context);

    TextSpan _delimiter = TextSpan(
      text: _readMore ? widget.delimiter : '',
      style: effectiveTextStyle,
    );

    _readMore = false;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;

        // Create a TextSpan with data
        final text = TextSpan(
          style: effectiveTextStyle,
          text: widget.text,
        );

        // Layout and measure link
        /* TextPainter textPainter = TextPainter(
          text: link,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final linkSize = textPainter.size;*/

        // Layout and measure delimiter
        TextPainter textPainter = TextPainter(
          text: _delimiter,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: widget.trimLines,
          ellipsis: overflow == TextOverflow.ellipsis ? widget.delimiter : null,
          locale: locale,
        );
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        final delimiterSize = textPainter.size;

        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;

        // Get the endIndex of data
        int endIndex;

        final readMoreSize = delimiterSize.width;
        final pos = textPainter.getPositionForOffset(Offset(
          textDirection == TextDirection.rtl
              ? readMoreSize
              : textSize.width - readMoreSize,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;

        late TextSpan textSpan;
        switch (widget.trimMode) {
          case TrimMode.length:
            if (widget.trimLength < widget.text.length) {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: widget.text.substring(0, widget.trimLength),
                children: <TextSpan>[_delimiter],
              );
              _readMore = true;
            } else {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: widget.text,
              );
            }
            break;
          case TrimMode.line:
            if (textPainter.didExceedMaxLines) {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: widget.text.substring(0, endIndex),
                children: <TextSpan>[_delimiter],
              );
              _readMore = true;
            } else {
              textSpan = TextSpan(
                style: effectiveTextStyle,
                text: widget.text,
              );
            }
            break;
          default:
            throw Exception(
                'TrimMode type: ${widget.trimMode} is not supported');
        }

        Widget textWidget = RichText(
          textAlign: textAlign,
          textDirection: textDirection,
          softWrap: true,
          //softWrap,
          overflow: TextOverflow.clip,
          //overflow,
          textScaleFactor: textScaleFactor,
          text: textSpan,
        );
        if (_readMore) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [textWidget, widget.more],
          );
        }
        return textWidget;
      },
    );
  }
}
