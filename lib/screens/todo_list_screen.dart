import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../services/todo_service.dart';
import 'todo_detail_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  final TodoService _todoService = TodoService();
  late TabController _tabController;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add some sample todos for demo purposes
    // _todoService.addTodo('Buy groceries', description: 'Milk, eggs, bread');
    // _todoService.addTodo('Complete Flutter project');
    // _todoService.addTodo('Go for a run', description: '5K in the park');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Completed')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTodoList(false), _buildTodoList(true)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoList(bool isCompleted) {
    final todos = _todoService.getTodosByStatus(isCompleted);

    return todos.isEmpty
        ? Center(
          child: Text(
            isCompleted
                ? 'No completed tasks yet'
                : 'No active tasks. Add some!',
            style: const TextStyle(fontSize: 18),
          ),
        )
        : ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return _buildTodoItem(todo);
          },
        );
  }

  Widget _buildTodoItem(TodoItem todo) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            setState(() {
              _todoService.toggleTodoStatus(todo.id);
            });
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: todo.description.isNotEmpty ? Text(todo.description) : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            await _todoService.moveToTrash(todo.id);
            setState(() {});
          },
        ),
        onTap: () {
          _navigateToTodoDetail(todo);
        },
      ),
    );
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String description = '';

        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter task title',
                ),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter task description',
                ),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  setState(() {
                    _todoService.addTodo(title, description: description);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTodoDetail(TodoItem todo) async {
    final updatedTodo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoDetailScreen(todo: todo)),
    );

    if (updatedTodo != null) {
      setState(() {
        _todoService.updateTodo(updatedTodo);
      });
    }
  }
}
