import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_strings.dart' as gql_string;

Future<Map<String, dynamic>> getTodo({int? id}) async {
  HttpLink link = HttpLink("https://graphqlzero.almansi.me/api"); 
  GraphQLClient qlClient = GraphQLClient(
    link: link,
    cache: GraphQLCache(
      store: HiveStore(),
    ), 
  );
  QueryResult queryResult = await qlClient.query(
    QueryOptions(
        fetchPolicy: FetchPolicy.networkOnly,
        document: gql(
          gql_string.getTodoQuery,
        ),
        variables: const {
          "id": "5",
        }),
  );
  print("Todo got");
  return queryResult.data?['todo'] ??
      {}; 
}
