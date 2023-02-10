import 'dart:convert';

import 'package:listatarefas/models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String todoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  void saveTodoList(List<ToDo> todos) {
    final String jsonString = json.encode(todos);
    sharedPreferences.setString(todoListKey, jsonString);
  }

  Future<List<ToDo>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString);
    return jsonDecoded.map((e) => ToDo.fromJson(e)).toList();
  }
}
