import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphqltodo/todo/service/createTodo.dart';
import 'package:graphqltodo/todo/service/updateTodo.dart';
import 'package:graphqltodo/todo/snackbar.dart';

class AddUpdateTodoScreen extends StatefulWidget {
  final todoId;
  const AddUpdateTodoScreen({Key? key, this.todoId}) : super(key: key);
  static const routeName = "addUpdateTodo";
  @override
  State<AddUpdateTodoScreen> createState() => _AddUpdateTodoState();
}

class _AddUpdateTodoState extends State<AddUpdateTodoScreen> {
  final TextEditingController _titleController = TextEditingController();
  late String title;

  @override
  void initState() {
    _titleController.text =
        widget.todoId?['title'] == null ? '' : widget.todoId?['title'];
    title = _titleController.text;
  }

  @override
  Widget build(BuildContext context) {
    String appbartitle = widget.todoId != null ? "Mettre à jour " : "Créer";

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(appbartitle),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: TextField(
                controller: _titleController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  filled: true,
                  hintText: "Entrez votre todo",
                  label: Text(
                    "Todo",
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[a-zA-Z.' ]")),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: ElevatedButton(
                onPressed: () async {
                 
                 
             if (widget.todoId != null) {
                      
                      var res = await updateTodo(
                          id: widget.todoId?['id'],
                          title: title,
                          completed: "false");
                      if (res) {
                        snackBar("Todo mis à jour", context);
                        Navigator.of(context).pop();
                      } else {
                        snackBar("Erreur de mise à jour", context);
                      }
                    } else if (widget.todoId == null) {
                      print('mmm');
                      var res = await createTodo(id: '4', title: title);
                      if (res) {
                        snackBar("Todo créé",context); 
                      } else {
                        snackBar("Erreur", context);
                      }
                      
                    }
                    
                  }
                ,
                child: Text(widget.todoId != null ? "Modifié" : "Créer"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
