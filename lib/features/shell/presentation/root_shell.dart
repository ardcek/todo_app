import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/core/config/language_controller.dart';
import 'package:todo_app/core/theme/theme_controller.dart';
import 'package:todo_app/features/tasks/presentation/add_task_sheet.dart';
import 'package:todo_app/features/tasks/presentation/projects_page.dart';
import 'package:todo_app/features/tasks/presentation/today_page.dart';
import 'package:todo_app/features/tasks/presentation/upcoming_page.dart';
import 'package:todo_app/features/tasks/presentation/today_page.dart' as today;
import 'package:todo_app/features/timer/presentation/timer_widget.dart';
import 'package:todo_app/features/tasks/presentation/models/project_model.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final index = ref.watch(selectedIndexProvider);
    final language = ref.watch(languageControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TimerWidget(),
            Expanded(
              child: IndexedStack(
                index: index,
                children: const [
                  TodayPage(),
                  UpcomingPage(),
                  ProjectsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _FABButton(index: index, language: language),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _BottomNav(index: index, language: language, colorScheme: colorScheme),
      appBar: _AppBarWidget(index: index, language: language),
    );
  }
}

// Separate FAB to prevent rebuild
class _FABButton extends ConsumerWidget {
  const _FABButton({required this.index, required this.language});
  
  final int index;
  final String language;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () async {
        if (index == 2) {
          // Projects page - add project
          _showAddProjectDialog(context, ref, language);
        } else {
          // Today/Upcoming - add task
          final result = await showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            showDragHandle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            builder: (context) => const AddTaskSheet(),
          );
          if (result != null && context.mounted) {
            // UI-only: yeni task'ı bugün listesine pushla
            try {
              final title = result['title'] as String;
              final priority = (result['priority'] as int?) ?? 1;
              final dt = result['dateTime'] as DateTime?;
              
              // Get current task count for unnamed tasks
              final allTasks = ref.read(today.todayTasksProvider);
              int unnamedCount = 1;
              for (final task in allTasks) {
                final titleLower = task.title.toLowerCase();
                if (titleLower.startsWith('unnamed task') || 
                    titleLower.startsWith('adsız görev')) {
                  final match = RegExp(r'\d+').firstMatch(task.title);
                  if (match != null) {
                    final num = int.tryParse(match.group(0)!) ?? 0;
                    if (num >= unnamedCount) unnamedCount = num + 1;
                  }
                }
              }
              
              final taskTitle = title.trim().isEmpty
                  ? (language == 'en' 
                      ? 'Unnamed Task $unnamedCount' 
                      : 'Adsız Görev $unnamedCount')
                  : title;
              
              final newTask = today.DemoTask(
                title: taskTitle,
                priorityIdx: priority.clamp(0, 2),
                dueLabel: dt != null ? _formatDueLabel(dt) : null,
                dueDate: dt,
              );
              ref.read(today.todayTasksProvider.notifier).add(newTask);
              
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(language == 'en' ? 'Task added' : 'Görev eklendi'),
                  action: SnackBarAction(label: language == 'en' ? 'Undo' : 'Geri al', onPressed: () {}),
                ),
              );
            } catch (_) {}
          }
        }
      },
      icon: const Icon(Icons.add),
      label: Text(
        index == 2
            ? (language == 'en' ? 'Add Project' : 'Proje Ekle')
            : (language == 'en' ? 'Add Task' : 'Görev Ekle'),
      ),
    );
  }

  String _formatDueLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dt.year, dt.month, dt.day);
    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (dateOnly == today) return 'Bugün $time';
    final tomorrow = today.add(const Duration(days: 1));
    if (dateOnly == tomorrow) return 'Yarın $time';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} $time';
  }
  
  void _showAddProjectDialog(BuildContext context, WidgetRef ref, String language) {
    final nameController = TextEditingController();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    final icons = [
      Icons.folder,
      Icons.work,
      Icons.home,
      Icons.school,
      Icons.shopping_cart,
      Icons.fitness_center,
    ];
    
    Color selectedColor = colors[0];
    IconData selectedIcon = icons[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(language == 'en' ? 'New Project' : 'Yeni Proje'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: language == 'en' ? 'Project name' : 'Proje adı',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  language == 'en' ? 'Color' : 'Renk',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colors.map((color) {
                    return InkWell(
                      onTap: () => setDialogState(() => selectedColor = color),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: selectedColor == color
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: selectedColor == color
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  language == 'en' ? 'Icon' : 'İkon',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: icons.map((icon) {
                    return InkWell(
                      onTap: () => setDialogState(() => selectedIcon = icon),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: selectedIcon == icon
                              ? selectedColor.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedIcon == icon
                                ? selectedColor
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: selectedIcon == icon ? selectedColor : Colors.grey[600],
                          size: 28,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(language == 'en' ? 'Cancel' : 'İptal'),
            ),
            FilledButton(
              onPressed: () {
                var name = nameController.text.trim();
                
                // Eğer isim boşsa otomatik isim oluştur
                if (name.isEmpty) {
                  final allProjects = ref.read(projectsProvider);
                  int unnamedCount = 1;
                  for (final project in allProjects) {
                    final projectName = project.name.toLowerCase();
                    if (projectName.startsWith('unnamed project') || 
                        projectName.startsWith('adsız proje')) {
                      final match = RegExp(r'\d+').firstMatch(project.name);
                      if (match != null) {
                        final num = int.tryParse(match.group(0)!) ?? 0;
                        if (num >= unnamedCount) unnamedCount = num + 1;
                      }
                    }
                  }
                  name = language == 'en' 
                      ? 'Unnamed Project $unnamedCount' 
                      : 'Adsız Proje $unnamedCount';
                }
                
                final project = Project(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  color: selectedColor,
                  icon: selectedIcon,
                );
                ref.read(projectsProvider.notifier).addProject(project);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      language == 'en'
                          ? 'Project created: $name'
                          : 'Proje oluşturuldu: $name',
                    ),
                  ),
                );
              },
              child: Text(language == 'en' ? 'Create' : 'Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}

// Separate BottomNav to prevent rebuild
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.index,
    required this.language,
    required this.colorScheme,
  });

  final int index;
  final String language;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => ref.read(selectedIndexProvider.notifier).state = value,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.today_outlined),
              selectedIcon: const Icon(Icons.today),
              label: language == 'en' ? 'Today' : 'Bugün',
            ),
            NavigationDestination(
              icon: const Icon(Icons.upcoming_outlined),
              selectedIcon: const Icon(Icons.upcoming),
              label: language == 'en' ? 'Upcoming' : 'Yaklaşan',
            ),
            NavigationDestination(
              icon: const Icon(Icons.folder_outlined),
              selectedIcon: const Icon(Icons.folder),
              label: language == 'en' ? 'Projects' : 'Projeler',
            ),
          ],
          indicatorColor: colorScheme.secondaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );
      },
    );
  }
}

// Separate AppBar to prevent rebuild
class _AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  const _AppBarWidget({
    required this.index,
    required this.language,
  });

  final int index;
  final String language;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _getPageTitle(int index, String language) {
    if (language == 'en') {
      return index == 0 ? 'Today' : index == 1 ? 'Upcoming' : 'Projects';
    }
    return index == 0 ? 'Bugün' : index == 1 ? 'Yaklaşan' : 'Projeler';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: Text(_getPageTitle(index, language)),
      actions: [
        Consumer(builder: (context, ref, _) {
          final isDark = ref.watch(themeControllerProvider);
          return IconButton(
            tooltip: isDark 
              ? (language == 'en' ? 'Light mode' : 'Aydınlık mod') 
              : (language == 'en' ? 'Dark mode' : 'Karanlık mod'),
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeControllerProvider.notifier).toggleTheme(),
          );
        }),
        Consumer(builder: (context, ref, _) {
          final lang = ref.watch(languageControllerProvider);
          return PopupMenuButton<String>(
            tooltip: language == 'en' ? 'Language' : 'Dil',
            icon: Text(lang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            onSelected: (value) => ref.read(languageControllerProvider.notifier).setLanguage(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'tr',
                child: Text('🇹🇷 ${language == "en" ? "Turkish" : "Türkçe"}'),
              ),
              const PopupMenuItem(value: 'en', child: Text('🇺🇸 English')),
            ],
          );
        }),
      ],
    );
  }
}



