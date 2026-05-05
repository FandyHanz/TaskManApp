import 'package:flutter/material.dart';
import '../models/task_models.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _showFinishedCategory = false;

  @override
  void initState() {
    super.initState();
    _loadAllTasks();
    _notificationService.init().then((_) {
      _notificationService.requestPermissions();
      _notificationService.checkExactAlarmPermission();
    });
  }

  Future<void> _loadAllTasks() async {
    final data = await _storageService.loadTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  void _addNewTask(String title, String desc, DateTime deadline) {
    final int taskId = Random().nextInt(2147483647);
    final newTask = Task(
      id: taskId,
      title: title,
      desc: desc,
      deadline: deadline,
    );
    setState(() => _tasks.add(newTask));
    _storageService.saveTasks(_tasks);
    _scheduleTaskNotify(newTask);
  }

  void _editTask(
    int id,
    String newTitle,
    String newDesc,
    DateTime newDeadline,
  ) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == id); // Pake ID lama
      if (index != -1) {
        _tasks[index].title = newTitle;
        _tasks[index].desc = newDesc;
        _tasks[index].deadline = newDeadline;
      }
    });
    _storageService.saveTasks(_tasks);

    final task = _tasks.firstWhere((t) => t.id == id);
    _notificationService.cancelNotification(id);
    _scheduleTaskNotify(task);
  }

  void _scheduleTaskNotify(Task task) {
    final now = DateTime.now();
    final oneDayBefore = task.deadline.subtract(const Duration(days: 1));
    final oneHourBefore = task.deadline.subtract(const Duration(hours: 1));

    if (oneDayBefore.isAfter(now)) {
      // Scenario: Deadline is at least more than 24 hours away.
      _notificationService.scheduleNotification(
        id: task.id,
        title: "Upcoming Deadline",
        body: "Reminder: Your task \"${task.title}\" is due tomorrow.",
        scheduledDate: oneDayBefore,
      );
    } else if (oneHourBefore.isAfter(now)) {
      // Scenario: Deadline is today, and there's still more than an hour left.
      _notificationService.scheduleNotification(
        id: task.id,
        title: "Urgent: Final Hour",
        body: "Heads up! Your task \"${task.title}\" is due in one hour.",
        scheduledDate: oneHourBefore,
      );
    } else if (task.deadline.isAfter(now)) {
      // Scenario: Deadline is very close (less than an hour).
      _notificationService.scheduleNotification(
        id: task.id,
        title: "Task Due Now",
        body:
            "Time's up! Your task \"${task.title}\" has reached its deadline.",
        scheduledDate: task.deadline,
      );
    }
  }

  void _markAsDone(int id) {
    setState(() => _tasks.firstWhere((t) => t.id == id).isFinished = true);
    _storageService.saveTasks(_tasks);
  }

  void _deleteTask(int id) {
    setState(() => _tasks.removeWhere((t) => t.id == id));
    _storageService.saveTasks(_tasks);
    _notificationService.cancelNotification(id);
  }

  void _showTaskDialog({Task? task}) {
    final isEdit = task != null;
    final titleController = TextEditingController(
      text: isEdit ? task.title : "",
    );
    final descController = TextEditingController(text: isEdit ? task.desc : "");

    // Default: H+1 dari sekarang
    DateTime selectedDate = isEdit
        ? task.deadline
        : DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              isEdit ? "Edit Task" : "New Task",
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Task Title",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        if (!context.mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          // Pake setDialogState biar teks tombol langsung update!
                          setDialogState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.alarm),
                    label: Text(
                      "${selectedDate.day}/${selectedDate.month} - ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    if (isEdit) {
                      _editTask(
                        task.id,
                        titleController.text,
                        descController.text,
                        selectedDate,
                      );
                    } else {
                      _addNewTask(
                        titleController.text,
                        descController.text,
                        selectedDate,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEdit ? "Update" : "Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentTasks = _tasks
        .where((t) => t.isFinished == _showFinishedCategory)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(_showFinishedCategory ? "Finished Board" : "To-Do Board"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1F1B24),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 50),
            const Icon(Icons.apps, size: 64, color: Colors.purpleAccent),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.playlist_add_check_rounded,
                color: !_showFinishedCategory
                    ? Colors.purpleAccent
                    : Colors.white70,
              ),
              title: Text(
                "To Do List",
                style: TextStyle(
                  color: !_showFinishedCategory
                      ? Colors.purpleAccent
                      : Colors.white70,
                ),
              ),
              onTap: () {
                setState(() => _showFinishedCategory = false);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.done_all_rounded,
                color: _showFinishedCategory
                    ? Colors.greenAccent
                    : Colors.white70,
              ),
              title: Text(
                "Finished Board",
                style: TextStyle(
                  color: _showFinishedCategory
                      ? Colors.greenAccent
                      : Colors.white70,
                ),
              ),
              onTap: () {
                setState(() => _showFinishedCategory = true);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _showFinishedCategory
          ? null
          : FloatingActionButton(
              onPressed: () => _showTaskDialog(),
              backgroundColor: Colors.purpleAccent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _showFinishedCategory
                    ? Colors.green.withOpacity(0.1)
                    : Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_showFinishedCategory ? "Done" : "Tasks"} (${currentTasks.length})",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _showFinishedCategory
                      ? Colors.greenAccent
                      : Colors.purpleAccent,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: currentTasks.length,
                itemBuilder: (context, index) {
                  final task = currentTasks[index];
                  return Card(
                    color: const Color(0xFF1E1E1E),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      onTap: () => _showTaskDialog(task: task),
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            task.desc,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${task.deadline.day}/${task.deadline.month}/${task.deadline.year}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          _showFinishedCategory
                              ? Icons.delete_sweep
                              : Icons.check_circle,
                          color: _showFinishedCategory
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          size: 28,
                        ),
                        onPressed: () => _showFinishedCategory
                            ? _deleteTask(task.id)
                            : _markAsDone(task.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
