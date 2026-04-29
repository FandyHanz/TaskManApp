import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/task_models.dart';

class StorageService {
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
}