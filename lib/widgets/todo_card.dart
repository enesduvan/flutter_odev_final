import 'package:flutter/material.dart';

import '../models/todo.dart';
import '../utils/date_time_formatter.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onDelete,
    required this.onToggleCompleted,
  });

  final Todo todo;
  final VoidCallback onTap;
  final Future<void> Function() onDelete;
  final Future<void> Function(bool value) onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final isCompleted = todo.isCompleted;
    final isOverdue = todo.isOverdue;
    final colors = Theme.of(context).colorScheme;

    final Color accentColor = isCompleted
        ? Colors.green
        : isOverdue
            ? Colors.red
            : colors.primary;
    final Color backgroundColor = accentColor.withValues(alpha: 0.08);
    final Color borderColor = accentColor.withValues(alpha: 0.22);

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.task_alt_rounded
                        : isOverdue
                            ? Icons.priority_high_rounded
                            : Icons.task_rounded,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        todo.description.isEmpty
                            ? 'Açıklama eklenmedi.'
                            : todo.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      if (todo.dueAt != null)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 280),
                          opacity: isCompleted ? 0.6 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.11),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Hatırlatma: ${formatDateTime(todo.dueAt!)}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        )
                      else
                        Text(
                          'Hatırlatma tarihi yok',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Checkbox(
                      value: isCompleted,
                      activeColor: accentColor,
                      onChanged: (value) async {
                        if (value == null) {
                          return;
                        }
                        await onToggleCompleted(value);
                      },
                    ),
                    IconButton(
                      onPressed: () async {
                        await onDelete();
                      },
                      tooltip: 'Sil',
                      icon: Icon(Icons.delete_outline, color: colors.error),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
