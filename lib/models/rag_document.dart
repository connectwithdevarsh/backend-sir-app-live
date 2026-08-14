/// RagDocument represents an uploaded and processed document in the RAG pipeline.
class RagDocument {
  final String documentId;
  final String filename;
  final String fileType;
  final int fileSize;
  final int chunkCount;
  final String status; // "selected", "processing", "ready", "failed"

  RagDocument({
    required this.documentId,
    required this.filename,
    required this.fileType,
    required this.fileSize,
    required this.chunkCount,
    required this.status,
  });

  factory RagDocument.fromJson(Map<String, dynamic> json) {
    return RagDocument(
      documentId: json['documentId'] ?? '',
      filename: json['filename'] ?? 'document.txt',
      fileType: json['fileType'] ?? 'txt',
      fileSize: json['fileSize'] ?? 0,
      chunkCount: json['chunkCount'] ?? 0,
      status: json['status'] ?? 'ready',
    );
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
