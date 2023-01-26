import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_strings.dart' as gql_string;

Future<bool> createTodo({String? id, String? title, String? completed}) async {
  HttpLink link = HttpLink("https://graphqlzero.almansi.me/api"); 

  GraphQLClient qlClient = GraphQLClient(
    link: link,
    cache: GraphQLCache(
      store: HiveStore(),
    ),
  );
  QueryResult queryResult = await qlClient.mutate(
    MutationOptions(
        document: gql(
          gql_string.createTodoMutation,
        ),
        variables: {
          "input": {"title": "A Very Captivating Post Title", "completed": true}
        }),
  );
  print("crreate");
  print(queryResult);
  return queryResult.data?['createTodo'] == null? false: true;
  //return queryResult.data?['createTodo'] ?? false;
}
