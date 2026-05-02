import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task_models.dart';
import '../models/note_models.dart';

class StorageService {


  Future<File> get _taskFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks.json');
  }

  Future<File> get _noteFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/notes_data.json'); // File khusus Notes
  }

  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/tasks.json');
  }

  Future<List<Task>> loadTasks() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      String content = await file.readAsString();
      List jsonList = json.decode(content);
      return jsonList.map((e) => Task.fromJson(e)).toList();
    } catch (e) { return []; }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final file = await _localFile;
    await file.writeAsString(json.encode(tasks.map((e) => e.toJson()).toList()));
  }

  Future<void> clearAll() async {
    final file = await _localFile;
    if (await file.exists()) await file.delete();
  }

  Future<List<Note>> loadNotes() async {
    try {
      final file = await _noteFile;
      if (!await file.exists()) return [];
      String content = await file.readAsString();
      List jsonList = json.decode(content);
      return jsonList.map((e) => Note.fromJson(e)).toList();
    } catch (e) { 
      print(" Error loading notes: $e");
      return []; 
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    try {
      final file = await _noteFile;
      await file.writeAsString(json.encode(notes.map((e) => e.toJson()).toList()));
    } catch (e) {
      print(" Error saving notes: $e");
    }
  }

  Future<void> clearAllNotes() async {
    final taskF = await _taskFile;
    final noteF = await _noteFile;
    if (await taskF.exists()) await taskF.delete();
    if (await noteF.exists()) await noteF.delete();
  }
}