import 'package:flutter/material.dart';
import 'package:listatarefas/models/todo.dart';
import 'package:listatarefas/repositories/todo_repository.dart';
import 'package:listatarefas/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todosControles = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<ToDo> todos = [];

  ToDo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) => {
          setState(() {
            todos = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todosControles,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Informe a Tarefa",
                          hintText: "Ex. Estudar",
                          errorText: errorText,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color(0xff00d7f3),
                            width: 3,
                          )),
                          labelStyle: TextStyle(
                            color: Color(0xff00d7f3),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (todosControles.text == "") {
                          setState(() {
                            errorText = 'Campo Obrigatório';
                          });
                          return;
                        }
                        setState(() {
                          ToDo newTodo = ToDo(
                            title: todosControles.text,
                            dateTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                          todoRepository.saveTodoList(todos);
                          todosControles.clear();
                          errorText = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00d7f3),
                        padding: EdgeInsets.all(14),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (ToDo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Você possui ${todos.length} terefas pendentes.",
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: showDeletedTodoConfirmationDialog,
                      child: const Text("Limpar Tudo"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00d7f3),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(ToDo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
      todoRepository.saveTodoList(todos);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Tarefa ${todo.title} apagada com sucesso.",
          style: TextStyle(
            color: Color(0xff060708),
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: "Desfazer",
          textColor: Color(0xff00d7f3),
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
              todoRepository.saveTodoList(todos);
            });
          },
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void showDeletedTodoConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Limpar tudo?"),
        content: Text("Deseja realmente limpar tudo?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancelar", style: TextStyle(color: Color(0xff00d7f3))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAll();
            },
            child: Text(
              "Limpar Tudo",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  void deleteAll() {
    setState(() {
      todos.clear();
      todoRepository.saveTodoList(todos);
    });
  }
}
