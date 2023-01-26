import 'package:flutter/material.dart';
import 'package:graphqltodo/todo/service/getTodo.dart';

class DisplayTodo extends StatefulWidget {
  final todo;
  const DisplayTodo({Key? key, required this.todo}) : super(key: key);
  static const routeName = "/displayTodo";
  @override
  State<DisplayTodo> createState() => _DisplayTodoState();
}

class _DisplayTodoState extends State<DisplayTodo> {
  String? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
          future: getTodo(id: int.tryParse(id ?? '')),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              print("hey");
              print(widget.todo);
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1100000D),
                      blurRadius: 16,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height / 8,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.todo?['id'],
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Id: " + widget.todo?['title'],
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Container();
          }),
    );
  }
}
