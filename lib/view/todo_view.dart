import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_mvvm/view/widgets/todo_item_widget.dart';
import '../models/todo_modal.dart';
import '../viewmodels/todo_vm.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoViewModel>().fetchTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MVVM Todo App'),
        elevation: 2,
        actions: [
          Consumer<TodoViewModel>(
            builder: (context, viewModel, child) {
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    '${viewModel.completedTodosCount}/${viewModel.totalTodos}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<TodoViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.todos.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    viewModel.errorMsg,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.clearError();
                      viewModel.fetchTodos();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No todos yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first todo',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchTodos(),
            child: ListView.builder(
              itemCount: viewModel.totalTodos+1,
              itemBuilder: (context, index) {
                if (index == viewModel.totalTodos) {
                  if(viewModel.isLoading){
                    return Center(child: Container(padding: EdgeInsets.all(16), width: 70, height: 70, child: CircularProgressIndicator(),),);
                  }
                  return null;
                } else  {
                  final todo = viewModel.todos[index];
                  return TodoItemWidget(
                    todo: todo,
                    onToggle: () => viewModel.toggleComplete(todo.id),
                    onDelete: () =>
                        _showDeleteConfirmation(context, todo, viewModel),
                    onEdit: () => _showEditDialog(context, todo, viewModel)
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        tooltip: 'Add Todo',
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Todo todo,
      TodoViewModel viewModel) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Edit Todo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isNotEmpty) {
                    viewModel.updateItem(
                      todo.id,
                      title,
                      descriptionController.text.trim(),

                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Add New Todo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isNotEmpty) {
                    context.read<TodoViewModel>().addTodo(
                      title,
                      descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
    );
  }


  void _showDeleteConfirmation(BuildContext context, Todo todo,
      TodoViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Delete Todo'),
            content: Text('Are you sure you want to delete "${todo.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  viewModel.deleteItem(todo.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }
}
