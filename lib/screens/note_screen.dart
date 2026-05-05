import 'package:flutter/material.dart';
import '../models/note_models.dart';
import '../services/storage_service.dart'; 

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final StorageService _storageService = StorageService(); 
  List<Note> _notes = [];
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadNotes(); 
  }

  Future<void> _loadNotes() async {
    final data = await _storageService.loadNotes();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  void _saveNotes() {
    _storageService.saveNotes(_notes);
  }

  void _addNote(String title, String content) {
    setState(() {
      _notes.add(
        Note(
          id: DateTime.now().millisecondsSinceEpoch,
          title: title,
          content: content,
          isHidden: false, 
        ),
      );
    });
    _saveNotes(); 
  }

  void _toggleHide(int id) {
    setState(() {
      final note = _notes.firstWhere((n) => n.id == id);
      note.isHidden = !note.isHidden;
    });
    _saveNotes(); 
  }

  void _deleteNote(int id) {
    setState(() {
      _notes.removeWhere((n) => n.id == id);
    });
    _saveNotes(); 
  }

  void _editNote(int id, String newTitle, String newContent) {
    setState(() {
      final note = _notes.firstWhere((n) => n.id == id);
      note.title = newTitle;
      note.content = newContent;
    });
    _saveNotes(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("My Notes", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
        : _notes.isEmpty
            ? const Center(
                child: Text(
                  "Don't have any notes yet.\nTap the + button to add one!",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : Padding(
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
                        onTap: () => _showEditNoteDialog(context, note), 
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
    _buildNoteDialog(context, "New Note", titleController, contentController, () {
      if (titleController.text.isNotEmpty) {
        _addNote(titleController.text, contentController.text);
        Navigator.pop(context);
      }
    }, "Save");
  }

  void _showEditNoteDialog(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    _buildNoteDialog(context, "Edit Note", titleController, contentController, () {
      if (titleController.text.isNotEmpty) {
        _editNote(note.id, titleController.text, contentController.text);
        Navigator.pop(context);
      }
    }, "Update");
  }

  void _buildNoteDialog(BuildContext context, String title, TextEditingController tCtrl, TextEditingController cCtrl, VoidCallback onAction, String actionText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Title", 
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
              ),
            ),
            TextField(
              controller: cCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Content", 
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: onAction,
            child: Text(actionText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}