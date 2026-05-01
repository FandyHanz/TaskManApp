import 'package:flutter/material.dart';
import '../models/task_models.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

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

  // State untuk kontrol kategori mana yang tampil (To Do / Finished)
  bool _showFinishedCategory = false;

  @override
  void initState() {
    super.initState();
    _loadAllTasks();
    _notificationService.init();
  }

  // 1. Load data dari JSON
  Future<void> _loadAllTasks() async {
    final data = await _storageService.loadTasks();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  // 2. Fungsi Tambah Task Baru (Ini yang tadi hilang)
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

    final reminderTime = deadline.subtract(const Duration(days: 1));
    if (reminderTime.isAfter(DateTime.now())) {
      _notificationService.scheduleNotification(
        id: newTask.id,
        title: "H-1 Deadline: $title",
        body: "Tommorow is the due date",
        scheduledDate: reminderTime,
      );
    }
  }

  // 3. Fungsi Tandai Selesai
  void _markAsDone(int id) {
    setState(() {
      _tasks.firstWhere((t) => t.id == id).isFinished = true;
    });
    _storageService.saveTasks(_tasks);
  }

  // 4. Fungsi Hapus Task
  void _deleteTask(int id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
    _storageService.saveTasks(_tasks);
    _notificationService.cancelNotification(id);
  }

  // 5. Fungsi Tampilkan Dialog Input (Ini jg tadi bikin merah)
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("New Task", style: TextStyle(color: Colors.white)),
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
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Description",
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.purpleAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tombol Pilih Tanggal
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) selectedDate = picked;
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("Set Deadline"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
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
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void tambahTask(BuildContext context) {
    _showAddTaskDialog(context);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
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
