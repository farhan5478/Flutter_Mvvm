import 'package:flutter/foundation.dart';
import '../models/todo_modal.dart';
import '../services/todo_service.dart';

enum TodoViewState { idle, loading, error }

class TodoViewModel extends ChangeNotifier {
  final TodoService _todoService = TodoService();
  List<Todo> _todos = [];
  TodoViewState _state = TodoViewState.idle;
  String _errorMsg = "";

  List<Todo> get todos => _todos;

  TodoViewState get state => _state;

  String get errorMsg => _errorMsg;

  List<Todo> get completedTodos =>
      _todos.where((item) => item.isCompleted).toList();

  List<Todo> get pendingTodos => _todos.where((item) {
    return !item.isCompleted;
  }).toList();

  int get totalTodos => _todos.length;

  int get completedTodosCount => completedTodos.length;

  int get pendingTodosCount => pendingTodos.length;

  bool get isLoading => _state == TodoViewState.loading;

  bool get hasError => _state == TodoViewState.error;

  bool get isIdle => _state == TodoViewState.idle;

  void _setState(TodoViewState todoViewState) {
    _state = todoViewState;
    if (todoViewState != TodoViewState.error) {
      _errorMsg = '';
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMsg = error;
    _state = TodoViewState.error;
    notifyListeners();
  }

  void clearError() {
    _setError('');
    _setState(TodoViewState.idle);
  }

  Future<void> fetchTodos() async {
    try {
      _setState(TodoViewState.loading);
      _todos = await _todoService.getAllTodos();
      _setState(TodoViewState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> addTodo(String title, String description) async {
    if (title.trim().isEmpty) {
      _setError('Title cannot be empty');
      return;
    }
    try {
      _setState(TodoViewState.loading);
      await _todoService.addTodo(title, description);
      _setState(TodoViewState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteItem(int id) async {
    _setState(TodoViewState.loading);
    try {
      await _todoService.deleteTodo(id);
      _setState(TodoViewState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateItem(int id, String title, String description) async {
    _setState(TodoViewState.loading);
    try {
      final todo = await _todoService.updateTodo(id, title, description);
      _setState(TodoViewState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<Todo> toggleComplete(int id) async {
    await Future.delayed(Duration(milliseconds: 300));

    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        isCompleted: !_todos[index].isCompleted,
      );
      notifyListeners();
      return _todos[index];
    }
    throw Exception('Todo not found');
  }
}
