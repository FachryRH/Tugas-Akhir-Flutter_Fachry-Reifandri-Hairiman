import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: TaskListPage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class TaskListPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const TaskListPage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  TaskListPageState createState() => TaskListPageState();
}

class TaskListPageState extends State<TaskListPage> {
  List<Map<String, dynamic>> tasks = [];

  void _navigateToAddTaskPage() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    );

    if (newTask != null && newTask['task']!.isNotEmpty) {
      setState(() {
        tasks.add(newTask);
        tasks.sort((a, b) {
          if (b['important'] && b['urgent']) return 1;
          if (a['important'] && a['urgent']) return -1;
          if (b['urgent']) return 1;
          if (a['urgent']) return -1;
          if (b['important']) return 1;
          if (a['important']) return -1;
          return 0;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task['completed']).toList();
    final pendingTasks = tasks.where((task) => !task['completed']).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text('To-Do List'),
          actions: [
            IconButton(
              icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: widget.toggleTheme,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Tasks'),
              Tab(text: 'Completed Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(pendingTasks, allowCheckbox: true),
            _buildTaskList(completedTasks, allowCheckbox: false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddTaskPage,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasksToDisplay, {required bool allowCheckbox}) {
    if (tasksToDisplay.isEmpty) {
      return const Center(
        child: Text(
          'No tasks here!',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    return ListView.builder(
      itemCount: tasksToDisplay.length,
      itemBuilder: (context, index) {
        final task = tasksToDisplay[index];
        List<Widget> tags = [];
        if (task['important']) {
          tags.add(const TagWidget(label: 'Important', color: Colors.red));
        }
        if (task['urgent']) {
          tags.add(const TagWidget(label: 'Urgent', color: Colors.orange));
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: allowCheckbox
                ? Checkbox(
              value: task['completed'] ?? false,
              onChanged: (value) {
                setState(() {
                  task['completed'] = value;
                });
              },
            )
                : null,
            title: Text(task['task']!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task['note'] != null && task['note']!.isNotEmpty)
                  Text(task['note']!),
                if (tags.isNotEmpty)
                  Row(
                    children: tags,
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  tasks.remove(task);
                });
              },
            ),
          ),
        );
      },
    );
  }
}

class TagWidget extends StatelessWidget {
  final String label;
  final Color color;

  const TagWidget({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  AddTaskPageState createState() => AddTaskPageState();
}

class AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isImportant = false;
  bool _isUrgent = false;

  void _addTask() {
    final task = _taskController.text.trim();
    final note = _noteController.text.trim();
    if (task.isNotEmpty) {
      Navigator.pop(context, {'task': task, 'note': note, 'important': _isImportant, 'urgent': _isUrgent, 'completed': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Important'),
                    value: _isImportant,
                    onChanged: (value) {
                      setState(() {
                        _isImportant = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Urgent'),
                    value: _isUrgent,
                    onChanged: (value) {
                      setState(() {
                        _isUrgent = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}