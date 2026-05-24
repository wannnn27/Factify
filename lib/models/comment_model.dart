class Comment {
  final String id;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final List<Comment> replies;
  bool isLiked;

  Comment({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.replies = const [],
    this.isLiked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'isLiked': isLiked,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Handle timestamp: could be ISO 8601 string, Firestore Timestamp, or null
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      // Firestore Timestamp has toDate() method
      if (value is DateTime) return value;
      try {
        // Handle Firestore Timestamp object
        return (value as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return Comment(
      id: json['id'] ?? '',
      userName: json['userName'] ?? 'Anonim',
      userAvatar: json['userAvatar'] ?? '',
      content: json['content'] ?? '',
      timestamp: parseTimestamp(json['timestamp']),
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      replies: (json['replies'] as List?)
              ?.map((r) => Comment.fromJson(Map<String, dynamic>.from(r)))
              .toList() ??
          [],
    );
  }
}