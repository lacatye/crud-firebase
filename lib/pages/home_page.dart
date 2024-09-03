import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; // Adicione este pacote ao seu pubspec.yaml

import '../models/todo.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayTextInputDialog,
        backgroundColor: const Color(0xFF6F50FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Arredondar os cantos do botão
        ),
        child: const Icon(
          Icons.add, // Ícone padrão
          color: Colors.white,
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFF6F50FF),
      title: Text(
        "To Do List",
        style: GoogleFonts.poppins( // Fonte moderna
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Column(
      children: [
        _messagesListView(),
      ],
    ));
  }

  Widget _messagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          List todos = snapshot.data?.docs ?? [];
          if (todos.isEmpty) {
            return const Center(
              child: Text("Add a todo!"),
            );
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              Todo todo = todos[index].data();
              String todoId = todos[index].id;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Material(
                  elevation: 5, // Sombra
                  borderRadius: BorderRadius.circular(12), // Arredondar os cantos
                  color: Colors.white, // Fundo claro
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Arredondar os cantos do ListTile
                    ),
                    title: Text(todo.task,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        )),
                    subtitle: Text(
                      DateFormat("dd-MM-yyyy h:mm a").format(
                        todo.updatedOn.toDate(),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        Todo updatedTodo = todo.copyWith(
                            isDone: !todo.isDone, updatedOn: Timestamp.now());
                        _databaseService.updateTodo(todoId, updatedTodo);
                      },
                    ),
                    onLongPress: () {
                      _databaseService.deleteTodo(todoId);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _displayTextInputDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Add a todo',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: "Todo...."),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: const Color(0xFF6F50FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Botão arredondado
                ),
              ),
              child: const Text('Ok'),
              onPressed: () {
                Todo todo = Todo(
                    task: _textEditingController.text,
                    isDone: false,
                    createdOn: Timestamp.now(),
                    updatedOn: Timestamp.now());
                _databaseService.addTodo(todo);
                Navigator.pop(context);
                _textEditingController.clear();
              },
            ),
          ],
        );
      },
    );
  }
}
