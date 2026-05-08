import 'package:flutter/material.dart';

import '../../domain/entities/todo.dart';

Color _fade(Color color, double opacity) => color.withAlpha((opacity * 255).round());

class TodoItemCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItemCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return const Color(0xFF16A34A);
      case TodoPriority.medium:
        return const Color(0xFFF59E0B);
      case TodoPriority.high:
        return const Color(0xFFEF4444);
    }
  }

  String _getPriorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return 'Низкий';
      case TodoPriority.medium:
        return 'Средний';
      case TodoPriority.high:
        return 'Высокий';
    }
  }

  String _getStatusLabel(bool isCompleted) {
    return isCompleted ? 'Выполнено' : 'В работе';
  }

  Color _getStatusColor(bool isCompleted) {
    return isCompleted ? const Color(0xFF0F766E) : const Color(0xFF334155);
  }

  Widget _buildChip({
    required String label,
    required Color foreground,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _getPriorityColor(todo.priority);
    final backgroundColor = _fade(accentColor, 0.12);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              Colors.white,
            ],
          ),
          border: Border.all(
            color: _fade(accentColor, 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _fade(Colors.black, 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: todo.isCompleted,
                  activeColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) => onToggle(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: todo.isCompleted ? Colors.blueGrey.shade300 : const Color(0xFF0F172A),
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            label: _getPriorityLabel(todo.priority),
                            foreground: accentColor,
                            background: _fade(accentColor, 0.12),
                          ),
                          _buildChip(
                            label: _getStatusLabel(todo.isCompleted),
                            foreground: _getStatusColor(todo.isCompleted),
                            background: _fade(_getStatusColor(todo.isCompleted), 0.1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                  ),
                  tooltip: 'Удалить задачу',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
