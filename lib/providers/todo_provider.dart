import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class TodoProvider extends ChangeNotifier {
  List<TodoItem> _todos = [];
  String _filter = 'all'; // all, pending, completed

  List<TodoItem> get todos {
    switch (_filter) {
      case 'pending':
        return _todos.where((t) => !t.isCompleted).toList();
      case 'completed':
        return _todos.where((t) => t.isCompleted).toList();
      default:
        return List.unmodifiable(_todos);
    }
  }

  List<TodoItem> get allTodos => List.unmodifiable(_todos);
  String get filter => _filter;
  int get pendingCount => _todos.where((t) => !t.isCompleted).length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('todos');
    if (jsonString != null) {
      _todos = TodoItem.decodeList(jsonString);
    }
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('todos', TodoItem.encodeList(_todos));
  }

  void setFilter(String filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> addTodo(TodoItem todo) async {
    _todos.insert(0, todo);
    await _saveTodos();
    notifyListeners();
  }

  Future<void> updateTodo(TodoItem updated) async {
    final index = _todos.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _todos[index] = updated;
      await _saveTodos();
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      await _saveTodos();
      notifyListeners();
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((t) => t.id == id);
    await _saveTodos();
    notifyListeners();
  }

  List<TodoItem> get upcomingTodos {
    return _todos
        .where((t) => !t.isCompleted)
        .take(3)
        .toList();
  }
}
