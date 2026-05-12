import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';
import '../services/notification_service.dart';

class TodoProvider extends ChangeNotifier {
  TodoProvider({NotificationService? notificationService})
    : _notificationService =
          notificationService ?? NotificationService.instance;

  static const String _storageKey = 'saved_todos_v1';
  static const String _notificationCounterKey = 'notification_counter_v1';

  final NotificationService _notificationService;
  final List<Todo> _todos = [];

  SharedPreferences? _prefs;
  bool _isLoading = true;
  bool _isInitialized = false;

  List<Todo> get todos => List.unmodifiable(_todos);
  bool get isLoading => _isLoading;

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((todo) => todo.isCompleted).length;
  int get pendingCount => _todos.where((todo) => !todo.isCompleted).length;
  int get overdueCount => _todos.where((todo) => todo.isOverdue).length;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final rawTodos = prefs.getString(_storageKey);

    if (rawTodos != null && rawTodos.isNotEmpty) {
      final decoded = jsonDecode(rawTodos) as List<dynamic>;
      _todos
        ..clear()
        ..addAll(
          decoded.map((item) => Todo.fromJson(item as Map<String, dynamic>)),
        );
      _sortTodos();
    }

    _isLoading = false;
    notifyListeners();
  }

  Todo? todoById(String id) {
    for (final todo in _todos) {
      if (todo.id == id) {
        return todo;
      }
    }
    return null;
  }

  Future<void> addTodo({
    required String title,
    required String description,
    DateTime? dueAt,
    required bool setReminder,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Görev başlığı boş olamaz.');
    }

    int? notificationId;
    if (setReminder && dueAt != null && dueAt.isAfter(DateTime.now())) {
      notificationId = await _nextNotificationId();
      await _notificationService.scheduleTodoReminder(
        notificationId: notificationId,
        title: normalizedTitle,
        body: normalizedDescription.isEmpty
            ? 'Görev zamanı geldi.'
            : normalizedDescription,
        scheduledAt: dueAt,
      );
    }

    final newTodo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: normalizedTitle,
      description: normalizedDescription,
      createdAt: DateTime.now(),
      dueAt: dueAt,
      notificationId: notificationId,
    );

    _todos.add(newTodo);
    _sortTodos();
    await _persistTodos();
    notifyListeners();
  }

  Future<void> toggleTodoCompletion(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      return;
    }

    final existing = _todos[index];
    final nextCompleted = !existing.isCompleted;

    if (nextCompleted && existing.notificationId != null) {
      await _notificationService.cancelNotification(existing.notificationId!);
    }

    if (!nextCompleted &&
        existing.notificationId != null &&
        existing.dueAt != null &&
        existing.dueAt!.isAfter(DateTime.now())) {
      await _notificationService.scheduleTodoReminder(
        notificationId: existing.notificationId!,
        title: existing.title,
        body: existing.description.isEmpty
            ? 'Görev zamanı geldi.'
            : existing.description,
        scheduledAt: existing.dueAt!,
      );
    }

    _todos[index] = existing.copyWith(isCompleted: nextCompleted);
    _sortTodos();
    await _persistTodos();
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      return;
    }

    final target = _todos[index];
    if (target.notificationId != null) {
      await _notificationService.cancelNotification(target.notificationId!);
    }

    _todos.removeAt(index);
    await _persistTodos();
    notifyListeners();
  }

  Future<void> _persistTodos() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();

    final encodedTodos = jsonEncode(
      _todos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedTodos);
  }

  Future<int> _nextNotificationId() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final current = prefs.getInt(_notificationCounterKey) ?? 1;
    await prefs.setInt(_notificationCounterKey, current + 1);
    return current;
  }

  void _sortTodos() {
    _todos.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }

      if (a.dueAt == null && b.dueAt != null) {
        return 1;
      }
      if (a.dueAt != null && b.dueAt == null) {
        return -1;
      }
      if (a.dueAt != null && b.dueAt != null) {
        final dueComparison = a.dueAt!.compareTo(b.dueAt!);
        if (dueComparison != 0) {
          return dueComparison;
        }
      }

      return b.createdAt.compareTo(a.createdAt);
    });
  }
}
