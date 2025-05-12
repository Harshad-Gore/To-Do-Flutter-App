import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class TodoService {
  final List<TodoItem> _todos = [];
  final List<TodoItem> _deletedTodos = [];
  final _uuid = const Uuid();
  static const String _todosKey = 'todos';
  static const String _deletedTodosKey = 'deleted_todos';

  List<TodoItem> get todos => List.unmodifiable(_todos);
  List<TodoItem> get deletedTodos => List.unmodifiable(_deletedTodos);

  // Load todos from SharedPreferences
  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Load active todos
    final todosJson = prefs.getStringList(_todosKey) ?? [];
    _todos.clear();
    _todos.addAll(
      todosJson.map((json) => TodoItem.fromJson(jsonDecode(json))).toList(),
    );

    // Load deleted todos
    final deletedTodosJson = prefs.getStringList(_deletedTodosKey) ?? [];
    _deletedTodos.clear();
    _deletedTodos.addAll(
      deletedTodosJson
          .map((json) => TodoItem.fromJson(jsonDecode(json)))
          .toList(),
    );
  }

  // Save todos to SharedPreferences
  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();

    // Save active todos
    final todosJson = _todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList(_todosKey, todosJson);

    // Save deleted todos
    final deletedTodosJson =
        _deletedTodos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList(_deletedTodosKey, deletedTodosJson);
  }

  Future<void> addTodo(
    String title, {
    String description = '',
    bool isImportant = false,
    DateTime? dueDate,
  }) async {
    final todo = TodoItem(
      id: _uuid.v4(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
      isImportant: isImportant,
      dueDate: dueDate,
    );
    _todos.add(todo);
    await saveTodos();
  }

  Future<void> toggleTodoStatus(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      await saveTodos();
    }
  }

  Future<void> updateTodo(TodoItem updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      await saveTodos();
    }
  }

  Future<void> moveToTrash(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final todo = _todos[index].copyWith(isDeleted: true);
      _todos.removeAt(index);
      _deletedTodos.add(todo);
      await saveTodos();
    }
  }

  Future<void> restoreFromTrash(String id) async {
    final index = _deletedTodos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final todo = _deletedTodos[index].copyWith(isDeleted: false);
      _deletedTodos.removeAt(index);
      _todos.add(todo);
      await saveTodos();
    }
  }

  Future<void> deleteFromTrash(String id) async {
    _deletedTodos.removeWhere((todo) => todo.id == id);
    await saveTodos();
  }

  Future<void> emptyTrash() async {
    _deletedTodos.clear();
    await saveTodos();
  }

  List<TodoItem> getTodosByStatus(bool isCompleted) {
    return _todos
        .where((todo) => todo.isCompleted == isCompleted && !todo.isDeleted)
        .toList();
  }

  List<TodoItem> getImportantTodos() {
    return _todos.where((todo) => todo.isImportant && !todo.isDeleted).toList();
  }

  // Move a task up in the list
  Future<void> moveUp(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index > 0) {
      final temp = _todos[index - 1];
      _todos[index - 1] = _todos[index];
      _todos[index] = temp;
      await saveTodos();
    }
  }

  // Move a task down in the list
  Future<void> moveDown(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1 && index < _todos.length - 1) {
      final temp = _todos[index + 1];
      _todos[index + 1] = _todos[index];
      _todos[index] = temp;
      await saveTodos();
    }
  }

  // Filter todos by title (case-insensitive)
  List<TodoItem> filterByTitle(
    String query, {
    bool? isCompleted,
    bool? isImportant,
  }) {
    return _todos.where((todo) {
      final matches = todo.title.toLowerCase().contains(query.toLowerCase());
      final statusMatch =
          isCompleted == null || todo.isCompleted == isCompleted;
      final importantMatch =
          isImportant == null || todo.isImportant == isImportant;
      return matches && statusMatch && importantMatch && !todo.isDeleted;
    }).toList();
  }
}
