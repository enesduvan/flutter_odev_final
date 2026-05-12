import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_card.dart';
import 'add_todo_page.dart';
import 'todo_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Görev Hatırlatıcı'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Takvim',
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer.withValues(alpha: 0.45),
                  colors.secondaryContainer.withValues(alpha: 0.25),
                  colors.surface,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final summaryPanel = _SummaryPanel(provider: provider);
                  final todos = provider.todos;
                  final mainContent = _TodoSection(todos: todos);

                  if (constraints.maxWidth >= 980) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 320,
                            child: Column(
                              children: [
                                const _HeroPanel(),
                                const SizedBox(height: 16),
                                summaryPanel,
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: mainContent),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: _HeroPanel(),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: summaryPanel,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: mainContent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AddTodoPage()));
        },
        icon: const Icon(Icons.add_task),
        label: const Text('Görev Ekle'),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colors = Theme.of(context).colorScheme;
    final months = <String>[
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${now.day} ${months[now.month - 1]}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Bugün için odak: net plan, güçlü takip.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Görevlerini düzenle, hatırlatmaları aktif tut ve ritmini koru.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.provider});

  final TodoProvider provider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatChip(
              title: 'Toplam',
              value: provider.totalCount.toString(),
              color: Colors.indigo,
              icon: Icons.stacked_bar_chart_rounded,
            ),
            _StatChip(
              title: 'Bekleyen',
              value: provider.pendingCount.toString(),
              color: Colors.orange,
              icon: Icons.timelapse_rounded,
            ),
            _StatChip(
              title: 'Tamamlanan',
              value: provider.completedCount.toString(),
              color: Colors.green,
              icon: Icons.verified_rounded,
            ),
            _StatChip(
              title: 'Geciken',
              value: provider.overdueCount.toString(),
              color: Colors.red,
              icon: Icons.error_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoSection extends StatelessWidget {
  const _TodoSection({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: todos.isEmpty
            ? const _EmptyState(key: ValueKey('empty-state'))
            : _TodoList(todos: todos),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.todos, super.key});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const ValueKey('todo-list'),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
      itemCount: todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final todo = todos[index];

        return TodoCard(
          todo: todo,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => TodoDetailPage(todoId: todo.id),
              ),
            );
          },
          onDelete: () async {
            await context.read<TodoProvider>().deleteTodo(todo.id);
          },
          onToggleCompleted: (_) async {
            await context.read<TodoProvider>().toggleTodoCompletion(todo.id);
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.primary, colors.secondary],
                ),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 42,
                color: colors.onPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz görev yok',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni görev ekleyerek hatırlatmalarını planlayabilirsin.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
