import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '/models/crud_todo.dart';
import '/models/todo.dart';
import 'package:provider/provider.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;

  const TodoTile({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crudTodo = Provider.of<CrudTodo>(context, listen: false);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      key: ValueKey(todo.id),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
      ),
      child: Slidable(
        key: ValueKey(todo.id),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                todo.isDone = true;
                crudTodo.updateTaskItemToServer(todo);
              },
              backgroundColor: Colors.lightGreen.shade300,
              foregroundColor: Colors.white,
              icon: Icons.done,
              label: 'Done',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                crudTodo.deleteTaskItemToServer(todo);
              },
              backgroundColor: Colors.red.shade300,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            todo.title,
            style: TextStyle(
                decoration: todo.isDone ? TextDecoration.lineThrough : null),
          ),
          leading: const Icon(Icons.task),
          trailing: todo.isReminder ? const Icon(Icons.notifications_active) : null,
        ),
      ),
    );
  }
}
