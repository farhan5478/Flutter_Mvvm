import '../models/todo_modal.dart';

class TodoService {
  final List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<List<Todo>> getAllTodos() async {
    await Future.delayed(const Duration(seconds: 3));
    return _todos;
  }

  Future<Todo> addTodo(String title, String description) async {
    await Future.delayed(const Duration(seconds: 3));
    final todo = Todo(
      id: _todos.length + 1,
      title: title,
      description: description,
    );
    _todos.add(todo);
    return todo;
  }

  Future<Todo> updateTodo(int id,String title, String description) async {
    await Future.delayed(const Duration(seconds: 15));
    final todo = _todos.firstWhere((todoItem) => todoItem.id == id);
    todo.copyWith(title: title, description: description);
    final index = _todos.indexOf(todo);
    _todos[index] = todo;
    return todo;
  }

  Future<void> deleteTodo(int id) async {
    await Future.delayed(const Duration(seconds: 3));
    _todos.removeWhere((item) {
      return item.id == id;
    });
  }

  Future<Todo> getTodoById(int id) async {
    await Future.delayed(const Duration(seconds: 3));
    return _todos.firstWhere((element) => element.id == id);
  }
}
