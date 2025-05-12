import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create a 512x512 picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Drawing area
  const size = Size(512, 512);
  final rect = Offset.zero & size;

  // Background
  final bgPaint = Paint()..color = const Color(0xFF6200EE);
  canvas.drawRect(rect, bgPaint);

  // Draw clipboard
  final clipboardRect = Rect.fromLTWH(
    size.width * 0.25,
    size.height * 0.15,
    size.width * 0.5,
    size.height * 0.7,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(clipboardRect, const Radius.circular(20)),
    Paint()..color = Colors.white,
  );

  // Draw clipboard top
  final clipTopRect = Rect.fromLTWH(
    size.width * 0.38,
    size.height * 0.08,
    size.width * 0.24,
    size.height * 0.12,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(clipTopRect, const Radius.circular(10)),
    Paint()..color = Colors.white,
  );

  // Draw lines on clipboard
  final linePaint =
      Paint()
        ..color = const Color(0xFF6200EE)
        ..strokeWidth = 6;
  double lineY = size.height * 0.35;
  for (int i = 0; i < 3; i++) {
    canvas.drawLine(
      Offset(size.width * 0.33, lineY),
      Offset(size.width * 0.67, lineY),
      linePaint,
    );
    lineY += size.height * 0.15;
  }

  // Draw checkmark
  final checkPaint =
      Paint()
        ..color = const Color(0xFF03DAC6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round;
  final path =
      Path()
        ..moveTo(size.width * 0.3, size.height * 0.5)
        ..lineTo(size.width * 0.45, size.height * 0.65)
        ..lineTo(size.width * 0.7, size.height * 0.35);
  canvas.drawPath(path, checkPaint);

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Save to file
  final file = File('assets/icon/calendar.png');
  await file.create(recursive: true);
  await file.writeAsBytes(buffer);
  print('Icon saved to ${file.path}');
}
