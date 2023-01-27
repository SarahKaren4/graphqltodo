const String getTodoQuery = """
query(\$id: ID!) {
  todo(id: \$id) {
    id
    title
    completed
  }
}
""";

const createTodoMutation = """
mutation (
  \$input: CreateTodoInput!
) {
  createTodo(input: \$input) {
   id
    title
  }
}

""";

const updateTodoMutation = """

mutation (
 \$id: ID!,
 \$input: UpdateTodoInput!
) {
  updateTodo(id:\$id, input:\$input) {
    title
    completed
  }
}
""";
const deleteTodoMutation = """
mutation (
 \$id: ID!
) {
  deleteTodo(id:\$id)
}

""";

const String getAllTodosQuery = """query (
  \$options: PageQueryOptions
) {
  todos(options: \$options) {
    data {
      id
      title
    }
    meta {
      totalCount
    }
  }
}""";

const String fetchmore = """query (
  \$options: PageQueryOptions
) {
  todos(options: \$options) {
    
  links{
    next{
    page 
    limit
    }
  }
    data {
      id
      title
    }
    meta {
      totalCount
    }
    
  }
}
""";
