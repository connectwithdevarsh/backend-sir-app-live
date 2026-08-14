import 'retrieved_chunk.dart';

/// SourceCitation represents a source reference citation from RAG search results.
class SourceCitation {
  final String documentId;
  final String filename;
  final int page;
  final String chunkId;
  final double? score;

  SourceCitation({
    required this.documentId,
    required this.filename,
    required this.page,
    required this.chunkId,
    this.score,
  });

  factory SourceCitation.fromJson(Map<String, dynamic> json) {
    return SourceCitation(
      documentId: json['documentId'] ?? '',
      filename: json['filename'] ?? 'document',
      page: json['page'] ?? 1,
      chunkId: json['chunkId'] ?? 'chunk_01',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
    );
  }
}

/// RagResponse encapsulates the response from a RAG query execution.
class RagResponse {
  final bool success;
  final String question;
  final String answer;
  final List<SourceCitation> sources;
  final List<RetrievedChunk> retrievedChunks;
  final String prompt;
  final String model;
  final int executionTimeMs;
  final String? error;

  RagResponse({
    required this.success,
    required this.question,
    required this.answer,
    required this.sources,
    required this.retrievedChunks,
    required this.prompt,
    required this.model,
    required this.executionTimeMs,
    this.error,
  });

  factory RagResponse.fromJson(Map<String, dynamic> json) {
    var rawSources = json['sources'] as List? ?? [];
    List<SourceCitation> srcList = rawSources.map((s) => SourceCitation.fromJson(s)).toList();

    var rawChunks = json['retrievedChunks'] as List? ?? [];
    List<RetrievedChunk> chkList = rawChunks.map((c) => RetrievedChunk.fromJson(c)).toList();

    return RagResponse(
      success: json['success'] ?? true,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      sources: srcList,
      retrievedChunks: chkList,
      prompt: json['prompt'] ?? '',
      model: json['model'] ?? 'unknown',
      executionTimeMs: json['executionTimeMs'] ?? 0,
      error: json['error'],
    );
  }
}
