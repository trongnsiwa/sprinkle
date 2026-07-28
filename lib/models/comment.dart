class Comment {
  final int? id;
  final String memoryUuid;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime createdAt;

  Comment({
    this.id,
    required this.memoryUuid,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json, {String? name, String? avatar}) {
    return Comment(
      id: json['id'] as int?,
      memoryUuid: json['memory_uuid'] as String,
      userId: json['user_id'] as String,
      userName: name ?? json['users']?['name'] ?? 'Sprinkle User',
      userAvatar: avatar ?? json['users']?['avatar'] ?? '📸',
      content: json['content'] as String,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memory_uuid': memoryUuid,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
