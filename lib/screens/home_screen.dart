import 'package:flutter/material.dart';
import '../models/task_models.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllTasks();
  }

  // Load data dari JSON
  Future<void> _loadAllTasks() async {
    final data = await _storageService.loadTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  // Tambah Task Baru
  void _addNewTask(String title, String desc, DateTime deadline) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      desc: desc,
      deadline: deadline,
    );
    setState(() {
      _tasks.add(newTask);
    });
    _storageService.saveTasks(_tasks);
  }

  void _markAsDone(int id) {
    setState(() {
      _tasks.firstWhere((t) => t.id == id).isFinished = true;
    });
    _storageService.saveTasks(_tasks);
  }

  void _deleteTask(int id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
    _storageService.saveTasks(_tasks);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final todoTasks = _tasks.where((t) => !t.isFinished).toList();
    final finishedTasks = _tasks.where((t) => t.isFinished).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Task Board"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom To Do
            Expanded(child: _buildTaskColumn("To Do", todoTasks, false)),
            const SizedBox(width: 16),
            // Kolom Finished
            Expanded(child: _buildTaskColumn("Finished", finishedTasks, true)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskColumn(String title, List<Task> tasks, bool isFinished) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isFinished
                ? Colors.green.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$title (${tasks.length})",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFinished ? Colors.green : Colors.blueAccent,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.desc),
                      const SizedBox(height: 8),
                      // Baris 139 di kode ente mestinya bagian ini:
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${task.deadline.day}/${task.deadline.month}/${task.deadline.year}",
                              overflow: TextOverflow
                                  .ellipsis, 
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isFinished)
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          onPressed: () => _markAsDone(task.id),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteTask(task.id),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Task"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Task Title"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.date_range),
                label: const Text("Select Deadline"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) selectedDate = picked;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addNewTask(
                  titleController.text,
                  descController.text,
                  selectedDate,
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Add Task"),
          ),
        ],
      ),
    );
  }
}
