import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../services/todo_service.dart';

class TrashScreen extends StatefulWidget {
  final TodoService todoService;

  const TrashScreen({super.key, required this.todoService});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  @override
  Widget build(BuildContext context) {
    final deletedTodos = widget.todoService.deletedTodos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        actions: [
          if (deletedTodos.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Empty Trash',
              onPressed: _confirmEmptyTrash,
            ),
        ],
      ),
      body:
          deletedTodos.isEmpty
              ? _buildEmptyTrash()
              : ListView.builder(
                itemCount: deletedTodos.length,
                itemBuilder: (context, index) {
                  return _buildDeletedTodoItem(deletedTodos[index]);
                },
              ),
    );
  }

  Widget _buildEmptyTrash() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Trash is Empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items in trash will be automatically deleted after 30 days',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedTodoItem(TodoItem todo) {
    return Card(
      child: ListTile(
        title: Text(
          todo.title,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty) Text(todo.description),
            const SizedBox(height: 4),
            Text(
              'Deleted on: ${_formatDate(todo.createdAt)}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: 'Restore',
              onPressed: () async {
                await widget.todoService.restoreFromTrash(todo.id);
                setState(() {});
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Task restored')));
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete permanently',
              onPressed: () => _confirmDeletePermanently(todo),
            ),
          ],
        ),
        isThreeLine: todo.description.isNotEmpty,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDeletePermanently(TodoItem todo) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Permanently?'),
            content: Text(
              'Are you sure you want to permanently delete "${todo.title}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await widget.todoService.deleteFromTrash(todo.id);
                  setState(() {});
                },
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }

  void _confirmEmptyTrash() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Empty Trash?'),
            content: const Text(
              'Are you sure you want to permanently delete all items in the trash? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await widget.todoService.emptyTrash();
                  setState(() {});
                },
                child: const Text('EMPTY TRASH'),
              ),
            ],
          ),
    );
  }
}
