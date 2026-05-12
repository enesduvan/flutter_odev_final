import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../utils/date_time_formatter.dart';

class TodoDetailPage extends StatelessWidget {
  const TodoDetailPage({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todo = provider.todoById(todoId);
        if (todo == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Görev Detayı')),
            body: const Center(child: Text('Görev bulunamadı.')),
          );
        }

        final colors = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Görev Detayı')),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.secondaryContainer.withValues(alpha: 0.36),
                  colors.surface,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final detailsCard = _TodoDetailsCard(todo: todo);
                  final actionPanel = _ActionPanel(todo: todo);

                  if (constraints.maxWidth >= 920) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: detailsCard),
                          const SizedBox(width: 16),
                          Expanded(child: actionPanel),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      detailsCard,
                      const SizedBox(height: 16),
                      actionPanel,
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TodoDetailsCard extends StatelessWidget {
  const _TodoDetailsCard({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final statusText = todo.isCompleted
        ? 'Tamamlandı'
        : todo.isOverdue
            ? 'Gecikti'
            : 'Devam ediyor';
    final statusColor = todo.isCompleted
        ? Colors.green
        : todo.isOverdue
            ? Colors.red
            : Colors.orange;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  todo.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: statusColor.withValues(alpha: 0.16),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            todo.description.isEmpty
                ? 'Bu görev için açıklama eklenmedi.'
                : todo.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          _InfoBox(
            icon: Icons.event_available_rounded,
            title: 'Oluşturulma',
            value: formatDateTime(todo.createdAt),
          ),
          const SizedBox(height: 10),
          _InfoBox(
            icon: Icons.notifications_active_outlined,
            title: 'Hatırlatma',
            value:
                todo.dueAt == null ? 'Belirtilmedi' : formatDateTime(todo.dueAt!),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: () async {
              await context.read<TodoProvider>().toggleTodoCompletion(todo.id);
            },
            icon: Icon(
              todo.isCompleted
                  ? Icons.radio_button_unchecked
                  : Icons.check_circle_outline,
            ),
            label: Text(
              todo.isCompleted ? 'Bekleyen olarak işaretle' : 'Tamamlandı yap',
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<TodoProvider>().deleteTodo(todo.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.delete_outline),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error.withValues(alpha: 0.5)),
            ),
            label: const Text('Görevi Sil'),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title: $value',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
