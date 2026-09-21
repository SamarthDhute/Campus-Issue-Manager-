import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_issue_manager/features/resolution/presentation/widgets/media_attachment_picker.dart';

void main() {
  group('MediaAttachmentPicker Widget Tests', () {
    testWidgets('Renders camera and gallery buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaAttachmentPicker(
              onFilesChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Attach Photos & Evidence'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery / Files'), findsOneWidget);
      expect(find.text('0/5'), findsOneWidget);
    });

    testWidgets('Displays thumbnails for initial picked items', (WidgetTester tester) async {
      // 1x1 valid transparent PNG
      final validPng = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
      ]);

      final sampleItems = [
        PickedMediaItem(
          fileName: 'tap.png',
          bytes: validPng,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaAttachmentPicker(
              initialFiles: sampleItems,
              onFilesChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('1/5'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
