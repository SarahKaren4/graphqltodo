import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphqltodo/todo/screen/ShowTodoScreen.dart';
import 'package:graphqltodo/todo/screen/addTodoScreen.dart';
import 'package:graphqltodo/todo/service/deleteTodo.dart';
import 'package:graphqltodo/todo/service/getTodo.dart';
import 'package:graphqltodo/todo/snackbar.dart';
import './graphql_strings.dart' as gql_string;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: HttpLink("https://graphqlzero.almansi.me/api"),
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'GraphQL todo',
        home: MyHomePage(
          title: 'Load more and refetch',
        ),
      ),
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
    return Query(
        options: QueryOptions(
            document: gql(
              gql_string.fetchmore,
            ),
            variables: {
              "options": const {
                "paginate": {"page": 1, "limit": 6}
              }
            }),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const CircularProgressIndicator();
          }

          if (result.hasException) {}
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.amber,
                title: Text(widget.title),
                actions: [
                  IconButton(
                    onPressed: () {
                      refetch!();
                    },
                    icon: const Icon(Icons.refresh),
                  )
                ],
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.amber,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddUpdateTodoScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
              body: Query(
                builder: (result, {fetchMore, refetch}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  if (result.isLoading) {
                    return Center(child: const CircularProgressIndicator());
                  }

                  List? todos = result.data?['todos']['data'];
                  int? nextPage =
                      result.data?['todos']?['links']?['next']?['page'];
                  print("NextPage    : $nextPage");
                  final opts = FetchMoreOptions(
                      variables: {
                        "options": {
                          "paginate": {"page": nextPage, "limit": 6}
                        }
                      },
                      updateQuery: (previousResultData, fetchMoreResultData) {
                        final List<dynamic> repos = [
                          ...previousResultData?['todos']['data']
                              as List<dynamic>,
                          ...fetchMoreResultData?['todos']['data']
                              as List<dynamic>
                        ];

                        fetchMoreResultData?['todos']['data'] = repos;

                        return fetchMoreResultData;
                      });

                  if (todos == null) {
                    return const Text('No todo');
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        print(todos.length);
                        return Column(
                          children: [
                            Container(
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
                                      "# ${todo['id']}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      todo['title'],
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
                                                todo: todo?[index],
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
                                          final Map<String, dynamic>? _items =
                                              await loadData(todo['id']);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddUpdateTodoScreen(
                                                todoId: _items,
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
                                              id: int.parse(todo['id']));
                                          if (res) {
                                            snackBar("Todo supprimé", context);
                                            //  setState(() {});
                                          } else {
                                            snackBar("Erreur de suppression",
                                                context);
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (todo['id'] == (todos.length).toString())
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 50),
                                color: Colors.black,
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                        onPressed: () => fetchMore!(opts),
                                        child: Center(
                                          child: Text('Load more',
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                        ))
                                  ],
                                ),
                              )
                          ],
                        );
                      });
                },
                options: QueryOptions(
                  document: gql(
                    gql_string.fetchmore,
                  ),
                  // ignore: prefer_const_literals_to_create_immutables
                  variables: {
                    "options": const {
                      "paginate": {"page": 1, "limit": 6}
                    }
                  },
                ),
              ));
        });
  }
} 

/*
child: Scaffold(
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
                  builder: (context) => AddUpdateTodoScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          body: FutureBuilder<List>(
              future: TodoFetchMore(),
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
                          final Map pageInfo = todos['title'];
                          final String fetchMoreCursor = pageInfo['endCursor'];
                          FetchMoreOptions opts = FetchMoreOptions(
                            variables: {'cursor': fetchMoreCursor},
                            updateQuery:
                                (previousResultData, fetchMoreResultData) {
                              final List<dynamic> repos = [
                                ...previousResultData?['todos']['data']
                                    as List<dynamic>,
                                ...fetchMoreResultData?['todos']['data']
                                    as List<dynamic>
                              ];
    
                              
                              fetchMoreResultData?['todos']['data'] = repos;
    
                              return fetchMoreResultData;
                            },
                          );
                          return Column(
                            children: [
                              Container(
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
                                        style: const TextStyle(fontSize: 7),
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
                                            final Map<String, dynamic>? _items =
                                                await loadData(
                                                    snapshot.data?[index]['id']);
    
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddUpdateTodoScreen(
                                                  todoId: _items,
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
                                              snackBar("Erreur de suppression",
                                                  context);
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
                              ),
                              if (snapshot.data?[index]['id'] == '6')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.amber,
                                      child: TextButton(
                                          onPressed: (() =>fetchMore(opts)),
                                          child: Text('Load more')),
                                    )
                                  ],
                                )
                            ],
                          );
                        }),
                  );
                }
    
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
    
                return Container();
              })),
  
*/