import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'image_preview_widget.dart';

/// A widget that allows file uploads with drag & drop support.
class FileUploadWidget extends StatefulWidget {
  /// Initial file URL or base64 data
  final String? initialValue;

  /// Callback when file is selected
  final void Function(FileUploadResult?)? onFileSelected;

  /// Allowed file extensions (e.g., ['jpg', 'png', 'pdf'])
  final List<String>? allowedExtensions;

  /// Maximum file size in bytes
  final int? maxFileSize;

  /// Whether to show image preview
  final bool showPreview;

  /// Label for the upload area
  final String? label;

  /// Whether the field is read-only
  final bool readOnly;

  const FileUploadWidget({
    super.key,
    this.initialValue,
    this.onFileSelected,
    this.allowedExtensions,
    this.maxFileSize,
    this.showPreview = true,
    this.label,
    this.readOnly = false,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  FileUploadResult? _uploadedFile;
  bool _isDragging = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _uploadedFile = FileUploadResult(
        fileName: 'existing_file',
        fileUrl: widget.initialValue,
      );
    }
  }

  Future<void> _pickFile() async {
    if (widget.readOnly) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: widget.allowedExtensions != null
            ? FileType.custom
            : FileType.any,
        allowedExtensions: widget.allowedExtensions,
        withData: true, // Get file bytes for preview/upload
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validate file size
        if (widget.maxFileSize != null &&
            file.size > widget.maxFileSize!) {
          setState(() {
            _error =
                'File too large. Max size: ${(widget.maxFileSize! / 1024 / 1024).toStringAsFixed(2)} MB';
            _isLoading = false;
          });
          return;
        }

        // Create upload result
        final uploadResult = FileUploadResult(
          fileName: file.name,
          fileBytes: file.bytes,
          fileSize: file.size,
          mimeType: lookupMimeType(file.name),
        );

        setState(() {
          _uploadedFile = uploadResult;
          _error = null;
          _isLoading = false;
        });

        widget.onFileSelected?.call(uploadResult);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick file: $e';
        _isLoading = false;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _uploadedFile = null;
      _error = null;
    });
    widget.onFileSelected?.call(null);
  }

  bool _isImage(String? mimeType) {
    if (mimeType == null) return false;
    return mimeType.startsWith('image/');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

        // Upload area
        if (_uploadedFile == null)
          GestureDetector(
            onTap: widget.readOnly || _isLoading ? null : _pickFile,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isDragging = true),
              onExit: (_) => setState(() => _isDragging = false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isDragging
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: _isDragging
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.grey.shade50,
                ),
                child: _isLoading
                    ? Column(
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading file...',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: _isDragging
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.readOnly
                                ? 'No file selected'
                                : 'Drop file here or click to browse',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                          if (widget.allowedExtensions != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Allowed: ${widget.allowedExtensions!.join(", ")}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          if (widget.maxFileSize != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Max size: ${(widget.maxFileSize! / 1024 / 1024).toStringAsFixed(2)} MB',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),

        // File preview
        if (_uploadedFile != null)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Image preview with lightbox
                if (widget.showPreview &&
                    _isImage(_uploadedFile!.mimeType) &&
                    _uploadedFile!.fileBytes != null &&
                    _uploadedFile!.toDataUrl() != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ImagePreviewWidget(
                      imageSource: _uploadedFile!.toDataUrl()!,
                      thumbnailHeight: 200,
                      thumbnailWidth: double.infinity,
                      enableLightbox: true,
                      fit: BoxFit.contain,
                    ),
                  ),

                // File info
                Row(
                  children: [
                    Icon(
                      _getFileIcon(_uploadedFile!.mimeType),
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _uploadedFile!.fileName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_uploadedFile!.fileSize != null)
                            Text(
                              _formatFileSize(_uploadedFile!.fileSize!),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!widget.readOnly)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _removeFile,
                        tooltip: 'Remove file',
                      ),
                  ],
                ),
              ],
            ),
          ),

        // Error message
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;

    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf;
    if (mimeType.contains('word')) return Icons.description;
    if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart;
    }
    if (mimeType.contains('zip') || mimeType.contains('rar')) {
      return Icons.folder_zip;
    }

    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}

/// Result of a file upload operation.
class FileUploadResult {
  final String fileName;
  final Uint8List? fileBytes;
  final int? fileSize;
  final String? mimeType;
  final String? fileUrl;

  FileUploadResult({
    required this.fileName,
    this.fileBytes,
    this.fileSize,
    this.mimeType,
    this.fileUrl,
  });

  /// Convert file bytes to base64 string for storage
  String? toBase64() {
    if (fileBytes == null) return null;
    return base64Encode(fileBytes!);
  }

  /// Get data URL (base64 with mime type prefix)
  String? toDataUrl() {
    if (fileBytes == null) return null;
    final base64 = base64Encode(fileBytes!);
    final mime = mimeType ?? 'application/octet-stream';
    return 'data:$mime;base64,$base64';
  }
}
