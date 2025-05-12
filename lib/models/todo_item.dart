class TodoItem {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  bool isImportant;
  DateTime? dueDate;
  bool isDeleted;

  TodoItem({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.isImportant = false,
    this.dueDate,
    this.isDeleted = false,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    bool? isImportant,
    DateTime? dueDate,
    bool? isDeleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      isImportant: isImportant ?? this.isImportant,
      dueDate: dueDate ?? this.dueDate,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // Convert TodoItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'isImportant': isImportant,
      'dueDate': dueDate?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  // Create TodoItem from JSON
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      isImportant: json['isImportant'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
