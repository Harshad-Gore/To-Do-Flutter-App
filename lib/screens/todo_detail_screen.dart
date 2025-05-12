import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';

class TodoDetailScreen extends StatefulWidget {
  final TodoItem todo;

  const TodoDetailScreen({super.key, required this.todo});

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late bool _isCompleted;
  late bool _isImportant;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    _isCompleted = widget.todo.isCompleted;
    _isImportant = widget.todo.isImportant;
    _dueDate = widget.todo.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value!;
                    });
                  },
                ),
                const Text('Mark as completed'),
                const SizedBox(width: 16),
                Checkbox(
                  value: _isImportant,
                  onChanged: (value) {
                    setState(() {
                      _isImportant = value!;
                    });
                  },
                ),
                const Text('Important'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? 'Due: 	${DateFormat('yyyy-MM-dd').format(_dueDate!)}'
                        : 'No due date',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_calendar),
                  tooltip: 'Set due date',
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _dueDate = picked;
                      });
                    }
                  },
                ),
                if (_dueDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear due date',
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Created on: ${_formatDate(widget.todo.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _saveChanges() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty')));
      return;
    }

    final updatedTodo = widget.todo.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      isCompleted: _isCompleted,
      isImportant: _isImportant,
      dueDate: _dueDate,
    );

    Navigator.pop(context, updatedTodo);
    // Only show SnackBar if context is still mounted (not after pop)
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Task updated successfully')),
    // );
  }
}
