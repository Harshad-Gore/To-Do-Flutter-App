import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import '../services/todo_service.dart';
import '../theme/app_theme.dart';
import 'todo_detail_screen.dart';
import 'trash_screen.dart';
import 'diary_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class TodoListScreen extends StatefulWidget {
  final TodoService todoService;
  final void Function(BuildContext context)? openSettings;

  const TodoListScreen({
    super.key,
    required this.todoService,
    this.openSettings,
  });

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 2; // Home is center
  final List<DiaryEntry> _diaryEntries = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Add some sample todos for demo purposes (commented out for production)
    // _initSampleTodos();
  }

  /* Uncomment to add sample todos for testing
  Future<void> _initSampleTodos() async {
    await widget.todoService.addTodo(
      'Buy groceries',
      description: 'Milk, eggs, bread',
      isImportant: true,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    await widget.todoService.addTodo(
      'Complete Flutter project',
      dueDate: DateTime.now().add(const Duration(days: 5)),
    );
    
    await widget.todoService.addTodo(
      'Go for a run',
      description: '5K in the park',
      isImportant: false,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    );
    
    setState(() {});
  }
  */

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _onAddDiaryEntry() async {
    final entry = await showDialog<DiaryEntry>(
      context: context,
      builder: (context) => _DiaryEntryDialog(),
    );
    if (entry != null) {
      setState(() {
        _diaryEntries.insert(0, entry);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedIndex == 0) {
      body = DiaryScreen(entries: _diaryEntries, onAddEntry: _onAddDiaryEntry);
    } else if (_selectedIndex == 2) {
      body = Scaffold(
        appBar: AppBar(
          title: const Text('TaskMaster'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Important'),
            ],
          ),
          actions: [
            if (widget.openSettings != null)
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () => widget.openSettings!(context),
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Trash',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            TrashScreen(todoService: widget.todoService),
                  ),
                ).then((_) => setState(() {}));
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildTaskList(0), _buildTaskList(1), _buildTaskList(2)],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTodoDialog,
          child: const Icon(Icons.add),
          tooltip: 'Add Task',
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    } else {
      body = const SizedBox.shrink();
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildTaskList(int tabIndex) {
    List<TodoItem> todos;
    if (_searchQuery.isNotEmpty) {
      if (tabIndex == 0) {
        todos = widget.todoService.filterByTitle(
          _searchQuery,
          isCompleted: false,
        );
      } else if (tabIndex == 1) {
        todos = widget.todoService.filterByTitle(
          _searchQuery,
          isCompleted: true,
        );
      } else {
        todos = widget.todoService.filterByTitle(
          _searchQuery,
          isImportant: true,
        );
      }
    } else {
      switch (tabIndex) {
        case 0:
          todos = widget.todoService.getTodosByStatus(false);
          break;
        case 1:
          todos = widget.todoService.getTodosByStatus(true);
          break;
        case 2:
          todos = widget.todoService.getImportantTodos();
          break;
        default:
          todos = [];
      }
    }

    if (todos.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return _buildTodoItem(todos[index], index, todos.length);
      },
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String message;
    IconData icon;

    switch (tabIndex) {
      case 0:
        message = "You don't have any active tasks.\nTap + to add a new task!";
        icon = Icons.task_alt;
        break;
      case 1:
        message = "You haven't completed any tasks yet.";
        icon = Icons.check_circle_outline;
        break;
      case 2:
        message =
            "No important tasks.\nMark a task as important to see it here.";
        icon = Icons.star_border;
        break;
      default:
        message = "No tasks available";
        icon = Icons.info_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoItem todo, int index, int total) {
    final bool isPastDue =
        todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.isCompleted;

    Color statusColor;
    if (todo.isCompleted) {
      statusColor = AppColors.completed;
    } else if (isPastDue) {
      statusColor = Colors.redAccent;
    } else if (todo.isImportant) {
      statusColor = Colors.amber;
    } else {
      statusColor = Colors.transparent;
    }

    return Slidable(
      key: ValueKey(todo.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              if (!todo.isCompleted) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Mark as Completed?'),
                        content: const Text(
                          'Ticking this task will mark it as completed.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                );
                if (confirm != true) return;
              }
              await widget.todoService.toggleTodoStatus(todo.id);
              setState(() {});
            },
            backgroundColor: AppColors.completed,
            foregroundColor: Colors.white,
            icon: todo.isCompleted ? Icons.undo : Icons.check,
            label: todo.isCompleted ? 'Undo' : 'Complete',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Move to Trash?'),
                      content: const Text(
                        'Are you sure you want to move this task to the trash bin?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Trash'),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                await widget.todoService.moveToTrash(todo.id);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Task moved to trash'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () async {
                        await widget.todoService.restoreFromTrash(todo.id);
                        setState(() {});
                      },
                    ),
                  ),
                );
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Trash',
          ),
          SlidableAction(
            onPressed: (_) async {
              final updatedTodo = todo.copyWith(isImportant: !todo.isImportant);
              await widget.todoService.updateTodo(updatedTodo);
              setState(() {});
            },
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            icon: todo.isImportant ? Icons.star : Icons.star_border,
            label: todo.isImportant ? 'Unstar' : 'Star',
          ),
          SlidableAction(
            onPressed: (_) async {
              if (index > 0) {
                await widget.todoService.moveUp(todo.id);
                setState(() {});
              }
            },
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            icon: Icons.arrow_upward,
            label: 'Up',
          ),
          SlidableAction(
            onPressed: (_) async {
              if (index < total - 1) {
                await widget.todoService.moveDown(todo.id);
                setState(() {});
              }
            },
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            icon: Icons.arrow_downward,
            label: 'Down',
          ),
        ],
      ),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border:
                statusColor != Colors.transparent
                    ? Border(left: BorderSide(color: statusColor, width: 6))
                    : null,
            color: todo.isCompleted ? Colors.grey[100] : Colors.white,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _navigateToTodoDetail(todo),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) async {
                      if (!todo.isCompleted) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Mark as Completed?'),
                                content: const Text(
                                  'Ticking this task will mark it as completed.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm != true) return;
                      }
                      await widget.todoService.toggleTodoStatus(todo.id);
                      setState(() {});
                    },
                    shape: const CircleBorder(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (todo.isImportant)
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                            Expanded(
                              child: Text(
                                todo.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      todo.isImportant
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  decoration:
                                      todo.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                  color:
                                      todo.isCompleted
                                          ? Colors.grey
                                          : Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (todo.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              todo.description,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                                decoration:
                                    todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (todo.dueDate != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color:
                                        isPastDue
                                            ? Colors.red
                                            : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(todo.dueDate!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          isPastDue
                                              ? Colors.red
                                              : Colors.grey[600],
                                      fontWeight:
                                          isPastDue
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  if (isPastDue)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 4.0),
                                      child: Text(
                                        'OVERDUE',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Trash can icon for quick trashing
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Move to Trash',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Move to Trash?'),
                              content: const Text(
                                'Are you sure you want to move this task to the trash bin?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Trash'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await widget.todoService.moveToTrash(todo.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Task moved to trash'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () async {
                                await widget.todoService.restoreFromTrash(
                                  todo.id,
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String description = '';
        bool isImportant = false;
        DateTime? dueDate;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.add_task, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('New Task'),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isImportant ? Icons.star : Icons.star_border,
                      color: isImportant ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isImportant = !isImportant;
                      });
                    },
                    tooltip: 'Mark as important',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Enter task description',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        description = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        dueDate != null
                            ? 'Due date: ${DateFormat('MMM d, yyyy').format(dueDate!)}'
                            : 'Set due date',
                      ),
                      trailing:
                          dueDate != null
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    dueDate = null;
                                  });
                                },
                              )
                              : null,
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            dueDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (title.isNotEmpty) {
                      await widget.todoService.addTodo(
                        title,
                        description: description,
                        isImportant: isImportant,
                        dueDate: dueDate,
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      setState(() {}); // Refresh the UI
                    }
                  },
                  child: const Text('ADD TASK'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => setState(() {}));
  }

  void _navigateToTodoDetail(TodoItem todo) async {
    final updatedTodo = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoDetailScreen(todo: todo)),
    );

    if (updatedTodo != null) {
      await widget.todoService.updateTodo(updatedTodo);
      setState(() {});
    }
  }
}

class _DiaryEntryDialog extends StatefulWidget {
  @override
  State<_DiaryEntryDialog> createState() => _DiaryEntryDialogState();
}

class _DiaryEntryDialogState extends State<_DiaryEntryDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Diary Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: 3,
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time (e.g. 8:00pm)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _contentController.text.isNotEmpty) {
              Navigator.pop(
                context,
                DiaryEntry(
                  title: _titleController.text,
                  content: _contentController.text,
                  time: _timeController.text,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
