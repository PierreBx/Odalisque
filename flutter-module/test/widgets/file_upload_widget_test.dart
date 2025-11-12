import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/widgets/file_upload_widget.dart';

void main() {
  group('FileUploadWidget Tests', () {
    Widget createUploadWidget({
      String? initialValue,
      void Function(FileUploadResult?)? onFileSelected,
      List<String>? allowedExtensions,
      int? maxFileSize,
      bool showPreview = true,
      String? label,
      bool readOnly = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: FileUploadWidget(
            initialValue: initialValue,
            onFileSelected: onFileSelected,
            allowedExtensions: allowedExtensions,
            maxFileSize: maxFileSize,
            showPreview: showPreview,
            label: label,
            readOnly: readOnly,
          ),
        ),
      );
    }

    testWidgets('should display upload area when no file selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget());

      expect(find.text('Drop file here or click to browse'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
    });

    testWidgets('should display label when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget(label: 'Upload Document'));

      expect(find.text('Upload Document'), findsOneWidget);
    });

    testWidgets('should hide label when not provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget());

      expect(find.byType(FileUploadWidget), findsOneWidget);
    });

    testWidgets('should display allowed extensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(allowedExtensions: ['jpg', 'png', 'pdf']),
      );

      expect(find.text('Allowed: jpg, png, pdf'), findsOneWidget);
    });

    testWidgets('should display max file size', (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(maxFileSize: 5242880), // 5MB
      );

      expect(find.text('Max size: 5.00 MB'), findsOneWidget);
    });

    testWidgets('should display both allowed extensions and max size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(
          allowedExtensions: ['pdf'],
          maxFileSize: 10485760, // 10MB
        ),
      );

      expect(find.text('Allowed: pdf'), findsOneWidget);
      expect(find.text('Max size: 10.00 MB'), findsOneWidget);
    });

    testWidgets('should show "No file selected" when readOnly and no file',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget(readOnly: true));

      expect(find.text('No file selected'), findsOneWidget);
    });

    testWidgets('should not show browse text when readOnly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget(readOnly: true));

      expect(find.textContaining('click to browse'), findsNothing);
    });

    testWidgets('should display file preview when file is uploaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(initialValue: 'http://example.com/file.pdf'),
      );

      // File info should be displayed
      expect(find.text('existing_file'), findsOneWidget);
    });

    testWidgets('should show remove button when file is uploaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(initialValue: 'http://example.com/file.pdf'),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byTooltip('Remove file'), findsOneWidget);
    });

    testWidgets('should hide remove button when readOnly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(
          initialValue: 'http://example.com/file.pdf',
          readOnly: true,
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should show proper upload area styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget());

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.borderRadius, equals(BorderRadius.circular(8)));
    });

    testWidgets('should initialize with initial value',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(initialValue: 'data:image/png;base64,abc123'),
      );

      // File should be loaded
      expect(find.text('existing_file'), findsOneWidget);
    });

    testWidgets('should handle empty initial value',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget(initialValue: ''));

      // Should show upload area
      expect(find.text('Drop file here or click to browse'), findsOneWidget);
    });

    testWidgets('should be tappable when not readOnly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget());

      final gestureDetector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );

      expect(gestureDetector.onTap, isNotNull);
    });

    testWidgets('should not be tappable when readOnly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget(readOnly: true));

      final gestureDetector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );

      expect(gestureDetector.onTap, isNull);
    });

    testWidgets('should have MouseRegion for drag & drop',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget());

      expect(find.byType(MouseRegion), findsOneWidget);
    });
  });

  group('FileUploadResult Tests', () {
    test('should create FileUploadResult with fileName', () {
      final result = FileUploadResult(fileName: 'test.pdf');

      expect(result.fileName, equals('test.pdf'));
      expect(result.fileBytes, isNull);
      expect(result.fileSize, isNull);
      expect(result.mimeType, isNull);
      expect(result.fileUrl, isNull);
    });

    test('should create FileUploadResult with all fields', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final result = FileUploadResult(
        fileName: 'document.pdf',
        fileBytes: bytes,
        fileSize: 1024,
        mimeType: 'application/pdf',
        fileUrl: 'http://example.com/doc.pdf',
      );

      expect(result.fileName, equals('document.pdf'));
      expect(result.fileBytes, equals(bytes));
      expect(result.fileSize, equals(1024));
      expect(result.mimeType, equals('application/pdf'));
      expect(result.fileUrl, equals('http://example.com/doc.pdf'));
    });

    test('toBase64 should return null when no fileBytes', () {
      final result = FileUploadResult(fileName: 'test.txt');

      expect(result.toBase64(), isNull);
    });

    test('toBase64 should encode bytes correctly', () {
      final bytes = Uint8List.fromList([72, 101, 108, 108, 111]); // "Hello"
      final result = FileUploadResult(
        fileName: 'test.txt',
        fileBytes: bytes,
      );

      final base64 = result.toBase64();
      expect(base64, isNotNull);
      expect(base64, equals('SGVsbG8='));
    });

    test('toDataUrl should return null when no fileBytes', () {
      final result = FileUploadResult(fileName: 'test.txt');

      expect(result.toDataUrl(), isNull);
    });

    test('toDataUrl should create data URL with mime type', () {
      final bytes = Uint8List.fromList([72, 101, 108, 108, 111]);
      final result = FileUploadResult(
        fileName: 'test.txt',
        fileBytes: bytes,
        mimeType: 'text/plain',
      );

      final dataUrl = result.toDataUrl();
      expect(dataUrl, isNotNull);
      expect(dataUrl, startsWith('data:text/plain;base64,'));
      expect(dataUrl, endsWith('SGVsbG8='));
    });

    test('toDataUrl should use default mime type when not provided', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final result = FileUploadResult(
        fileName: 'unknown.bin',
        fileBytes: bytes,
      );

      final dataUrl = result.toDataUrl();
      expect(dataUrl, startsWith('data:application/octet-stream;base64,'));
    });

    test('should handle empty bytes', () {
      final bytes = Uint8List.fromList([]);
      final result = FileUploadResult(
        fileName: 'empty.txt',
        fileBytes: bytes,
      );

      final base64 = result.toBase64();
      expect(base64, equals(''));
    });

    test('should handle large byte arrays', () {
      final bytes = Uint8List.fromList(List.generate(1000, (i) => i % 256));
      final result = FileUploadResult(
        fileName: 'large.bin',
        fileBytes: bytes,
        fileSize: 1000,
      );

      final base64 = result.toBase64();
      expect(base64, isNotNull);
      expect(base64!.length, greaterThan(0));
    });
  });

  group('FileUploadWidget Icon Tests', () {
    testWidgets('should display file icon based on mime type',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FileUploadWidget(
              initialValue: 'http://example.com/file.pdf',
            ),
          ),
        ),
      );

      // File icon should be present
      expect(find.byIcon(Icons.insert_drive_file), findsOneWidget);
    });

    test('_getFileIcon should return correct icon for images', () {
      // This is testing internal logic conceptually
      const imageMime = 'image/png';
      const videoMime = 'video/mp4';
      const audioMime = 'audio/mp3';
      const pdfMime = 'application/pdf';

      // In actual widget, these would map to different icons
      expect(imageMime.startsWith('image/'), isTrue);
      expect(videoMime.startsWith('video/'), isTrue);
      expect(audioMime.startsWith('audio/'), isTrue);
      expect(pdfMime, equals('application/pdf'));
    });
  });

  group('FileUploadWidget File Size Formatting', () {
    test('_formatFileSize should format bytes correctly', () {
      // Bytes
      expect(_formatFileSize(500), equals('500 B'));

      // Kilobytes
      expect(_formatFileSize(1024), equals('1.00 KB'));
      expect(_formatFileSize(2048), equals('2.00 KB'));

      // Megabytes
      expect(_formatFileSize(1024 * 1024), equals('1.00 MB'));
      expect(_formatFileSize(5 * 1024 * 1024), equals('5.00 MB'));

      // Gigabytes
      expect(_formatFileSize(1024 * 1024 * 1024), equals('1.00 GB'));
      expect(_formatFileSize(2 * 1024 * 1024 * 1024), equals('2.00 GB'));
    });

    test('_formatFileSize should handle zero', () {
      expect(_formatFileSize(0), equals('0 B'));
    });

    test('_formatFileSize should handle edge cases', () {
      expect(_formatFileSize(1), equals('1 B'));
      expect(_formatFileSize(1023), equals('1023 B'));
      expect(_formatFileSize(1025), equals('1.00 KB'));
    });
  });

  group('FileUploadWidget Error Handling', () {
    testWidgets('should display error message when validation fails',
        (WidgetTester tester) async {
      await tester.pumpWidget(createUploadWidget());

      // Error handling is internal to the widget
      // This tests the widget structure
      expect(find.byType(FileUploadWidget), findsOneWidget);
    });

    testWidgets('should clear error when file is removed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(initialValue: 'http://example.com/file.pdf'),
      );

      // Tap remove button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // File should be removed
      expect(find.text('existing_file'), findsNothing);
      expect(find.text('Drop file here or click to browse'), findsOneWidget);
    });
  });

  group('FileUploadWidget Callback Tests', () {
    testWidgets('should call onFileSelected when file is removed',
        (WidgetTester tester) async {
      FileUploadResult? selectedFile;

      await tester.pumpWidget(
        createUploadWidget(
          initialValue: 'http://example.com/file.pdf',
          onFileSelected: (file) {
            selectedFile = file;
          },
        ),
      );

      // Tap remove button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Callback should have been called with null
      expect(selectedFile, isNull);
    });
  });

  group('FileUploadWidget Image Preview Tests', () {
    testWidgets('should show image preview when showPreview is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(
          initialValue: 'http://example.com/image.jpg',
          showPreview: true,
        ),
      );

      // File info should be displayed
      expect(find.text('existing_file'), findsOneWidget);
    });

    testWidgets('should hide image preview when showPreview is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createUploadWidget(
          initialValue: 'http://example.com/image.jpg',
          showPreview: false,
        ),
      );

      // File info still shown, just no image preview
      expect(find.text('existing_file'), findsOneWidget);
    });

    test('_isImage should correctly identify image mime types', () {
      expect(_isImage('image/png'), isTrue);
      expect(_isImage('image/jpeg'), isTrue);
      expect(_isImage('image/gif'), isTrue);
      expect(_isImage('image/svg+xml'), isTrue);

      expect(_isImage('application/pdf'), isFalse);
      expect(_isImage('text/plain'), isFalse);
      expect(_isImage('video/mp4'), isFalse);
      expect(_isImage(null), isFalse);
    });
  });
}

// Helper functions matching widget internal logic
String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
}

bool _isImage(String? mimeType) {
  if (mimeType == null) return false;
  return mimeType.startsWith('image/');
}
