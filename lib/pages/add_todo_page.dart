import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';
import '../utils/date_time_formatter.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDueAt;
  bool _setReminder = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueAt ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueAt ?? now),
    );

    if (!mounted || pickedTime == null) {
      return;
    }

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (selected.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen ileri bir tarih/saat seçin.')),
      );
      return;
    }

    setState(() {
      _selectedDueAt = selected;
    });
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await context.read<TodoProvider>().addTodo(
          title: _titleController.text,
          description: _descriptionController.text,
          dueAt: _selectedDueAt,
          setReminder: _selectedDueAt != null && _setReminder,
        );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Görev')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.5),
              colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints.maxWidth > 760 ? 640 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(
                          dueAt: _selectedDueAt,
                          onSelectDate: _pickDateTime,
                          onClearDate: _selectedDueAt == null
                              ? null
                              : () {
                                  setState(() {
                                    _selectedDueAt = null;
                                  });
                                },
                        ),
                        const SizedBox(height: 14),
                        _FormCard(
                          formKey: _formKey,
                          titleController: _titleController,
                          descriptionController: _descriptionController,
                          selectedDueAt: _selectedDueAt,
                          setReminder: _setReminder,
                          onReminderChanged: (value) {
                            setState(() {
                              _setReminder = value;
                            });
                          },
                          isSubmitting: _isSubmitting,
                          onSave: _saveTodo,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.dueAt,
    required this.onSelectDate,
    required this.onClearDate,
  });

  final DateTime? dueAt;
  final VoidCallback onSelectDate;
  final VoidCallback? onClearDate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [colors.primary, colors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Görev planını oluştur',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Başlık, açıklama ve hatırlatma tarihini belirleyip tek dokunuşla kaydet.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onPrimary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.onPrimary,
                  foregroundColor: colors.primary,
                ),
                onPressed: onSelectDate,
                icon: const Icon(Icons.schedule_rounded),
                label: const Text('Tarih/Saat Seç'),
              ),
              if (onClearDate != null)
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.onPrimary,
                    side: BorderSide(color: colors.onPrimary),
                  ),
                  onPressed: onClearDate,
                  child: const Text('Temizle'),
                ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: colors.onPrimary.withValues(alpha: 0.2),
                ),
                child: Text(
                  dueAt == null
                      ? 'Hatırlatma: seçilmedi'
                      : 'Hatırlatma: ${formatDateTime(dueAt!)}',
                  style: TextStyle(color: colors.onPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.selectedDueAt,
    required this.setReminder,
    required this.onReminderChanged,
    required this.isSubmitting,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final DateTime? selectedDueAt;
  final bool setReminder;
  final ValueChanged<bool> onReminderChanged;
  final bool isSubmitting;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.93),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Görev başlığı boş bırakılamaz.';
                }
                if (value.trim().length < 3) {
                  return 'En az 3 karakter girin.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: descriptionController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                title: const Text('Bildirim ile hatırlat'),
                subtitle: const Text('Seçili tarih/saatte bildirim gönderilir.'),
                value: selectedDueAt != null && setReminder,
                onChanged: selectedDueAt == null ? null : onReminderChanged,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: isSubmitting ? null : onSave,
              icon: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: const Text('Görevi Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
