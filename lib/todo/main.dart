import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphqltodo/todo/screen/ShowTodoScreen.dart';
import 'package:graphqltodo/todo/screen/addTodoScreen.dart';
import 'package:graphqltodo/todo/service/deleteTodo.dart';
import 'package:graphqltodo/todo/service/getAllTodos.dart';
import 'package:graphqltodo/todo/service/getTodo.dart';
import 'package:graphqltodo/todo/snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphQL todo',
      home: const MyHomePage(title: 'GraphQL todo'),
      routes: {
        AddUpdateTodoScreen.routeName: (_) => const AddUpdateTodoScreen(
              todoId: null,
            ),
        DisplayTodo.routeName: (_) => const DisplayTodo(
              todo: [],
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? _todo;
  final TextEditingController _titleController = TextEditingController();

  loadData(String id) async {
    _todo = await getTodo(id: int.tryParse(id));
    print("letodo");
    print(_todo);
    if (_todo != null && _todo!.isNotEmpty) {
      _titleController.text = _todo?['title'] ?? '';
    }
    print('hola');
    print(_todo?['title']);
    return _todo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddUpdateTodoScreen(),
                                        ),
                                      );
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List>(
            future: getAllTodos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(snapshot.connectionState);
                print(snapshot.data);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        final todos = snapshot.data?[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
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
                          child: Column(
                            children: [
                              Row(children: [
                                Text(
                                  "# ${todos['id']}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  todos['title'],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ]),
                              Row(
                                children: [
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DisplayTodo(
                                            todo: snapshot.data?[index],
                                          ),
                                        ),
                                      );
                                      print("show todo");
                                      //print(snapshot.data?[index]['id']);
                                    },
                                    icon: const Icon(
                                      Icons.launch_outlined,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final Map<String, dynamic>? _items = await loadData(
                                                snapshot.data?[index]['id']);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddUpdateTodoScreen(
                                            todoId: _items ,
                                          ),
                                        ),
                                      );
                                      print("Add or update");
                                      //print(snapshot.data?[index]['id']);
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      var res = await deleteTodo(
                                          id: int.parse(
                                              snapshot.data?[index]['id']));
                                      if (res) {
                                        snackBar("Todo supprimé", context);
                                        //  setState(() {});
                                      } else {
                                        snackBar(
                                            "Erreur de suppression", context);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return Container();
            }));
  }
}
