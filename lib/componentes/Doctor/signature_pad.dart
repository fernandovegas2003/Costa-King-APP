import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({
    super.key,
    this.penColor = Colors.black,
    this.strokeWidth = 2.0,
    this.controller,
  });

  final Color penColor;
  final double strokeWidth;
  final SignaturePadController? controller;

  @override
  SignaturePadState createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final GlobalKey _boundaryKey = GlobalKey();
  final List<Offset?> _points = <Offset?>[];
  late SignaturePadController _controller;

  bool get isEmpty => _points.isEmpty;
  SignaturePadController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? SignaturePadController())
      .._attach(this);
  }

  @override
  void didUpdateWidget(covariant SignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      _controller = (widget.controller ?? SignaturePadController())
        .._attach(this);
    }
  }

  @override
  void dispose() {
    _controller._detach();
    super.dispose();
  }

  void clear() {
    setState(_points.clear);
  }

  Future<Uint8List?> toPngBytes({double pixelRatio = 3.0}) async {
    if (_points.isEmpty) return null;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _addPoint(Offset point) {
    setState(() {
      _points.add(point);
    });
  }

  void _endStroke() {
    setState(() {
      _points.add(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _boundaryKey,
      child: GestureDetector(
        onPanStart: (details) {
          final box = context.findRenderObject() as RenderBox?;
          final localPosition = box?.globalToLocal(details.globalPosition);
          if (localPosition != null) {
            _addPoint(localPosition);
          }
        },
        onPanUpdate: (details) {
          final box = context.findRenderObject() as RenderBox?;
          final localPosition = box?.globalToLocal(details.globalPosition);
          if (localPosition != null) {
            _addPoint(localPosition);
          }
        },
        onPanEnd: (_) {
          if (_points.isNotEmpty && _points.last != null) {
            _endStroke();
          }
        },
        child: CustomPaint(
          painter: _SignaturePainter(
            points: _points,
            color: widget.penColor,
            strokeWidth: widget.strokeWidth,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class SignaturePadController {
  SignaturePadState? _state;

  bool get isAttached => _state != null;
  bool get isEmpty => _state?._points.isEmpty ?? true;
  bool get hasPoints => !isEmpty;

  List<Offset?> get points =>
      List<Offset?>.unmodifiable(_state?._points ?? const <Offset?>[]);

  void clear() {
    _state?.clear();
  }

  Future<Uint8List?> toPngBytes({double pixelRatio = 3.0}) {
    return _state?.toPngBytes(pixelRatio: pixelRatio) ?? Future.value(null);
  }

  void _attach(SignaturePadState state) {
    _state = state;
  }

  void _detach() {
    _state = null;
  }
}


class _SignaturePainter extends CustomPainter {
  const _SignaturePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      final point = points[i];
      final next = points[i + 1];
      if (point != null && next != null) {
        canvas.drawLine(point, next, paint);
      } else if (point != null && next == null) {
        canvas.drawPoints(ui.PointMode.points, [point], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
