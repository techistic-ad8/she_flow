import 'dart:convert';

enum Priority { low, medium, high }

extension PriorityExtension on Priority {
  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  String get emoji {
    switch (this) {
      case Priority.low:
        return '🟢';
      case Priority.medium:
        return '🟡';
      case Priority.high:
        return '🔴';
    }
  }
}

class TodoItem {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? dueDate;

  TodoItem({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.priority = Priority.medium,
    DateTime? createdAt,
    this.dueDate,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  TodoItem copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    Priority? priority,
    DateTime? dueDate,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      priority: Priority.values[json['priority'] ?? 1],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      dueDate:
          json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  static String encodeList(List<TodoItem> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList());
  }

  static List<TodoItem> decodeList(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return list.map((e) => TodoItem.fromJson(e)).toList();
  }
}
