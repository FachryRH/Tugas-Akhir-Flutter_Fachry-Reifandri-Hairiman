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
  List<Map<String, dynamic>> completedTasks = [];

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
          // Priority: Urgent + Important, Urgent, Important, None
          int aPriority = (a['urgent'] ? 2 : 0) + (a['important'] ? 1 : 0);
          int bPriority = (b['urgent'] ? 2 : 0) + (b['important'] ? 1 : 0);
          return bPriority.compareTo(aPriority);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Tab(text: 'Tasks'),
              Tab(text: 'Completed Tasks'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            tasks.isEmpty
                ? const Center(
              child: Text(
                'No tasks yet. Add a new task!',
                style: TextStyle(fontSize: 18.0),
              ),
            )
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                List<Widget> tags = [];
                if (task['important']) {
                  tags.add(_buildTag('Important', Colors.red));
                }
                if (task['urgent']) {
                  tags.add(_buildTag('Urgent', Colors.orange));
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Checkbox(
                      value: task['completed'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          task['completed'] = value;
                          if (value == true) {
                            completedTasks.add(task);
                            tasks.removeAt(index);
                          }
                        });
                      },
                    ),
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
                          tasks.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            completedTasks.isEmpty
                ? const Center(
              child: Text(
                'No completed tasks yet.',
                style: TextStyle(fontSize: 18.0),
              ),
            )
                : ListView.builder(
              itemCount: completedTasks.length,
              itemBuilder: (context, index) {
                final task = completedTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(task['task']!),
                    subtitle: task['note'] != null && task['note']!.isNotEmpty
                        ? Text(task['note']!)
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          completedTasks.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddTaskPage,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
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