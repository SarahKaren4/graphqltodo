import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_strings.dart' as gql_string;

Future<List> TodoFetchMore() async {
  HttpLink link = HttpLink("https://graphqlzero.almansi.me/api");
  GraphQLClient qlClient = GraphQLClient(
    link: link,
    cache: GraphQLCache(
      store: HiveStore(),
    ),
  );
  QueryResult queryResult = await qlClient.query(
    QueryOptions(
      document: gql(
        gql_string.fetchmore,
      ),
      variables: {
  "options": const {
    "paginate": {
      "page": 1,
      "limit": 6
    }  
  } 
}

    ),
  );

  print("All todos ");
  return queryResult.data?['todos']['data'];
}
