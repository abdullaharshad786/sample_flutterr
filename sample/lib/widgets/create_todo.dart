import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/main.dart';
import '/models/crud_todo.dart';
import '/models/todo.dart';
import 'package:provider/provider.dart';

class CreateTodo extends StatefulWidget {
  final DateTime selectedDay;
  const CreateTodo({Key? key, required this.selectedDay}) : super(key: key);

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  final _formKey = GlobalKey<FormState>();
  var showError = false;
  var title = '';
  var remindMe = false;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          height: 350.h,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.h),
          child: Form(
            key: _formKey,
            autovalidateMode: showError
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Create Task',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
                ),
                SizedBox(height: 18.h),
                TextFormField(
                  maxLines: 2,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.task),
                    labelText: 'Title',
                  ),
                  autocorrect: false,
                  onChanged: (value) {
                    title = value;
                    if (showError) {
                      setState(() {
                        showError = false;
                      });
                    }
                  },
                  validator: (value) {
                    if (value != null && value.length <= 4) {
                      return "Title is too short.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                SwitchListTile(
                  value: remindMe,
                  onChanged: (bool newValue) {
                    setState(() {
                      remindMe = newValue;
                    });
                  },
                  title: const Text('Remind me'),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final crudTodo = Provider.of<CrudTodo>(context, listen: false);
                      final todo = Todo(createdAt : widget.selectedDay.toUtc(), title: title, isReminder: remindMe, isDone: false);
                      crudTodo.putTaskItemsToServer(todo);
                      _showNotification(todo);
                      Navigator.pop(context);
                    }else{
                      setState(() {
                        showError = true;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNotification(Todo todo) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('todo-channel', 'Todo Notifications',
        channelDescription: 'Show notification when created',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, 'Your task created.', platformChannelSpecifics,
        payload: '${todo.createdAt}');
  }
}
