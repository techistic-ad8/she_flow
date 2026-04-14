import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, _) {
        final todos = todoProvider.todos;

        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text(
                        'My Tasks',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${todoProvider.pendingCount} pending',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: ['all', 'pending', 'completed'].map((filter) {
                      final isSelected = todoProvider.filter == filter;
                      final labels = {
                        'all': 'All',
                        'pending': 'Pending',
                        'completed': 'Completed'
                      };
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => todoProvider.setFilter(filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.primaryMedium.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              labels[filter]!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textMedium,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Todo list
                Expanded(
                  child: todos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✅',
                                  style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              Text(
                                todoProvider.filter == 'completed'
                                    ? 'No completed tasks yet'
                                    : 'No tasks yet!',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap + to add a new task',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];
                            return _TodoTile(
                              todo: todo,
                              onToggle: () =>
                                  todoProvider.toggleComplete(todo.id),
                              onDelete: () =>
                                  todoProvider.deleteTodo(todo.id),
                              onEdit: () => _showAddEditDialog(
                                  context, todoProvider,
                                  existingTodo: todo),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddEditDialog(context, todoProvider),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddEditDialog(BuildContext context, TodoProvider todoProvider,
      {TodoItem? existingTodo}) {
    final titleController =
        TextEditingController(text: existingTodo?.title ?? '');
    final descController =
        TextEditingController(text: existingTodo?.description ?? '');
    Priority priority = existingTodo?.priority ?? Priority.medium;
    DateTime? dueDate = existingTodo?.dueDate;
    final isEditing = existingTodo != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMedium.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Edit Task' : 'New Task',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'What needs to be done?',
                    prefixIcon: const Icon(Icons.task_alt,
                        color: AppColors.primaryMedium),
                  ),
                ),
                const SizedBox(height: 14),

                // Description
                TextFormField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add details...',
                    prefixIcon: const Icon(Icons.notes,
                        color: AppColors.primaryMedium),
                  ),
                ),
                const SizedBox(height: 16),

                // Priority
                Text('Priority',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: Priority.values.map((p) {
                    final isSelected = priority == p;
                    final colors = [
                      AppColors.mintGreen,
                      AppColors.softYellow,
                      AppColors.coral,
                    ];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => priority = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors[p.index]
                                : colors[p.index].withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colors[p.index]
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${p.emoji} ${p.displayName}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Due date
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.primary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setSheetState(() => dueDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          dueDate != null
                              ? 'Due: ${DateFormat('MMM d, y').format(dueDate!)}'
                              : 'Set due date (optional)',
                          style: GoogleFonts.poppins(
                            color: dueDate != null
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                        ),
                        if (dueDate != null) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                setSheetState(() => dueDate = null),
                            child: const Icon(Icons.close,
                                color: AppColors.textLight, size: 18),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a task title',
                                style: GoogleFonts.poppins()),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        return;
                      }

                      if (isEditing) {
                        todoProvider.updateTodo(existingTodo.copyWith(
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          priority: priority,
                          dueDate: dueDate,
                        ));
                      } else {
                        todoProvider.addTodo(TodoItem(
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          priority: priority,
                          dueDate: dueDate,
                        ));
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isEditing ? 'Update' : 'Add Task',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _TodoTile({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColors = [
      AppColors.mintGreen,
      AppColors.softYellow,
      AppColors.coral,
    ];

    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: todo.isCompleted
                ? AppColors.primaryLight.withValues(alpha: 0.5)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!todo.isCompleted)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              // Priority stripe
              Container(
                width: 4,
                height: 46,
                decoration: BoxDecoration(
                  color: priorityColors[todo.priority.index],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: todo.isCompleted
                        ? AppColors.primary
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: todo.isCompleted
                          ? AppColors.primary
                          : AppColors.primaryMedium,
                      width: 2,
                    ),
                  ),
                  child: todo.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: todo.isCompleted
                            ? AppColors.textLight
                            : AppColors.textDark,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (todo.description.isNotEmpty)
                      Text(
                        todo.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (todo.dueDate != null)
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 13,
                              color: _isDueSoon(todo.dueDate!)
                                  ? AppColors.coral
                                  : AppColors.textLight),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d').format(todo.dueDate!),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: _isDueSoon(todo.dueDate!)
                                  ? AppColors.coral
                                  : AppColors.textLight,
                              fontWeight: _isDueSoon(todo.dueDate!)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Text(todo.priority.emoji),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDueSoon(DateTime date) {
    return date.difference(DateTime.now()).inDays <= 2;
  }
}
