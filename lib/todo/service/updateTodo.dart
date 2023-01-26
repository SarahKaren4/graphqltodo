import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_strings.dart' as gql_string;

Future<bool> updateTodo({String? id, String? title, String? completed}) async {
  HttpLink link = HttpLink("https://graphqlzero.almansi.me/api");
  GraphQLClient qlClient = GraphQLClient(
    link: link,
    cache: GraphQLCache(
      store: HiveStore(),
    ),
  );
  QueryResult queryResult = await qlClient.mutate(
    MutationOptions(
        fetchPolicy: FetchPolicy.networkOnly,
        document: gql(
          gql_string.updateTodoMutation,
        ),
        variables: {
          "id": int.tryParse(id ?? ''),
          "input": {"title": title},
          'completed': completed,
        }),
  );
  print('in update');
  print(queryResult.data);

  return queryResult.data?['updateTodo'] == null? false: true; 
}
