import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_strings.dart' as gql_string;

Future<bool> deleteTodo({
  int? id,
}) async {
  HttpLink link = HttpLink("https://graphqlzero.almansi.me/api"); 
  GraphQLClient qlClient = GraphQLClient(
    link: link,
    cache: GraphQLCache(
      store: HiveStore(),
    ),
  );
  QueryResult queryResult = await qlClient.query(
    QueryOptions(
        fetchPolicy: FetchPolicy
            .networkOnly,      document: gql(
          gql_string.deleteTodoMutation,
        ),
        variables: {
          'id': id,
        }),
  );
  print("Supprimé");
  return queryResult.data?['deleteTodo'] ??
      false; }
