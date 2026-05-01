import 'package:flutter/material.dart';
import '../models/note_models.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> _notes = [];

  void _addNote(String title, String content) {
    setState(() {
      _notes.add(
        Note(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          content: content,
        ),
      );
    });
  }

  void _toggleHide(int id) {
    setState(() {
      final note = _notes.firstWhere((n) => n.id == id);
      note.isHidden = !note.isHidden;
    });
  }

  void _deleteNote(int id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Notes"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // drawer: Drawer(
      //   backgroundColor: const Color(0xFF1F1B24),
      //   child: Column(
      //     children: [
      //       const SizedBox(height: 50),
      //       const Icon(Icons.note_alt, size: 64, color: Colors.orangeAccent),
      //       ListTile(
      //         leading: const Icon(Icons.list, color: Colors.white),
      //         title: const Text(
      //           "Task Board",
      //           style: TextStyle(color: Colors.white),
      //         ),
      //         onTap: () => Navigator.pushReplacementNamed(context, '/'),
      //       ),
      //       ListTile(
      //         leading: const Icon(Icons.edit_note, color: Colors.orangeAccent),
      //         title: const Text(
      //           "My Notes",
      //           style: TextStyle(color: Colors.orangeAccent),
      //         ),
      //         onTap: () => Navigator.pop(context),
      //       ),
      //     ],
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  note.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  note.isHidden ? "••••••••" : note.content,
                  style: TextStyle(
                    color: note.isHidden ? Colors.grey : Colors.white70,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tombol Mata (Hidden Feature)
                    IconButton(
                      icon: Icon(
                        note.isHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.orangeAccent,
                      ),
                      onPressed: () => _toggleHide(note.id),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _deleteNote(note.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: () => _showNoteDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("New Note", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Title",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: contentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Content",
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addNote(titleController.text, contentController.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
