import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/todo.dart';
import '../cubit/todos_cubit.dart';
import '../cubit/todos_state.dart';
import '../widgets/error_view.dart';
import '../widgets/todo_item_card.dart';

Color _fade(Color color, double opacity) => color.withAlpha((opacity * 255).round());

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TodosCubit>()..fetchTodos(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF4F7FB),
        floatingActionButton: Builder(
          builder: (screenContext) => FloatingActionButton.extended(
            onPressed: () => _showAddSheet(screenContext),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить задачу'),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEAF8F6),
                Color(0xFFF4F7FB),
                Color(0xFFFDFDFD),
              ],
            ),
          ),
          child: Stack(
            children: [
              const _BackgroundOrbs(),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                      child: BlocBuilder<TodosCubit, TodosState>(
                        builder: (context, state) {
                          final todos = state is TodosLoaded ? state.todos : const <Todo>[];
                          final totalCount = todos.length;
                          final doneCount = todos.where((todo) => todo.isCompleted).length;
                          final pendingCount = totalCount - doneCount;

                          return _HeaderCard(
                            title: 'Список задач',
                            subtitle: 'Задачи из сети, приоритеты, свайп-удаление и быстрое добавление.',
                            totalCount: totalCount,
                            pendingCount: pendingCount,
                            doneCount: doneCount,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _fade(Colors.white, 0.72),
                              border: Border.all(
                                color: _fade(Colors.white, 0.8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _fade(Colors.black, 0.06),
                                  blurRadius: 30,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: BlocBuilder<TodosCubit, TodosState>(
                              builder: (context, state) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  child: _buildStateContent(context, state),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, TodosState state) {
    if (state is TodosLoading) {
      return const _LoadingState(
        key: ValueKey('loading'),
      );
    }

    if (state is TodosError) {
      return Padding(
        key: const ValueKey('error'),
        padding: const EdgeInsets.all(16),
        child: ErrorView(
          message: state.message,
          onRetry: () => context.read<TodosCubit>().fetchTodos(),
        ),
      );
    }

    if (state is TodosLoaded) {
      if (state.todos.isEmpty) {
        return _EmptyState(
          key: const ValueKey('empty'),
          onCreate: () => _showAddSheet(context),
        );
      }

      return RefreshIndicator(
        key: const ValueKey('loaded'),
        color: const Color(0xFF0F766E),
        onRefresh: () => context.read<TodosCubit>().fetchTodos(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 96),
          itemCount: state.todos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            final todo = state.todos[index];
            return Dismissible(
              key: ValueKey('todo-${todo.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
              ),
              onDismissed: (_) => context.read<TodosCubit>().deleteTodo(todo.id),
              child: TodoItemCard(
                todo: todo,
                onToggle: () => context.read<TodosCubit>().toggleTodoStatus(todo),
                onDelete: () => context.read<TodosCubit>().deleteTodo(todo.id),
              ),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink(key: ValueKey('initial'));
  }

  Future<void> _showAddSheet(BuildContext screenContext) async {
    final controller = TextEditingController();
    TodoPriority selectedPriority = TodoPriority.medium;

    try {
      await showModalBottomSheet<void>(
        context: screenContext,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDFEFF),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade200,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Новая задача',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Добавьте задачу и сразу выберите её приоритет.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey.shade600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: controller,
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Название задачи',
                              hintText: 'Например: Купить продукты',
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Приоритет',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: TodoPriority.values.map((priority) {
                              final isSelected = selectedPriority == priority;
                              final accentColor = _priorityColor(priority);
                              return ChoiceChip(
                                label: Text(_priorityLabel(priority)),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    selectedPriority = priority;
                                  });
                                },
                                labelStyle: TextStyle(
                                  color: isSelected ? accentColor : Colors.blueGrey.shade700,
                                  fontWeight: FontWeight.w700,
                                ),
                                selectedColor: _fade(accentColor, 0.14),
                                backgroundColor: const Color(0xFFF5F7FA),
                                side: BorderSide(
                                  color: isSelected ? accentColor : Colors.transparent,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final title = controller.text.trim();
                                if (title.isEmpty) return;

                                screenContext.read<TodosCubit>().addTodo(
                                      title,
                                      selectedPriority,
                                    );
                                Navigator.pop(sheetContext);
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Добавить задачу'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  String _priorityLabel(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return 'Низкий';
      case TodoPriority.medium:
        return 'Средний';
      case TodoPriority.high:
        return 'Высокий';
    }
  }

  Color _priorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return const Color(0xFF16A34A);
      case TodoPriority.medium:
        return const Color(0xFFF59E0B);
      case TodoPriority.high:
        return const Color(0xFFEF4444);
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int totalCount;
  final int pendingCount;
  final int doneCount;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.totalCount,
    required this.pendingCount,
    required this.doneCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _fade(Colors.white, 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _fade(Colors.white, 0.8)),
        boxShadow: [
          BoxShadow(
            color: _fade(Colors.black, 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Всего',
                  value: totalCount.toString(),
                  color: const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'В работе',
                  value: pendingCount.toString(),
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  label: 'Готово',
                  value: doneCount.toString(),
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.swipe_down_rounded,
                label: 'Обновление свайпом вниз',
              ),
              _InfoPill(
                icon: Icons.swipe_left_rounded,
                label: 'Свайп влево удаляет задачу',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _fade(color, 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFE6FFFB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inbox_rounded,
                size: 42,
                color: Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Пока нет задач',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте первую задачу, чтобы начать работу и отслеживать приоритеты.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Добавить первую задачу'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF0F766E),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  _fade(const Color(0xFF0F766E), 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _fade(const Color(0xFF0F766E), 0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _fade(const Color(0xFF0F766E), 0.20),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator.adaptive(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Загружаем задачи',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Подключаемся к сети и готовим аккуратный список задач.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                const _SkeletonTaskCard(),
                const SizedBox(height: 12),
                const _SkeletonTaskCard(),
                const SizedBox(height: 12),
                const _SkeletonTaskCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonTaskCard extends StatelessWidget {
  const _SkeletonTaskCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 10,
                  width: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrbs extends StatelessWidget {
  const _BackgroundOrbs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _fade(const Color(0xFF14B8A6), 0.18),
                    _fade(const Color(0xFF14B8A6), 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _fade(const Color(0xFF60A5FA), 0.12),
                    _fade(const Color(0xFF60A5FA), 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
