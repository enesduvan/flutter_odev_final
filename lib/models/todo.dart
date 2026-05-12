class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.dueAt,
    this.notificationId,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueAt;
  final int? notificationId;
  final bool isCompleted;

  bool get isOverdue =>
      !isCompleted && dueAt != null && dueAt!.isBefore(DateTime.now());

  Todo copyWith({
    String? title,
    String? description,
    DateTime? dueAt,
    int? notificationId,
    bool? isCompleted,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      dueAt: dueAt ?? this.dueAt,
      notificationId: notificationId ?? this.notificationId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueAt': dueAt?.toIso8601String(),
      'notificationId': notificationId,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueAt: json['dueAt'] == null
          ? null
          : DateTime.parse(json['dueAt'] as String),
      notificationId: json['notificationId'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
