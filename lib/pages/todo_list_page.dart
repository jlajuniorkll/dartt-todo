import 'package:dartt_todo/pages/components/todo_list_item.dart';
import 'package:dartt_todo/pages/models/todo.dart';
import 'package:dartt_todo/repository/todo_repository.dart';
import 'package:flutter/material.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> tarefas = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;

  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then((value) {
      setState(() {
        tarefas = value;
      });
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
                      controller: todoController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "Adicione uma tarefa",
                          hintText: "Ex: Ir ao mercado",
                          errorText: errorText),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String text = todoController.text;
                      if (text.isEmpty) {
                        setState(() {
                          errorText = "O título não pode ficar em branco";
                        });
                        return;
                      }
                      setState(() {
                        Todo newTodo =
                            Todo(title: text, dateTime: DateTime.now());
                        tarefas.add(newTodo);
                        errorText = null;
                      });
                      todoController.clear();
                      todoRepository.saveTodoList(tarefas);
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: const EdgeInsets.all(14.0)),
                    child: const Icon(Icons.add, size: 30),
                  ),
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Todo tarefa in tarefas)
                      TodoListItem(todo: tarefa, onDelete: onDelete),
                  ],
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Expanded(
                      child: Text(
                          "Você possui ${tarefas.length} tarefas pendentes")),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: showDeleteTodosConfirmationDialog,
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: const EdgeInsets.all(14.0)),
                    child: const Text("Limpar Tudo"),
                  )
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  void onDelete(Todo tarefa) {
    deletedTodo = tarefa;
    deletedTodoPos = tarefas.indexOf(tarefa);
    setState(() {
      tarefas.remove(tarefa);
    });
    todoRepository.saveTodoList(tarefas);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tarefa ${tarefa.title} excluida com sucesso!',
        ),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              tarefas.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(tarefas);
          },
        ),
      ),
    );
  }

  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text("Limpar Tudo"),
          content: const Text("Você tem certeza que deseja limpar tudo?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAllTodos();
              },
              child: const Text("Confirmar"),
              style: TextButton.styleFrom(primary: Colors.redAccent),
            ),
          ]),
    );
  }

  void deleteAllTodos() {
    setState(() {
      tarefas.clear();
    });
    todoRepository.saveTodoList(tarefas);
  }
}
