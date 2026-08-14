/// RetrievedChunk represents a text chunk retrieved from the vector index during RAG query.
class RetrievedChunk {
  final String chunkId;
  final String text;
  final int page;
  final double? score;

  RetrievedChunk({
    required this.chunkId,
    required this.text,
    this.page = 1,
    this.score,
  });

  factory RetrievedChunk.fromJson(Map<String, dynamic> json) {
    return RetrievedChunk(
      chunkId: json['chunkId'] ?? 'chunk_01',
      text: json['text'] ?? '',
      page: json['page'] ?? 1,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
    );
  }
}
