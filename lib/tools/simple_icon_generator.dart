import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;

class AppIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Background gradient
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [const Color(0xFF6200EE), const Color(0xFF3700B3)],
    );

    final paint =
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.fill;

    // Draw rounded rectangle background
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.2)),
      paint,
    );

    // Draw check mark
    final checkPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.08
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.7);
    path.lineTo(size.width * 0.75, size.height * 0.3);

    canvas.drawPath(path, checkPaint);

    // Draw circle behind check
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.35,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  final size = const Size(512, 512);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Paint the icon
  final painter = AppIconPainter();
  painter.paint(canvas, size);

  // Convert to image
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final pngBytes = byteData!.buffer.asUint8List();

  // Save to file
  final file = File('d:/Git repository/Android/first/assets/icon/app_icon.png');
  await file.writeAsBytes(pngBytes);
  print('Icon saved to: ${file.path}');
}
